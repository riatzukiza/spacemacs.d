;; -*- mode: emacs-lisp; lexical-binding: t -*-
;;; config/agent-shell.el --- Agent-shell project workflows  -*- lexical-binding: t -*-
;;; Commentary:
;; Workflows that pick a project with the Helm projectile finder and open it
;; as a split layout: dired of the project root on top and a fresh agent-shell
;; below, with the cursor in the agent shell.
;; Loaded by `dotspacemacs/user-config'.

;;; Code:

;; Ensure locally-installed packages (agent-shell, acp, shell-maker) are on
;; `load-path' even when they are not part of `package-selected-packages'.
(require 'package)
(package-initialize t)

(require 'agent-shell)

;; Emacs daemons often run with TERM=dumb, which breaks comint/shell-maker
;; terminal creation for agent-shell. Force a usable terminal type.
(when (member (getenv "TERM") '("dumb" nil))
  (setenv "TERM" "xterm-256color"))

(defconst err/agent-shell-project-frame-name "agent-shell-project"
  "Name for the Emacs frame created by the project + agent-shell workflow.")

(defvar err/agent-shell-project-shell-function #'agent-shell-new-shell
  "Function used to create the agent shell in the project layout.
Called with no arguments and should return the new shell buffer.")

(defconst err/agent-shell-project-frame-params
  `((name . ,err/agent-shell-project-frame-name)
    (display . ,(or (getenv "DISPLAY") ":0"))
    (minibuffer . t)
    (width . 130)
    (height . 45)
    (menu-bar-lines . 0)
    (tool-bar-lines . 0)
    (vertical-scroll-bars . nil)
    (horizontal-scroll-bars . nil))
  "Frame parameters for the dedicated project + agent-shell frame.")

(defun err/agent-shell-project-layout (project-dir &optional new-frame shell-fn)
  "Open PROJECT-DIR with dired on top and a fresh agent shell below.
When NEW-FRAME is non-nil, create a new Emacs frame for the layout.
SHELL-FN is called to create the shell; it defaults to
`err/agent-shell-project-shell-function'.
The agent shell starts in the bottom window and receives keyboard focus."
  (let* ((default-directory project-dir)
         (frame (if new-frame
                    (make-frame err/agent-shell-project-frame-params)
                  (selected-frame)))
         top-window bottom-window shell-buffer)
    (select-frame-set-input-focus frame)
    (delete-other-windows (frame-selected-window frame))
    (setq top-window (frame-selected-window frame))
    (dired project-dir)
    (setq bottom-window (split-window-below
                         (floor (* (window-body-height top-window) 0.6))))
    (select-window bottom-window)
    (setq shell-buffer (funcall (or shell-fn err/agent-shell-project-shell-function)))
    (when (buffer-live-p shell-buffer)
      (unless (get-buffer-window shell-buffer frame)
        (set-window-buffer bottom-window shell-buffer))
      (select-window (get-buffer-window shell-buffer frame)))
    (message "Agent shell project: %s" project-dir)))

(defun err/switch-project-to-agent-shell-here ()
  "Pick a project and open dired + agent shell in the current frame.
Uses `projectile-switch-project', which will use Helm for completion when
Helm is active, but respects `projectile-switch-project-action'."
  (interactive)
  (let ((projectile-switch-project-action
         (lambda ()
           (err/agent-shell-project-layout default-directory nil))))
    (call-interactively #'projectile-switch-project)))

(defun err/switch-project-to-agent-shell-new-frame ()
  "Pick a project and open dired + agent shell in a new frame.
Uses `projectile-switch-project', which will use Helm for completion when
Helm is active, but respects `projectile-switch-project-action'."
  (interactive)
  (let ((projectile-switch-project-action
         (lambda ()
           (err/agent-shell-project-layout default-directory t))))
    (call-interactively #'projectile-switch-project)))

(defun err/helm-popup-switch-project-to-agent-shell ()
  "Pick a project via the floating Helm popup, then open dired + agent shell.
The layout is created in a fresh Emacs frame and the popup is closed."
  (interactive)
  (let* ((frame (make-frame err/helm-popup-frame-params))
         (projectile-switch-project-action
          (lambda ()
            (err/agent-shell-project-layout default-directory t))))
    (set-frame-parameter frame 'frame-title-format err/helm-popup-frame-name)
    (set-frame-parameter frame 'icon-title-format err/helm-popup-frame-name)
    (select-frame-set-input-focus frame)
    (delete-other-windows)
    (unwind-protect
        (let ((helm-full-frame t)
              (helm-display-function #'helm-default-display-buffer)
              (display-buffer-alist nil))
          ;; Use `projectile-switch-project' rather than
          ;; `helm-projectile-switch-project' so our custom
          ;; `projectile-switch-project-action' is honored.
          (call-interactively #'projectile-switch-project))
      (when (frame-live-p frame)
        (delete-frame frame)))))

(spacemacs/declare-prefix "o a" "agent-shell-project")

(spacemacs/set-leader-keys
  "oaa" #'err/switch-project-to-agent-shell-here
  "oaA" #'err/switch-project-to-agent-shell-new-frame
  "oap" #'err/helm-popup-switch-project-to-agent-shell)

;;; agent-shell.el ends here
