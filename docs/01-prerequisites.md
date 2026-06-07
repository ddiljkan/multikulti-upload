# 01 — Prerequisites

Read this once. Everything you need before running `terraform apply`.

## Accounts you need

| Account | Purpose | Cost |
|---|---|---|
| [Hetzner Cloud](https://console.hetzner.cloud) | Hosts the VPS | ~€5/month |
| [Cloudflare](https://dash.cloudflare.com) | DNS for `kud-mladost.org` (already set up) | €0 |

The Cloudflare account already manages `kud-mladost.org` — we just create a
subdomain record under it.

## Local tools

Install on your laptop:

```bash
# macOS via Homebrew
brew install terraform hcloud cloudflare/cloudflare/cf-terraforming

# Linux: see https://developer.hashicorp.com/terraform/install
# and https://github.com/hetznercloud/cli/releases
```

You also need a working SSH keypair. If `~/.ssh/id_ed25519.pub` doesn't
exist, generate one:

```bash
ssh-keygen -t ed25519 -C "dejan@multikulti-upload"
```

## API tokens to create

### 1. Hetzner Cloud API token

1. Go to <https://console.hetzner.cloud> → select (or create) a project
   called `multikulti-upload`.
2. Left sidebar: **Security → API Tokens**.
3. **Generate API token**:
   - Description: `terraform`
   - Permissions: **Read & Write**
4. **Copy the token immediately** — Hetzner shows it only once. Paste it
   into a password manager.

### 2. Cloudflare API token

1. Go to <https://dash.cloudflare.com/profile/api-tokens>.
2. **Create Token** → **Get started** (custom token).
3. Configure:
   - Name: `terraform-multikulti-upload`
   - Permissions:
     - `Zone` → `DNS` → `Edit`
   - Zone Resources:
     - `Include` → `Specific zone` → `kud-mladost.org`
   - TTL: leave default (no expiry) or set 1 year if you prefer rotation.
4. **Continue to summary → Create Token** → copy token to password manager.

### 3. Cloudflare Zone ID

1. In the Cloudflare dashboard, open `kud-mladost.org`.
2. The **Zone ID** is on the right sidebar of the Overview tab.
3. Copy it.

## What you'll have at the end

Three secrets, ready to paste into `terraform/terraform.tfvars`:

- `hcloud_token`
- `cloudflare_api_token`
- `cloudflare_zone_id`

Plus your local SSH public key at `~/.ssh/id_ed25519.pub`.

Next: [02 — Initial Setup](02-initial-setup.md).
