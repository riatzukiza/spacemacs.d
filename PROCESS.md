# PROCESS.md — .spacemacs.d (knoxx)

## Mini epiphany charter

This repo adopts a trimmed-down version of the Epiphany process charter.
The canonical charter lives in the foresight checkout at:

```
~/spaces/foresight/epiphany/PROCESS.md
```

This path has been **verified to exist on knoxx** (the `foresight`
consolidation root is checked out at `~/spaces/foresight` and contains the
`epiphany` submodule). If you are on a different machine, resolve the
charter through that machine's spaces layout; do not assume the same path.

## Local constraints (durable, per the charter's spirit)

- **Evidence over assertion.** A config change is not "done" because the
  file was edited. It is done when the editor loads it without error and
  `make test` passes.
- **Bounded commitments.** Each change names its scope (which layer/config
  file, which blast radius) before work begins.
- **Consequential claims are preserved.** For non-trivial changes, leave a
  short record of what was measured (test output, load errors observed and
  fixed) in the commit message or kanban notes.
- **Revise without misrepresenting.** If a previous change turns out wrong,
  fix forward with a new commit that states the correction; do not rewrite
  history.

## Workflow for this repo

1. Confirm you are on `device/knoxx` and note the dirty env files
   (`.spacemacs.env`, `core/user-env.el`) — they are in-flight and off-limits.
2. Make the change in the narrowest scope (`layers/err-*` for layer work,
   `config/` for feature modules, `core/` only when unavoidable).
3. Validate: `make test` (batch ERT). For load-level validation, restart the
   daemon or use a fresh `emacs -Q`-derived batch load.
4. Commit explicitly (`git add <only your files>`) on `device/knoxx`.
