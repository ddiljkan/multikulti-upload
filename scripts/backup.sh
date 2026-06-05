#!/usr/bin/env bash
#
# backup.sh — optional manual backup of /srv/pingvin/data to a local tarball.
# Hetzner automated snapshots are the primary backup; this is an extra "I want
# the files on my laptop right now" tool.
#
# Usage (run on your laptop):
#   bash scripts/backup.sh <vps-ip> [output-dir]

set -euo pipefail

VPS_IP="${1:?usage: backup.sh <vps-ip> [output-dir]}"
OUT_DIR="${2:-./backups}"
SSH_USER="${SSH_USER:-admin}"

mkdir -p "$OUT_DIR"
STAMP="$(date +%Y%m%d-%H%M%S)"
OUT_FILE="${OUT_DIR}/pingvin-data-${STAMP}.tar.gz"

echo "[backup] Creating tarball on the VPS…"
ssh "${SSH_USER}@${VPS_IP}" \
  "sudo tar -czf /tmp/pingvin-data.tar.gz -C /srv/pingvin data"

echo "[backup] Downloading…"
scp "${SSH_USER}@${VPS_IP}:/tmp/pingvin-data.tar.gz" "$OUT_FILE"

echo "[backup] Cleaning up remote tarball…"
ssh "${SSH_USER}@${VPS_IP}" "sudo rm -f /tmp/pingvin-data.tar.gz"

echo "[backup] Done: $OUT_FILE"
du -h "$OUT_FILE"
