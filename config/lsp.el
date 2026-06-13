;; -*- mode: emacs-lisp; lexical-binding: t -*-
;;; config/lsp.el --- LSP and syntax-checking customizations  -*- lexical-binding: t -*-
;;; Commentary:
;; Loaded by `dotspacemacs/user-config' after layers have initialized.

;;; Code:

;; Enable Flycheck globally.  This used to live in `user-config' directly;
;; grouping it here keeps all linting-related setup in one place.
(global-flycheck-mode)

;; LSP-mode customizations.
(with-eval-after-load 'lsp-mode
  ;; Semgrep is not used; disable its language list so LSP does not try to
  ;; configure a missing backend.
  (setq lsp-semgrep-languages nil))

;;; lsp.el ends here
