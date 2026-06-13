;; -*- mode: emacs-lisp; lexical-binding: t -*-
;;; config/helm-popup.el --- Floating Helm popup frame  -*- lexical-binding: t; -*-
;;; Commentary:
;; Spotlight-style floating Helm frames via leader bindings.
;; Loaded by `dotspacemacs/user-config'.

;;; Code:

(defconst err/helm-popup-frame-name "helm-popup"
  "Name used for the Helm popup frame.")

(defconst err/helm-popup-frame-params
  `((name . ,err/helm-popup-frame-name)
    (minibuffer . t)
    (width . 110)
    (height . 18)
    (undecorated . t)
    (skip-taskbar . t)
    (internal-border-width . 12)
    (menu-bar-lines . 0)
    (tool-bar-lines . 0)
    (vertical-scroll-bars . nil)
    (horizontal-scroll-bars . nil))
  "Default frame parameters for the Helm popup frame.")

(defun err/helm-popup (cmd)
  "Run Helm CMD in a small floating frame.
The popup frame is destroyed when Helm exits.  If a Helm action opened a
new buffer, that buffer is shown in the originally selected frame."
  (let* ((orig-frame (selected-frame))
         (orig-buffer (current-buffer))
         (frame (make-frame err/helm-popup-frame-params)))
    (set-frame-parameter frame 'frame-title-format err/helm-popup-frame-name)
    (set-frame-parameter frame 'icon-title-format err/helm-popup-frame-name)
    (select-frame-set-input-focus frame)
    (delete-other-windows)
    (unwind-protect
        (let ((helm-full-frame t)
              (helm-display-function #'helm-default-display-buffer))
          (call-interactively cmd))
      (let ((result-buffer (current-buffer)))
        (when (and (not (eq result-buffer orig-buffer))
                   (buffer-live-p result-buffer)
                   (frame-live-p orig-frame))
          (with-selected-frame orig-frame
            (switch-to-buffer result-buffer)
            (select-frame-set-input-focus orig-frame))))
      (when (frame-live-p frame)
        (delete-frame frame)))))

(defun err/helm-popup-find-files ()
  "Open `helm-find-files' in the popup frame."
  (interactive)
  (err/helm-popup #'helm-find-files))

(defun err/helm-popup-list-buffers ()
  "Open `helm-buffers-list' in the popup frame."
  (interactive)
  (err/helm-popup #'helm-buffers-list))

(defun err/helm-popup-recentf ()
  "Open `helm-projectile-recentf' in the popup frame."
  (interactive)
  (err/helm-popup #'helm-projectile-recentf))

(defun err/helm-popup-switch-project ()
  "Open `helm-projectile-switch-project' in the popup frame."
  (interactive)
  (err/helm-popup #'helm-projectile-switch-project))

(spacemacs/declare-prefix "o h" "helm-popup")

(spacemacs/set-leader-keys
  "ohf" #'err/helm-popup-find-files
  "ohb" #'err/helm-popup-list-buffers
  "ohr" #'err/helm-popup-recentf
  "ohp" #'err/helm-popup-switch-project)

;;; helm-popup.el ends here
