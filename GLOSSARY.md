# GLOSSARY — spacemacs.d

## Domain terms

- **Spacemacs** — Emacs distribution layering a mnemonic Spc-leader keymap
  and curated "layers" on top of stock Emacs. This repo *is* the Spacemacs
  user config for this device (`~/.spacemacs.d/init.el` replaces
  `~/.spacemacs`).
- **Layer** — a directory of conventional files (`packages.el`, `funcs.el`,
  `config.el`, `keybindings.el`, `layers.el`) declaring a bundle of packages
  and configuration. Discovered via `dotspacemacs-configuration-layer-path`
  (here: `layers/`). Owned packages get `<layer>/init-<pkg>` and
  `<layer>/post-init-<pkg>` hooks.
- **evil-mode** — Vim emulation layer in Emacs; Spacemacs is built on it.
  Keybindings in `keybindings.el` are Spacemacs leader bindings (e.g.
  `SPC o m n` for `err-core/next-conflicted-file`).
- **package.el** — Emacs' built-in package manager; installs into
  `~/.emacs.d/elpa/`. This config uses package.el (not straight.el);
  `package-selected-packages` is persisted in `init.el`'s custom-settings
  block.
- **lexical-binding** — the file-local variable (cookie on line 1) that
  makes Elisp use lexical scope. Without it, code runs under dynamic
  scoping; modern Emacs emits a warning for every such file, and future
  Emacs versions will drop dynamic-scope support.
- **byte-compilation** — compiling `.el` to `.elc`/`.eln` to catch errors
  and warnings ahead of runtime. The validation step for any changed file
  here.
- **elpa** — the package archive directory `~/.emacs.d/elpa/` where
  package.el installs; also shorthand for ELPA package archives (MELPA,
  etc.). Cache, not source.
- **daemon** — `emacs.service`, the user systemd unit running Emacs in
  `--fg-daemon` mode (snap Emacs on stealth) so every frame is a client of
  one long-lived Emacs process.
- **emacsclient** — the CLI that connects to the daemon: `emacsclient -c`
  opens a frame, `emacsclient -e '(expr)'` evaluates Elisp (how config is
  reloaded here).
- **server socket** — the Unix socket the daemon listens on and
  emacsclient connects to. If the unit is active but the socket does not
  answer, startup is half-broken.
- **crash loop** — what this device's `emacs.service` does when startup
  fails: `Restart=on-failure` + `RestartSec=5` relaunches Emacs every 5
  seconds; a fast-growing restart counter in `systemctl --user status
  emacs` is the signature.
- **cider** — the Emacs Clojure IDE package: REPL integration, eval,
  connection to Clojure backends. See also nrepl below.
- **LSP** — Language Server Protocol; this config drives it through the
  Spacemacs `lsp` layer + `lsp-mode` (with `consult-lsp` companions), used
  for TypeScript, Clojure, Common Lisp, etc.

## Named things in this repo

- **err-core** — the base device layer (`layers/err-core/`): frame
  transparency, merge-conflict navigation, copilot indent fallback, and
  `promethean-*` LSP/gitignore helpers. The most-included user layer.
- **err-ts / err-commonlisp** — device layers for TypeScript and Common
  Lisp tooling respectively.
- **promethean-\*** — layers tied to the Promethean project ecosystem
  (`promethean-lisp`, `promethean-vterm`); their helpers
  (`promethean--*`, `promethean-lsp-*`) live in `layers/err-core/funcs.el`.
- **eta-mu (ημ)** — the actor/kanban process system referenced by this
  repo's `.ημ/` receipts and `kanban/` cards. Process scaffolding alongside
  `docs/`.
- **gptel / ellama / mcp / acp** — LLM integration packages configured by
  the `llm` layer; keys resolve via `auth-source`, never literals.
- **codex layer** — `layers/codex/`: OpenAI Codex CLI integration with a
  `codex-token-budget` for context trimming (a budget number, not a
  credential).

## Clojure terms

This repo configures the Emacs side of the user's Clojure work, so agents
touching it should know these in plain language:

- **cider** — the Emacs package that turns Emacs into a Clojure IDE: it
  launches or connects to a REPL, sends code from buffers to be evaluated,
  shows results inline, and provides completion/documentation for Clojure
  source.
- **nrepl** — the REPL protocol underneath cider: a network server that a
  Clojure program exposes so clients (cider) can evaluate code, load files,
  and inspect state. "Connect cider to nrepl" means pointing the IDE at
  that server.
- **clj-kondo** — a static linter for Clojure/ClojureScript that flags
  unused vars, bad requires, and arity errors. The Clojure-side analog of
  the no-warnings law in STYLE.md.
- **babashka (bb)** — a fast-starting Clojure interpreter/scripting runtime
  used for build glue and agent tooling (e.g. `bb -e` for EDN validation in
  sibling repos). Not an Emacs package — it is what Clojure config on this
  machine is commonly driven *from*.
- **shadow-cljs** — a ClojureScript build tool commonly paired with cider
  as the REPL backend for browser/Node projects.
