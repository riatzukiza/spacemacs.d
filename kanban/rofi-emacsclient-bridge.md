---
uuid: "rofi-emacsclient-bridge"
title: "Implement rofi -> emacsclient bridge launcher"
status: "completed"
priority: "P1"
labels: ["ux", "rofi", "emacs", "i3"]
created_at: "2026-06-13T02:25:00Z"
source: ".spacemacs.d/docs/notes/2026.06.13.02.25.21.md"
points: 3
category: "ux"
---

# Implement rofi -> emacsclient bridge launcher

Build a unified launcher where rofi selects and Emacs acts:

- `~/.local/bin/wm-go` shell entrypoint from i3.
- Soft prefix scheme: `f ` files, `b ` buffers, `p ` projects, `t ` terminals, `w ` workspaces, `a ` agents, `:` commands.
- Emacs helpers in `dotspacemacs/user-config`:
  - `my/rofi-lines` returning recent files, buffers, projects.
  - `my/new-vterm-dispatch` and `my/new-eshell-dispatch` with context-aware default directory.
- i3 binding mode `go` triggered by `$mod+g` with `Escape`/`Return` back to default.
- Context rule: current project, then current buffer dir, then prompt.

## Acceptance

- `$mod+g f` opens rofi filtered to recent files and opens selection via `emacsclient`.
- `$mod+Shift+Return` opens a new vterm in the current context.
- i3 mode exits cleanly with `Escape`.

---

Extracted from note on 2026-06-13.
