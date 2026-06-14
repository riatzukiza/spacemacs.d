---
uuid: "i3-xephyr-harness-concrete"
title: "Build concrete Xephyr harness with sample E2E spec"
status: "pending"
priority: "P1"
labels: ["i3-config-testing", "testing", "xephyr", "ipc"]
created_at: "2026-06-14T00:00:00Z"
source: ".spacemacs.d/docs/notes/i3-config-testing/01-reload-and-ipc-snapshot-testing.md"
points: 5
category: "testing"
---

# Build concrete Xephyr harness with sample E2E spec

Implement the Xephyr-based test harness and one sample end-to-end spec for i3 config changes.

## Tasks

- Create `~/bin/i3-test-xephyr` that starts Xephyr, launches i3 with a temp config, and runs a test script.
- Create `~/bin/i3-snapshot` helper for `get_tree` / `get_workspaces` capture.
- Create `~/bin/i3-dev-reload` for safe host-session config reload.
- Write a sample E2E spec: launch Emacs popup -> assert window lands floating on expected workspace -> tree matches snapshot shape.
- Add `~/.spacemacs.d/lisp/i3-bridge.el` and `~/.spacemacs.d/tests/i3-bridge-test.el` for Emacs-side helpers.

## Acceptance

- `i3-test-xephyr` runs the sample spec without touching the host i3 session.
- Spec fails if the floating rule or workspace assignment regresses.
- `make test` includes the new ERT tests.

---

Synthesized from note on 2026-06-14.
