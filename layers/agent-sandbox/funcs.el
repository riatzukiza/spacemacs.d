;;; funcs.el --- agent-sandbox layer functions -*- lexical-binding: t; -*-
;;; Commentary:
;; Helper functions for the agent i3 sandbox.

;;; Code:

(defun agent/snapshot-i3 ()
  "Snapshot the current i3 tree and workspaces into the artifact directory.
Returns the list of written file paths and signals an error on failure."
  (interactive)
  (make-directory agent-sandbox-artifact-dir t)
  (let* ((ts (format-time-string "%Y%m%d-%H%M%S-%N"))
         (tree-file (expand-file-name (format "tree-%s.json" ts) agent-sandbox-artifact-dir))
         (workspaces-file (expand-file-name (format "workspaces-%s.json" ts) agent-sandbox-artifact-dir))
         (tree-cmd (format "i3-msg -t get_tree > %s" (shell-quote-argument tree-file)))
         (workspaces-cmd (format "i3-msg -t get_workspaces > %s" (shell-quote-argument workspaces-file)))
         (status (shell-command (format "%s && %s" tree-cmd workspaces-cmd))))
    (unless (zerop status)
      (error "agent/snapshot-i3 failed in %s (exit %d)" agent-sandbox-artifact-dir status))
    (message "Wrote %s and %s" tree-file workspaces-file)
    (list tree-file workspaces-file)))

;; Preserve the old name as an alias for backward compatibility.
(defalias 'agent/snapshot-i3-tree 'agent/snapshot-i3)

(defun agent/open-workspace ()
  "Open the agent workspace root in Dired."
  (interactive)
  (dired agent-sandbox-workspace-root))

(defun agent/find-workspace ()
  "Prompt for and open a subdirectory under the agent workspace root."
  (interactive)
  (let ((dir (read-directory-name "Workspace: " agent-sandbox-workspace-root nil t)))
    (dired dir)))

(defun agent/new-vterm-in-project ()
  "Open a new vterm in the current project root or `default-directory'."
  (interactive)
  (let ((default-directory (or (and (fboundp 'projectile-project-root)
                                    (ignore-errors (projectile-project-root)))
                               default-directory
                               (expand-file-name "~"))))
    (if (fboundp 'vterm)
        (vterm (generate-new-buffer-name "*vterm*"))
      (error "vterm is not available; ensure the shell layer is loaded"))))

(defun agent/send-path-to-opencode ()
  "Open a new vterm running opencode on the current file or directory."
  (interactive)
  (let* ((path (or (buffer-file-name) default-directory))
         (default-directory (if (file-directory-p path)
                                path
                              (file-name-directory path))))
    (if (fboundp 'vterm)
        (let ((buf (generate-new-buffer-name "*opencode*")))
          (vterm buf)
          (vterm-send-string (format "opencode %s" (shell-quote-argument path)))
          (vterm-send-return))
      (error "vterm is not available; ensure the shell layer is loaded"))))

;;; funcs.el ends here
