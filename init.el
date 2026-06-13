;; -*- mode: emacs-lisp; lexical-binding: t -*-
;; This file is loaded by Spacemacs at startup.
;; It must be stored in your home directory.

(defun dotspacemacs/layers ()
  "Layer configuration.
This function should only modify configuration layer settings."
  (load (expand-file-name "core/layers.el" dotspacemacs-directory)))

(defun dotspacemacs/init ()
  "Initialization.
This function is called at the very beginning of Spacemacs startup,
before layer configuration."
  (load (expand-file-name "config/ui.el" dotspacemacs-directory)))

(defun dotspacemacs/user-env ()
  "Environment variables setup.
This function defines the environment variables for your Emacs session."
  (load (expand-file-name "core/user-env.el" dotspacemacs-directory)))

(defun dotspacemacs/user-init ()
  "Initialization for user code.
This function is called immediately after `dotspacemacs/init', before layer
configuration."
  (load (expand-file-name "core/user-init.el" dotspacemacs-directory)))

(defun dotspacemacs/user-config ()
  "Configuration for user code.
This function is called at the very end of Spacemacs startup, after layer
configuration."
  (load (expand-file-name "config/lsp.el" dotspacemacs-directory))
  (load (expand-file-name "config/frame-title.el" dotspacemacs-directory)))


;; Do not write anything past this comment. This is where Emacs will
;; auto-generate custom variable definitions.
(defun dotspacemacs/emacs-custom-settings ()
  "Emacs custom settings.
This is an auto-generated function, do not modify its content directly, use
Emacs customize menu instead.
This function is called at the very end of Spacemacs initialization."
  (custom-set-variables
   ;; custom-set-variables was added by Custom.
   ;; If you edit it by hand, you could mess it up, so be careful.
   ;; Your init file should contain only one such instance.
   ;; If there is more than one, they won't work right.
   '(package-selected-packages
     '(a ace-link acp add-node-modules-path agent-shell aggressive-indent aio alert
         all-the-icons auctex auto-compile auto-highlight-symbol auto-yasnippet
         avy-jump-helm-line browse-at-remote centered-cursor-mode cider
         cider-eval-sexp-fu clean-aindent-mode clojure-mode clojure-snippets
         closql code-cells code-review column-enforce-mode company company-web
         consult consult-lsp consult-omni copilot copilot-chat cython-mode
         dactyl-mode deferred define-word devdocs diff-hl diminish
         dired-quick-sort direnv disable-mouse dotenv-mode drag-stuff dumb-jump
         eat edit-indirect elgrep elisp-def elisp-demos elisp-slime-nav ellama
         emacsql emmet-mode emojify emr esh-help eshell-prompt-extras eshell-z
         eval-sexp-fu evil-anzu evil-args evil-cleverparens evil-collection
         evil-easymotion evil-escape evil-evilified-state evil-exchange
         evil-goggles evil-iedit-state evil-indent-plus evil-lion evil-lisp-state
         evil-matchit evil-mc evil-nerd-commenter evil-numbers evil-org
         evil-surround evil-textobj-line evil-tutor evil-unimpaired
         evil-visual-mark-mode evil-visualstar expand-region eyebrowse
         fancy-battery flycheck flycheck-elsa flycheck-package flycheck-pos-tip
         flyspell-correct flyspell-correct-helm forge gh-md ghub git-link
         git-messenger git-modes git-timemachine gitignore-templates gntp gnuplot
         golden-ratio google-translate gptel gptel-mcp gptel-quick haml-mode
         helm-ag helm-c-yasnippet helm-cider helm-comint helm-company
         helm-css-scss helm-descbinds helm-git-grep helm-ls-git helm-lsp helm-make
         helm-mode-manager helm-org helm-org-rifle helm-projectile helm-purpose
         helm-pydoc helm-swoop helm-themes helm-xref hide-comnt
         highlight-indentation highlight-numbers highlight-parentheses hl-todo
         holy-mode htmlize hungry-delete hybrid-mode impatient-mode indent-guide
         info+ inheritenv inspector journalctl-mode json-mode json-navigator
         json-reformat json-snatcher link-hint live-py-mode llama llm
         load-env-vars log4e lorem-ipsum lsp-eslint lsp-mode lsp-origami
         lsp-sonarlint lsp-treemacs lsp-ui macrostep magit magit-section
         markdown-mode markdown-toc mcp monokai-theme multi-line multi-term
         multi-vterm mwim nameless nginx-mode obsidian open-junk-file
         org-category-capture org-cliplink org-contrib org-download org-mime
         org-pomodoro org-present org-project-capture org-projectile org-rich-yank
         org-superstar orgit orgit-forge origami overseer package-lint
         page-break-lines paradox parseclj parseedn password-generator pcre2el
         persistent-scratch pip-requirements pipenv pippel plz plz-event-source
         plz-media-type poetry polymode popwin pos-tip psc-ide psci pug-mode
         purescript-mode py-isort pydoc pyenv-mode pylookup pytest python-pytest
         pythonic pyvenv queue quickrun rainbow-delimiters request restart-emacs
         rjsx-mode sass-mode scss-mode sem sesman shell-maker shell-pop slim-mode
         smeargle space-doc spaceline spacemacs-purpose-popwin
         spacemacs-whitespace-cleanup sphinx-doc sql-indent sqlup-mode
         string-edit-at-point string-inflection symbol-overlay symon systemd
         tagedit term-cursor terminal-here texfrag toc-org toml-mode transient
         treemacs-evil treemacs-icons-dired treemacs-magit treemacs-persp
         treemacs-projectile treepy treesit-auto undo-fu undo-fu-session unfill
         unkillable-scratch uuidgen vi-tilde-fringe vimrc-mode volatile-highlights
         vterm vundo web-beautify web-completion-data web-mode wgrep winum
         with-editor writeroom-mode ws-butler yaml yaml-mode yasnippet
         yasnippet-snippets))
   '(package-vc-selected-packages
     '((agent-shell :url "https://github.com/xenodium/agent-shell")))
   '(safe-local-variable-values
     '((prom/unique-mode-targets (markdown-mode :dir "docs/inbox" :ext ".md")
                                 (org-mode :dir "docs/inbox" :ext ".org")
                                 (text-mode :dir "docs/text" :ext ".txt")
                                 (js-mode :dir "pseudo/inbox" :ext ".js")
                                 (typescript-ts-mode :dir "pseudo/inbox" :ext
                                                     ".ts"))
       (prom/unique-default-dir . "docs/unique")
       (prom/unique-doc-format . "%Y.%m.%d.%H.%M.%S")
       (eval promethean-lsp-append-gitignore-to-ignored-dirs)
       (typescript-backend . tide) (typescript-backend . lsp)
       (javascript-backend . tide) (javascript-backend . tern)
       (javascript-backend . lsp))))
  (custom-set-faces
   ;; custom-set-faces was added by Custom.
   ;; If you edit it by hand, you could mess it up, so be careful.
   ;; Your init file should contain only one such instance.
   ;; If there is more than one, they won't work right.
   )
  )
