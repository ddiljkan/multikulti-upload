# 06 — Troubleshooting

Common issues and the 30-second fix for each.

## Cloudflare error 525 / 526 on first visit

**Symptom:** Right after `terraform apply`, opening the URL shows a
Cloudflare error.

**Cause:** Caddy hasn't yet obtained the Let's Encrypt cert.

**Fix:** Wait 60–120 seconds and reload. Verify Caddy logs:

```bash
ssh admin@<vps-ip>
docker compose -f /srv/pingvin/docker-compose.yml logs caddy | grep -i "certificate"
# Look for "certificate obtained successfully"
```

If after 5 minutes there's still no cert, check that Cloudflare's
proxy mode is **on** and SSL mode is **Full (strict)**. With proxy on,
Caddy uses the HTTP-01 challenge over port 80 — make sure the Hetzner
firewall has port 80 open (it does by default in our Terraform).

## Upload fails with 413 / "file too large"

**Cause:** Either Caddy's `max_size` or Cloudflare's body limit.

**Fix:**
- Caddy: increase `max_upload_size_mb` in `terraform.tfvars`, `terraform
  apply`, and update the Caddyfile in cloud-init (or directly edit
  `/srv/pingvin/Caddyfile` on the VPS and `docker compose restart caddy`).
- Cloudflare free plan: hard cap of **100 MB per request**. To exceed,
  set that DNS record to **DNS-only** (grey cloud) so requests bypass
  the proxy. You lose the WAF benefits for that hostname.

## I can't SSH in

**Possible causes & fixes:**

1. **Source IP not allowed.** If you set `ssh_allowed_cidrs` to specific
   IPs, your current IP may not be in the list. Use the Hetzner console
   web terminal (Hetzner Cloud → server → **Console**) to get in, fix
   `sshd_config` or the Hetzner firewall.

2. **fail2ban banned you.** From the web console:
   ```bash
   sudo fail2ban-client unban <your-ip>
   ```

3. **Wrong SSH key.** Confirm the key in `~/.ssh/id_ed25519.pub` matches
   what was uploaded:
   ```bash
   hcloud ssh-key list
   ```

## Pingvin admin panel asks me to create an account, but I already have one

**Cause:** You're hitting a fresh VPS — likely after `terraform destroy
&& terraform apply` or a restore from the OS image (not a snapshot).

**Fix:** That's expected — there's no admin account because there's no
data. Create a new one. If you wanted to restore the old admin, use the
snapshot restore path in [05](05-teardown-and-restore.md).

## Pingvin says "TRUST_PROXY error" or shows Cloudflare IPs as the client IP

**Cause:** `TRUST_PROXY=true` is required when Caddy is in front of
Pingvin. It's set in cloud-init, but if you edited the compose file by
hand, you may have removed it.

**Fix:** Verify `/srv/pingvin/docker-compose.yml` contains
`TRUST_PROXY=true` under the `pingvin` service environment. Restart:

```bash
docker compose -f /srv/pingvin/docker-compose.yml up -d
```

## Disk full

Unlikely at this scale, but possible if many old shares accumulate.

```bash
df -h /srv/pingvin
du -sh /srv/pingvin/data/*
```

Delete old shares from the Pingvin admin UI, or:

```bash
docker compose -f /srv/pingvin/docker-compose.yml down
sudo rm -rf /srv/pingvin/data/uploads/<old-share-id>
docker compose -f /srv/pingvin/docker-compose.yml up -d
```

## Terraform state is out of sync

If you manually changed something in the Hetzner console (e.g. resized
the server):

```bash
terraform refresh
terraform plan   # see what drifted
```

If a resource was deleted outside Terraform, you can:

```bash
terraform state rm <address>   # forget it
terraform apply                # recreate
```

## I lost terraform.tfstate

This is why we said "fine for a solo project but if you lose your
laptop you have to re-import."

**Recovery:** import each resource by ID:

```bash
terraform import hcloud_server.app <server-id>
terraform import hcloud_firewall.web <fw-id>
terraform import cloudflare_record.app_v4 <zone-id>/<record-id>
# etc
```

Find IDs in the respective dashboards. Then `terraform plan` — it should
show no changes if the imports went well.

For the next iteration of this project, consider remote state in S3 or
Hetzner Object Storage.

## I forgot the admin password

In Pingvin's data directory there's a SQLite DB. You can reset the
admin password:

```bash
ssh admin@<vps-ip>
docker compose -f /srv/pingvin/docker-compose.yml exec pingvin sh
# inside the container, follow Pingvin docs for password reset
# https://stonith404.github.io/pingvin-share/
```

Or, faster: restore from yesterday's Hetzner backup if the password
was working then.
