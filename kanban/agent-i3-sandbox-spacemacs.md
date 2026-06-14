---
uuid: "agent-i3-sandbox-spacemacs"
title: "Build Spacemacs target for agent i3 sandbox"
status: "completed"
priority: "P1"
labels: ["infrastructure", "docker", "spacemacs", "layer"]
created_at: "2026-06-13T02:13:00Z"
source: ".spacemacs.d/docs/notes/2026.06.13.02.13.23.md"
points: 5
category: "infrastructure"
---

# Build Spacemacs target for agent i3 sandbox

Create a higher-fidelity `spacemacs` target that layers Spacemacs onto the core image:

- `Dockerfile.spacemacs` inheriting from `core` image.
- Clone Spacemacs into `/home/agent/.emacs.d`.
- Add `.spacemacs.agent` selecting `agent-sandbox` private layer.
- Add `private/agent-sandbox/` skeleton with `layers.el`, `packages.el`, `funcs.el`, `config.el`, `keybindings.el`.
- Use a named daemon (e.g., `agent-spacemacs`) and explicit `emacsclient -s` connections.
- Update `agentctl` to support `up spacemacs`, `smoke spacemacs`, `emacs spacemacs <path>`.

## Acceptance

- `docker compose build spacemacs` succeeds.
- `./scripts/agentctl up spacemacs` starts the container.
- `./scripts/agentctl smoke spacemacs` passes.
- The private layer loads without errors and `agent/open-workspace` is available.

---

Extracted from note on 2026-06-13.
