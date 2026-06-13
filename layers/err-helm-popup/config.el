;;; config.el --- err-helm-popup frame parameters  -*- lexical-binding: t -*-
;;; Commentary:
;; Frame parameters for the floating Helm popup.

;;; Code:

(defconst err-helm-popup-frame-name "helm-popup"
  "Name used for the Helm popup frame.")

(defconst err-helm-popup-frame-params
  `((name . ,err-helm-popup-frame-name)
    (minibuffer . t)
    (width . 110)
    (height . 18)
    (undecorated . t)
    (skip-taskbar . t)
    (internal-border-width . 12)
    (menu-bar-lines . 0)
    (tool-bar-lines . 0)
    (vertical-scroll-bars . nil)
    (horizontal-scroll-bars . nil))
  "Default frame parameters for the Helm popup frame.")

;;; config.el ends here
