# spacemacs.d — the live Spacemacs configuration for this device (stealth)

This repository is **the source of truth for Emacs on this machine**. It is the
`~/.spacemacs.d` directory that the `emacs.service` user daemon loads at
startup. `~/.emacs.d` is only the cache/ELPA directory — never edit there;
edit here.

Custom layers written for this device live under `layers/` (the `err-*`
namespace plus local layers such as `codex`, `llm`, `promethean-*`,
`agent-sandbox`, `semantic-search`, `unique-files`, `direnv`, `obsidian`).
The branch `device/stealth` carries device-specific commits; it is currently
**6 commits ahead of `main`, 0 behind** — device work has not been merged
back yet.

## Quick Start

Config changes are picked up by the running daemon in one of two ways:

```sh
# Reload a single changed file into the running daemon:
emacsclient -e '(load-file "~/.spacemacs.d/layers/err-core/config.el")'

# Or full restart of the daemon:
systemctl --user restart emacs
```

**Readiness gate:** unlike the yoga sibling, this device's `emacs.service`
unit (`~/.config/systemd/user/emacs.service`, snap Emacs `--fg-daemon`,
`Restart=on-failure`, `RestartSec=5`) currently has **no `ExecStartPost`
waitready script**. The gate to verify by hand after a restart is therefore:

```sh
systemctl --user status emacs   # unit must be active, not "activating (auto-restart)"
emacsclient -e '(message "ok")' # must answer
```

Any config that breaks startup will put the unit into a `Restart=on-failure`
crash loop — a failing restart counter is the regression signal. See
[Status](#status): the daemon is currently flapping.

Changes under `core/` and `init.el` (the `dotspacemacs/*` bootstrap) generally
require the daemon restart; layer-internal tweaks can often be reloaded with
`load-file` (and `M-x configuration-layer/reload` interactively).

## Example: adding a package to a user layer

Layers own packages through a `packages.el` file declaring
`<layer>-packages` plus `init`/`post-init` functions. To add a package to the
`err-core` layer (`layers/err-core/packages.el`):

```elisp
(defconst err-core-packages
  '(my-existing-package my-new-package)     ; 1. declare it
  "Packages configured by err-core.")

(defun err-core/init-my-new-package ()      ; 2. own + configure it
  (use-package my-new-package
    :defer t))
```

If the package needs hooks after another package loads, add an
`err-core/post-init-<package>` function (see `layers/err-core/packages.el`
for the real pattern). Then add the layer to
`dotspacemacs-configuration-layers` in `core/layers.el` if it is not already
listed, and restart the daemon or `configuration-layer/reload`.

## Concepts

- **Spacemacs layer model** — a layer is a directory of conventional files
  (`packages.el`, `funcs.el`, `config.el`, `keybindings.el`, `layers.el`,
  `README.org`). Spacemacs discovers packages via `<layer>-packages`, calls
  `<layer>/init-<pkg>` once per owned package, and `<layer>/post-init-<pkg>`
  after other layers have initialized theirs. Layers declare upstream
  dependencies with `configuration-layer/declare-layer-dependencies`.
- **The `err-*` namespace** — layers named `err-<thing>` are written by the
  user for this device (`err-core`, `err-ts`, `err-commonlisp`). Treat that
  prefix as the ownership boundary: device-specific config belongs there, not
  in copies of stock Spacemacs layers.
- **`core/` bootstrap order** — `init.el` defines the `dotspacemacs/*`
  functions Spacemacs calls in a fixed order; each one just `load`s a file
  from this repo (all paths resolve against `dotspacemacs-directory`):
  `core/layers.el` (layer declaration) → `config/ui.el` (`dotspacemacs/init`
  settings) → `core/user-env.el` → `core/user-init.el` (pre-package) → layer
  config → `config/*.el` in `user-config` (post-layer). Editing `core/` is
  high blast radius: it runs before package initialization and errors there
  can take down daemon startup.
- **lexical-binding cookies** — the first line of each Elisp file should
  carry `-*- lexical-binding: t; -*-`. Modern Emacs warns (and future Emacs
  will break) for files that rely on dynamic scoping defaults; the missing
  list in [Status](#status) is tracked debt, not accepted style.

## Repository Structure

```
init.el            dotspacemacs/* entry points; loads core/ + config/ files
.spacemacs.env     environment variables loaded at startup (tracked)
core/              layers.el, user-env.el, user-init.el (bootstrap body)
config/            ui.el, lsp.el, frame-title.el, helm-popup.el,
                   rofi-bridge.el, consult-launcher.el, agent-shell.el
layers/            custom layers (err-core, err-ts, err-commonlisp,
                   unique-files, codex, llm, direnv, obsidian,
                   promethean-*, promethean-vterm, agent-sandbox,
                   semantic-search)
gptel-tools.el     elisp utilities for gptel
tests/             ERT suite: unit/ integration/ smoke/ + run-tests.el,
                   coverage-report.el, helpers.el
Makefile           `make test`, `make coverage`, `make clean`
.github/workflows  ci.yml (ERT suite), coverage.yml
docs/, kanban/, .ημ/   notes, kanban cards, receipts
```

## Development

- **Validate** a changed Elisp file:

  ```sh
  emacsclient -e '(byte-compile-file "/home/err/.spacemacs.d/layers/err-core/config.el")'
  # or, without the daemon:
  emacs -Q --batch -f batch-byte-compile layers/err-core/config.el
  ```

  Byte-compile with warnings treated as failure; see STYLE.md's no-warnings law.
- **Test**: `make test` runs the full ERT suite in batch mode
  (`tests/run-tests.el`). Unit tests target `layers/err-core/funcs.el`,
  the integration test targets the err-core layer structure, smoke tests
  assert startup-level invariants.
- **Coverage**: `make coverage` writes `coverage/lcov.info` (also run by
  `.github/workflows/coverage.yml`).
- **CI**: pushes to any branch run `make test` under Emacs 29.4
  (`.github/workflows/ci.yml`).
- **Commit** on `device/stealth`. Never switch branches for config changes;
  device-specific work lives on the device branch.

## Status

Divergence vs `main` (measured 2026-09-11, `git log main..device/stealth`):

- `05e31f3` merge, `d1d9641` minor adjustments
- `4cb3083` Merge PR #5 (chore/organize-notes)
- `285dd54` Π: fork-tax reflection artifacts (receipts + session-mycology)
- `e13cce5`, `9a3e0fa` Π: fork-tax snapshots

Six commits ahead, zero behind. Device-only commits are mostly fork-tax
snapshots plus the config tweaks around them; merging back to `main` is
pending work.

Known warnings observed — recorded as debt, **not** fixed yet:

- **Daemon flapping**: `emacs.service` is crash-looping (`Restart=on-failure`,
  restart counter in the thousands at time of writing). The two dirty
  worktree files (`.spacemacs.env`, `core/user-env.el`) are uncommitted
  local edits; do not assume the committed state boots the daemon cleanly
  on stealth.
- Missing `lexical-binding` cookies in 11 tracked `.el` files:
  `gptel-tools.el`, `layers/codex/keybindings.el`,
  `layers/err-commonlisp/layers.el`, `layers/err-ts/layers.el`,
  `layers/llm/config.el`, all three `tests/unit|integration|smoke/*.el`
  test files, `tests/coverage-report.el`, and
  `.agents/skills/agent-i3-sandbox/{init.el,scripts/install-agent-shell.el}`.
  (`core/*.el`, `config/*.el`, and `init.el` all carry the cookie correctly.)
- No waitready gate on the service unit (see Quick Start above) —
  verification is manual until one is added.

## Documentation

- [AGENTS.md](AGENTS.md) — agent contract: invariants, validation, change rules
- [STYLE.md](STYLE.md) — Elisp conventions used in this repo
- [PROCESS.md](PROCESS.md) — process charter (epiphany-modeled)
- [GLOSSARY.md](GLOSSARY.md) — domain + Clojure terms
- [GIT_MODULE_INDEX.md](GIT_MODULE_INDEX.md) — parent/child repo map
- [README.org](README.org) — original (Org-mode) README

## License

GPL-3.0-or-later. Configuration code in this repository is released under the
GNU General Public License v3 or (at your option) any later version.
