# STYLE.md — Elisp conventions in .spacemacs.d

These are the conventions actually used in this repository; follow them for
new code.

## File headers and cookies

Every elisp file opens with a triple-semicolon header and a
`lexical-binding` cookie:

```elisp
;;; layers.el --- err-core layer dependencies -*- lexical-binding: t; -*-
;;; Commentary:
;; Declare upstream layer dependencies for err-core.

;;; Code:

;;; layers.el ends here
```

- First line: `;;; <file>.el --- <one-line description> -*- lexical-binding: t; -*-`
- `;;; Commentary:` section (even if brief).
- `;;; Code:` marker before executable code.
- Closing `;;; <file>.el ends here` line.
- The `lexical-binding: t` cookie is mandatory. 42 existing files carry it;
  do not regress this.

## Comment density

- `;;;` for file headers, `;;` for standalone comment lines / Commentary,
  `;` for inline trailing comments (used sparingly, e.g. in
  `dotspacemacs/emacs-custom-settings` auto-generated region).
- Section separators in auto-generated or long files use `;;` banners:
  `;; custom-set-variables was added by Custom.` style notes are preserved.

## Function style

- Prefer `defun` with a docstring for anything exported from `funcs.el`.
- Layer files follow Spacemacs structure:
  - `layers.el` — only `configuration-layer/declare-layer-dependencies`.
  - `packages.el` — package lists and `init` functions (`(defun <layer>/init-<package> ...)`).
  - `config.el` — configuration variables and hooks.
  - `funcs.el` — helper functions.
  - `keybindings.el` — Spacemacs key bindings.
- `init.el` uses simple `load` delegation per `dotspacemacs/*` hook; keep
  new wiring in `config/` modules loaded from `dotspacemacs/user-config`,
  not inline in `init.el`.

## Naming

- First-party layers: `err-<domain>` (`err-core`, `err-ts`,
  `err-commonlisp`).
- Machine/role-flavored layers: descriptive names (`agent-sandbox`,
  `promethean-vterm`, `semantic-search`).
- Config modules: one concern per file (`ui.el`, `lsp.el`, `frame-title.el`,
  `rofi-bridge.el`).

## Tests

- ERT tests live under `tests/unit/`, `tests/smoke/`, `tests/integration/`
  and are collected by `tests/run-tests.el`; run via `make test`.
- Helpers belong in `tests/helpers.el`; coverage instrumentation in
  `tests/coverage-report.el` (undercover).

## Things not to do

- No `setq` of package variables outside `config.el` / `packages.el` init
  functions.
- No hand edits inside the `dotspacemacs/emacs-custom-settings` auto
  region of `init.el`.
- No machine-specific environment values outside the (uncommitted)
  `.spacemacs.env` / `core/user-env.el` env files.
- No committing of `coverage/`, `elpa/`, or package caches.
