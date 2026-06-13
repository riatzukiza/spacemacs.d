# Makefile — spacemacs.d test runner
EMACS ?= emacs
BATCH  = $(EMACS) -Q --batch

.PHONY: test coverage clean

## Run the full ERT suite in batch mode
test:
	$(BATCH) \
	  -l ert \
	  -l tests/run-tests.el

## Run coverage-instrumented suite; output goes to coverage/lcov.info
coverage:
	mkdir -p coverage
	$(BATCH) \
	  --eval "(package-initialize)" \
	  --eval "(unless (package-installed-p 'undercover) \
	            (add-to-list 'package-archives '(\"melpa\" . \"https://melpa.org/packages/\") t) \
	            (package-refresh-contents) \
	            (package-install 'undercover))" \
	  -l ert \
	  -l tests/coverage-report.el

## Remove generated artifacts
clean:
	rm -rf coverage/
