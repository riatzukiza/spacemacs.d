;; -*- mode: emacs-lisp; lexical-binding: t -*-
;;; config/consult-launcher.el --- Consult/Vertico minibuffer popup launcher  -*- lexical-binding: t; -*-
;;; Commentary:
;; Rofi-like launcher using a minibuffer-only Emacs frame.
;; Requires the `vertico' and `consult' packages.
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

(defun my/launcher-find-file ()
  "Open `find-file' in a centered minibuffer-only frame.
If `vertico-mode' is available it is enabled for the duration of the
launcher so Vertico/Consult completion is active."
  (interactive)
  (let ((frame (make-frame (my/launcher-frame-params)))
        (had-vertico (and (boundp 'vertico-mode) vertico-mode)))
    (select-frame-set-input-focus frame)
    (unwind-protect
        (progn
          (when (fboundp 'vertico-mode)
            (vertico-mode 1))
          (call-interactively #'find-file))
      (when (frame-live-p frame)
        (delete-frame frame))
      (when (and (fboundp 'vertico-mode) (not had-vertico))
        (vertico-mode -1)))))

;;; consult-launcher.el ends here
