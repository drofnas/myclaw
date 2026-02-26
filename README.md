# MyClaw (Gitea + Ollama) on Tailscale

This setup runs **Gitea** and **Ollama** with a **Tailscale sidecar** per service (rootless-friendly), with **no Docker host port publishing**.

## Prereqs
- Docker (rootless is fine), with `docker compose`
- A Tailscale **auth key** (recommended: reusable + preauthorized)
- For Gitea HTTPS: tailnet HTTPS certificates enabled (required by Tailscale Serve)

## Run

```bash
cd /path/to/myclaw
chmod +x ./setup.sh
./setup.sh
```

Optional hostnames:

```bash
export MYCLAW_GITEA_TS_HOSTNAME="myclaw-gitea"
export MYCLAW_OLLAMA_TS_HOSTNAME="myclaw-ollama"
```

## Discover URLs

Tailscale Serve prints the full `...ts.net` URL from inside the sidecars:

```bash
docker exec myclaw-gitea-tailscale tailscale serve status
docker exec myclaw-ollama-tailscale tailscale serve status
```

## Verify from another tailnet device (or NanoBot)

```bash
curl http://myclaw-ollama:11434/api/version
ssh -p 2222 git@myclaw-gitea
```

Gitea UI should be reachable at the `https://...ts.net/` URL shown by `tailscale serve status`.

