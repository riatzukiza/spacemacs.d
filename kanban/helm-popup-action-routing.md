---
uuid: "helm-popup-action-routing"
title: "Route Helm popup actions back to the original frame"
status: "pending"
priority: "P2"
labels: ["emacs-launcher", "helm", "popup-frame", "i3"]
created_at: "2026-06-14T00:00:00Z"
source: ".spacemacs.d/docs/notes/emacs-launcher/04-helm-popup-frame-in-i3.md"
points: 3
category: "ux"
---

# Route Helm popup actions back to the original frame

Close the Helm popup frame automatically and open selected files/buffers in the previously focused frame.

## Tasks

- Record the previously selected frame before opening the Helm popup.
- Add Helm actions (or advices) that switch back to the original frame after selection.
- Delete the popup frame after the action completes.
- Handle cancellation (C-g) so the popup frame still closes.

## Acceptance

- Selecting a file in the Helm popup opens it in the caller frame, not the popup.
- Pressing C-g closes the popup and returns focus to the caller frame.
- Works for `helm-find-files`, `helm-list-buffers`, `helm-projectile-recentf`, and `helm-projectile-switch-project`.

---

Synthesized from note on 2026-06-14.
