;;; funcs.el --- codex layer functions -*- lexical-binding: t; -*-
;;; Commentary:
;; Functions to interact with the OpenAI Codex CLI.

;;; Code:

(require 'json)
(require 'subr-x)
(require 'cl-lib)
(require 'seq)

(defun codex--project-root ()
  "Return the current project root."
  (or (and (fboundp 'projectile-project-root) (projectile-project-root))
      (and (fboundp 'project-current)
           (when-let ((pr (project-current)))
             (project-root pr)))
      default-directory))

(defun codex--git-branch ()
  "Return the current git branch, or empty string."
  (string-trim (or (ignore-errors (shell-command-to-string "git rev-parse --abbrev-ref HEAD")) "")))

(defun codex--git-diff-summary ()
  "Return a git diff stat, or empty string."
  (let* ((default-directory (codex--project-root))
         (cmd "git --no-pager diff --stat -- .")
         (out (ignore-errors (shell-command-to-string cmd))))
    (if (and out (> (length out) 0)) out "")))

(defun codex--git-hunks (file n)
  "Return git diff hunks for FILE with N context lines."
  (let* ((default-directory (codex--project-root))
         (cmd (format "git --no-pager diff -U%d -- %s" n (shell-quote-argument file))))
    (or (ignore-errors (shell-command-to-string cmd)) "")))

(defun codex--flycheck-errors ()
  "Return current Flycheck errors as a string, or nil."
  (when (and codex-include-flycheck-errors (bound-and-true-p flycheck-current-errors))
    (mapconcat
     (lambda (e)
       (format "%s:%d:%d: %s"
               (or (flycheck-error-filename e) (buffer-file-name))
               (flycheck-error-line e)
               (or (flycheck-error-column e) 0)
               (flycheck-error-message e)))
     flycheck-current-errors
     "\n")))

(defun codex--lsp-symbols ()
  "Return current LSP document symbols as a string, or empty string."
  (when (and codex-include-lsp-context
             (boundp 'lsp-mode) lsp-mode
             (fboundp 'lsp-request)
             buffer-file-name)
    (condition-case _
        (let* ((doc (lsp-request "textDocument/documentSymbol"
                                 `(:textDocument (:uri ,(concat "file://" buffer-file-name)))))
               (names (cl-labels ((grab (x) (or (alist-get 'name x)
                                                (alist-get :name x))))
                        (mapconcat #'identity (delq nil (mapcar #'grab doc)) ", "))))
          (if (and names (> (length names) 0))
              (format "LSP symbols: %s" names)
            ""))
      (error ""))))

(defun codex--buffer-chunk ()
  "Return region or buffer contents, capped by `codex-context-max-bytes'."
  (let* ((sel (if (use-region-p)
                  (buffer-substring-no-properties (region-beginning) (region-end))
                (buffer-substring-no-properties (point-min) (point-max)))))
    (if (<= (string-bytes sel) codex-context-max-bytes)
        sel
      (let* ((limit codex-context-max-bytes)
             (i (min (length sel) limit)))
        (while (and (> i 0)
                    (> (string-bytes (substring sel 0 i)) limit))
          (setq i (1- i)))
        (substring sel 0 i)))))

(defun codex--approx-tokens (s)
  "Rough token estimate: bytes / 4."
  (/ (max 1 (string-bytes s)) 4))

(defun codex--strip-noise (txt)
  "Naive comment stripping for JS/TS buffers."
  (let ((case-fold-search nil))
    (setq txt (replace-regexp-in-string "^\\s-*//.*$" "" txt))
    (setq txt (replace-regexp-in-string "/\\*\\(.\\|\n\\)*?\\*/" "" txt))
    (replace-regexp-in-string "^[ \t]+$" "" txt)))

(defun codex--compact-context (txt file)
  "Return (:text :hunks) with optional token-budget trimming."
  (let* ((base (codex--strip-noise txt))
         (est (codex--approx-tokens base)))
    (when (> est codex-token-budget)
      (setq base (substring base 0 (min (length base) (* 4 codex-token-budget)))))
    (let* ((hunks (when (and file (file-exists-p file))
                    (codex--git-hunks file codex-diff-context-lines))))
      (list :text base :hunks hunks))))

(defun codex--build-prompt (kind user-prompt)
  "Build a markdown-ish prompt for Codex CLI."
  (let* ((root (codex--project-root))
         (file buffer-file-name)
         (rel (when (and file (file-exists-p file))
                (file-relative-name file root)))
         (cursor (format "Cursor: line %d, column %d"
                         (line-number-at-pos (point)) (current-column)))
         (branch (codex--git-branch))
         (diff (if codex-include-git-summary (codex--git-diff-summary) ""))
         (ctx (codex--compact-context (codex--buffer-chunk) file))
         (lsp (codex--lsp-symbols))
         (errs (codex--flycheck-errors)))
    (string-join
     (seq-filter #'identity
                 (list
                  (format "### Task: %s" kind)
                  (when user-prompt (format "#### Instruction\n%s" user-prompt))
                  "#### Editor State"
                  (format "- Project: %s" (abbreviate-file-name root))
                  (format "- File: %s" (or rel (buffer-name)))
                  (format "- Mode: %s" (symbol-name major-mode))
                  (format "- %s" cursor)
                  (when (and branch (> (length branch) 0)) (format "- Git branch: %s" branch))
                  (when (and diff (> (length diff) 0)) (concat "#### Git diff summary\n```\n" diff "\n```"))
                  (when (plist-get ctx :hunks) (concat "#### Git hunks\n```\n" (plist-get ctx :hunks) "\n```"))
                  (when (and lsp (> (length lsp) 0)) (concat "#### LSP\n" lsp))
                  (when (and errs (> (length errs) 0)) (concat "#### Diagnostics\n```\n" errs "\n```"))
                  "#### Current Buffer/Region\n```text"
                  (plist-get ctx :text)
                  "```"
                  "#### Rules"
                  "- Make minimal, targeted edits."
                  "- Explain changes if non-trivial."
                  "- Use project conventions; do not reformat unrelated code."))
     "\n\n")))

(defun codex--call (prompt &optional root)
  "Invoke codex and display output in a dedicated buffer."
  (let* ((default-directory (or root (codex--project-root)))
         (buf (get-buffer-create "*Codex*"))
         (cmd (executable-find codex-executable)))
    (unless cmd
      (user-error "Cannot find codex executable; set `codex-executable`"))
    (with-current-buffer buf (erase-buffer))
    (let* ((proc (start-process "codex" buf cmd)))
      (process-send-string proc (concat prompt "\n"))
      (process-send-eof proc)
      (display-buffer buf))))

(defun codex-ask (prompt)
  "Ask Codex about the current region/buffer with a freeform prompt."
  (interactive "sCodex ask: ")
  (codex--call (codex--build-prompt "Explain/answer" prompt)))

(defun codex-fix-file ()
  "Ask Codex to fix issues in the current file."
  (interactive)
  (codex--call (codex--build-prompt "Fix the file" "Fix any issues, keep behavior, minimal diffs.")))

(defun codex-review-buffer ()
  "Ask Codex to review the current buffer."
  (interactive)
  (codex--call (codex--build-prompt "Code review" "Identify issues, suggest diffs, prioritize safety.")))

(defun codex-run-task (prompt)
  "Delegate a task to Codex with full project context."
  (interactive "sCodex task: ")
  (codex--call (codex--build-prompt "Implement task" prompt)))

;;; funcs.el ends here
