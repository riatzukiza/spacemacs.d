---
subject: emacs-launcher
tags: [emacs-launcher, helm, consult, vertico, ivy, rofi, minibuffer-frame]
created: 2026-06-13
---

Yes: if your goal is a **rofi-like** launcher, Helm is probably not the best fit. Helm is excellent at completion, but its normal UI keeps candidates in a separate Helm buffer or frame, while a rofi-style launcher is much easier to build with a minibuffer-native stack such as Consult plus Vertico, or Ivy, because those workflows center the interaction in the minibuffer itself. [reddit](https://www.reddit.com/r/emacs/comments/uqsogq/integrating_the_window_manager_and_emacs/)

## Facts

A real minibuffer-only frame is an Emacs primitive, and people do launch it from a window-manager binding via `emacsclient -e`, then let the WM float that uniquely named frame. [reddit](https://www.reddit.com/r/emacs/comments/s7pei3/using_emacs_as_your_app_launcher_crosspost_from/)
That pattern matches your stated goal much better than stock Helm, because Helm’s standard model separates minibuffer input from the candidate display, whereas Consult is built on `completing-read`, and modern minibuffer packages are explicitly about upgrading that minibuffer interaction layer. [emacs-helm.github](https://emacs-helm.github.io/helm/)

## Interpretation

If you want “looks and behaves like rofi, but opens in Emacs”, the best architecture is usually: Emacs daemon, `emacsclient`, one tiny popup frame, and a minibuffer-native completion UI. [github](https://github.com/muffinmad/emacs-mini-frame)
If you stay with Helm, the clean solution is the floating popup frame from the previous answer, but that is closer to “Helm in a popup” than “rofi implemented in Emacs.” [reddit](https://www.reddit.com/r/emacs/comments/7rho4f/now_you_can_use_helm_with_frames_instead_of/)

## Options

| Path | Fit for your goal | Tradeoff |
|---|---|---|
| Keep Helm in a floating frame | Least migration if your Spacemacs setup is already Helm-centric, but Helm normally uses a separate candidate window/frame rather than a pure minibuffer launcher.  [emacs-helm.github](https://emacs-helm.github.io/helm/) | More WM-popup engineering, less “just a launcher.”  [emacs-helm.github](https://emacs-helm.github.io/helm/) |
| Consult + Vertico in a minibuffer-only or mini-frame popup | Closest to a rofi feel, because Consult is based on `completing-read`, and Consult commands can group/narrow candidates in the minibuffer flow.  [github](https://github.com/minad/consult) | Requires changing part of your completion stack. |
| Ivy in a minibuffer popup | Also viable for a launcher feel, and `ivy-posframe` is explicitly described as giving a rofi/dmenu vibe.  [reddit](https://www.reddit.com/r/emacs/comments/efwlib/shoutout_to_ivyposframe/) | There are historical reports of minibuffer-only-frame issues with Ivy, though workarounds exist.  [github](https://github.com/abo-abo/swiper/issues/380) |
| Keep real Rofi, send result to `emacsclient` | Lowest coupling and probably the simplest mental model. | You lose the “everything is Emacs completion” unification. |

## Spacemacs move

In Spacemacs terms, this belongs in `dotspacemacs/user-config` if you are testing the idea, and it graduates to a private layer only if you want reusable launcher behavior, custom commands, and tighter integration with your editor workflow.  
For your use case, I would start with a tiny launcher command that creates a named minibuffer-only frame and calls a minibuffer-native command, then bind i3 to `emacsclient -e` and float that frame by title. [reddit](https://www.reddit.com/r/emacs/comments/rxa29k/is_it_possible_to_have_a_window_which_is_just_the/)

```elisp
(defun my/launcher-find-file ()
  (interactive)
  (let ((frame (make-frame
                '((name . "emacs-launcher")
                  (title . "emacs-launcher")
                  (minibuffer . only)
                  (width . 100)
                  (height . 1)
                  (undecorated . t)
                  (skip-taskbar . t)))))
    (select-frame-set-input-focus frame)
    (unwind-protect
        (call-interactively #'find-file)
      (when (frame-live-p frame)
        (delete-frame frame)))))
```

```i3
for_window [class="^Emacs$" title="^emacs-launcher$"] floating enable, move position center
bindsym --release $mod+Ctrl+f exec --no-startup-id emacsclient -e '(my/launcher-find-file)'
```

## Recommendation

My recommendation is: do **not** optimize around Helm for this particular launcher problem. Use Helm when you want Helm inside Emacs; use a minibuffer-native stack when you want a rofi analogue, and use actual Rofi plus `emacsclient` when you want the lowest-complexity WM-level launcher. [github](https://github.com/minad/consult)
The sharp first experiment is either “built-in `find-file` in a minibuffer-only frame” or “Consult/Vertico popup launcher”, because both test the core UX without first solving Helm’s extra display model. [youtube](https://www.youtube.com/watch?v=d3aaxOqwHhI)

Would you like the next pass to be a minimal Spacemacs-native Consult/Vertico launcher, or a pure `rofi -> emacsclient` bridge script?
