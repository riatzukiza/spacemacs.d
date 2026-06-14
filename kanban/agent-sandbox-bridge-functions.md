---
uuid: "agent-sandbox-bridge-functions"
title: "Add remaining agent-sandbox bridge functions"
status: "pending"
priority: "P1"
labels: ["agent-i3-sandbox", "spacemacs", "layer", "emacs-lisp"]
created_at: "2026-06-14T00:00:00Z"
source: ".spacemacs.d/docs/notes/agent-i3-sandbox/01-core-container-harness.md"
points: 3
category: "editor"
---

# Add remaining agent-sandbox bridge functions

Flesh out the `agent-sandbox` private layer with the bridge functions described in the design notes.

## Tasks

- `agent/send-path-to-opencode` — send current file/dir to an opencode agent session.
- `agent/new-vterm-in-project` — open a new vterm in the current project context.
- `agent/find-workspace` — find or create a named i3 workspace from Emacs.
- Update `keybindings.el` with leader bindings for the new functions.
- Add ERT tests for pure logic where possible.

## Acceptance

- All functions are callable via `M-x` and leader keys.
- Functions that shell out handle errors and report context.
- Tests pass in `make test`.

---

Synthesized from note on 2026-06-14.
