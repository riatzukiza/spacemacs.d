;;; keybindings.el --- agent-sandbox layer keybindings -*- lexical-binding: t; -*-
;;; Commentary:
;; Package-independent leader bindings for the agent-sandbox layer.

;;; Code:

(spacemacs/declare-prefix "a" "agent")
(spacemacs/set-leader-keys
  "as" 'agent/snapshot-i3
  "aw" 'agent/open-workspace
  "af" 'agent/find-workspace
  "at" 'agent/new-vterm-in-project
  "ap" 'agent/send-path-to-opencode)

;;; keybindings.el ends here
