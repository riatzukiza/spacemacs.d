---
subject: agent-i3-sandbox
tags: [agent-i3-sandbox, spacemacs, private-layer, docker-target, layer-architecture]
created: 2026-06-13
---

Yes — I would make Spacemacs an **optional target**, not the base image. Spacemacs can absolutely live in a container, but fresh installs and full package bootstrap can be slow enough that a lean default target is better for fast i3/E2E loops, while a second target gives you Spacemacs parity when you actually need layer behavior or private-layer code under test. [github](https://github.com/syl20bnr/spacemacs/issues/5658)

## Facts

In Spacemacs, a layer has distinct responsibilities: `layers.el` declares dependencies, `packages.el` owns packages through `init`/`pre-init`/`post-init`, `funcs.el` holds helper functions, `config.el` holds layer variables and related setup, and `keybindings.el` is for package-independent bindings. [reddit](https://www.reddit.com/r/i3wm/comments/9w64j1/can_i_should_i_use_i3_as_a_floating_window_manager/)
That means your instinct is right: the durable logic should mostly be ordinary Emacs Lisp in layer files, especially `funcs.el`, with package wiring left in `packages.el` and timing-sensitive setup placed in the right lifecycle hook. [reddit](https://www.reddit.com/r/i3wm/comments/9w64j1/can_i_should_i_use_i3_as_a_floating_window_manager/)
Spacemacs also supports container-oriented workflows at a basic level, and there are long-standing examples of people running Spacemacs in Docker, but startup cost and fresh-install state are common pain points. [github](https://github.com/syl20bnr/spacemacs/issues/8144)

## Interpretation

So I would not ask every agent container to pay the full Spacemacs bootstrap tax by default. Instead, I’d define a small target matrix:

| Target | Purpose | Default |
|---|---|---|
| `core` | Xvfb + i3 + Emacs daemon + scripts, fastest loop for WM integration and IPC snapshots.  [tobyho](https://tobyho.com/2015/01/09/headless-browser-testing-xvfb/) | Yes. |
| `spacemacs` | Same as `core`, but with Spacemacs installed and a mounted private layer or dotfile for realistic editor behavior.  [github](https://github.com/syl20bnr/spacemacs/issues/5658) | No. |
| `dev` | Full parity image for hacking on Spacemacs layers or source, possibly mounting your local layer tree and package caches.  [reddit](https://www.reddit.com/r/i3wm/comments/9w64j1/can_i_should_i_use_i3_as_a_floating_window_manager/) | No. |

That gives you the right defaults: quick container spin-up for most agent work, and a slower but truer environment when the thing under test is actually Spacemacs integration. [github](https://github.com/syl20bnr/spacemacs/issues/8144)

## Suggested changes

I’d structure the kit like this:

```text
agent-i3-sandbox/
├── SKILL.md
├── docker-compose.yml
├── Dockerfile
├── Dockerfile.spacemacs
├── i3.config
├── init.el
├── .spacemacs.agent
├── private/
│   └── agent-sandbox/
│       ├── packages.el
│       ├── funcs.el
│       ├── config.el
│       └── keybindings.el
└── scripts/
    ├── agent-entrypoint
    ├── agent-emacsclient
    ├── snapshot-i3
    ├── smoke-i3
    └── agentctl
```

Why this belongs here:
- `core` keeps the WM harness independent of Spacemacs, which makes failures easier to localize. [i3wm](https://i3wm.org/docs/ipc.html)
- The Spacemacs-specific behavior should live in a private layer, because once the config becomes reusable and cross-package, a real layer is the Spacemacs-native path instead of piling more into the dotfile. [spacemacs](https://www.spacemacs.org/doc/FAQ.html)
- Emacs daemons should be named explicitly per target or per agent, since Emacs supports multiple named servers and clients can target them with `-s`. [reddit](https://www.reddit.com/r/emacs/comments/p45akt/how_to_run_multiple_emacs_daemon_instances/)

## Docker targets

I’d use a multi-stage or multi-file setup.

### Base `core` image
- Debian/Ubuntu base.
- `xvfb`, `i3-wm`, `jq`, `xdotool`, `rofi`, `xterm`, `emacs`.
- Starts `Xvfb`, then `emacs --fg-daemon=<name>`, then `i3`. [gnu](https://www.gnu.org/software/emacs/manual/html_node/emacs/Emacs-Server.html)

### `spacemacs` image
- Inherits from `core`.
- Clones Spacemacs into `/home/agent/.emacs.d`.
- Copies in `.spacemacs.agent`.
- Copies in `private/agent-sandbox/`.
- Optionally warms packages during image build so runtime startup is not doing first-boot installation every time. The general Docker principle here is to bake expensive steps into cached layers when possible. [cloudbees](https://www.cloudbees.com/blog/docker-build-without-cache)

A good mental split is:
- `core` tests your WM and shell contracts.
- `spacemacs` tests your layer contracts.
- `dev` tests source edits against a near-real environment.

## Spacemacs placement

For Spacemacs-specific code, I would avoid putting real logic in `.spacemacs.agent` beyond layer declaration and a few variables. In Spacemacs terms, `.spacemacs` should mainly select layers and user lifecycle hooks, while reusable behavior goes into a private layer. [reddit](https://www.reddit.com/r/i3wm/comments/9w64j1/can_i_should_i_use_i3_as_a_floating_window_manager/)
So the private layer might look like:

- `layers.el`: depends on `emacs-lisp`, maybe `shell`, maybe `docker`. [spacemacs](https://www.spacemacs.org/layers/+tools/docker/README.html)
- `packages.el`: declares `i3ipc` helpers or any package integrations.
- `funcs.el`: `agent/snapshot-i3`, `agent/new-vterm`, `agent/find-workspace`, `agent/send-path-to-opencode`.
- `config.el`: layer variables like agent daemon name, artifact directory, workspace root.
- `keybindings.el`: package-independent entry points. [reddit](https://www.reddit.com/r/i3wm/comments/9w64j1/can_i_should_i_use_i3_as_a_floating_window_manager/)

That preserves ownership clarity and keeps the container boot image from being tightly coupled to ad hoc dotfile code. [reddit](https://www.reddit.com/r/i3wm/comments/9w64j1/can_i_should_i_use_i3_as_a_floating_window_manager/)

## Recommendation

My recommendation is:

1. Keep the current simple container as the default `core` target. [tobyho](https://tobyho.com/2015/01/09/headless-browser-testing-xvfb/)
2. Add a `spacemacs` target that mounts or bakes a private layer, not a giant hand-edited `.spacemacs`. [reddit](https://www.reddit.com/r/i3wm/comments/9w64j1/can_i_should_i_use_i3_as_a_floating_window_manager/)
3. Put almost all agent behavior in `funcs.el` plus a little package wiring in `packages.el`, because that matches the Spacemacs loading model and makes the code portable between container and host. [reddit](https://www.reddit.com/r/i3wm/comments/9w64j1/can_i_should_i_use_i3_as_a_floating_window_manager/)
4. Use named daemons per target, for example `agent-core`, `agent-spacemacs`, and `agent-dev`, and always connect with `emacsclient -s <name>`. [laihoconsulting](https://laihoconsulting.com/blog/2021-08-emacs-daemon-and-multiple-daemons/)

Concretely, I’d expose these control-plane commands:

- `agentctl up core`
- `agentctl up spacemacs`
- `agentctl up dev`
- `agentctl smoke core`
- `agentctl smoke spacemacs`
- `agentctl emacs spacemacs /workspace/foo.el`

That gives you a sane default, plus higher-fidelity targets when the test subject is really the Spacemacs layer rather than i3 itself. [github](https://github.com/syl20bnr/spacemacs/issues/8144)

Would you like me to write the actual `SKILL.md`, `Dockerfile` pair, and `agentctl` script for the three-target design next?
