# STYLE — Elisp conventions in spacemacs.d

These describe how this repo's Elisp is actually written. Match existing
files; deviations should be deliberate.

## File headers

- **lexical-binding cookie on line 1, always.** Two real patterns in use:
  - `core/` and `init.el` style:
    ```elisp
    ;; -*- mode: emacs-lisp; lexical-binding: t -*-
    ;;; core/layers.el --- Spacemacs layer configuration  -*- lexical-binding: t -*-
    ```
  - layer-file style (`packages.el`, `funcs.el`, `config.el`,
    `keybindings.el`):
    ```elisp
    ;;; packages.el --- unique-files layer -*- lexical-binding: t; -*-
    ```
  New files must carry the cookie (see AGENTS.md invariant 3). Existing files
  missing it are recorded debt (README Status), not license for new debt.
- Standard `;;; Commentary:` / `;;; Code:` / `;;; <file> ends here` skeleton.
- Section dividers inside large `funcs.el` files use the
  `;;;; ---------- Section ----------` form (see
  `layers/unique-files/funcs.el`).

## Package configuration pattern (as used here)

Layers own packages with the Spacemacs triple:

```elisp
;; packages.el
(defconst err-ts-packages
  '(lsp-mode typescript-mode prettier-js add-node-modules-path)
  "Packages configured by err-ts.")

(defun err-ts/init-prettier-js ()
  "Register prettier-js for ownership by this layer."
  (use-package prettier-js
    :defer t))

(defun err-ts/post-init-typescript-mode ()   ; hook into other packages
  (dolist (hook '(typescript-mode-hook typescript-ts-mode-hook))
    (add-hook hook #'prettier-js-mode)))
```

- `init-<pkg>` functions use `use-package` with `:defer t` when lazy loading
  is possible; package-name-keywords (e.g. `:hook`, `:mode`) are fine.
- Cross-package wiring goes in `post-init-<pkg>`, never in `init-`.
- Layer dependencies are declared at the top of `layers.el`:
  `(configuration-layer/declare-layer-dependencies '(typescript lsp ...))`.
- User options go in `config.el` as `defcustom` in a `defgroup`, with
  `:type`/`:group`, and get `safe-local-variable` properties when they are
  meant to be set from `.dir-locals.el` (see `layers/unique-files/config.el`).
- Leader keys live in `keybindings.el` via
  `spacemacs/declare-prefix` + `spacemacs/set-leader-keys`; do not bind
  global keys in layers without a reason.

## Docstrings and naming

- Every `defun`/`defcustom`/`defvar` gets a docstring; first line is a
  complete sentence. Docstrings quote symbols with backticks/commas
  (`\`unique-files-mode-targets'`).
- Private/internal functions use the layer's `//` convention:
  `unique-files//project-root`.
- Test names use the `μ/` prefix and read as claims:
  `(ert-deftest μ/my-func-does-the-right-thing () ...)`.

## Spacing and layout

- Top-level forms separated by a single blank line; no trailing whitespace.
- `setq-default` blocks in `core/layers.el` use aligned keyword lists with
  comment-group headers (`;; Languages / frameworks`, `;; Private layers`).
- Prefer `dolist`/`when-let`/`pcase` over raw `loop`/`mapcar`-side-effects.

## No-warnings law

Byte-compiling any file in this repo must produce **zero warnings**.
`free-variable`, `unbound`, `nor-generated-autoloads` style warnings are
treated as failures, not noise. If a warning cannot be removed, it is
recorded in README Status with its cause. Known current debt: missing
lexical-binding cookies in a few layer files, the unknown `aider` layer, and
duplicate init functions for `prettier-js` / `add-node-modules-path`
(layer-precedence warnings from `err-ts` owning packages that are also in
`dotspacemacs-additional-packages`).

## Doc formatting (Markdown)

- Headings sentence case; code fenced with ```` ```elisp ```` / ```` ```sh ````.
- Relative links between doc files; tables for path maps.
- Keep README.md as the front door; deep detail goes to the referenced file,
  not inline sprawl.
