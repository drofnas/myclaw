#!/usr/bin/env bash
set -euo pipefail

# Run from anywhere; resolves paths relative to this file.
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

cd "$ROOT_DIR"

echo "Pulling latest Ollama + Tailscale images..."
docker compose -f docker-compose.yml -f docker-compose.tailscale.yml pull

echo "Recreating Ollama stack (Tailscale override included)..."
docker compose -f docker-compose.yml -f docker-compose.tailscale.yml up -d --force-recreate

cat <<EOF
Done.

Notes:
- If this host is already enrolled in Tailscale, you typically do NOT need to set MYCLAW_TS_AUTHKEY again.
- If this is a first-time enrollment, use ../setup.sh (or export MYCLAW_TS_AUTHKEY and rerun).
EOF
