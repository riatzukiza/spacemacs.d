;;; funcs.el --- promethean-lisp helpers -*- lexical-binding: t; -*-
;;; Commentary:
;; Helpers for the promethean-lisp layer.

;;; Code:

(defface promethean-lisp-regex-test-face
  '((t :underline t :background "#333344"))
  "Face used to highlight regex test matches temporarily.")

(defun promethean-lisp--highlight-matches (re)
  "Highlight all matches of RE in the current buffer for ~1 second."
  (save-excursion
    (let ((ovs nil))
      (goto-char (point-min))
      (while (re-search-forward re nil t)
        (let ((ov (make-overlay (match-beginning 0) (match-end 0))))
          (overlay-put ov 'face 'promethean-lisp-regex-test-face)
          (push ov ovs)))
      (run-with-timer 1.0 nil (lambda (xs) (mapc #'delete-overlay xs)) ovs)
      (message "Promethean Lisp: highlighted %d matches for %S" (length ovs) re))))

(defun promethean-lisp-regex-test-keywords ()
  "Flash matches for the keyword regex."
  (interactive)
  (promethean-lisp--highlight-matches promethean--re-keywords))

(defun promethean-lisp-regex-test-builtins ()
  "Flash matches for the builtin regex."
  (interactive)
  (promethean-lisp--highlight-matches promethean--re-builtins))

(defun promethean-lisp-regex-test-const ()
  "Flash matches for the constants regex."
  (interactive)
  (promethean-lisp--highlight-matches promethean--re-const))

(defun promethean-lisp-regex-test-number ()
  "Flash matches for the number regex."
  (interactive)
  (promethean-lisp--highlight-matches promethean--re-number))

(defun promethean-lisp-regex-test-def-name ()
  "Flash matches for the definition-head regex."
  (interactive)
  (promethean-lisp--highlight-matches promethean--re-def-name))

(defun promethean-lisp-format-buffer ()
  "Indent the current Promethean buffer."
  (interactive)
  (indent-region (point-min) (point-max))
  (message "Promethean Lisp: buffer indented"))

(defun promethean-lisp-open-repl ()
  "Open IELM as a placeholder REPL for Promethean interaction."
  (interactive)
  (ielm)
  (message "Promethean Lisp: IELM opened (placeholder REPL)"))

(require 'ert)

(ert-deftest promethean-regex-tests ()
  "Sanity checks for Promethean regexes."
  (should (string-match-p promethean--re-keywords " (def x)"))
  (should-not (string-match-p promethean--re-keywords " (definitely x)"))
  (should (string-match-p promethean--re-builtins " (+ x 1)"))
  (should-not (string-match-p promethean--re-builtins " (++ x)"))
  (should (string-match-p promethean--re-const ":true"))
  (should-not (string-match-p promethean--re-const "truely"))
  (should-not (string-match-p promethean--re-const ":nilpotent"))
  (should (string-match-p promethean--re-number "-42"))
  (should (string-match-p promethean--re-number "3.1415"))
  (should (string-match-p promethean--re-number "0"))
  (should-not (string-match-p promethean--re-number "3.14.15"))
  (should-not (string-match-p promethean--re-number "-"))
  (let* ((s "(defun greet-user name)")
         (m (string-match promethean--re-def-name s)))
    (should m)
    (should (equal (match-string 1 s) "defun"))
    (should (equal (match-string 2 s) "greet-user"))))

;;; funcs.el ends here
