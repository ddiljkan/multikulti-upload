# Architecture

## System overview

```mermaid
flowchart TB
    subgraph Internet
        Club1[Club 1 browser]
        Club2[Club 2 browser]
        ClubN[Club N browser]
        Admin[Admin browser<br/>= you]
    end

    subgraph Cloudflare[Cloudflare edge]
        CF[DNS + Proxy<br/>WAF + Bot mgmt<br/>Edge SSL]
    end

    subgraph Hetzner["Hetzner Cloud — Falkenstein (fsn1)"]
        FW[Hetzner Firewall<br/>22 / 80 / 443]

        subgraph VPS["CX22 VPS — Ubuntu 24.04"]
            Caddy[Caddy<br/>:80 :443<br/>Let's Encrypt cert]
            Pingvin[Pingvin Share X<br/>:3000 internal]
            SQLite[(SQLite DB)]
            Files[(./data/uploads<br/>NVMe)]
        end

        Snap[(Daily snapshots<br/>7-day retention)]
    end

    Club1 & Club2 & ClubN & Admin -->|HTTPS| CF
    CF -->|HTTPS Full strict| FW
    FW --> Caddy
    Caddy -->|HTTP localhost| Pingvin
    Pingvin --> SQLite
    Pingvin --> Files
    VPS -.->|Hetzner backup service| Snap
```

## Network flow on a single upload

```mermaid
sequenceDiagram
    autonumber
    participant Club as Club browser
    participant CF as Cloudflare edge
    participant Caddy
    participant Pingvin
    participant Disk

    Club->>CF: GET https://multikulti-2026.kud-mladost.org/r/abc
    CF->>Caddy: TLS-terminated request<br/>(Cloudflare proxy → origin)
    Caddy->>Pingvin: HTTP proxy localhost:3000
    Pingvin-->>Caddy: HTML upload page
    Caddy-->>CF: response (compressed)
    CF-->>Club: cached/forwarded HTML

    Club->>CF: POST file (multipart, ≤50 MB)
    CF->>CF: WAF + bot checks
    CF->>Caddy: streamed body
    Caddy->>Caddy: enforce max_size 50 MB
    Caddy->>Pingvin: forward body
    Pingvin->>Disk: write to ./data/uploads/<share-id>/
    Pingvin-->>Club: 200 OK + share URL
```

## Lifecycle for one event

```mermaid
stateDiagram-v2
    [*] --> Provisioned: terraform apply
    Provisioned --> Configured: admin login<br/>+ SMTP setup
    Configured --> Active: create 20 reverse shares<br/>+ email clubs
    Active --> Collecting: clubs upload
    Collecting --> Active: more uploads
    Collecting --> EventDay: all uploads in<br/>(or close enough)
    EventDay --> Archived: download all files<br/>locally
    Archived --> Snapshotted: hcloud create-image
    Snapshotted --> Destroyed: terraform destroy
    Destroyed --> [*]: pays ~€0.57/mo for snapshot

    Destroyed --> Provisioned: next event<br/>(terraform apply)
```

## Data layout on the VPS

```
/srv/pingvin/
├── docker-compose.yml      # Caddy + Pingvin services
├── Caddyfile               # reverse-proxy config
└── data/                   # ← persistent volume (the only thing that matters for backup)
    ├── pingvin.sqlite      # accounts, shares, reverse-share configs
    ├── uploads/
    │   ├── <share-id-1>/   # one folder per share (created on each upload)
    │   │   ├── 01_intro.mp3
    │   │   └── 02_main.mp3
    │   └── <share-id-2>/
    └── images/             # logos, custom assets

/var/log/caddy/access.log   # access log, rotated at 10 MiB × 5 files
```

## Security boundaries

```mermaid
flowchart LR
    Internet([Internet])
    CF[Cloudflare<br/>L7 WAF<br/>DDoS L3/4<br/>Bot mgmt]
    HW[Hetzner FW<br/>L3/4 stateless<br/>22/80/443 only]
    UFW[ufw on VPS<br/>same rules<br/>defense-in-depth]
    F2B[fail2ban<br/>SSH brute-force]
    Caddy2[Caddy<br/>TLS termination<br/>HSTS + security headers]
    Pingvin2[Pingvin<br/>app-layer auth<br/>per-share isolation]

    Internet --> CF --> HW --> UFW --> Caddy2 --> Pingvin2
    UFW --> F2B
```

Layered defense: every step trims attack surface. Even if Cloudflare's
proxy is bypassed (someone resolves the origin IP), the Hetzner firewall
+ ufw still limit traffic to web ports, fail2ban catches SSH brute force,
and Pingvin's auth model means an attacker still can't see other clubs'
files without their unique URL + PIN.
