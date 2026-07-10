---
uuid: "kanban-implementation-2026-06-13"
title: "Implement Spacemacs/i3 DevOps Kanban"
status: "review"
priority: "P0"
labels: ["process", "kanban", "spacemacs", "i3", "docker"]
created_at: "2026-06-13T00:00:00Z"
source: ".spacemacs.d/spec/kanban-implementation-2026-06-13.md"
points: 13
category: "process"
---

# Spec: Implement Spacemacs/i3 DevOps Kanban

## Scope

Implement all cards in `/home/err/.spacemacs.d/kanban/`:

1. `agent-i3-sandbox-core`
2. `agent-i3-sandbox-spacemacs`
3. `agent-i3-sandbox-dev`
4. `spacemacs-agent-sandbox-layer`
5. `spacemacs-docker-package-warmup`
6. `i3-config-test-harness`
7. `helm-popup-frame-i3`
8. `rofi-emacsclient-bridge`
9. `consult-vertico-popup-launcher`
10. `named-emacs-daemons`

## Existing state

- `docker/` already has `Dockerfile`, `Dockerfile.spacemacs`, `Dockerfile.dev`, `docker-compose.yml`, `i3.config`, `init.el`, `.spacemacs.agent`, and `scripts/`.
- `layers/agent-sandbox/` exists but is missing `layers.el` and several `funcs.el` helpers.
- `config/helm-popup.el` + `~/.config/i3/conf.d/helm-spotlight.conf` already implement Helm popup frames.
- Host i3 config already uses modular `conf.d/*.conf`.
- Named daemon env vars are already wired through Docker/compose/scripts.

## Gaps to close

1. **Layer**: add `layers/agent-sandbox/layers.el`; complete `funcs.el` with `agent/snapshot-i3`, `agent/send-path-to-opencode`, `agent/new-vterm-in-project`, `agent/find-workspace`; add daemon-name var to `config.el`.
2. **Docker**: make `Dockerfile.spacemacs` inherit from `core` image; ensure `.spacemacs.agent` registers the layer robustly; add package-warmup step.
3. **Named daemons**: document socket behavior in `docker/SKILL.md`.
4. **Host harness**: create `~/bin/i3-test-xephyr`, `~/bin/i3-snapshot`, `~/bin/i3-dev-reload`, and a sample tree assertion test.
5. **Rofi bridge**: create `~/.local/bin/wm-go`, Emacs helpers in `config/rofi-bridge.el`, and an i3 `go` mode binding.
6. **Consult launcher**: add `vertico`/`consult` packages, create `config/consult-launcher.el`, and add i3 float rule.

## Verification results

- `make test` in `.spacemacs.d`: 19/19 passed.
- Shell script syntax (`bash -n`): all OK.
- `docker compose build core`: OK.
- `docker compose build spacemacs`: OK (using `develop` ref after `v0.9.1` failed to bootstrap `use-package`).
- `docker compose build dev`: OK.
- `./scripts/agentctl smoke core|spacemacs|dev`: OK.
- `./scripts/agentctl snapshot core|spacemacs`: writes tree/workspaces JSON.
- `agent/open-workspace` available in spacemacs/dev daemon: confirmed.
- Host i3 config validates (`i3 -c ~/.config/i3/config -C`): OK.
- `~/bin/i3-test-xephyr --display N --wait S`: starts nested i3.
- `~/bin/i3-test-emacs-popup` via `i3-test-xephyr`: PASS.
- `~/bin/i3-snapshot --stdout`: emits normalized JSON.

## Notes / deviations

- `SPACEMACS_REF` changed from `v0.9.1` to `develop` because the pinned tag failed to bootstrap `use-package` and left the daemon unusable.
- `Dockerfile.spacemacs` now uses `FROM agent-i3-core` with a `CORE_IMAGE` build arg; `depends_on: core` is set in compose.
- The `agent-sandbox` layer is mounted at runtime (`../layers/agent-sandbox:/home/agent/.emacs.d/private/agent-sandbox`) per the existing review-fix spec; it is not baked into the image because the Docker build context is `docker/`.
- Package warmup is best-effort (`warmup-spacemacs || true`); it initializes enough packages to speed first boot but may not warm everything before the timeout.
- Helm popup (`config/helm-popup.el`) already existed and satisfies `helm-popup-frame-i3`; no changes were needed.

## Definition of done

All kanban acceptance criteria are satisfied, files are created/edited, and verification commands above pass without new failures.
