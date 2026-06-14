---
uuid: "rofi-bridge-concrete-implementation"
title: "Implement concrete rofi-emacsclient bridge files"
status: "pending"
priority: "P1"
labels: ["emacs-launcher", "rofi", "emacsclient", "i3"]
created_at: "2026-06-14T00:00:00Z"
source: ".spacemacs.d/docs/notes/emacs-launcher/02-rofi-emacsclient-bridge.md"
points: 3
category: "ux"
---

# Implement concrete rofi-emacsclient bridge files

Turn the rofi bridge sketch into working files for files, buffers, projects, terminals, and context-aware `new vterm`.

## Tasks

- Create `~/.local/bin/wm-go` shell script with fuzzy rofi selection.
- Add Emacs helpers in `dotspacemacs/user-config` (or private layer):
  - `my/rofi-lines` for recents, buffers, projects.
  - `my/new-vterm-dispatch` and `my/new-eshell-dispatch` with context-aware default directory.
- Wire i3 bindings: `$mod+g` for `go` mode, `$mod+Shift+Return` for new context terminal.
- Add i3 `go` mode with `[f]iles [b]uffers [p]rojects [t]erminals [w]orkspaces [a]gents`.

## Acceptance

- `$mod+g f` opens rofi filtered to recent files; selecting opens in Emacs.
- `$mod+g t` lists existing terminals; selecting raises the terminal.
- `$mod+Shift+Return` opens a new vterm in the current project/buffer directory.
- Escape and Return exit i3 `go` mode back to default.

---

Synthesized from note on 2026-06-14.
