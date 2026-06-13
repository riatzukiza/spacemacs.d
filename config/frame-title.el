;; -*- mode: emacs-lisp; lexical-binding: t -*-
;;; config/frame-title.el --- Dynamic frame title  -*- lexical-binding: t -*-
;;; Commentary:
;; Show the abbreviated path (or buffer name) of every window in the frame.
;; Titles look like: ~/proj/a/foo.ts │ ~/proj/b/bar.ts │ *scratch*
;; Loaded by `dotspacemacs/user-config'.

;;; Code:

(setq frame-title-format
      '(:eval
        (let* ((wins  (window-list (selected-frame) 'nomini)) ; no minibuffer
               (paths (mapcar (lambda (w)
                                (with-current-buffer (window-buffer w)
                                  (cond
                                   (buffer-file-name
                                    (abbreviate-file-name buffer-file-name))
                                   (default-directory
                                    (abbreviate-file-name default-directory))
                                   (t (format "*%s*" (buffer-name))))))
                              wins))
               (joined (mapconcat #'identity (delete-dups paths) " │ ")))
          ;; keep it sane for WMs/launchers; tail-ellipsis if too long
          (truncate-string-to-width joined 200 nil nil "…"))))

;; When iconified, keep the same info in the taskbar/dock entry.
(setq icon-title-format frame-title-format)

;;; frame-title.el ends here
