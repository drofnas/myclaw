#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if [[ -z "${MYCLAW_TS_AUTHKEY:-}" ]]; then
  echo "Enter a Tailscale auth key to enroll these containers." >&2
  echo "Leave blank to reuse existing persisted Tailscale state (already enrolled)." >&2
  read -r -s -p "Tailscale auth key (tskey-...): " MYCLAW_TS_AUTHKEY
  echo >&2
  export MYCLAW_TS_AUTHKEY
fi

export MYCLAW_GITEA_TS_HOSTNAME="${MYCLAW_GITEA_TS_HOSTNAME:-myclaw-gitea}"
export MYCLAW_OLLAMA_TS_HOSTNAME="${MYCLAW_OLLAMA_TS_HOSTNAME:-myclaw-ollama}"

docker compose \
  -f "$ROOT_DIR/ollama/docker-compose.yml" \
  -f "$ROOT_DIR/ollama/docker-compose.tailscale.yml" \
  up -d

docker compose \
  -f "$ROOT_DIR/gitea/docker-compose.yml" \
  -f "$ROOT_DIR/gitea/docker-compose.tailscale.yml" \
  up -d

cat <<EOF
Up.

Gitea:
  UI:  (run) docker exec myclaw-gitea-tailscale tailscale serve status
  SSH: ssh -p 2222 git@${MYCLAW_GITEA_TS_HOSTNAME}

Ollama:
  API: http://${MYCLAW_OLLAMA_TS_HOSTNAME}:11434
  (run) docker exec myclaw-ollama-tailscale tailscale serve status
EOF
