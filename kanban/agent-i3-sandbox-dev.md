---
uuid: "agent-i3-sandbox-dev"
title: "Add dev target mounting local Spacemacs layers"
status: "review"
priority: "P2"
labels: ["infrastructure", "docker", "spacemacs", "dev-loop"]
created_at: "2026-06-13T02:33:00Z"
source: ".spacemacs.d/docs/notes/agent-i3-sandbox/03-control-script-and-first-fixes.md"
points: 3
category: "infrastructure"
---

# Add dev target mounting local Spacemacs layers

Create a `dev` target for hacking on Spacemacs layers without rebuilding the image:

- `docker-compose.yml` service `dev` bind-mounts local Spacemacs checkout or private layers.
- Uses named daemon (e.g., `agent-dev`) to avoid collision with core/spacemacs.
- `agentctl up dev`, `agentctl smoke dev`, `agentctl emacs dev <path>`.
- Optional: mount host package caches to speed first boot.

## Acceptance

- Editing a local layer file is reflected inside the container without rebuild.
- `agentctl smoke dev` passes after a layer change.
- Named daemon is isolated from `core` and `spacemacs` targets.

---

Extracted from note on 2026-06-13.
