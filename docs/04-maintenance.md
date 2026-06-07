# 04 — Maintenance

Routine operations between events.

## Updating the stack

Pingvin and Caddy both release updates. Run this every 1–3 months,
or before each event:

```bash
ssh admin@<vps-ip>
cd /srv/pingvin
docker compose pull
docker compose up -d
docker image prune -f
```

Or use the convenience script:

```bash
scp scripts/update.sh admin@<vps-ip>:~
ssh admin@<vps-ip> 'bash update.sh'
```

Updates are usually zero-downtime (a few seconds during container swap).
If Pingvin has a breaking migration, check the release notes at
<https://github.com/stonith404/pingvin-share/releases> first.

## OS updates

`unattended-upgrades` is enabled by cloud-init — security patches install
automatically. Kernel updates may require a reboot:

```bash
ssh admin@<vps-ip>
sudo apt list --upgradable
sudo apt upgrade -y
[ -f /var/run/reboot-required ] && sudo reboot
```

After reboot, Docker auto-restarts the stack (the containers have
`restart: unless-stopped`).

## Backups

### Hetzner automatic backups

Already enabled via `enable_hetzner_backups = true`. Hetzner takes a
daily snapshot, keeps the last 7. Restore via the Hetzner console:

1. <https://console.hetzner.cloud> → server `multikulti-upload-01` → **Backups**.
2. Click any snapshot → **Restore**.

This restores the entire VM (OS + Pingvin data) to that point in time.

### Manual snapshot before risky changes

Before a major update, take an ad-hoc snapshot:

```bash
# Install Hetzner CLI locally first: brew install hcloud
hcloud server create-image multikulti-upload-01 \
  --type snapshot \
  --description "pre-update-$(date +%F)"
```

Snapshots cost €0.0143/GB-month — a 40 GB snapshot is ~€0.57/month.

### Restoring an accidentally-deleted reverse share

If you (or a colleague) deletes a reverse share with files in it, restore
the VPS from the most recent Hetzner backup, then `scp` just the
relevant data folder back. The data lives at:

```
/srv/pingvin/data/uploads/
```

## Monitoring

For a hobby project this scale, no monitoring is needed. If you want a
free uptime ping:

- <https://uptimerobot.com> free tier: 5-minute HTTP checks, alerts on
  downtime. Point it at the HTTPS URL.

## Log files

```bash
# Caddy access log (HTTP requests, useful for debugging)
ssh admin@<vps-ip> sudo tail -f /var/log/caddy/access.log

# Pingvin app log
ssh admin@<vps-ip> docker compose -f /srv/pingvin/docker-compose.yml logs -f pingvin

# Cloud-init log (only meaningful on first boot)
ssh admin@<vps-ip> sudo tail -n 200 /var/log/cloud-init-output.log

# fail2ban — see banned IPs
ssh admin@<vps-ip> sudo fail2ban-client status sshd
```

## Cost watch

Once a month, glance at the Hetzner console → **Billing**. Expected:

- Server `cx22`: €4.49
- Backups (+20 %): €0.90
- IPv4 address: included
- **Total: ~€5.40/month**

If anything is dramatically higher, something is wrong (e.g. someone is
hammering uploads and consuming bandwidth — though 20 TB of monthly
traffic is included and 20 clubs × 200 MB = 4 GB is rounding error).

Next: [05 — Teardown and Restore](05-teardown-and-restore.md).
