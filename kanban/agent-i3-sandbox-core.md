---
uuid: "agent-i3-sandbox-core"
title: "Build core agent i3 sandbox container target"
status: "completed"
priority: "P0"
labels: ["infrastructure", "docker", "i3", "emacs"]
created_at: "2026-06-13T02:40:00Z"
source: ".spacemacs.d/docs/notes/2026.06.12.22.40.53.md"
points: 5
category: "infrastructure"
---

# Build core agent i3 sandbox container target

Create the fast `core` target for an isolated agent i3 sandbox:

- `Dockerfile` with Debian bookworm-slim base, `xvfb`, `i3-wm`, `emacs`, `jq`, `xdotool`, `rofi`, `xterm`, etc.
- `docker-compose.yml` exposing `DISPLAY=:99`, `XDG_RUNTIME_DIR`, and `EMACS_DAEMON_NAME`.
- `i3.config` with minimal keybindings, `urxvtc`, `rofi`, reload/restart/exit bindings.
- `init.el` minimal Emacs daemon init with `agent/open-workspace`.
- `scripts/agent-entrypoint` booting Xvfb, named Emacs daemon, then i3.
- `scripts/agent-emacsclient`, `scripts/snapshot-i3`, `scripts/smoke-i3`, `scripts/agentctl`.

## Acceptance

- `docker compose up -d --build` succeeds.
- `./scripts/agentctl smoke core` passes.
- `./scripts/agentctl snapshot core` writes tree/workspaces JSON.
- `./scripts/agentctl emacs core /workspace/README.md` opens via `emacsclient`.

---

Extracted from note on 2026-06-12.
