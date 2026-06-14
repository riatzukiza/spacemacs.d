---
uuid: "spacemacs-docker-package-warmup-verify"
title: "Verify and complete Spacemacs Docker package warmup"
status: "pending"
priority: "P1"
labels: ["agent-i3-sandbox", "docker", "spacemacs", "performance"]
created_at: "2026-06-14T00:00:00Z"
source: ".spacemacs.d/docs/notes/agent-i3-sandbox/03-control-script-and-first-fixes.md"
points: 3
category: "infrastructure"
---

# Verify and complete Spacemacs Docker package warmup

Ensure the Spacemacs image build actually warms package installation so first-boot is not doing fresh installation every time.

## Tasks

- Inspect current `Dockerfile.spacemacs` and `Dockerfile.dev` for warmup logic.
- If missing, add a build step that starts Emacs once to trigger package install, then caches the result.
- Measure cold vs. warmed `agentctl up spacemacs` startup time.
- Document the warmup behavior and any cache-bust considerations.

## Acceptance

- Warmed image starts Spacemacs target noticeably faster than a cold install.
- Build still succeeds when Spacemacs ref or layers change.
- Warmed layer is invalidated correctly when `SPACEMACS_REF` or layer files change.

---

Synthesized from note on 2026-06-14.
