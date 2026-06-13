;; -*- mode: emacs-lisp; lexical-binding: t -*-
;;; core/layers.el --- Spacemacs layer configuration  -*- lexical-binding: t -*-
;;; Commentary:
;; This file holds the body of `dotspacemacs/layers'.
;; It is loaded by `~/.spacemacs.d/init.el'.

;;; Code:

(setq-default
 dotspacemacs-distribution 'spacemacs

 dotspacemacs-enable-lazy-installation 'unused

 dotspacemacs-ask-for-lazy-installation t

 dotspacemacs-configuration-layer-path '("~/.spacemacs.d/layers/")

 dotspacemacs-configuration-layers
 '(
   ;; Languages / frameworks
   purescript
   aider
   ;; direnv
   openai
   latex
   sql
   nginx
   pandoc
   (clojure :variables
            clojure-enable-fancify-symbols t
            clojure-enable-linters t)
   vimscript
   systemd
   react
   python
   common-lisp
   (typescript :variables
               typescript-linter 'eslint
               typescript-fmt-on-save t
               typescript-fmt-tool 'prettier
               node-add-modules-path t)
   (javascript :variables
               javascript-fmt-tool 'prettier
               node-add-modules-path t)
   opencode-agent-shell
   html
   toml
   yaml

   ;; Spacemacs essentials
   auto-completion
   (better-defaults :variables relative-line-numbers t)
   emacs-lisp
   git
   helm
   lsp
   markdown
   multiple-cursors
   org
   github-copilot

   ;; Private layers
   unique-files
   err-helm-popup

   (shell :variables
          shell-default-height 30
          shell-default-position 'bottom
          shell-default-shell 'vterm)
   spell-checking
   syntax-checking
   version-control
   (llm-client :variables llm-client-enable-ellama t
               llm-client-enable-gptel t)

   treemacs

   llm
   codex

   promethean
   promethean-lisp
   err-core
   err-ts
   err-commonlisp
   )

 dotspacemacs-additional-packages '(yasnippet-snippets prettier-js lsp-sonarlint obsidian)
 dotspacemacs-frozen-packages '()
 dotspacemacs-excluded-packages '()

 dotspacemacs-install-packages 'used-only)

;;; layers.el ends here
