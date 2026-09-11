# GLOSSARY.md — .spacemacs.d (knoxx)

Plain-language definitions for the terms used in this config and the tooling
it touches. knoxx may run Clojure services, so the Clojure-adjacent terms
matter here.

## Spacemacs / Emacs terms

- **Emacs** — the extensible editor/runtime. On knoxx it typically runs as a
  **daemon** (background server) and you attach via `emacsclient`.
- **Daemon** — a headless Emacs server process. On a headless host like
  knoxx, all editing happens through `emacsclient` talking to the daemon.
- **Spacemacs** — a distribution layered on Emacs providing a layer system
  and Vim-style editing. This repo *is* the Spacemacs config (it replaces
  the `~/.spacemacs` file).
- **Layer** — a bundled unit of editor configuration: packages, settings,
  and keybindings in one directory. Upstream layers (e.g. `lsp`, `git`,
  `org`) are declared as dependencies; first-party ones are the `err-*`
  layers.
- **Package** — an installable Emacs Lisp library, installed by Spacemacs
  into `elpa/` (never committed).
- **ERT** — Emacs Lisp's built-in regression test framework. This repo's
  tests (`tests/unit`, `tests/smoke`, `tests/integration`) are ERT tests run
  in batch mode via `make test`.
- **Batch mode** — running `emacs --batch` to execute Lisp without a UI,
  used for tests and scripted config checks.
- **lexical-binding** — the file-local cookie enabling lexical scoping for
  that file's Lisp. Mandatory here.
- **`custom-set-variables`** — the auto-generated settings block at the end
  of `init.el`, owned by Emacs' customize system; never hand-edit it.

## Clojure-adjacent terms (relevant because knoxx may run Clojure services)

- **Clojure** — a Lisp on the JVM; **ClojureScript (CLJS)** is the same
  language compiled to JavaScript. The `err-core` layer brings
  `clojure-mode`; CIDER is the interactive environment.
- **CIDER** — Clojure Interactive Development Environment that Rocks; the
  Emacs package (installed by `err-core`) that turns Emacs into a Clojure
  IDE.
- **nREPL** — the network REPL protocol Clojure programs expose so editors
  can evaluate code inside the running process. CIDE↔CIDER talk over nREPL;
  Clojure services on knoxx expose an nREPL endpoint for interactive work.
- **REPL** — Read-Eval-Print Loop: an interactive prompt where code is
  evaluated live inside your program's runtime. The core of Clojure's
  REPL-driven development style.
- **babashka (bb)** — a fast-starting, single-binary Clojure for scripting
  and CLI tasks. Used across the constellation for automation scripts
  (`bb.edn` files); may appear in tasks run from Emacs shells here.
- **shadow-cljs** — a ClojureScript build tool (used by several sibling
  repos, e.g. knoxx's frontend/backend). If you edit service code from this
  editor, CIDER connects to its nREPL.
- **clj-kondo** — a static linter for Clojure/ClojureScript; often wired
  into flycheck/lsp so the editor shows lint diagnostics inline.

## Environment terms

- **`.spacemacs.env`** — the file Spacemacs loads to set up environment
  variables at startup (the successor of the `exec-path-from-shell` dance).
  On knoxx it is uncommitted, in-flight server-side adaptation.
- **`core/user-env.el`** — this repo's own environment wiring, loaded by
  `dotspacemacs/user-env`. Also uncommitted on knoxx (server-side values).
- **direnv** — the per-directory environment tool; the `direnv` layer
  integrates it so Emacs buffers inherit project-specific env.
