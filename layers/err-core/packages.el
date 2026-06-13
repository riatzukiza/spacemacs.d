;;; packages.el --- err-core layer packages file for Spacemacs -*- lexical-binding: t; -*-
;;; Commentary:
;; err-core package registrations and post-init hooks.

;;; Code:

(defconst err-core-packages
  '(lsp-sonarlint
    lsp-mode
    markdown-mode
    org
    flycheck
    treesit-auto
    company)
  "Packages configured by err-core.")

(defun err-core/post-init-lsp-sonarlint ()
  "Configure lsp-sonarlint when loaded."
  (with-eval-after-load 'lsp-sonarlint
    (setq lsp-sonarlint-auto-download t)
    (setq lsp-sonarlint-enabled-analyzers '("js" "ts" "yaml" "json" "javascript" "typescript"))))

(defun err-core/post-init-lsp-mode ()
  "Configure lsp-mode defaults and TS/JS language IDs."
  (with-eval-after-load 'lsp-mode
    (setq lsp-log-io nil
          lsp-idle-delay 0.5
          lsp-response-timeout 30
          lsp-file-watch-threshold 1500)

    (setq lsp-file-watch-ignored
          (append lsp-file-watch-ignored
                  '("[/\\\\]\\.git$" "[/\\\\]node_modules$" "[/\\\\]dist$"
                    "[/\\\\]build$" "[/\\\\]\\.next$" "[/\\\\]\\.turbo$")))

    (add-hook 'lsp-before-initialize-hook #'promethean-lsp-load-gitignore-ignores)

    (add-to-list 'lsp-language-id-configuration '(typescript-ts-mode . "typescript"))
    (add-to-list 'lsp-language-id-configuration '(tsx-ts-mode         . "typescriptreact"))
    (add-to-list 'lsp-language-id-configuration '(js-ts-mode          . "javascript"))

    (setq lsp-clients-typescript-server "typescript-language-server")
    (setq lsp-diagnostics-provider :flycheck)
    (add-hook 'lsp-mode-hook 'flycheck-mode)

    (setq lsp-eslint-enable t
          lsp-eslint-validate '("javascript" "javascriptreact" "typescript" "typescriptreact")
          lsp-eslint-working-directories ["auto"]
          lsp-eslint-auto-fix-on-save t
          lsp-eslint-format nil)

    (setq lsp-sonarlint-enabled-analyzers '("javascript" "typescript" "json" "ts" "js")
          lsp-sonarlint-auto-download t
          lsp-sonarlint-verbose-logs t
          lsp-sonarlint-show-analyzer-logs t)

    (add-hook 'typescript-ts-mode-hook #'lsp-deferred)
    (add-hook 'tsx-ts-mode-hook #'lsp-deferred)
    (add-hook 'js-ts-mode-hook #'lsp-deferred)
    (add-hook 'json-ts-mode-hook #'lsp-deferred)
    (add-hook 'css-ts-mode-hook #'lsp-deferred)))

(defun err-core/post-init-markdown-mode ()
  "Configure markdown-mode code block fontification."
  (with-eval-after-load 'markdown-mode
    (setq markdown-fontify-code-blocks-natively t)
    (dolist (pair '(("ts" . typescript-ts-mode)
                    ("bb" . clojure-ts-mode)
                    ("babashka" . clojure-ts-mode)
                    ("clj" . clojure-ts-mode)
                    ("cljs" . clojure-ts-mode)
                    ("edn" . clojure-ts-mode)
                    ("el" . elisp-mode)))
      (add-to-list 'markdown-code-lang-modes pair))))

(defun err-core/post-init-org ()
  "Configure Org Babel and inline images."
  (with-eval-after-load 'org
    (org-babel-do-load-languages 'org-babel-load-languages '((python . t)))
    (setq org-src-fontify-natively t
          org-src-tab-acts-natively t
          org-edit-src-content-indentation 0
          org-confirm-babel-evaluate (lambda (lang _)
                                       (not (member lang '("emacs-lisp" "python"))))
          org-startup-with-inline-images t
          org-babel-python-command (or (executable-find "python3") "python3"))
    (add-hook 'org-babel-after-execute-hook #'org-display-inline-images)))

(defun err-core/post-init-company ()
  "Enable company globally once loaded."
  (with-eval-after-load 'company
    (global-company-mode 1)))

(defun err-core/post-init-flycheck ()
  "Enable Flycheck globally once loaded."
  (with-eval-after-load 'flycheck
    (add-hook 'after-init-hook #'global-flycheck-mode)
    (global-flycheck-mode 1)))

(defun err-core/init-treesit-auto ()
  "Install and configure treesit-auto, plus major-mode remapping."
  (use-package treesit-auto
    :custom
    (treesit-auto-install 'prompt)
    :config
    (treesit-auto-add-to-auto-mode-alist 'all)
    (global-treesit-auto-mode))
  (setq major-mode-remap-alist
        '((js-mode . js-ts-mode)
          (typescript-mode . typescript-ts-mode)
          (tsx-ts-mode . tsx-ts-mode)
          (json-mode . json-ts-mode)
          (css-mode . css-ts-mode)
          (c-mode . c-ts-mode)
          (c++-mode . c++-ts-mode)
          (python-mode . python-ts-mode)
          (yaml-mode . yaml-ts-mode))))

;;; packages.el ends here
