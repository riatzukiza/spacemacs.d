;;; keybindings.el --- unique-files keys -*- lexical-binding: t; -*-
;;; Commentary:
;; Spacemacs leader bindings for unique-files.

;;; Code:

(spacemacs/declare-prefix "n u" "unique")

(spacemacs/set-leader-keys
  "nuu" #'unique-files/open-like-this-buffer
  "nuE" #'unique-files/open-with-extension
  "num" #'unique-files/open-markdown
  "nuo" #'unique-files/open-org
  "nut" #'unique-files/open-text
  "nuj" #'unique-files/open-js
  "nuM" #'unique-files/open-for-mode
  "nlr" #'unique-files/list-renumber-block)

(spacemacs/declare-prefix "n l" "lists")

;;; keybindings.el ends here
