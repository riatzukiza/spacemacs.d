;; -*- mode: emacs-lisp; lexical-binding: t -*-
;;; config/ui.el --- UI and startup settings  -*- lexical-binding: t -*-
;;; Commentary:
;; This file is loaded inside `dotspacemacs/init'.
;; It sets the bulk of the dotspacemacs UI / behavior variables that must be
;; configured before layer initialization.

;;; Code:

(setq-default
 dotspacemacs-elpa-timeout 5
 dotspacemacs-gc-cons '(100000000 0.1)
 dotspacemacs-read-process-output-max (* 1024 1024)
 dotspacemacs-use-spacelpa nil

 dotspacemacs-verify-spacelpa-archives t

 dotspacemacs-check-for-update nil

 dotspacemacs-elpa-subdirectory 'emacs-version

 dotspacemacs-editing-style 'vim

 dotspacemacs-startup-buffer-show-version t

 dotspacemacs-startup-banner 'official

 dotspacemacs-startup-banner-scale 'auto

 dotspacemacs-startup-lists '((recents . 5)
                              (projects . 7)
                              (bookmarks . 5)
                              (agenda . 5)
                              (todos . 5)
                              (recents-by-project . (5 . 5)))

 dotspacemacs-startup-buffer-responsive t

 dotspacemacs-show-startup-list-numbers t

 dotspacemacs-startup-buffer-multi-digit-delay 0.4

 dotspacemacs-startup-buffer-show-icons nil

 dotspacemacs-new-empty-buffer-major-mode 'org-mode

 dotspacemacs-scratch-mode 'text-mode

 dotspacemacs-scratch-buffer-persistent t

 dotspacemacs-scratch-buffer-unkillable t

 dotspacemacs-initial-scratch-message "Happy hacking, err!"

 dotspacemacs-themes '(monokai
                       spacemacs-dark
                       spacemacs-light)

 dotspacemacs-mode-line-theme '(spacemacs :separator wave :separator-scale 1.5)

 dotspacemacs-colorize-cursor-according-to-state t

 dotspacemacs-default-font '("Source Code Pro"
                             :size 10.0
                             :weight normal
                             :width normal)

 dotspacemacs-default-icons-font 'all-the-icons

 dotspacemacs-leader-key "SPC"

 dotspacemacs-emacs-command-key "SPC"

 dotspacemacs-ex-command-key ":"

 dotspacemacs-emacs-leader-key "M-m"

 dotspacemacs-major-mode-leader-key ","

 dotspacemacs-major-mode-emacs-leader-key (if window-system "M-<return>" "C-M-m")

 dotspacemacs-distinguish-gui-tab nil

 dotspacemacs-default-layout-name "Default"

 dotspacemacs-display-default-layout nil

 dotspacemacs-auto-resume-layouts nil

 dotspacemacs-auto-generate-layout-names nil

 dotspacemacs-large-file-size 1

 dotspacemacs-auto-save-file-location 'cache

 dotspacemacs-max-rollback-slots 5

 dotspacemacs-enable-paste-transient-state t

 dotspacemacs-which-key-delay 0.4

 dotspacemacs-which-key-position 'bottom

 dotspacemacs-switch-to-buffer-prefers-purpose nil

 dotspacemacs-maximize-window-keep-side-windows t

 dotspacemacs-enable-load-hints nil

 dotspacemacs-enable-package-quickstart nil

 dotspacemacs-loading-progress-bar t

 dotspacemacs-fullscreen-at-startup nil

 dotspacemacs-fullscreen-use-non-native nil

 dotspacemacs-maximized-at-startup t

 dotspacemacs-undecorated-at-startup nil

 dotspacemacs-active-transparency 80

 dotspacemacs-inactive-transparency 65

 dotspacemacs-background-transparency 60

 dotspacemacs-show-transient-state-title t

 dotspacemacs-show-transient-state-color-guide t

 dotspacemacs-mode-line-unicode-symbols t

 dotspacemacs-smooth-scrolling t

 dotspacemacs-scroll-bar-while-scrolling t

 dotspacemacs-line-numbers 'relative

 dotspacemacs-folding-method 'evil

 dotspacemacs-smartparens-strict-mode nil

 dotspacemacs-activate-smartparens-mode t

 dotspacemacs-smart-closing-parenthesis nil

 dotspacemacs-highlight-delimiters 'all

 dotspacemacs-enable-server nil

 dotspacemacs-server-socket-dir nil

 dotspacemacs-persistent-server nil

 dotspacemacs-search-tools '("rg" "grep")

 dotspacemacs-undo-system 'undo-fu

 ;; Frame/icon title is overridden dynamically in config/frame-title.el.
 dotspacemacs-frame-title-format nil
 dotspacemacs-icon-title-format nil

 dotspacemacs-show-trailing-whitespace t

 dotspacemacs-whitespace-cleanup 'trailing

 dotspacemacs-use-clean-aindent-mode t

 dotspacemacs-use-SPC-as-y nil

 dotspacemacs-swap-number-row nil

 dotspacemacs-zone-out-when-idle nil

 dotspacemacs-pretty-docs nil

 dotspacemacs-home-shorten-agenda-source nil

 dotspacemacs-byte-compile nil)

;;; ui.el ends here
