;;; packages.el --- err-ts layer packages file for Spacemacs -*- lexical-binding: t; -*-
;;; Commentary:
;; TypeScript/JavaScript tweaks that are not covered by upstream layers.

;;; Code:

(defconst err-ts-packages
  '(lsp-mode typescript-mode prettier-js add-node-modules-path)
  "Packages configured by err-ts.")

(defun err-ts/init-prettier-js ()
  "Register prettier-js for ownership by this layer."
  (use-package prettier-js
    :defer t))

(defun err-ts/init-add-node-modules-path ()
  "Register add-node-modules-path for ownership by this layer."
  (use-package add-node-modules-path
    :defer t))

(defun err-ts/post-init-typescript-mode ()
  "Hook prettier-js and node-modules-path into TS modes."
  (dolist (hook '(typescript-mode-hook typescript-ts-mode-hook))
    (add-hook hook #'prettier-js-mode)
    (add-hook hook #'add-node-modules-path)))

(defun err-ts/post-init-lsp-mode ()
  "Configure lsp-mode TypeScript options."
  (with-eval-after-load 'lsp-mode
    (setq lsp-typescript-update-imports-on-file-move-enabled 'always
          lsp-typescript-validate-enable t)
    (setq lsp-typescript-initialization-options
          `(:tsserver
            (:logDirectory ,(expand-file-name ".lsp-tsserver-logs" user-emacs-directory)
                           :logVerbosity "verbose")))))

;;; packages.el ends here
