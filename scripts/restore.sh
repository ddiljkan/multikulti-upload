#!/usr/bin/env bash
#
# restore.sh — restore a previously-created tarball into /srv/pingvin/data.
# This OVERWRITES existing data. Stop the stack first.
#
# Usage (run on your laptop):
#   bash scripts/restore.sh <vps-ip> <backup-tarball>

set -euo pipefail

VPS_IP="${1:?usage: restore.sh <vps-ip> <backup-tarball>}"
TARBALL="${2:?usage: restore.sh <vps-ip> <backup-tarball>}"
SSH_USER="${SSH_USER:-admin}"

[[ -f "$TARBALL" ]] || { echo "tarball not found: $TARBALL" >&2; exit 1; }

echo "[restore] Uploading tarball…"
scp "$TARBALL" "${SSH_USER}@${VPS_IP}:/tmp/pingvin-restore.tar.gz"

echo "[restore] Stopping stack…"
ssh "${SSH_USER}@${VPS_IP}" \
  "cd /srv/pingvin && docker compose down"

echo "[restore] Restoring data (overwriting /srv/pingvin/data)…"
ssh "${SSH_USER}@${VPS_IP}" \
  "sudo rm -rf /srv/pingvin/data && sudo tar -xzf /tmp/pingvin-restore.tar.gz -C /srv/pingvin && sudo chown -R ${SSH_USER}:${SSH_USER} /srv/pingvin/data"

echo "[restore] Restarting stack…"
ssh "${SSH_USER}@${VPS_IP}" \
  "cd /srv/pingvin && docker compose up -d"

echo "[restore] Cleaning up remote tarball…"
ssh "${SSH_USER}@${VPS_IP}" "rm -f /tmp/pingvin-restore.tar.gz"

echo "[restore] Done."
