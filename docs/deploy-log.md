# Deploy Log

A running record of what's actually deployed in production. Update this on
every `terraform apply` that changes infrastructure, and on every `docker
compose pull && up -d` that changes container versions.

> Why bother? In 18 months you'll open this repo, see `pingvin:latest` in
> the compose file, and have no idea what version is actually running on
> the VPS or what changed since last event. This log answers that.

---

## How to update

1. After every deploy, add a new section at the **top** of the table below.
2. Fill in date, the change in plain language, and (if relevant) the
   image digests so you can roll back.
3. To get the running image digests on the VPS:
   ```bash
   ssh admin@<vps-ip>
   docker inspect pingvin caddy --format '{{.RepoDigests}}'
   ```
4. Commit the change to `main` with a message like
   `chore: deploy log entry for 2026-08-15`.

---

## Log

| Date | Author | What changed | Pingvin digest | Caddy digest | Notes |
|---|---|---|---|---|---|
| _YYYY-MM-DD_ | _name_ | _e.g. "Initial deploy for Multikulti 2026"_ | `sha256:...` | `sha256:...` | _e.g. "Took 4 min, no issues"_ |

---

## Quick rollback recipe

If a deploy goes wrong, the previous row tells you exactly which image digests were
running before. To roll back:

```bash
ssh admin@<vps-ip>
cd /srv/pingvin

# Edit docker-compose.yml — replace ":latest" with the previous digest:
#   image: stonith404/pingvin-share@sha256:<previous-digest>

docker compose up -d
```

The Pingvin SQLite database is forward-compatible across patch versions
but **may break on major version rollbacks**. If you're rolling back across
a major version, also restore `/srv/pingvin/data/` from the most recent
Hetzner snapshot (see [04-maintenance.md](04-maintenance.md)).
