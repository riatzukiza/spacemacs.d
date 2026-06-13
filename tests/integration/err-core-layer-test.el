;;; tests/integration/err-core-layer-test.el --- integration tests
;;; -*- lexical-binding: t; -*-
;;; Commentary:
;; Layer-level contract tests for err-core.  Loads the layer files directly
;; without booting Spacemacs.

;;; Code:

(require 'ert)
(require 'cl-lib)

(defvar test/repo-root
  (locate-dominating-file load-file-name ".git")
  "Absolute path to the repository root.")

(defun test/load-layer-file (layer file)
  "Load FILE from private LAYER directory."
  (load-file (expand-file-name
              (format "layers/%s/%s" layer file)
              test/repo-root)))

(ert-deftest μ/err-core-packages-list-is-bound ()
  "Loading packages.el binds `err-core-packages'."
  (test/load-layer-file "err-core" "packages.el")
  (should (boundp 'err-core-packages))
  (should (listp err-core-packages)))

(ert-deftest μ/err-core-each-owned-package-has-init ()
  "Each package declared in err-core-packages that is not configured by another
layer has a corresponding init function."
  (test/load-layer-file "err-core" "packages.el")
  (dolist (pkg err-core-packages)
    (let ((init-fn (intern (format "err-core/init-%s" pkg)))
          (pre-fn  (intern (format "err-core/pre-init-%s" pkg)))
          (post-fn (intern (format "err-core/post-init-%s" pkg))))
      (unless (or (fboundp pre-fn) (fboundp post-fn))
        (should (fboundp init-fn))))))

(ert-deftest μ/err-core-funcs-provides-its-feature ()
  "funcs.el can be loaded without errors."
  (should-not
   (condition-case err
       (progn (test/load-layer-file "err-core" "funcs.el") nil)
     (error (format "Load error: %S" err)))))

(ert-deftest μ/err-core-config-loads-cleanly ()
  "config.el can be loaded without signaling an error."
  (should-not
   (condition-case err
       (progn (test/load-layer-file "err-core" "config.el") nil)
     (error (format "Load error: %S" err)))))

(provide 'err-core-layer-test)
;;; err-core-layer-test.el ends here
