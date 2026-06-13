;;; tests/coverage-report.el --- coverage-instrumented test runner
;;; -*- lexical-binding: t; -*-
;;; Commentary:
;; Wraps the same test suite with `undercover.el' to produce an lcov report.

;;; Code:

(require 'ert)

(defvar test/root
  (file-name-directory (or load-file-name buffer-file-name))
  "Directory containing this runner.")

;; undercover must be installed before this file is loaded.
(require 'undercover)

(undercover "layers/err-core/funcs.el"
            "layers/err-core/config.el"
            "layers/err-core/packages.el"
            (:report-format 'lcov)
            (:send-report nil)
            (:report-file "coverage/lcov.info"))

(defun test/load (relative-path)
  "Load RELATIVE-PATH under `test/root'."
  (load-file (expand-file-name relative-path test/root)))

(test/load "helpers.el")
(test/load "unit/err-core-funcs-test.el")
(test/load "integration/err-core-layer-test.el")

(ert-run-tests-batch-and-exit)
;;; coverage-report.el ends here
