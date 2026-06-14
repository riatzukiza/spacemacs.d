;;; layers.el --- agent-sandbox layer dependencies -*- lexical-binding: t; -*-
;;; Commentary:
;; Declare upstream layer dependencies for agent-sandbox.

;;; Code:

(configuration-layer/declare-layer-dependencies
 '(emacs-lisp
   shell
   docker))

;;; layers.el ends here
