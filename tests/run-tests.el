;;; tests/run-tests.el --- batch ERT runner -*- lexical-binding: t; -*-
;;; Commentary:
;; Loads all test files and runs them in batch mode.

;;; Code:

(require 'ert)

(defvar test/root
  (file-name-directory (or load-file-name buffer-file-name))
  "Directory containing this runner.")

(defun test/load (relative-path)
  "Load RELATIVE-PATH under `test/root'."
  (load-file (expand-file-name relative-path test/root)))

(test/load "helpers.el")
(test/load "unit/err-core-funcs-test.el")
(test/load "integration/err-core-layer-test.el")
(test/load "smoke/init-smoke-test.el")

(ert-run-tests-batch-and-exit)
;;; run-tests.el ends here
