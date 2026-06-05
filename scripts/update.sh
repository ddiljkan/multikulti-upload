#!/usr/bin/env bash
#
# update.sh — pull latest Pingvin + Caddy images and restart the stack.
# Run on the VPS, or scp + ssh from your laptop.
#
# Usage:
#   ssh admin@<vps-ip> 'bash -s' < scripts/update.sh

set -euo pipefail

STACK_DIR="/srv/pingvin"

echo "[update] Pulling latest images…"
cd "$STACK_DIR"
docker compose pull

echo "[update] Restarting stack…"
docker compose up -d

echo "[update] Pruning unused images…"
docker image prune -f

echo "[update] Done. Current state:"
docker compose ps
