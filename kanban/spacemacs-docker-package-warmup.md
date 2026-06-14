---
uuid: "spacemacs-docker-package-warmup"
title: "Warm Spacemacs package installation in Docker build"
status: "completed"
priority: "P2"
labels: ["docker", "spacemacs", "performance"]
created_at: "2026-06-13T02:33:00Z"
source: ".spacemacs.d/docs/notes/2026.06.13.02.33.49.md"
points: 3
category: "infrastructure"
---

# Warm Spacemacs package installation in Docker build

Reduce Spacemacs target startup time by baking package installation into the image:

- In `Dockerfile.spacemacs`, after cloning Spacemacs and copying dotfile/layer, run a headless Emacs startup that installs declared packages.
- Capture package archives in a Docker layer so they do not re-download on every container start.
- Keep layer cache-friendly: copy stable files first, volatile files last.

## Acceptance

- `docker compose build spacemacs` completes.
- First `agentctl up spacemacs` does not spend minutes installing packages.
- Image size remains reasonable.

---

Extracted from note on 2026-06-13.
