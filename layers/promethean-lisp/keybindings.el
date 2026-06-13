;;; keybindings.el --- promethean-lisp layer keybindings -*- lexical-binding: t; -*-
;;; Commentary:
;; Evil leader bindings for Promethean buffers.

;;; Code:

(spacemacs/set-leader-keys-for-major-mode 'promethean-mode
  "="  #'promethean-lisp-format-buffer
  "rr" #'promethean-lisp-open-repl
  ;; lsp-mode common actions
  "ld" #'lsp-find-definition
  "lD" #'lsp-find-declaration
  "lr" #'lsp-find-references
  "lh" #'lsp-describe-thing-at-point
  "la" #'lsp-execute-code-action
  "lf" #'lsp-format-buffer
  "ls" #'lsp-workspace-folders-switch
  "lR" #'lsp-restart-workspace)

(spacemacs/set-leader-keys-for-major-mode 'promethean-mode
  "tk" #'promethean-lisp-regex-test-keywords
  "tb" #'promethean-lisp-regex-test-builtins
  "tc" #'promethean-lisp-regex-test-const
  "tn" #'promethean-lisp-regex-test-number
  "td" #'promethean-lisp-regex-test-def-name)

;;; keybindings.el ends here
