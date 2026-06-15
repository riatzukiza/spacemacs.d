;; -*- mode: emacs-lisp; lexical-binding: t -*-
;;; config/consult-launcher.el --- Consult/Vertico minibuffer popup launcher  -*- lexical-binding: t; -*-
;;; Commentary:
;; Emacs-native rofi-like launcher using a minibuffer-only popup frame.
;; Requires the `vertico' and `consult' packages (autoloaded by Spacemacs).
;; Loaded by `dotspacemacs/user-config'.

;;; Code:

(defun my/launcher-frame-params ()
  "Frame parameters for the minibuffer launcher popup."
  `((name . "emacs-launcher")
    (title . "emacs-launcher")
    (minibuffer . only)
    (width . 100)
    (height . 1)
    (undecorated . t)
    (skip-taskbar . t)
    (internal-border-width . 12)
    (menu-bar-lines . 0)
    (tool-bar-lines . 0)
    (vertical-scroll-bars . nil)
    (horizontal-scroll-bars . nil)))

(defun my/launcher (fn)
  "Run FN interactively in a centered minibuffer-only frame.
If `vertico-mode' is available it is enabled for the duration of the
launcher so Vertico/Consult completion is active.  The result buffer is
shown in the originally selected frame and the popup frame is destroyed.
FN should be an interactive command."
  (let* ((orig-frame (selected-frame))
         (orig-buffer (current-buffer))
         (frame (make-frame (my/launcher-frame-params)))
         (had-vertico (and (boundp 'vertico-mode) vertico-mode)))
    (select-frame-set-input-focus frame)
    (unwind-protect
        (progn
          (when (fboundp 'vertico-mode)
            (vertico-mode 1))
          (call-interactively fn))
      (let ((result-buffer (current-buffer)))
        (when (and (not (eq result-buffer orig-buffer))
                   (buffer-live-p result-buffer)
                   (frame-live-p orig-frame))
          (with-selected-frame orig-frame
            (switch-to-buffer result-buffer)
            (select-frame-set-input-focus orig-frame))))
      (when (frame-live-p frame)
        (delete-frame frame))
      (when (and (fboundp 'vertico-mode) (not had-vertico))
        (vertico-mode -1)))))

(defun my/launcher-go ()
  "Open a unified `consult-buffer' launcher.
Narrow with b buffers, f files, p project files, m bookmarks."
  (interactive)
  (my/launcher #'consult-buffer))

(defun my/launcher-files ()
  "Open `consult-recent-file' in the launcher frame."
  (interactive)
  (my/launcher #'consult-recent-file))

(defun my/launcher-buffers ()
  "Open `consult-buffer' in the launcher frame."
  (interactive)
  (my/launcher #'consult-buffer))

(defun my/launcher-projects ()
  "Open `consult-project-buffer' in the launcher frame.
Falls back to `projectile-switch-project' if consult-project-buffer is
unavailable."
  (interactive)
  (cond
   ((fboundp 'consult-project-buffer)
    (my/launcher #'consult-project-buffer))
   ((fboundp 'projectile-switch-project)
    (my/launcher #'projectile-switch-project))
   (t (error "No project switcher available"))))

(defun my/launcher-find-file ()
  "Open `find-file' in the launcher frame."
  (interactive)
  (my/launcher #'find-file))

;;; consult-launcher.el ends here
