;;; packages.el --- agent-sandbox layer packages -*- lexical-binding: t; -*-
;;; Commentary:
;; Package wiring for the agent-sandbox layer.
;; This layer relies on packages provided by its declared dependencies
;; (emacs-lisp, shell, docker) and does not own additional packages.

;;; Code:

(defconst agent-sandbox-packages
  '()
  "Packages required by the agent-sandbox layer.")

;;; packages.el ends here
