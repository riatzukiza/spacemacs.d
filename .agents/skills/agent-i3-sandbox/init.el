(setq inhibit-startup-screen t
      initial-scratch-message nil
      make-backup-files nil
      auto-save-default nil)

(require 'server)
(setq server-name (or (getenv "EMACS_DAEMON_NAME") "agent-core"))
(unless (server-running-p server-name)
  (server-start))

(defun agent/open-workspace ()
  (interactive)
  (dired "/workspace"))
