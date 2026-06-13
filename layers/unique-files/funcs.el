;;; funcs.el --- unique-files functions -*- lexical-binding: t; -*-
;;; Commentary:
;; Timestamped unique-file helpers and list continuation.

;;; Code:

(require 'project nil t)
(eval-when-compile (require 'subr-x))

;;;; ---------- Unique files core ----------

(defun unique-files//project-root ()
  "Return the current project root, falling back to `default-directory'."
  (or (when (fboundp 'project-current)
        (when-let ((p (project-current nil)))
          (ignore-errors (project-root p))))
      (locate-dominating-file default-directory ".git")
      default-directory))

(defun unique-files//expand (path)
  "Expand PATH relative to the current project root."
  (let ((root (unique-files//project-root)))
    (if (file-name-absolute-p path) path (expand-file-name path root))))

(defun unique-files//normalize-mode (mode)
  "Normalize MODE aliases to canonical names used by `unique-files-mode-targets'."
  (pcase mode
    ('gfm-mode 'markdown-mode)
    ('js-ts-mode 'js-mode)
    ('typescript-ts-mode 'typescript-mode)
    (_ mode)))

(defun unique-files//target (mode)
  "Return plist (:dir :ext) for MODE, expanding :dir relative to project root."
  (let* ((mode (unique-files//normalize-mode mode))
         (pl   (alist-get mode unique-files-mode-targets)))
    (list :dir (unique-files//expand (or (plist-get pl :dir) unique-files-default-dir))
          :ext (or (plist-get pl :ext) ".txt"))))

(defun unique-files//timestamp ()
  "Return a timestamp string using `unique-files-doc-format'."
  (format-time-string unique-files-doc-format (current-time)))

(defun unique-files//unique-path (dir ext)
  "Return a non-existent file path in DIR with timestamp base and EXT."
  (make-directory dir t)
  (let* ((ts   (unique-files//timestamp))
         (base (expand-file-name ts dir))
         (path (concat base ext))
         (n 1))
    (while (file-exists-p path)
      (setq path (format "%s-%d%s" base n ext)
            n (1+ n)))
    path))

(defun unique-files//insert-header-md (name)
  "Insert a Markdown header for NAME."
  (insert "# " name "\n\n"))

(defun unique-files//insert-header-org (name)
  "Insert an Org header for NAME."
  (insert "#+TITLE: " name "\n\n"))

(defun unique-files//insert-header-js (name)
  "Insert a JS block comment header for NAME."
  (insert "/* " name " */\n\n"))

(defun unique-files/open-for-mode (mode &optional ask-header ext)
  "Create and visit a timestamped file for MODE.
With prefix arg ASK-HEADER, insert a mode-appropriate header.
EXT overrides the default extension for MODE (e.g., \".md\")."
  (interactive
   (list (intern (completing-read
                  "Mode: "
                  (mapcar #'car unique-files-mode-targets)
                  nil t nil nil (symbol-name major-mode)))
         current-prefix-arg))
  (let* ((target (unique-files//target mode))
         (dir    (plist-get target :dir))
         (ext    (or ext (plist-get target :ext)))
         (path   (unique-files//unique-path dir ext)))
    (find-file path)
    (unless (eq major-mode mode)
      (if (fboundp mode)
          (funcall mode)
        (message "Mode %s is not available; staying in %s" mode major-mode)))
    (when ask-header
      (when-let ((hdr (alist-get (unique-files//normalize-mode mode) unique-files-mode-headers)))
        (funcall hdr (file-name-base path))))
    (save-buffer)
    (message "New %s: %s" mode path)
    path))

(defun unique-files/open-like-this-buffer (&optional ask-header)
  "Create a unique file using the `major-mode' of the current buffer.
With prefix arg ASK-HEADER, insert a header."
  (interactive "P")
  (unique-files/open-for-mode major-mode ask-header))

(defun unique-files/open-with-extension (ext &optional ask-header)
  "Prompt for EXT (e.g., \".md\") and create a unique file for this buffer's mode.
With prefix arg ASK-HEADER, insert a header."
  (interactive
   (list (read-string "Extension (with dot): "
                      (or (and buffer-file-name
                               (let ((e (file-name-extension buffer-file-name)))
                                 (and e (concat "." e))))
                          (plist-get (unique-files//target major-mode) :ext)))
         current-prefix-arg))
  (let ((ext (if (string-prefix-p "." ext) ext (concat "." ext))))
    (unique-files/open-for-mode major-mode ask-header ext)))

(defun unique-files/open-markdown (&optional ask-header)
  "Create a unique Markdown file.
With prefix arg ASK-HEADER, insert a header."
  (interactive "P")
  (unique-files/open-for-mode 'markdown-mode ask-header))

(defun unique-files/open-org (&optional ask-header)
  "Create a unique Org file.
With prefix arg ASK-HEADER, insert a header."
  (interactive "P")
  (unique-files/open-for-mode 'org-mode ask-header))

(defun unique-files/open-text (&optional ask-header)
  "Create a unique text file.
With prefix arg ASK-HEADER, insert a header."
  (interactive "P")
  (unique-files/open-for-mode 'text-mode ask-header))

(defun unique-files/open-js (&optional ask-header)
  "Create a unique JavaScript file.
With prefix arg ASK-HEADER, insert a header."
  (interactive "P")
  (unique-files/open-for-mode (if (fboundp 'js-ts-mode) 'js-ts-mode 'js-mode) ask-header))

;;;; ---------- List continuation (fallback) ----------

(defun unique-files-list--empty-item-p ()
  "Return non-nil if the current line is an empty list item."
  (save-excursion
    (beginning-of-line)
    (looking-at
     "^[[:space:]]*\\([-+*]\\|[0-9]+[.)]\\|[A-Za-z][.)]\\)[[:space:]]+\\(\\[[ xX-]\\][[:space:]]+\\)?[[:space:]]*$")))

(defun unique-files-list--current-marker ()
  "Return a plist describing the current line's list marker, or nil.
Keys are :indent, :raw, :next, and :checkbox."
  (save-excursion
    (beginning-of-line)
    (when (looking-at
           (rx bol
               (group (* blank))                         ; 1: indent
               (group
                (or (any "-+*")
                    (seq (group (+ digit)) (any ".)"))   ; 3:num
                    (seq (group alpha)      (any ".)")))) ; 4:alpha
               (+ blank)
               (opt (group "[" (any " xX-") "]") (+ blank))))
      (let* ((indent (match-string 1))
             (raw    (match-string 2))
             (num    (match-string 3))
             (alp    (match-string 4))
             (cbx    (match-string 5))
             (next
              (cond
               (num (format "%d%c" (1+ (string-to-number num))
                            (aref raw (1- (length raw)))))
               (alp (format "%c%c" (1+ (string-to-char alp))
                            (aref raw (1- (length raw)))))
               (t raw))))
        (list :indent indent :raw raw :next next :checkbox cbx)))))

(defun unique-files-list--prev-list-indent ()
  "Return the `current-indentation' of the previous non-blank list line, or nil."
  (save-excursion
    (forward-line -1)
    (while (and (not (bobp)) (looking-at-p "^[[:space:]]*$"))
      (forward-line -1))
    (when (looking-at
           "^[[:space:]]*\\([-+*]\\|[0-9]+[.)]\\|[A-Za-z][.)]\\)[[:space:]]+")
      (current-indentation))))

(defun unique-files-list--first-marker-like (raw)
  "Given RAW like \"3.\", \"a)\" or \"-\", return the first in that style."
  (let ((term (aref raw (1- (length raw)))))
    (cond
     ((string-match-p "^[0-9]+" raw) (format "1%c" term))
     ((string-match-p "^[A-Z]" raw)  (format "A%c" term))
     ((string-match-p "^[a-z]" raw)  (format "a%c" term))
     (t raw))))

(defun unique-files-list--second-marker-like (raw)
  "Given RAW like \"3.\", \"a)\" or \"-\", return the second in that style."
  (let ((term (aref raw (1- (length raw)))))
    (cond
     ((string-match-p "^[0-9]+" raw) (format "2%c" term))
     ((string-match-p "^[A-Z]" raw)  (format "B%c" term))
     ((string-match-p "^[a-z]" raw)  (format "b%c" term))
     (t raw))))

(defun unique-files-list-ret-dwim ()
  "Insert newline with list continuation if at end of a list item.
Otherwise fall back to `newline-and-indent'."
  (interactive)
  (let* ((eol (line-end-position))
         (bol (line-beginning-position))
         (at-eol (eq (point) eol))
         (m (unique-files-list--current-marker)))
    (cond
     ;; Not on a list line or not at end of line → fallback
     ((or (null m) (not at-eol))
      (call-interactively #'newline-and-indent))
     ;; Empty item → exit list
     ((unique-files-list--empty-item-p)
      (delete-region bol eol)
      (newline))
     ;; List continuation
     (t
      (let* ((indent (or (plist-get m :indent) ""))
             (raw    (or (plist-get m :raw)    ""))
             (cb     (plist-get m :checkbox))
             (prev-indent (unique-files-list--prev-list-indent))
             (curr-indent (current-indentation))
             (deep? (and prev-indent
                         (> curr-indent prev-indent)
                         (or (string-match-p "^[0-9]+" raw)
                             (string-match-p "^[A-Za-z]" raw))))
             (next (plist-get m :next)))
        ;; If deeper indent, reset marker to 1/a/A
        (when deep?
          (let ((first (unique-files-list--first-marker-like raw)))
            (save-excursion
              (goto-char bol)
              (when (looking-at "^[[:space:]]*\\([-+*]\\|[0-9]+[.)]\\|[A-Za-z][.)]\\)")
                (let ((s (match-beginning 1)) (e (match-end 1)))
                  (unless (string-equal (match-string 1) first)
                    (goto-char s)
                    (delete-region s e)
                    (insert first)))))))
        (when deep?
          (setq next (unique-files-list--second-marker-like raw)))
        (newline)
        (insert indent next " ")
        (when cb (insert cb " ")))))))

(defvar unique-files-list-continue-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "RET") #'unique-files-list-ret-dwim)
    map)
  "Keymap for `unique-files-list-continue-mode'.")

(define-minor-mode unique-files-list-continue-mode
  "Minor mode for Obsidian-like list continuation on RET."
  :lighter " ▪RET"
  :keymap unique-files-list-continue-mode-map)

(defun unique-files/orgalist-ret-dwim ()
  "DWIM RET for `orgalist-mode': insert item if on a list, else newline."
  (interactive)
  (condition-case nil
      (call-interactively #'orgalist-insert-item)
    (error (call-interactively #'newline-and-indent))))

(defun unique-files/list-renumber-block ()
  "Renumber numeric list items in the current paragraph or active region.
Ordered, alphabetic, and bullet markers are left unchanged; only numeric
markers are restarted from 1."
  (interactive)
  (save-excursion
    (let* ((beg (if (use-region-p)
                    (region-beginning)
                  (progn (backward-paragraph) (point))))
           (end (if (use-region-p)
                    (region-end)
                  (progn (forward-paragraph) (point))))
           (n 1))
      (goto-char beg)
      (while (re-search-forward
              "^\\([[:space:]]*\\)\\([0-9]+\\)\\([.)]\\)\\([[:space:]]+\\)"
              end t)
        (replace-match (format "\\1%d\\3\\4" n) nil nil)
        (setq n (1+ n))))))

;;; funcs.el ends here
