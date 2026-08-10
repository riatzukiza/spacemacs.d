;; -*- mode: emacs-lisp; lexical-binding: t -*-
;;; config/rofi-bridge.el --- Rofi -> emacsclient bridge helpers  -*- lexical-binding: t; -*-
;;; Commentary:
;; Candidate generators and dispatch helpers for the wm-go rofi bridge.
;; Loaded by `dotspacemacs/user-config'.

;;; Code:

(defun my/read-dir-context ()
  "Return a context directory following the current-context rule.
Precedence: current projectile project root, current buffer's directory,
`default-directory', then an interactive prompt when no automatic context
is available.  When called non-interactively, falls back to ~ instead of
prompting so i3 keybindings do not hang."
  (let* ((project-root (and (fboundp 'projectile-project-root)
                            (ignore-errors (projectile-project-root))))
         (buffer-dir (and (buffer-file-name)
                          (file-name-directory (buffer-file-name))))
         (candidates (delete-dups
                      (delq nil (list project-root
                                      buffer-dir
                                      (and default-directory
                                           (not (string= default-directory "~/"))
                                           default-directory)
                                      "~/"))))
         (auto (or project-root
                   buffer-dir
                   (and default-directory
                        (not (string= default-directory "~/"))
                        default-directory))))
    (expand-file-name
     (or auto
         (and (called-interactively-p 'interactive)
              (completing-read "Context: " candidates nil t nil nil "~/"))
         "~/"))))

(defun my/rofi-lines (mode)
  "Return newline-separated rofi candidates for MODE.
MODE is one of: files, buffers, projects, workspaces, agents."
  (cl-case (intern (if (symbolp mode) (symbol-name mode) mode))
    (files
     (string-join
      (mapcar (lambda (f) (format "file:%s" f))
              (seq-take recentf-list 200))
      "\n"))
    (buffers
     (string-join
      (mapcar (lambda (b) (format "buffer:%s" (buffer-name b)))
              (seq-filter #'buffer-file-name (buffer-list)))
      "\n"))
    (projects
     (string-join
      (mapcar (lambda (p) (format "project:%s" p))
              (when (fboundp 'projectile-relevant-known-projects)
                (projectile-relevant-known-projects)))
      "\n"))
    (workspaces
     (string-join
      (mapcar (lambda (w) (format "workspace:%s" w))
              (when (fboundp 'eyebrowse--get)
                (mapcar (lambda (s) (format "%s" (car s)))
                        (eyebrowse--get 'window-configs))))
      "\n"))
    (agents
     (string-join
      '("agent:core" "agent:spacemacs" "agent:dev")
      "\n"))
    (otherwise "")))

(defun my/new-vterm-dispatch ()
  "Open a new vterm in the current context directory."
  (interactive)
  (let ((default-directory (my/read-dir-context)))
    (if (fboundp 'vterm)
        (vterm (generate-new-buffer-name "*vterm*"))
      (error "vterm is not available"))))

(defun my/new-eshell-dispatch ()
  "Open a new eshell in the current context directory."
  (interactive)
  (let ((default-directory (my/read-dir-context)))
    (eshell t)))

(defun my/rofi-dispatch (choice)
  "Act on a rofi CHOICE string with a soft prefix."
  (when (and choice (not (string-empty-p choice)))
    (cond
     ((string-prefix-p "file:" choice)
      (find-file (substring choice (length "file:"))))
     ((string-prefix-p "recent:" choice)
      (find-file (substring choice (length "recent:"))))
     ((string-prefix-p "buffer:" choice)
      (switch-to-buffer (substring choice (length "buffer:"))))
     ((string-prefix-p "project:" choice)
      (if (fboundp 'projectile-switch-project-by-name)
          (projectile-switch-project-by-name (substring choice (length "project:")))
        (error "Projectile is not available")))
     ((string-prefix-p "workspace:" choice)
      (let ((name (substring choice (length "workspace:"))))
        (if (fboundp 'eyebrowse-switch-to-window-config)
            (eyebrowse-switch-to-window-config (string-to-number name))
          (error "Eyebrowse is not available"))))
     ((string-prefix-p "agent:" choice)
      (let ((target (substring choice (length "agent:"))))
        (message "Launch agent target: %s" target)))
     ((string-prefix-p "cmd:" choice)
      (cl-case (intern (substring choice (length "cmd:")))
        (new-vterm (my/new-vterm-dispatch))
        (new-eshell (my/new-eshell-dispatch))
        (otherwise (message "Unknown command: %s" choice))))
     (t (message "Unhandled rofi choice: %s" choice)))))

;;; rofi-bridge.el ends here
