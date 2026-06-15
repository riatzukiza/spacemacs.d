---
uuid: "consult-vertico-popup-launcher"
title: "Build Consult/Vertico minibuffer popup launcher"
status: "review"
priority: "P2"
labels: ["ux", "consult", "vertico", "emacs", "i3"]
created_at: "2026-06-13T02:25:00Z"
source: ".spacemacs.d/docs/notes/emacs-launcher/03-minibuffer-native-launcher-options.md"
points: 3
category: "ux"
---

# Build Consult/Vertico minibuffer popup launcher

Create a rofi-like launcher using a minibuffer-native stack:

- Install/enable `vertico` and `consult` in Spacemacs if not present.
- `my/launcher-find-file` creates a named minibuffer-only frame (`emacs-launcher`) and calls `find-file`.
- i3 rule to float and center the `emacs-launcher` frame.
- Bind i3 to `emacsclient -e '(my/launcher-find-file)'`.

This is the alternative path to Helm popup; pick one after quick prototype.

## Acceptance

- `emacsclient -e '(my/launcher-find-file)'` opens a centered minibuffer-only frame.
- Vertico/Consult completion works inside the popup.
- Frame closes after selection or cancel.

---

Extracted from note on 2026-06-13.
