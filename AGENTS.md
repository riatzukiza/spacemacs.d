# AGENTS.md — spacemacs.d

## Role

This is the **live Spacemacs configuration for this device (stealth)**: the
`~/.spacemacs.d` directory that the `emacs.service` user daemon loads.
Working here means editing the Emacs environment every session on this
machine depends on — mistakes surface at daemon startup, not at review time.

## Invariants

1. **Layers live under `layers/err-*` (or other directories under `layers/`).**
   Never write config into stock Spacemacs layers or upstream layer copies.
   Device-specific behavior belongs in this repo's own layers. The `err-*`
   prefix is the namespace law: `err-core`, `err-ts`, `err-commonlisp` are
   user-written device layers; new device layers take the same prefix.
2. **`core/` is blast radius.** It is bootstrap order (`layers.el` →
   `user-env.el` → `user-init.el`, loaded by `init.el`'s `dotspacemacs/*`
   functions) and runs before package initialization. An error there breaks
   daemon startup for every session. Prefer layer or `config/` changes; touch
   `core/` only when the change must run before layer configuration.
3. **Every new `.el` file carries a `;;; lexical-binding: t` cookie on
   line 1** (or the missing cookie is accepted as explicitly recorded debt —
   see README Status). Do not add new files without the cookie.
4. **No package caches committed.** Installed packages, eln/elnc bytecode,
   and ELPA state live in `~/.emacs.d` — that directory is cache, not source.
   Nothing under `~/.emacs.d` is ever referenced as source or committed.
5. **Config that touches daemon startup must be verified against the
   running daemon.** `systemctl --user restart emacs`, confirm the unit
   reaches `active` (not `activating (auto-restart)`) via
   `systemctl --user status emacs`, then `emacsclient -e '(message "ok")'`.
   (This device has no waitready gate script; the manual check *is* the gate.
   If a waitready script is added later, that becomes the gate.)
6. **Secrets stay out of the repo.** API keys resolve through
   `auth-source-pick-first-password` (see `layers/llm/config.el`), never
   literals. `.spacemacs.env` is tracked — keep it free of credentials
   (it currently holds only desktop-session environment variables).
7. **Commit only what you touched.** Explicit `git add <files>`; no
   `git add -A`. Work happens on `device/stealth`; never switch branches.
   Pre-existing dirty files (`.spacemacs.env`, `core/user-env.el`) belong to
   other work — leave them out of your commits.

## Where things live

| Thing | Path |
|---|---|
| Entry points (`dotspacemacs/*`) | `init.el` |
| Layer declaration list | `core/layers.el` |
| Pre-package env / init | `core/user-env.el`, `core/user-init.el` |
| Post-layer config snippets | `config/*.el` |
| Custom layers (user-written) | `layers/err-*`, `layers/codex`, `layers/llm`, `layers/promethean-*`, `layers/agent-sandbox`, `layers/semantic-search`, `layers/unique-files`, `layers/direnv`, `layers/obsidian` |
| gptel utilities | `gptel-tools.el` |
| ERT tests | `tests/unit/`, `tests/integration/`, `tests/smoke/` |
| Test runner / coverage | `Makefile`, `tests/run-tests.el`, `tests/coverage-report.el` |
| CI | `.github/workflows/ci.yml`, `.github/workflows/coverage.yml` |
| Receipts / kanban / notes | `.ημ/`, `kanban/`, `docs/` |

## Validation

- Byte-compile changed files:
  `emacsclient -e '(byte-compile-file "...")'` or
  `emacs -Q --batch -f batch-byte-compile <file>` — zero warnings expected.
- Run the ERT suite: `make test` (batch, no display needed).
- Layer-structure sanity: every layer directory needs at least
  `packages.el` (or an entry in `core/layers.el`); init functions must match
  `<layer>/init-<package>` for each owned package.
- Startup-touching changes: restart the daemon and pass the manual gate
  (invariant 5).

## Change rules

- Add a package → declare in `<layer>-packages` + write
  `<layer>/init-<pkg>` (`use-package`, deferred where possible); only then
  reference it in `funcs.el`/`config.el`/`keybindings.el`.
- Add a layer → directory under `layers/` + entry in `core/layers.el`
  (order matters for precedence) + declare upstream dependencies.
- Edit `core/` or `init.el` → verify against the daemon gate before
  considering the change done.
- Known warnings (missing cookies, daemon flap) are **status**, tracked in
  README Status — do not silently "fix" unrelated warnings in passing;
  record them or fix them as their own change.

## Definition of done

- [ ] Changed files byte-compile without warnings
- [ ] `make test` passes
- [ ] Daemon still starts and `emacsclient` answers (if startup was touched)
- [ ] New `.el` files carry lexical-binding cookies
- [ ] No secrets, no package caches, no `~/.emacs.d` artifacts staged
- [ ] Only intended files staged (dirty worktree files untouched)
- [ ] Committed on `device/stealth` with explicit adds
