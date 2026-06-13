;;; layers.el --- err-core layer dependencies -*- lexical-binding: t; -*-
;;; Commentary:
;; Declare upstream layer dependencies for err-core.

;;; Code:

(configuration-layer/declare-layer-dependencies
 '(markdown
   lsp
   syntax-checking
   auto-completion
   git
   org))

;;; layers.el ends here
