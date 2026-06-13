;;; tests/helpers.el --- shared test helpers -*- lexical-binding: t; -*-
;;; Commentary:
;; Shared utilities used by the spacemacs.d test suite.

;;; Code:

(require 'cl-lib)

(defmacro with-temp-gitignore (lines &rest body)
  "Create a temp dir with a .gitignore containing LINES, run BODY with
`default-directory' bound to that dir, then clean up."
  (declare (indent 1))
  `(let* ((dir (make-temp-file "spacemacs-test-" t))
          (gi  (expand-file-name ".gitignore" dir))
          (default-directory dir))
     (unwind-protect
         (progn
           (with-temp-file gi
             (insert (mapconcat #'identity ,lines "\n")))
           ,@body)
       (delete-directory dir t))))

(provide 'helpers)
;;; helpers.el ends here
