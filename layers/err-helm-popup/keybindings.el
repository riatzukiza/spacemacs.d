;;; keybindings.el --- err-helm-popup keybindings  -*- lexical-binding: t -*-
;;; Commentary:
;; Leader bindings for the Helm popup commands.

;;; Code:

(spacemacs/declare-prefix "o h" "helm-popup")

(spacemacs/set-leader-keys
  "ohf" #'err/helm-popup-find-files
  "ohb" #'err/helm-popup-list-buffers
  "ohr" #'err/helm-popup-recentf
  "ohp" #'err/helm-popup-switch-project)

;;; keybindings.el ends here
