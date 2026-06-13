;; -*- mode: emacs-lisp; lexical-binding: t -*-
;;; core/user-env.el --- Environment variable setup  -*- lexical-binding: t -*-
;;; Commentary:
;; This file holds the body of `dotspacemacs/user-env'.
;; Environment variables that should be visible to the Emacs process and to
;; subprocesses (LSP servers, shells, etc.) belong here.

;;; Code:

;; Load the external env file if present (`~/.spacemacs.env' or
;; `~/.spacemacs.d/.spacemacs.env').
(spacemacs/load-spacemacs-env)

;; Pagers must be non-interactive inside Emacs so that LSP / shell / man output
;; is captured correctly.
(setenv "PAGER" "cat")
(setenv "MANPAGER" "cat")

;;; user-env.el ends here
