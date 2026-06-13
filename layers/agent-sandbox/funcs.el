(defun agent/snapshot-i3-tree ()
  (interactive)
  (make-directory agent-sandbox-artifact-dir t)
  (shell-command
   (format "i3-msg -t get_tree > %s/tree.json && i3-msg -t get_workspaces > %s/workspaces.json"
           (shell-quote-argument agent-sandbox-artifact-dir)
           (shell-quote-argument agent-sandbox-artifact-dir))))

(defun agent/open-workspace ()
  (interactive)
  (dired agent-sandbox-workspace-root))
