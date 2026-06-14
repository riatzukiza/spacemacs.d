---
uuid: "helm-popup-frame-i3"
title: "Float a dedicated Helm popup frame in i3"
status: "completed"
priority: "P2"
labels: ["ux", "helm", "i3", "emacs"]
created_at: "2026-06-13T02:26:00Z"
source: ".spacemacs.d/docs/notes/emacs-launcher/04-helm-popup-frame-in-i3.md"
points: 3
category: "ux"
---

# Float a dedicated Helm popup frame in i3

Create a floating Helm frame that i3 manages via `for_window`:

- Emacs Lisp in `dotspacemacs/user-config`:
  - `my/helm-popup-frame-params` with name/title `helm-popup`, `undecorated`, `skip-taskbar`.
  - `my/helm-popup` helper plus `my/helm-popup-find-files`, `my/helm-popup-list-buffers`, `my/helm-popup-recentf`, `my/helm-popup-switch-project`.
- i3 rule:
  ```i3
  for_window [class="^Emacs$" title="^helm-popup$"] floating enable, move position center, resize set 1200 500, border pixel 1
  ```
- Keybindings using `--release` to launch each popup.

## Acceptance

- Helm popup appears centered and floating.
- Selected file/buffer opens in the original frame.
- Popup frame closes after action.

---

Extracted from note on 2026-06-13.
