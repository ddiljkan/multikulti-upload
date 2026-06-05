# 02 — Initial Setup

From zero to live URL in about 5 minutes (3 of which are coffee while
cloud-init runs).

## Step 1 — Clone and configure

```bash
git clone <your-repo-url> gig-upload-platform
cd gig-upload-platform/terraform

cp terraform.tfvars.example terraform.tfvars
$EDITOR terraform.tfvars
```

Fill in the three tokens you collected in [01-prerequisites.md](01-prerequisites.md).
Double-check the `hostname` — it must be a subdomain under the
`cloudflare_zone_id` zone.

## Step 2 — Initialise Terraform

```bash
terraform init
```

This downloads the Hetzner and Cloudflare providers. State is stored
locally in `terraform.tfstate` (gitignored). If you ever switch laptops,
copy this file or rebuild with `terraform import`.

## Step 3 — Plan

```bash
terraform plan -out tfplan
```

Expected resources (~7):

- `hcloud_ssh_key.admin`
- `hcloud_firewall.web`
- `hcloud_server.app`
- `cloudflare_record.app_v4`
- `cloudflare_record.app_v6`

Read the plan, make sure the hostname and IPs look right.

## Step 4 — Apply

```bash
terraform apply tfplan
```

Takes ~30 seconds. Terraform creates the firewall, uploads your SSH key,
provisions the VPS, and sets the Cloudflare DNS records.

When done, Terraform prints:

```
Outputs:
  ipv4_address = "..."
  ipv6_address = "..."
  ssh_command  = "ssh admin@..."
  url          = "https://multikulti-2026.kud-mladost.org"
```

## Step 5 — Wait for cloud-init

The VPS now boots and runs the cloud-init script. This installs Docker,
Caddy, Pingvin, and pulls the container images. **Allow 2–3 minutes.**

You can watch progress:

```bash
ssh admin@<ipv4>
tail -f /var/log/cloud-init-output.log
# Wait for: "Pingvin Share is bootstrapping..."
```

Then check the containers:

```bash
sudo docker compose -f /srv/pingvin/docker-compose.yml ps
# Should show caddy and pingvin both "running"
```

## Step 6 — First visit & admin account

Open the URL from the Terraform output:
<https://multikulti-2026.kud-mladost.org>

The very first visit prompts you to **create the admin account**. Use
your `admin_email`. Pick a strong password — store it in your password
manager.

> If you see a Cloudflare error 525 or 526, Caddy hasn't finished
> issuing the Let's Encrypt cert yet. Wait another 60 seconds and reload.

## Step 7 — Configure Pingvin

In the admin panel (top right → Configuration):

1. **General**
   - App name: `Multikulti 2026 — Audio Uploads`
   - App URL: `https://multikulti-2026.kud-mladost.org`
   - Show home page: off (optional — hides marketing splash)
2. **Share**
   - Allow registration: **off**
   - Allow unauthenticated shares: **off**
   - Reverse shares enabled: **on** (default)
   - Default max share size: `200 MB`
   - Default expiration: `14 days`
3. **SMTP** (optional but recommended)
   - Sign up for [Brevo](https://brevo.com) free tier (300 emails/day).
   - Brevo gives you SMTP host, port, login, key. Paste them.
   - Enables email notifications when a club uploads.

## Step 8 — Cloudflare hardening (one-time)

In the Cloudflare dashboard, zone `kud-mladost.org`:

1. **SSL/TLS → Overview**: set to **Full (strict)**. This makes Cloudflare
   verify Caddy's Let's Encrypt cert.
2. **SSL/TLS → Edge Certificates**:
   - Always Use HTTPS: **on**
   - Minimum TLS Version: **TLS 1.2**
   - Automatic HTTPS Rewrites: **on**
3. **Security → Settings**:
   - Security Level: **Medium**
4. **Security → Bots**: Bot Fight Mode: **on**
5. **Rules → Rate Limiting Rules** (optional): create a rule to challenge
   any IP making >30 requests/minute to `/api/*`.

These steps apply at the zone level so they protect the upload subdomain
automatically.

## Step 9 — Verify end-to-end

From an incognito window:

1. Open `https://multikulti-2026.kud-mladost.org`.
2. Confirm padlock is green and the cert issuer is `Google Trust Services`
   or `Cloudflare Inc` (Cloudflare's edge cert).
3. Log in as admin.
4. Top-right → **New Reverse Share**:
   - Description: "Test club"
   - Max share size: 50 MB
   - Expiration: 1 day
   - Password: `test1234`
   - Click **Create**, copy the link.
5. Open that link in another incognito tab. Enter the password. Upload a
   small MP3. Confirm it appears in your admin panel.
6. Delete the test reverse share when done.

You're live.

Next: [03 — Event Operations](03-event-operations.md) to set up the 20
real clubs for an event.
