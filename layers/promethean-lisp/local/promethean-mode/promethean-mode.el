;;; promethean-mode.el --- Major mode for Promethean Lisp -*- lexical-binding: t; -*-
;;; Commentary:
;; Minimal major mode with documented regexes for font-lock and basics.

;;; Code:

(require 'rx)

(defgroup promethean nil
  "Promethean Lisp mode."
  :group 'languages)

(defconst promethean--keywords
  '("def" "defun" "lambda" "let" "let*" "if" "cond" "case" "match" "fn"
    "import" "export" "module" "macro" "quote" "quasiquote" "unquote" "splice" "include")
  "Reserved special forms and keywords.")

(defconst promethean--builtins
  '("+" "-" "*" "/" "=" "not" "and" "or" "car" "cdr" "cons" "list" "map" "reduce" "pipe")
  "Core built-ins and operators.")

;; Match any of the known keywords as a complete symbol, not as a prefix of a
;; longer symbol.  Example match: `(def foo)`.  Non-match: `(definitely x)`.
(defconst promethean--re-keywords
  (regexp-opt promethean--keywords 'symbols)
  "Regex for keywords as full symbols.")

;; Match any of the known built-in names/operators as full symbols.
;; Example match: `(+ x 1)`.  Non-match: `(++ x)`.
(defconst promethean--re-builtins
  (regexp-opt promethean--builtins 'symbols)
  "Regex for builtins as full symbols.")

;; Match Promethean boolean/constant symbols exactly: :true, :false, or :nil.
;; Examples: `:true`, `:nil`.  Non-match: `truely`, `:nilpotent`.
(defconst promethean--re-const
  (rx symbol-start (or ":true" ":false" ":nil") symbol-end)
  "Regex for constants: :true, :false, :nil.")

;; Match integer or simple decimal numbers as standalone symbols.
;; Optional leading '-'.  Requires digits, optional '.' and more digits.
;; Examples: `-42`, `3.14`, `0`.  Non-matches: `3.14.15`, `-`, `3.`.
(defconst promethean--re-number
  (rx symbol-start
      (? "-")
      (+ digit)
      (? "." (+ digit))
      (not (any digit))
      (*? any)
      symbol-end)
  "Regex for integers/decimals with optional leading '-'.")

;; Match a definition head: an opening paren, the word 'defun' or 'def',
;; horizontal whitespace, then the function/var NAME (captured), followed by
;; optional horizontal whitespace.
;;   group 1 -> the defining keyword ('defun'|'def')
;;   group 2 -> the defined name (letters, digits, and - _ ! ? / :)
;; Examples: `(defun greet-user name)`, `(def my-var 10)`.
;; Non-match: `(define x)` (different keyword), `(defun)` (no name).
(defconst promethean--re-def-name
  (rx "("
      (group (or "defun" "def"))
      (+ blank)
      (group (+ (or word "-" "_" "!" "?" "/" ":")))
      (* blank))
  "Regex for (defun|def NAME ...) with captures for keyword and name.")

(defconst promethean-font-lock
  `((,promethean--re-keywords . font-lock-keyword-face)
    (,promethean--re-builtins . font-lock-builtin-face)
    (,promethean--re-const    . font-lock-constant-face)
    (,promethean--re-number   . font-lock-number-face)
    (,promethean--re-def-name
     (1 font-lock-keyword-face)
     (2 font-lock-function-name-face)))
  "Font-lock rules for `promethean-mode'.")

(defvar promethean-mode-syntax-table
  (let ((st (make-syntax-table)))
    (modify-syntax-entry ?\( "()" st)
    (modify-syntax-entry ?\) ")( " st)
    (modify-syntax-entry ?\" "\"" st)
    (modify-syntax-entry ?\; "<" st)
    (modify-syntax-entry ?\n ">" st)
    (modify-syntax-entry ?- "w" st)
    (modify-syntax-entry ?_ "w" st)
    (modify-syntax-entry ?: "w" st)
    (modify-syntax-entry ?/ "w" st)
    (modify-syntax-entry ?! "w" st)
    (modify-syntax-entry ?? "w" st)
    st)
  "Syntax table for `promethean-mode'.")

(defun promethean--indent-line ()
  "Naive indentation based on parenthesis depth."
  (let* ((pos (- (point) (line-beginning-position))))
    (save-excursion
      (back-to-indentation)
      (let* ((ppss (syntax-ppss))
             (depth (nth 0 ppss)))
        (indent-line-to (max 0 (* 2 depth)))))
    (when (> pos 0) (goto-char (+ (line-beginning-position) pos)))))

(defvar promethean-imenu-generic-expression
  `((nil ,(rx "(" (or "defun" "def") (+ blank) (group (+ (or word "-" "_" "!" "?" "/" ":")))) 1))
  "Imenu definitions for `promethean-mode'.")

;;;###autoload
(define-derived-mode promethean-mode prog-mode "Promethean"
  "Major mode for editing Promethean Lisp."
  :syntax-table promethean-mode-syntax-table
  (setq-local font-lock-defaults '(promethean-font-lock))
  (setq-local comment-start ";")
  (setq-local comment-end "")
  (setq-local indent-line-function #'promethean--indent-line)
  (setq-local imenu-generic-expression promethean-imenu-generic-expression)
  (setq-local lsp-language-id "promethean"))

(provide 'promethean-mode)
;;; promethean-mode.el ends here
