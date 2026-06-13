;;; packages.el --- err-helm-popup layer  -*- lexical-binding: t -*-
;;; Commentary:
;; Private layer that provides a small floating frame for Helm commands.
;; It depends on the upstream `helm' layer (and projectile, used by some
;; popup commands) but does not own any packages itself.

;;; Code:

(defconst err-helm-popup-packages '()
  "This layer does not install any packages; it reuses Helm/Projectile.")

;;; packages.el ends here
