;;; config.el --- agent-sandbox layer variables -*- lexical-binding: t; -*-
;;; Commentary:
;; Configuration variables for the agent-sandbox layer.

;;; Code:

(defvar agent-sandbox-daemon-name (or (getenv "EMACS_DAEMON_NAME") "agent-core")
  "Name of the Emacs daemon used by this agent sandbox.
Defaults to the EMACS_DAEMON_NAME environment variable or \"agent-core\".")

(defvar agent-sandbox-artifact-dir "/workspace/.artifacts/i3"
  "Directory where i3 artifacts are written.")

(defvar agent-sandbox-workspace-root "/workspace"
  "Root directory of the mounted workspace.")

;;; config.el ends here
