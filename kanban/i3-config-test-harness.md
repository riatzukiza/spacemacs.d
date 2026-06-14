---
uuid: "i3-config-test-harness"
title: "Build Xephyr-based i3 config test harness"
status: "completed"
priority: "P1"
labels: ["testing", "i3", "xephyr", "ci"]
created_at: "2026-06-13T02:16:00Z"
source: ".spacemacs.d/docs/notes/i3-config-testing/01-reload-and-ipc-snapshot-testing.md"
points: 5
category: "testing"
---

# Build Xephyr-based i3 config test harness

Create an integration test harness for i3 config changes:

- `~/bin/i3-test-xephyr` launching a nested Xephyr X server and disposable i3.
- `~/bin/i3-snapshot` wrapping `i3-msg -t get_tree` and `get_workspaces`.
- `~/bin/i3-dev-reload` for safe host-session reload.
- Modular i3 config under `~/.config/i3/config.d/*.conf`.
- Sample test asserting a launched `emacsclient` popup lands as floating on a named workspace.

Prefer tree-JSON assertions over screenshots.

## Acceptance

- `i3-test-xephyr` starts a nested i3 without touching the host session.
- `i3-snapshot` emits normalized JSON.
- At least one sample test passes: config parses, i3 starts, keybinding reloads.

---

Extracted from note on 2026-06-13.
