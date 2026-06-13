;;; packages.el --- semantic-search layer  -*- lexical-binding: t; -*-
;;; Commentary:
;; Semantic (embeddings) search with sem.el plus consult fallbacks.

;;; Code:

(defconst semantic-search-packages
  '((sem :location (recipe :fetcher github :repo "lepisma/sem.el"))
    consult
    (consult-omni :location (recipe :fetcher github :repo "armindarvish/consult-omni"))
    f
    s)
  "Packages configured by semantic-search.")

(defun semantic-search--project-root ()
  "Return the current project root or `default-directory'."
  (or (when (fboundp 'project-current)
        (when-let* ((p (project-current nil)))
          (project-root p)))
      default-directory))

(defun semantic-search-index-project (&optional dir)
  "Index DIR (or current project) with sem.el."
  (interactive)
  (let* ((root (or dir (semantic-search--project-root))))
    (unless root (user-error "No project root; give a dir"))
    (message "[sem] indexing %s ..." root)
    (call-interactively #'sem-index)))

(defun semantic-search-query (query)
  "Semantic search using sem.el (prompt for QUERY)."
  (interactive "sQuery: ")
  (sem-search query))

(defun semantic-search-query-at-point ()
  "Semantic search using symbol/region at point."
  (interactive)
  (let* ((q (if (use-region-p)
                (buffer-substring-no-properties (region-beginning) (region-end))
              (thing-at-point 'symbol t))))
    (unless (and q (string-match-p "[^ \t\n]" q))
      (user-error "No symbol/region to query"))
    (sem-search q)))

(defun semantic-search-ripgrep-project (&optional dir)
  "Fast fallback lexical search in project (rg)."
  (interactive)
  (let* ((root (or dir (semantic-search--project-root))))
    (consult-ripgrep root)))

(defun semantic-search/init-sem ()
  "Initialize sem and bind semantic search commands."
  (use-package sem
    :commands (sem-index sem-search)
    :init
    (spacemacs/declare-prefix "os" "semantic-search")
    (spacemacs/set-leader-keys
      "osi" #'semantic-search-index-project
      "oss" #'semantic-search-query
      "osS" #'semantic-search-query-at-point)))

(defun semantic-search/init-consult ()
  "Initialize consult and bind ripgrep fallback."
  (use-package consult
    :commands (consult-ripgrep consult-line)
    :init
    (spacemacs/declare-prefix "og" "grep/search")
    (spacemacs/set-leader-keys
      "ogr" #'semantic-search-ripgrep-project
      "ogl" #'consult-line)))

(defun semantic-search/init-consult-omni ()
  "Initialize consult-omni."
  (use-package consult-omni
    :commands (consult-omni)
    :init
    (spacemacs/declare-prefix "oo" "omni")
    (spacemacs/set-leader-keys
      "ooo" #'consult-omni)))

(defun semantic-search/init-f ()
  "Initialize f.el helper library."
  (use-package f :defer t))

(defun semantic-search/init-s ()
  "Initialize s.el helper library."
  (use-package s :defer t))

;;; packages.el ends here
