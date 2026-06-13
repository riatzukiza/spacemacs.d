;;; config.el --- unique-files config -*- lexical-binding: t; -*-
;;; Commentary:
;; Customizable variables for the unique-files layer.

;;; Code:

(defgroup unique-files nil
  "Timestamped unique files and list helpers."
  :group 'convenience)

(defcustom unique-files-doc-format "%Y.%m.%d.%H.%M.%S"
  "Timestamp format for unique filenames.
Passed to `format-time-string'."
  :type 'string
  :group 'unique-files)

(defcustom unique-files-default-dir "docs/unique"
  "Fallback directory for modes without a mapping in `unique-files-mode-targets'.
Relative paths are resolved against the current project root."
  :type 'string
  :group 'unique-files)

(defcustom unique-files-mode-targets
  '((markdown-mode     :dir "docs/notes" :ext ".md")
    (gfm-mode          :dir "docs/notes" :ext ".md")
    (org-mode          :dir "docs/org"   :ext ".org")
    (text-mode         :dir "docs/text"  :ext ".txt")
    (js-mode           :dir "docs/dev"   :ext ".js")
    (js-ts-mode        :dir "docs/dev"   :ext ".js")
    (typescript-mode   :dir "docs/dev"   :ext ".ts")
    (typescript-ts-mode :dir "docs/dev"  :ext ".ts"))
  "Alist mapping major modes to plists with :dir and :ext keys."
  :type '(alist :key-type symbol
                :value-type (plist :key-type symbol :value-type string))
  :group 'unique-files)

(defcustom unique-files-mode-headers
  '((markdown-mode . unique-files//insert-header-md)
    (org-mode      . unique-files//insert-header-org)
    (js-mode       . unique-files//insert-header-js)
    (js-ts-mode    . unique-files//insert-header-js))
  "Alist mapping major modes to header insertion functions.
Each function receives the timestamp base name as its sole argument."
  :type '(alist :key-type symbol :value-type function)
  :group 'unique-files)

(defcustom unique-files-use-orgalist t
  "If non-nil, prefer `orgalist-mode' for list continuation in text modes.
When `orgalist' is unavailable, fall back to `unique-files-list-continue-mode'."
  :type 'boolean
  :group 'unique-files)

;; Mark variables safe for .dir-locals.el
(dolist (v '(unique-files-mode-targets unique-files-mode-headers))
  (put v 'safe-local-variable #'listp))

(dolist (v '(unique-files-doc-format unique-files-default-dir))
  (put v 'safe-local-variable #'stringp))

;; Enable list continuation behavior
(let* ((hooks '(text-mode-hook markdown-mode-hook gfm-mode-hook))
       (orgalist-ok (and unique-files-use-orgalist (require 'orgalist nil t))))
  (if orgalist-ok
      (progn
        (dolist (h hooks) (add-hook h #'orgalist-mode))
        (with-eval-after-load 'orgalist
          (define-key orgalist-mode-map (kbd "RET")   #'unique-files/orgalist-ret-dwim)
          (define-key orgalist-mode-map (kbd "M-RET") #'orgalist-insert-item)))
    (dolist (h hooks) (add-hook h #'unique-files-list-continue-mode))))

;;; config.el ends here
