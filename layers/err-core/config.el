;;; config.el --- err-core layer config -*- lexical-binding: t; -*-
;;; Commentary:
;; UI defaults and global performance knobs for err-core.

;;; Code:

(defgroup err-core nil
  "Core err-specific settings."
  :group 'convenience)

(defcustom err-core/frame-opacity 75
  "Frame opacity percentage: 0=transparent, 100=opaque."
  :type 'integer
  :group 'err-core)

(setq display-line-numbers-type 'relative)
(when (display-graphic-p)
  (global-display-line-numbers-mode t))

;; Apply transparency now, future frames, and defaults
(when (fboundp 'err-core/apply-transparency)
  (err-core/apply-transparency (selected-frame)))

(if (>= emacs-major-version 29)
    (add-to-list 'default-frame-alist `(alpha-background . ,err-core/frame-opacity))
  (add-to-list 'default-frame-alist `(alpha . (,err-core/frame-opacity . ,err-core/frame-opacity))))

;; Prefer project-local Python interpreters when available, else system python3.
(setq python-shell-interpreter
      (or (and (boundp 'python-shell-interpreter)
               python-shell-interpreter
               (executable-find python-shell-interpreter))
          (executable-find "python3")
          "python3"))

;; Larger process output and GC threshold for LSP-heavy sessions.
(setq read-process-output-max (* 1024 1024)) ;; 1 MiB
(setq gc-cons-threshold 100000000) ;; 100MB

;;; config.el ends here
