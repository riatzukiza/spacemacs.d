# spacemacs.d — the live Spacemacs configuration for this device (yoga)

This repository is **the source of truth for Emacs on this machine**. It is the
`~/.spacemacs.d` directory that the `emacs.service` user daemon loads at
startup. `~/.emacs.d` is only the cache/ELPA directory — never edit there;
edit here.

Custom layers written for this device live under `layers/err-*` (plus other
local layers such as `unique-files`, `codex`, `llm`, `promethean-*`). The
branch `device/yoga` carries device-specific commits merged with `origin/main`.

## Quick Start

Config changes are picked up by the running daemon in one of two ways:

```sh
# Reload a single changed file into the running daemon:
emacsclient -e '(load-file "~/.spacemacs.d/layers/err-ts/packages.el")'

# Or full restart of the daemon:
systemctl --user restart emacs
```

**Readiness gate:** the `emacs.service` unit runs
`ExecStartPost=/home/err/.config/systemd/user/emacs.waitready`, so
`systemctl --user restart emacs` blocks until the daemon is actually serving
`emacsclient` requests. Any config that breaks startup will hold or fail the
unit — treat a failed `systemctl --user status emacs` as the regression signal.

Changes under `core/` and `init.el` (the `dotspacemacs/*` bootstrap) generally
require the daemon restart; layer-internal tweaks can often be reloaded with
`load-file` (and `M-x configuration-layer/reload` interactively).

## Example: adding a package to a user layer

Layers own packages through a `packages.el` file declaring
`<layer>-packages` plus `init`/`post-init` functions. To add a package to the
`err-ts` layer (`layers/err-ts/packages.el`):

```elisp
(defconst err-ts-packages
  '(lsp-mode typescript-mode prettier-js add-node-modules-path
             my-new-package)          ; 1. declare it
  "Packages configured by err-ts.")

(defun err-ts/init-my-new-package ()   ; 2. own + configure it
  (use-package my-new-package
    :defer t))
```

If the package needs hooks after another package loads, add an
`err-ts/post-init-<package>` function (see `layers/err-ts/packages.el` for the
real pattern). Then add the layer to `dotspacemacs-configuration-layers` in
`core/layers.el` if it is not already listed, and restart the daemon or
`configuration-layer/reload`.

## Concepts

- **Spacemacs layer model** — a layer is a directory of conventional files
  (`packages.el`, `funcs.el`, `config.el`, `keybindings.el`, `layers.el`,
  `README.org`). Spacemacs discovers packages via `<layer>-packages`, calls
  `<layer>/init-<pkg>` once per owned package, and `<layer>/post-init-<pkg>`
  after other layers have initialized theirs. Layers declare upstream
  dependencies with `configuration-layer/declare-layer-dependencies`.
- **The `err-*` namespace** — layers named `err-<thing>` are written by the
  user for this device (`err-ts`, `err-commonlisp`, `err-core`). Treat that
  prefix as the ownership boundary: device-specific config belongs there, not
  in copies of stock Spacemacs layers.
- **`core/` bootstrap order** — `init.el` defines the `dotspacemacs/*`
  functions Spacemacs calls in a fixed order; each one just `load`s a file
  from this repo: `core/layers.el` (layer declaration) → `config/ui.el`
  (dotspacemacs/init settings) → `core/user-env.el` → `core/user-init.el`
  (pre-package) → layer config → `config/*.el` in `user-config` (post-layer).
  Editing `core/` is high blast radius: it runs before package
  initialization and errors there can take down daemon startup.
- **lexical-binding cookies** — the first line of each Elisp file should carry
  `-*- lexical-binding: t; -*-`. Emacs 31 warns (and future Emacs will break)
  for files that rely on dynamic scoping defaults; the warning list in
  [Status](#status) is tracked debt, not accepted style.

## Repository Structure

```
init.el            dotspacemacs/* entry points; loads core/ + config/ files
.spacemacs.env     environment variables loaded at startup (tracked)
core/              layers.el, user-env.el, user-init.el (bootstrap body)
config/            ui.el, lsp.el, frame-title.el, helm-popup.el,
                   rofi-bridge.el, consult-launcher.el, agent-shell.el
layers/            custom layers (err-core, err-ts, err-commonlisp,
                   unique-files, codex, llm, direnv, obsidian,
                   promethean-*, agent-sandbox, semantic-search)
gptel-tools.el     elisp utilities for gptel
tests/             ERT suite: unit/ integration/ smoke/ + run-tests.el
Makefile           `make test`, `make coverage`
docs/, kanban/, spec/, .ημ/   notes, kanban cards, specs, receipts
```

## Development

- **Validate** a changed Elisp file:

  ```sh
  emacsclient -e '(byte-compile-file "/home/err/.spacemacs.d/layers/err-ts/packages.el")'
  # or, without the daemon:
  emacs -Q --batch -f batch-byte-compile layers/err-ts/packages.el
  ```

  Byte-compile with warnings treated as failure; see STYLE.md's no-warnings law.
- **Test**: `make test` runs the full ERT suite in batch mode
  (`tests/run-tests.el`). Unit tests target layer `funcs.el`, integration
  tests target package lists and init-function contracts, smoke tests assert
  startup-level invariants. Test names use the `μ/` prefix and read as claims.
- **Coverage**: `make coverage` writes `coverage/lcov.info`.
- **Commit** on `device/yoga`. Never switch branches for config changes;
  device-specific work lives on the device branch.

## Status

Known warnings observed in init logs — recorded as debt, **not** fixed yet:

- Missing `lexical-binding` cookies in several layer files (e.g.
  `layers/llm/config.el`, `layers/codex/keybindings.el`,
  `layers/err-ts/layers.el`, `layers/err-commonlisp/layers.el`).
- Unknown layer `aider` declared in `core/layers.el` (not present under
  `layers/`); Spacemacs skips it with a warning.
- Multiple init functions registered for `prettier-js` /
  `add-node-modules-path` (layer-precedence warnings): both packages appear in
  `dotspacemacs-additional-packages` *and* are owned by the `err-ts` layer.

## Documentation

- [AGENTS.md](AGENTS.md) — agent contract: invariants, validation, change rules
- [STYLE.md](STYLE.md) — Elisp conventions used in this repo
- [PROCESS.md](PROCESS.md) — process charter (epiphany-modeled)
- [GLOSSARY.md](GLOSSARY.md) — domain + Clojure terms
- [GIT_MODULE_INDEX.md](GIT_MODULE_INDEX.md) — parent/child repo map
- [README.org](README.org) — original (Org-mode) README; test/CI details

## License

GPL-3.0-or-later. Configuration code in this repository is released under the
GNU General Public License v3 or (at your option) any later version.
