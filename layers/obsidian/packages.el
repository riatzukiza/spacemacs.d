;;; packages.el --- obsidian layer packages file for Spacemacs -*- lexical-binding: t; -*-
;;; Commentary:
;; Obsidian vault integration for markdown buffers.

;;; Code:

(defconst obsidian-packages '(obsidian)
  "Package required by the obsidian layer.")

(defcustom obsidian-directory (expand-file-name "~/vaults/main")
  "Root directory of the Obsidian vault."
  :type 'directory
  :group 'obsidian)

(defun obsidian/init-obsidian ()
  "Initialize obsidian-mode only inside `obsidian-directory'."
  (use-package obsidian
    :commands (obsidian-mode)
    :init
    (setq obsidian-directory obsidian-directory
          obsidian-daily-notes-directory "daily"
          obsidian-inbox-directory "inbox"
          obsidian-page-title-format "%s")
    (add-hook 'markdown-mode-hook #'obsidian/enable-maybe)
    :config
    (spacemacs/declare-prefix-for-mode 'markdown-mode "mo" "obsidian")
    (spacemacs/set-leader-keys-for-major-mode 'markdown-mode
      "oi" #'obsidian-insert-wikilink
      "of" #'obsidian-follow-link-at-point
      "ob" #'obsidian-backlink-jump
      "on" #'obsidian-daily-note
      "ot" #'obsidian-tag-insert
      "os" #'obsidian-search)))

(defun obsidian/enable-maybe ()
  "Enable `obsidian-mode' only when the file is inside `obsidian-directory'."
  (when (and buffer-file-name
             obsidian-directory
             (string-prefix-p (expand-file-name obsidian-directory)
                              (expand-file-name buffer-file-name)))
    (obsidian-mode 1)))

;;; packages.el ends here
