# GLOSSARY — spacemacs.d

## Domain terms

- **Spacemacs** — Emacs distribution layering a mnemonic Spc-leader keymap
  and curated "layers" on top of stock Emacs. This repo *is* the Spacemacs
  user config for this device (`~/.spacemacs.d/init.el` replaces `~/.spacemacs`).
- **Layer** — a directory of conventional files (`packages.el`, `funcs.el`,
  `config.el`, `keybindings.el`, `layers.el`) declaring a bundle of packages
  and configuration. Discovered via `dotspacemacs-configuration-layer-path`
  (here: `layers/`). Owned packages get `<layer>/init-<pkg>` and
  `<layer>/post-init-<pkg>` hooks.
- **evil-mode** — Vim emulation layer in Emacs; Spacemacs is built on it.
  Keybindings in `keybindings.el` are Spacemacs leader bindings (e.g. `SPC n u u`).
- **package.el** — Emacs' built-in package manager; installs into
  `~/.emacs.d/elpa/`. This config uses package.el (not straight.el);
  `package-selected-packages` is persisted in `init.el`'s custom-settings
  block, and `dotspacemacs-install-packages 'used-only` prunes unused ones.
- **lexical-binding** — the file-local variable (cookie on line 1) that makes
  Elisp use lexical scope. Without it, code runs under dynamic scoping;
  Emacs 31 emits a warning for every such file, and future Emacs versions
  will drop dynamic-scope support.
- **byte-compilation** — compiling `.el` to `.elc`/`.eln` to catch errors and
  warnings ahead of runtime. The validation step for any changed file here.
- **elpa** — the package archive directory `~/.emacs.d/elpa/` where
  package.el installs; also shorthand for ELPA package archives (MELPA, etc.).
  Cache, not source.
- **daemon** — `emacs.service`, the user systemd unit running Emacs
  headless/in-server mode so every frame is a client of one long-lived Emacs.
- **emacsclient** — the CLI that connects to the daemon: `emacsclient -c`
  opens a frame, `emacsclient -e '(expr)'` evaluates Elisp (how config is
  reloaded here).
- **server socket** — the Unix socket (`$XDG_RUNTIME_DIR/emacs/server`) the
  daemon listens on and emacsclient connects to. The waitready gate checks
  this is live before systemd marks the unit ready.
- **waitready gate** — `/home/err/.config/systemd/user/emacs.waitready`,
  wired as `ExecStartPost=` in `emacs.service`: blocks `systemctl --user
  restart emacs` from "completing" until the server socket answers. Any
  startup-breaking config shows up as the unit failing this gate.
- **cider** — the Emacs Clojure IDE package (owned by the `clojure` +
  `err-commonlisp`/`promethean-lisp` layer stack here): REPL integration,
  eval, connection to Clojure backends. See also nrepl below.
- **LSP** — Language Server Protocol; this config drives it through the
  Spacemacs `lsp` layer + `lsp-mode` (with `lsp-ui`, `treemacs`, `consult-lsp`
  companions), used for TypeScript, Clojure, etc.

## Named things in this repo

- **eta-mu (ημ)** — the actor/kanban process system referenced by this repo's
  `.ηm`→`.eta-mu` symlink and `.ημ/` receipts (`receipts.edn`,
  `PR_MANIFEST.sha256`, session-mycology ledger). Process scaffolding
  alongside `kanban/`, `docs/`, `spec/`.
- **gptel / ellama / mcp / acp** — LLM integration packages configured by the
  `llm` layer and `llm-client`; keys resolve via `auth-source`, never literals.

## Clojure terms

This repo configures the Emacs side of the user's Clojure work, so agents
touching it should know these in plain language:

- **cider** — the Emacs package that turns Emacs into a Clojure IDE: it
  launches or connects to a REPL, sends code from buffers to be evaluated,
  shows results inline, and provides completion/documentation for Clojure
  source. Configured here via the Spacemacs `clojure` layer and
  `cider-*` options in `init.el`'s custom block (shadow-cljs defaults).
- **nrepl** — the REPL protocol underneath cider: a network server that a
  Clojure program exposes so clients (cider) can evaluate code, load files,
  and inspect state. "Connect cider to nrepl" means pointing the IDE at that
  server. Project `.dir-locals` here select `cider-preferred-build-tool
  shadow-cljs` and `cider-default-cljs-repl shadow`.
- **clj-kondo** — a static linter for Clojure/ClojureScript that flags
  unused vars, bad requires, and arity errors. Enabled in this config by
  `clojure-enable-linters t` in `core/layers.el`; the Clojure-side analog of
  "no warnings" law.
- **babashka (bb)** — a fast-starting Clojure interpreter/scripting runtime
  used for build glue and agent tooling (e.g. `bb -e` for EDN validation in
  sibling repos). Not an Emacs package — it is what Clojure config on this
  machine is commonly driven *from*.
