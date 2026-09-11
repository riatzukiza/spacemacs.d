# STYLE — Elisp conventions in spacemacs.d

These describe how this repo's Elisp is actually written. Match existing
files; deviations should be deliberate.

## File headers

- **lexical-binding cookie on line 1, always.** Two real patterns in use:
  - `core/`, `config/` and `init.el` style:
    ```elisp
    ;; -*- mode: emacs-lisp; lexical-binding: t -*-
    ;;; core/layers.el --- Spacemacs layer configuration  -*- lexical-binding: t -*-
    ```
  - layer-file style (`packages.el`, `funcs.el`, `config.el`,
    `keybindings.el`):
    ```elisp
    ;;; funcs.el --- err-core layer funcs -*- lexical-binding: t; -*-
    ```
  (A few test files use a two-line variant — cookie on line 2 after a
  `;;;` title line. Prefer the single-line forms above for new files.)
  New files must carry the cookie (see AGENTS.md invariant 3). Existing
  files missing it are recorded debt (README Status), not license for new
  debt.
- Standard `;;; Commentary:` / `;;; Code:` skeleton after the header.

## Package configuration pattern (as used here)

Layers own packages with the Spacemacs triple:

```elisp
;; packages.el
(defconst err-core-packages
  '(some-package another-package)
  "Packages configured by err-core.")

(defun err-core/init-some-package ()
  "Register some-package for ownership by this layer."
  (use-package some-package
    :defer t))

(defun err-core/post-init-another-package ()   ; hook into other packages
  (add-hook 'another-package-hook #'err-core/some-helper))
```

- `init-<pkg>` functions use `use-package` with `:defer t` when lazy loading
  is possible; package-name keywords (e.g. `:hook`, `:mode`) are fine.
- Cross-package wiring goes in `post-init-<pkg>`, never in `init-`.
- Layer dependencies are declared via
  `configuration-layer/declare-layer-dependencies`.
- User options go in `config.el` as `defcustom` with `:type`/`:group`.
- Leader keys live in `keybindings.el` via `spacemacs/set-leader-keys`
  (e.g. `"omn" #'err-core/next-conflicted-file`); do not bind global keys
  in layers without a reason.

## Naming

- Public functions in a layer use the layer-name prefix:
  `err-core/apply-transparency`.
- Private/internal helpers use the `//` convention:
  `promethean--project-root`, `promethean--gitglob-to-dir-regex`.
- Functions shared across a layer family keep that family's prefix even when
  defined in a sibling layer's file (e.g. `promethean-lsp-*` in
  `layers/err-core/funcs.el`).
- Test names use the `μ/` prefix and read as claims:
  `(ert-deftest μ/err-core-each-owned-package-has-init () ...)`. Test
  docstrings may state the claim in plain sentences.

## Docstrings and comments

- Every `defun`/`defcustom`/`defvar` gets a docstring; first line is a
  complete sentence. Docstrings quote symbols with backticks/quotes.
- Inline comments explain *why*, not what; header comments in test files
  state scope and how to run (`make test`).

## Spacing and layout

- Top-level forms separated by a single blank line; no trailing whitespace.
- `setq-default` blocks in `core/layers.el` use aligned keyword lists with
  comment-group headers (`;; Languages / frameworks`, `;; Private layers`).
- Prefer `dolist`/`when-let`/`pcase` over raw `loop`/`mapcar`-side-effects.

## No-warnings law

Byte-compiling any file in this repo must produce **zero warnings**.
`free-variable`, `unbound`, and friends are treated as failures, not noise.
If a warning cannot be removed, it is recorded in README Status with its
cause. Known current debt: 11 files missing lexical-binding cookies and the
flapping daemon (see README Status).

## Doc formatting (Markdown)

- Headings sentence case; code fenced with ```` ```elisp ```` / ```` ```sh ````.
- Relative links between doc files; tables for path maps.
- Keep README.md as the front door; deep detail goes to the referenced file,
  not inline sprawl.
