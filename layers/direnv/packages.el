;;; packages.el --- direnv layer packages file for Spacemacs -*- lexical-binding: t; -*-
;;; Commentary:
;; Uses `envrc' to integrate direnv into Emacs.

;;; Code:

(defconst direnv-packages '(envrc)
  "Package required by the direnv layer.")

(defun direnv/init-envrc ()
  "Initialize envrc (direnv integration for Emacs)."
  (use-package envrc
    :defer t
    :config
    (envrc-global-mode 1)))

;;; packages.el ends here
