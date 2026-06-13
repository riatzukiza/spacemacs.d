;;; config.el --- codex layer configuration -*- lexical-binding: t; -*-
;;; Commentary:
;; Customizable variables for the codex layer.

;;; Code:

(defcustom codex-executable "codex"
  "Name or path to the Codex CLI binary."
  :type 'string
  :group 'codex)

(defcustom codex-context-max-bytes (* 512 1024)
  "Cap the bytes of buffer/region sent to Codex (default 512KB)."
  :type 'integer
  :group 'codex)

(defcustom codex-token-budget 8192
  "Rough token budget for context trimming."
  :type 'integer
  :group 'codex)

(defcustom codex-diff-context-lines 8
  "Number of context lines for git diff hunks."
  :type 'integer
  :group 'codex)

(defcustom codex-include-lsp-context t
  "Whether to include LSP document symbols in prompts."
  :type 'boolean
  :group 'codex)

(defcustom codex-include-flycheck-errors t
  "Whether to include Flycheck diagnostics in prompts."
  :type 'boolean
  :group 'codex)

(defcustom codex-include-git-summary t
  "Whether to include a git diff summary in prompts."
  :type 'boolean
  :group 'codex)

;;; config.el ends here
