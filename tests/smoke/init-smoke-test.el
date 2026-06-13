;;; tests/smoke/init-smoke-test.el --- smoke tests for init.el shape
;;; -*- lexical-binding: t; -*-
;;; Commentary:
;; Basic startup invariants for the split init.el entrypoint.

;;; Code:

(require 'ert)

(defvar test/repo-root
  (locate-dominating-file load-file-name ".git")
  "Absolute path to the repository root.")

(ert-deftest μ/smoke-init-el-is-parseable ()
  "init.el can be read without a parse error."
  (let ((path (expand-file-name "init.el" test/repo-root)))
    (should (file-readable-p path))
    (with-temp-buffer
      (insert-file-contents path)
      (should
       (condition-case _
           (progn
             (while (condition-case nil
                        (progn (read (current-buffer)) t)
                      (end-of-file nil)))
             t)
         (error nil))))))

(ert-deftest μ/smoke-dotspacemacs-functions-defined ()
  "After loading init.el, the critical dotspacemacs functions are fboundp."
  (let ((path (expand-file-name "init.el" test/repo-root)))
    (unless (fboundp 'dotspacemacs/layers)
      (load-file path)))
  (should (fboundp 'dotspacemacs/layers))
  (should (fboundp 'dotspacemacs/user-init))
  (should (fboundp 'dotspacemacs/user-config)))

(provide 'init-smoke-test)
;;; init-smoke-test.el ends here
