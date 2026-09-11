# .spacemacs.d — err's Spacemacs configuration on knoxx

This repository is the personal [Spacemacs](https://www.spacemacs.org/)
configuration for **err**, deployed at `~/.spacemacs.d` on the **knoxx**
production services host (`err@knoxx.promethean.rest`, Ubuntu 24.04.4,
headless). It is a working checkout of
[riatzukiza/spacemacs.d](https://github.com/riatzukiza/spacemacs.d), on the
`device/knoxx` branch.

## Identity and lineage

This branch descends from the **stealth branch tip** (`05e31f3`, "merge") —
the same configuration lineage that runs on the stealth machine. `device/knoxx`
was cut at that tip and is currently **6 commits ahead of `main` and 0 behind**
(see [Development](#development) for the measured divergence).

It carries the stealth-era shape of the config: a layered Spacemacs setup
split across `core/`, `config/`, and `layers/`, with custom `err-*` layers
(`err-core`, `err-ts`, `err-commonlisp`) plus machine-flavored layers
(`agent-sandbox`, `promethean-lisp`, `promethean-vterm`, `llm`, `codex`,
`obsidian`, `semantic-search`, `direnv`, `unique-files`).

## Role on knoxx

knoxx is the production services host. This Emacs configuration exists there
to serve server-side work: editing Clojure/ClojureScript service code
(CIDER/nREPL), running agent tooling, and operating the editor over the
daemon (`emacs --daemon` + `emacsclient`) as is customary for a headless
box.

Two files are **deliberately uncommitted, in-flight server-side
adaptations**:

- `.spacemacs.env` — server-side environment variable values.
- `core/user-env.el` — environment wiring for the knoxx user account.

These encode machine-local environment (paths, endpoints, secrets-adjacent
values) and must **not** be swept into a commit. They are listed in
[Status](#status).

## Quick start

```bash
# start (or attach to) the daemon
emacs --daemon
emacsclient -c   # or: emacsclient -nw for terminal frames

# run the ERT test suite in batch mode
cd ~/.spacemacs.d && make test
```

`init.el` is the entry point; it delegates to:

| Hook                      | Loads                    |
|---------------------------|--------------------------|
| `dotspacemacs/layers`     | `core/layers.el`         |
| `dotspacemacs/init`       | `config/ui.el`           |
| `dotspacemacs/user-env`   | `core/user-env.el`       |
| `dotspacemacs/user-init`  | `core/user-init.el`      |
| `dotspacemacs/user-config`| `config/lsp.el`, `config/frame-title.el`, `config/helm-popup.el`, `config/rofi-bridge.el`, `config/consult-launcher.el`, `config/agent-shell.el` |

Do not write anything past the auto-generated comment in `init.el`; that
region is owned by `custom-set-variables`.

## Concepts

- **Layer** — a Spacemacs configuration unit. Each directory under `layers/`
  may declare `packages.el` (what to install), `layers.el` (upstream
  dependencies), `config.el`, `funcs.el`, and `keybindings.el`.
- **err-* layers** — first-party layers owned by this repo
  (`err-core`, `err-ts`, `err-commonlisp`). See `layers/err-core/README.org`.
- **core/ vs config/** — `core/` holds load-bearing bootstrap files
  (`layers.el`, `user-env.el`, `user-init.el`); `config/` holds feature
  modules loaded from `dotspacemacs/user-config`.
- **Daemon workflow** — headless host, so Emacs runs as a daemon and all
  editing goes through `emacsclient`.

## Structure

```
init.el              entry point; wires dotspacemacs hooks to core/ + config/
core/                layers.el, user-env.el, user-init.el
config/              ui, lsp, frame-title, helm-popup, rofi-bridge,
                     consult-launcher, agent-shell
layers/              err-core, err-ts, err-commonlisp, promethean-lisp,
                     promethean-vterm, agent-sandbox, codex, llm, obsidian,
                     semantic-search, direnv, unique-files
tests/               ERT suite: unit/, smoke/, integration/, run-tests.el,
                     coverage-report.el
Makefile             `make test` (batch ERT), `make coverage` (undercover),
                     `make clean`
kanban/              kanban task files
docs/                internal docs
opencode.jsonc       OpenCode harness config for this repo
README.org           original upstream readme
```

## Development

- Branch: `device/knoxx`. Remote: `git@github.com:riatzukiza/spacemacs.d.git`.
- **Measured divergence vs `main`**: 6 commits ahead, 0 behind.
  `git log main..device/knoxx --oneline`:
  ```
  05e31f3 merge
  d1d9641 minor adjustments
  4cb3083 Merge pull request #5 from riatzukiza/chore/organize-notes
  285dd54 Π: fork-tax reflection artifacts (receipts + session-mycology)
  e13cce5 Π: fork-tax snapshot 2026-07-10T16:54:08Z
  9a3e0fa Π: fork-tax snapshot 2026-06-15T02:56:21Z
  ```
- Tests: `make test` runs `tests/run-tests.el` (unit + smoke + integration
  ERT). Coverage via `make coverage` (undercover → `coverage/lcov.info`).
- **In-flight, uncommitted** (leave dirty; do not commit, do not revert):
  - `M .spacemacs.env` (+113/−44 lines)
  - `M core/user-env.el` (+6/−2 lines)
  These are the server-side env adaptations that make the stealth-lineage
  config run correctly on knoxx. When they stabilize, upstreaming them as
  machine-profile logic (not raw values) is the intended direction.
- Never commit machine-local environment values.

## Status

- Branch `device/knoxx` is active; 6 ahead / 0 behind `main`.
- `.spacemacs.env` and `core/user-env.el` are **in-flight server-env
  adaptations** — intentionally uncommitted, part of the knoxx deployment
  adaptation work.
- 42 elisp files under `core/`, `config/`, and `layers/` carry
  `lexical-binding` cookies; keep that discipline in new files.
- See [GIT_MODULE_INDEX.md](GIT_MODULE_INDEX.md) for parentage in the
  federation superproject, and [PROCESS.md](PROCESS.md) for the process
  charter.
