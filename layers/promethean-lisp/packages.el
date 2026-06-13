;;; packages.el --- promethean-lisp layer packages -*- lexical-binding: t; -*-
;;; Commentary:
;; Spacemacs layer for Promethean Lisp (custom dialect). Provides a major mode
;; and optional lsp-mode integration.

;;; Code:

(defconst promethean-lisp-packages
  '(
    (promethean-mode :location local)
    lsp-mode)
  "List of packages required by the promethean-lisp layer.")

(defun promethean-lisp/init-promethean-mode ()
  "Initialize local `promethean-mode' package."
  (use-package promethean-mode
    :mode ("\\.prm\\'" . promethean-mode)
    :init
    (add-to-list 'auto-mode-alist '("\\.promethean\\'" . promethean-mode))
    :config
    (when promethean-lisp-lsp-enable
      (add-hook 'promethean-mode-hook #'lsp-deferred))))

(defun promethean-lisp/post-init-lsp-mode ()
  "Register the Promethean LSP client."
  (with-eval-after-load 'lsp-mode
    (lsp-register-client
     (make-lsp-client
      :new-connection (lsp-stdio-connection
                       (lambda ()
                         (cons promethean-lisp-lsp-command
                               promethean-lisp-lsp-args)))
      :activation-fn (lsp-activate-on "promethean")
      :server-id 'promethean-lsp
      :priority 1))))

;;; packages.el ends here
