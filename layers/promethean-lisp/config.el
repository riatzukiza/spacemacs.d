;;; config.el --- promethean-lisp layer config -*- lexical-binding: t; -*-
;;; Commentary:
;; Layer-level variables and defaults for promethean-lisp.

;;; Code:

(defgroup promethean-lisp nil
  "Promethean Lisp layer."
  :group 'languages)

(defcustom promethean-lisp-lsp-enable t
  "Whether to enable lsp-mode in Promethean buffers."
  :type 'boolean
  :group 'promethean-lisp)

(defcustom promethean-lisp-lsp-command "promethean-lsp"
  "Command used to start the Promethean LSP server."
  :type 'string
  :group 'promethean-lisp)

(defcustom promethean-lisp-lsp-args '("--stdio")
  "Arguments passed to `promethean-lisp-lsp-command'."
  :type '(repeat string)
  :group 'promethean-lisp)

(when (boundp 'lsp-language-id-configuration)
  (add-to-list 'lsp-language-id-configuration '(promethean-mode . "promethean")))

;;; config.el ends here
