;;; funcs.el --- err-helm-popup commands  -*- lexical-binding: t -*-
;;; Commentary:
;; Commands that run Helm in a small temporary floating frame.

;;; Code:

(defun err/helm-popup (cmd)
  "Run Helm CMD in a small floating frame.
The popup frame is destroyed when Helm exits.  If a Helm action opened a
new buffer, that buffer is shown in the originally selected frame."
  (interactive)
  (let* ((orig-frame (selected-frame))
         (orig-buffer (current-buffer))
         (frame (make-frame err-helm-popup-frame-params)))
    (set-frame-parameter frame 'frame-title-format err-helm-popup-frame-name)
    (set-frame-parameter frame 'icon-title-format err-helm-popup-frame-name)
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

;;; funcs.el ends here
