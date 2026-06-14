---
uuid: "spacemacs-agent-sandbox-layer"
title: "Create private Spacemacs agent-sandbox layer"
status: "completed"
priority: "P1"
labels: ["spacemacs", "layer", "emacs-lisp"]
created_at: "2026-06-13T02:13:00Z"
source: ".spacemacs.d/docs/notes/agent-i3-sandbox/02-optional-spacemacs-target-layer-architecture.md"
points: 5
category: "editor"
---

# Create private Spacemacs agent-sandbox layer

Move reusable agent behavior out of the dotfile into a real private layer:

- `private/agent-sandbox/layers.el`: declare dependencies (`emacs-lisp`, `shell`, `docker`).
- `private/agent-sandbox/packages.el`: package wiring.
- `private/agent-sandbox/funcs.el`:
  - `agent/open-workspace`
  - `agent/snapshot-i3`
  - `agent/send-path-to-opencode`
  - `agent/new-vterm-in-project`
  - `agent/find-workspace`
- `private/agent-sandbox/config.el`: layer variables (daemon name, artifact dir, workspace root).
- `private/agent-sandbox/keybindings.el`: package-independent bindings under `SPC a`.

## Acceptance

- Layer loads in both host and container Spacemacs.
- All declared functions are callable and bound.
- `dotspacemacs/test-dotfile` passes.

---

Extracted from note on 2026-06-13.
