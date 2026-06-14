---
subject: emacs-launcher
tags: [emacs-launcher, helm, popup-frame, i3, for_window]
created: 2026-06-13
---

Yes, but the cleanest answer is: make i3 float a specially named Emacs popup frame, not a literal minibuffer-only window. A true minibuffer-only frame exists in Emacs, but Helm normally keeps input in the minibuffer while showing candidates in a separate window or frame, so “just a Helm minibuffer” is not Helm’s normal display model. [github](https://github.com/i3/i3/discussions/5775)

## Architecture

- Fact: in i3, the reliable way to make a launched window float is to match it with `for_window` criteria such as `class`, `instance`, or `title`, then apply commands like `floating enable`, `move position center`, `resize set`, and border changes. [reddit](https://www.reddit.com/r/i3wm/comments/9w64j1/can_i_should_i_use_i3_as_a_floating_window_manager/)
- Fact: i3 keybindings can launch shell commands with `exec --no-startup-id`, and `--release` is useful when you want the command to run after modifiers are released. [reddit](https://www.reddit.com/r/i3wm/comments/9w64j1/can_i_should_i_use_i3_as_a_floating_window_manager/)
- Interpretation: for stock Helm, the practical target is a small dedicated Helm frame that i3 floats, not a one-line minibuffer strip, because Helm’s candidate UI is separate from the minibuffer itself. [reddit](https://www.reddit.com/r/emacs/comments/7rho4f/now_you_can_use_helm_with_frames_instead_of/)

## Emacs Lisp

Put the wrapper in `dotspacemacs/user-config`; this is user behavior layered on top of already-loaded packages, so it belongs after your layers have initialized.

```elisp
(defvar my/helm-popup-frame-params
  '((name . "helm-popup")
    (title . "helm-popup")
    (minibuffer . t)
    (width . 110)
    (height . 18)
    (undecorated . t)
    (skip-taskbar . t)
    (internal-border-width . 12)))

(defun my/helm-popup (cmd)
  (let ((frame (make-frame my/helm-popup-frame-params)))
    (select-frame-set-input-focus frame)
    (delete-other-windows)
    (funcall cmd)))

(defun my/helm-popup-find-files ()
  (interactive)
  (my/helm-popup #'helm-find-files))

(defun my/helm-popup-list-buffers ()
  (interactive)
  (my/helm-popup #'helm-list-buffers))

(defun my/helm-popup-recentf ()
  (interactive)
  (my/helm-popup #'helm-projectile-recentf))

(defun my/helm-popup-switch-project ()
  (interactive)
  (my/helm-popup #'helm-projectile-switch-project))
```

A literal minibuffer-only experiment would start from `(make-frame '((minibuffer . only)))`, but that only gives you the minibuffer frame primitive; it does not solve Helm’s separate candidate display by itself. [reddit](https://www.reddit.com/r/emacs/comments/rxa29k/is_it_possible_to_have_a_window_which_is_just_the/)

## i3 config

The i3 side is just “float any Emacs frame whose title is `helm-popup`,” because `for_window` is designed for exactly that kind of rule. [reddit](https://www.reddit.com/r/i3wm/comments/9w64j1/can_i_should_i_use_i3_as_a_floating_window_manager/)

```i3
for_window [class="^Emacs$" title="^helm-popup$"] \
  floating enable, move position center, resize set 1200 500, border pixel 1

bindsym --release $mod+Ctrl+f exec --no-startup-id emacsclient -e '(my/helm-popup-find-files)'
bindsym --release $mod+Ctrl+b exec --no-startup-id emacsclient -e '(my/helm-popup-list-buffers)'
bindsym --release $mod+Ctrl+r exec --no-startup-id emacsclient -e '(my/helm-popup-recentf)'
bindsym --release $mod+Ctrl+p exec --no-startup-id emacsclient -e '(my/helm-popup-switch-project)'
```

If that rule misses, inspect the popup with `xprop` and tighten the match to the actual `WM_CLASS`, instance, or title that your Emacs frame exports. [reddit](https://www.reddit.com/r/i3wm/comments/9w64j1/can_i_should_i_use_i3_as_a_floating_window_manager/)

## Caveat

This wrapper gives you a floating Helm frame, but the selected file or buffer may open in that popup frame unless you add Helm-specific action routing. That caveat follows from Helm’s frame/window-based UI model, and it is the main reason a true launcher-style minibuffer popup is awkward with stock Helm. [emacs-helm.github](https://emacs-helm.github.io/helm/)

If you want the stricter version, the next step is to hand-roll a popup that uses a minibuffer-only frame plus a different completion frontend, or add Helm-specific code so actions jump back to your previously focused frame. Emacs supports minibuffer-only frames, and child-frame minibuffer packages exist specifically to make minibuffer input appear as a popup. [github](https://github.com/muffinmad/emacs-mini-frame)

Do you want the next pass to be the “open result in the original frame, then auto-close the popup” version?
