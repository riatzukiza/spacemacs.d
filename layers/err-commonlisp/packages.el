;;; packages.el --- err-commonlisp layer packages file for Spacemacs -*- lexical-binding: t; -*-
;;; Commentary:
;; Common Lisp LSP and Flycheck setup.

;;; Code:

(defconst err-commonlisp-packages
  '(lsp-mode flycheck lisp-mode)
  "Packages configured by err-commonlisp.")

(defcustom err-commonlisp-cl-lsp-executable
  (or (executable-find "cl-lsp")
      (expand-file-name "~/.roswell/bin/cl-lsp"))
  "Path to the cl-lsp executable used for Common Lisp LSP support."
  :type 'file
  :group 'err-commonlisp)

(defun err-commonlisp/post-init-lsp-mode ()
  "Register the cl-lsp LSP client for `lisp-mode'."
  (with-eval-after-load 'lsp-mode
    (setq lsp-language-id-configuration
          (assq-delete-all 'lisp-mode lsp-language-id-configuration))
    (push '(lisp-mode . "commonlisp") lsp-language-id-configuration)
    (lsp-register-client
     (make-lsp-client
      :new-connection
      (lsp-stdio-connection (lambda () (list err-commonlisp-cl-lsp-executable)))
      :activation-fn (lsp-activate-on "commonlisp")
      :server-id 'cl-lsp
      :major-modes '(lisp-mode)))))

(defun err-commonlisp/post-init-lisp-mode ()
  "Configure `lisp-mode' hooks and optional SLIME helper."
  (with-eval-after-load 'lisp-mode
    (add-hook 'lisp-mode-hook #'lsp-deferred)
    (add-hook 'lisp-mode-hook #'flycheck-mode)
    (when (fboundp 'spacemacs/toggle-evil-safe-lisp-structural-editing-on-register-hook-lisp-mode)
      (spacemacs/toggle-evil-safe-lisp-structural-editing-on-register-hook-lisp-mode))
    (let ((slime-helper (expand-file-name "~/quicklisp/slime-helper.el")))
      (when (file-exists-p slime-helper)
        (load slime-helper)))))

(defun err-commonlisp/post-init-flycheck ()
  "Define a sblint-backed Flycheck checker for Common Lisp."
  (with-eval-after-load 'flycheck
    (flycheck-define-checker common-lisp-sblint
      "Common Lisp linting via sblint (SBCL)."
      :command ("sblint" source-inplace)
      :error-patterns
      ((error line-start (file-name) ":" line ":" column ": " (message) line-end))
      :modes (lisp-mode))
    (add-to-list 'flycheck-checkers 'common-lisp-sblint)))

;;; packages.el ends here
