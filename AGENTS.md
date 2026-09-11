# AGENTS.md — spacemacs.d

## Role

This is the **live Spacemacs configuration for this device (yoga)**: the
`~/.spacemacs.d` directory that the `emacs.service` user daemon loads.
Working here means editing the Emacs environment every session on this
machine depends on — mistakes surface at daemon startup, not at review time.

## Invariants

1. **Layers live under `layers/err-*` (or other directories under `layers/`).**
   Never write config into stock Spacemacs layers or upstream layer copies.
   Device-specific behavior belongs in this repo's own layers.
2. **`core/` is bootstrap order** (`layers.el` → `user-env.el` →
   `user-init.el`, loaded by `init.el`'s `dotspacemacs/*` functions).
   Changes there are blast-radius-high: an error breaks daemon startup for
   every session. Prefer layer or `config/` changes; touch `core/` only when
   the change must run before layer configuration.
3. **Every new `.el` file carries a `;;; lexical-binding: t` cookie on line 1**
   (or the missing cookie is accepted as explicitly recorded debt — see
   README Status). Do not add new files without the cookie.
4. **Config that touches daemon startup must be verified against the
   waitready gate**: `systemctl --user restart emacs` and confirm the unit
   reaches active with `ExecStartPost=.../emacs.waitready` succeeding
   (`systemctl --user status emacs`), then `emacsclient -e '(message "ok")'`.
5. **Never commit package caches.** Installed packages, eln/elnc bytecode,
   and ELPA state live in `~/.emacs.d` — that directory is cache, not source.
   Nothing under `~/.emacs.d` is ever referenced as source or committed.
6. **Secrets stay out of the repo.** API keys resolve through
   `auth-source-pick-first-password` (see `layers/llm/config.el`), never
   literals. `.spacemacs.env` is tracked — keep it free of credentials.
7. **Commit only what you touched.** Explicit `git add <files>`; no
   `git add -A`. Work happens on `device/yoga`; never switch branches.

## Where things live

| Thing | Path |
|---|---|
| Entry points (`dotspacemacs/*`) | `init.el` |
| Layer declaration list | `core/layers.el` |
| Pre-package env / init | `core/user-env.el`, `core/user-init.el` |
| Post-layer config snippets | `config/*.el` |
| Custom layers (user-written) | `layers/err-*`, `layers/unique-files`, `layers/codex`, `layers/llm`, `layers/promethean-*`, `layers/direnv`, `layers/obsidian`, `layers/agent-sandbox`, `layers/semantic-search` |
| gptel utilities | `gptel-tools.el` |
| ERT tests | `tests/unit/`, `tests/integration/`, `tests/smoke/` |
| Test runner / coverage | `Makefile`, `tests/run-tests.el` |
| Receipts / kanban / notes | `.ημ/`, `kanban/`, `docs/`, `spec/` |

## Validation

- Byte-compile changed files:
  `emacsclient -e '(byte-compile-file "...")'` or
  `emacs -Q --batch -f batch-byte-compile <file>` — zero warnings expected.
- Run the ERT suite: `make test` (batch, no display needed).
- Layer-structure sanity: every layer directory needs at least
  `packages.el` (or an entry in `core/layers.el`); init functions must match
  `<layer>/init-<package>` for each owned package.
- Startup-touching changes: restart the daemon and pass the waitready gate
  (invariant 4).

## Change rules

- Add a package → declare in `<layer>-packages` + write
  `<layer>/init-<pkg>` (`use-package`, deferred where possible); only then
  reference it in `funcs.el`/`config.el`/`keybindings.el`.
- Add a layer → directory under `layers/` + entry in `core/layers.el`
  (order matters for precedence) + declare upstream dependencies.
- Edit `core/` or `init.el` → verify against the waitready gate before
  considering the change done.
- Known warnings (aider, prettier-js precedence, missing cookies) are
  **status**, tracked in README Status — do not silently "fix" unrelated
  warnings in passing; record them or fix them as their own change.

## Definition of done

- [ ] Changed files byte-compile without warnings
- [ ] `make test` passes
- [ ] Daemon still passes the waitready gate (if startup was touched)
- [ ] New `.el` files carry lexical-binding cookies
- [ ] No secrets, no package caches, no `~/.emacs.d` artifacts staged
- [ ] Committed on `device/yoga` with explicit adds
