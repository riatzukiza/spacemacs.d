# AGENTS.md — .spacemacs.d (knoxx)

## Role

This repository is err's Spacemacs configuration as deployed on **knoxx**,
the production services host. Agents working here are editing a live editor
configuration that descends from the stealth branch (`05e31f3`) and runs on
branch `device/knoxx`.

## Invariants

1. **`err-*` layer law.** `layers/err-*` (`err-core`, `err-ts`,
   `err-commonlisp`) are first-party layers owned by this repo. Their
   `layers.el` declares upstream dependencies via
   `configuration-layer/declare-layer-dependencies`; their `packages.el`
   owns package lists. Changes to what these layers provide must go through
   those files, not by ad-hoc `setq` elsewhere.
2. **`core/` blast radius.** Everything under `core/` (`layers.el`,
   `user-env.el`, `user-init.el`) is loaded during early startup and affects
   *every* session, including batch/test runs and the daemon. Treat edits
   there as high-blast-radius: prefer `config/` modules for feature work,
   and verify with `make test` before claiming success.
3. **lexical-binding cookies.** Elisp files in this repo carry
   `;;; ... -*- lexical-binding: t; -*-` cookies (42 files under `core/`,
   `config/`, `layers/` currently do). New files MUST carry the cookie;
   existing files MUST NOT have it removed.
4. **No package caches in git.** `elpa/`, package-build artifacts,
   `coverage/`, and any downloaded packages are never committed. Do not
   vendor package sources into the repo.
5. **Env files stay dirty.** `.spacemacs.env` and `core/user-env.el` carry
   uncommitted, in-flight server-side environment adaptations. Do not commit
   them, do not revert them, do not "clean up" the working tree. They may
   contain machine-specific values that must never be pushed.
6. **Branch law.** Work happens on `device/knoxx`. Never switch branches to
   "get a clean tree"; never amend commits; never force push.
7. **No unrelated dirt.** Never stage or commit changes outside the files a
   task explicitly touched. Explicit `git add <file>` only — never
   `git add -A` / `git add .`.
8. **Tests before done.** Elisp changes should pass `make test` (batch ERT)
   before being committed.

## Process

See [PROCESS.md](PROCESS.md) (mini epiphany charter) and the full charter at
`~/spaces/foresight/epiphany/PROCESS.md` on knoxx.
