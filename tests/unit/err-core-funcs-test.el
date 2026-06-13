;;; tests/unit/err-core-funcs-test.el --- unit tests for err-core/funcs.el
;;; -*- lexical-binding: t; -*-
;;; Commentary:
;; Tests for pure/FS-bounded functions in layers/err-core/funcs.el.
;; Run with `make test' from the repo root.

;;; Code:

(require 'ert)
(load-file (expand-file-name "tests/helpers.el"
                             (locate-dominating-file load-file-name ".git")))
(load-file (expand-file-name "layers/err-core/funcs.el"
                             (locate-dominating-file load-file-name ".git")))

;;; ─── promethean--gitglob-to-dir-regex ───────────────────────────────────────

(ert-deftest μ/gitglob-converts-plain-dir ()
  "A plain name with no dot and no trailing slash becomes a valid LSP regexp."
  (let ((result (promethean--gitglob-to-dir-regex "node_modules")))
    (should (stringp result))
    (should (string-prefix-p "/" result))
    (should (string-suffix-p "\\'" result))))

(ert-deftest μ/gitglob-converts-trailing-slash ()
  "A glob with a trailing slash (explicit dir) is converted."
  (let ((result (promethean--gitglob-to-dir-regex "dist/")))
    (should (stringp result))))

(ert-deftest μ/gitglob-rejects-plain-file-pattern ()
  "A plain filename with a dot and no wildcard returns nil."
  (should-not (promethean--gitglob-to-dir-regex "secrets.env"))
  (should-not (promethean--gitglob-to-dir-regex "foo.bar")))

(ert-deftest μ/gitglob-accepts-wildcard-file-pattern ()
  "A glob with wildcards is converted even if it looks file-ish."
  (should (promethean--gitglob-to-dir-regex "*.log"))
  (should (promethean--gitglob-to-dir-regex "?.tmp")))

(ert-deftest μ/gitglob-strips-globstar-prefix ()
  "A **/foo pattern is treated as foo."
  (let ((result (promethean--gitglob-to-dir-regex "**/build")))
    (should (stringp result))
    (should (string-match-p "build" result))))

(ert-deftest μ/gitglob-escapes-dot-in-dir ()
  "A dir-like glob containing a dot is still converted when it ends with /."
  (let ((result (promethean--gitglob-to-dir-regex ".cache/")))
    (should (stringp result))))

;;; ─── promethean-lsp-gitignore-dir-regexes ───────────────────────────────────

(ert-deftest μ/gitignore-regexes-returns-list ()
  "Reading a valid .gitignore returns a non-empty list."
  (with-temp-gitignore '("node_modules" "dist/" ".cache/" "# a comment" "")
    (let ((result (promethean-lsp-gitignore-dir-regexes default-directory)))
      (should (listp result))
      (should (> (length result) 0)))))

(ert-deftest μ/gitignore-regexes-skips-comments-and-blanks ()
  "Comments (#) and blank lines are not emitted as regexps."
  (with-temp-gitignore '("# ignore build" "" "build/")
    (let ((result (promethean-lsp-gitignore-dir-regexes default-directory)))
      (should (= 1 (length result))))))

(ert-deftest μ/gitignore-regexes-errors-on-missing-file ()
  "Passing a directory with no .gitignore signals an error."
  (let ((dir (make-temp-file "spacemacs-nogi-" t)))
    (unwind-protect
        (should-error (promethean-lsp-gitignore-dir-regexes dir))
      (delete-directory dir t))))

(ert-deftest μ/gitignore-regexes-deduplicates ()
  "Duplicate patterns produce a deduplicated output list."
  (with-temp-gitignore '("build/" "build/" "dist/")
    (let* ((result (promethean-lsp-gitignore-dir-regexes default-directory))
           (uniq   (delete-dups (copy-sequence result))))
      (should (= (length result) (length uniq))))))

;;; ─── err-core/copilot-lisp-indent-fallback ──────────────────────────────────

(ert-deftest μ/indent-fallback-returns-number ()
  "The fallback always returns a number."
  (should (numberp (err-core/copilot-lisp-indent-fallback))))

(ert-deftest μ/indent-fallback-respects-lisp-body-indent ()
  "When `lisp-body-indent' is set, it is preferred."
  (let ((lisp-body-indent 4))
    (should (= 4 (err-core/copilot-lisp-indent-fallback)))))

(ert-deftest μ/indent-fallback-uses-2-as-final-default ()
  "With no bound indent vars, the fallback returns 2."
  (let (lisp-body-indent lisp-indent-offset standard-indent tab-width)
    (should (= 2 (err-core/copilot-lisp-indent-fallback)))))

(provide 'err-core-funcs-test)
;;; err-core-funcs-test.el ends here
