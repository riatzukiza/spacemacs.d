---
subject: agent-i3-sandbox
tags: [agent-i3-sandbox, docker-compose, agentctl, smoke-test, dev-target]
created: 2026-06-13
---

I wrote the two-image setup plus the control script: a fast `core` target and a slower `spacemacs` target, with Docker Compose wiring, entrypoint boot logic, and helper scripts for `emacsclient`, i3 snapshots, and smoke testing. The split matches the design we discussed: keep the default loop lightweight, and only pay the Spacemacs bootstrap cost when you actually need layer-level behavior under test. [github](https://github.com/syl20bnr/spacemacs/issues/8144)

## What’s in it

The setup includes:
- a base image that launches Xvfb, a named Emacs daemon, and i3 in isolation, 
- a Spacemacs image that clones Spacemacs and injects a private layer plus a dedicated `.spacemacs` file, 
- a small control plane script that lets you run `up`, `shell`, `logs`, `snapshot`, `smoke`, and `emacs` against either `core` or `spacemacs`. 

## How to use it

The main loop is:

- `./scripts/agentctl up core` to start the fast target. 
- `./scripts/agentctl up spacemacs` to start the higher-fidelity target. 
- `./scripts/agentctl smoke core` or `spacemacs` to verify i3 and Emacs came up correctly. 
- `./scripts/agentctl snapshot core` to capture `get_tree` and `get_workspaces` JSON. [reddit](https://www.reddit.com/r/i3wm/comments/9w64j1/can_i_should_i_use_i3_as_a_floating_window_manager/)
- `./scripts/agentctl emacs spacemacs /workspace/foo.el` to open a file through the target’s named daemon. [gnu](https://www.gnu.org/software/emacs/manual/html_node/emacs/Emacs-Server.html)

## Spacemacs fit

The Spacemacs target keeps reusable behavior in layer-style Emacs Lisp rather than bloating the dotfile, which is the Spacemacs-native direction once behavior becomes reusable and cross-package. [reddit](https://www.reddit.com/r/i3wm/comments/9w64j1/can_i_should_i_use_i3_as_a_floating_window_manager/)
Right now the private layer stub is intentionally tiny, but it gives you the correct place to grow `funcs.el`, then later add `packages.el`, `config.el`, and `keybindings.el` when the integration stops being just a prototype. [reddit](https://www.reddit.com/r/i3wm/comments/9w64j1/can_i_should_i_use_i3_as_a_floating_window_manager/)

## First fixes I’d make

Two practical upgrades come next.

- Add a third `dev` target that mounts your local Spacemacs checkout or private layers directly, so an agent can hack on layer code without rebuilding the image each time. That aligns with your “few different targets” idea and keeps the fast default intact. [reddit](https://www.reddit.com/r/i3wm/comments/9w64j1/can_i_should_i_use_i3_as_a_floating_window_manager/)
- Warm package installation in the Spacemacs image build, because Spacemacs startup cost is a known friction point and baking more of that cost into Docker layers will improve the agent loop. [github](https://github.com/syl20bnr/spacemacs/issues/5658)

## Validation

Run these in order:

- `docker compose build core spacemacs` from the project root. 
- `./scripts/agentctl up core` and then `./scripts/agentctl smoke core`. 
- `./scripts/agentctl up spacemacs` and then `./scripts/agentctl logs spacemacs` on first boot, since package initialization may take longer. [github](https://github.com/syl20bnr/spacemacs/issues/8144)
- In the Spacemacs target, confirm the daemon name matches the target and that the private layer code loads as expected. [gnu](https://www.gnu.org/software/emacs/manual/html_node/emacs/Emacs-Server.html)

Next I’d recommend adding the `dev` target plus a real `agent-sandbox` Spacemacs layer skeleton with `packages.el`, `config.el`, and `keybindings.el` so the containerized editor side grows in the Spacemacs way rather than as loose init glue. [reddit](https://www.reddit.com/r/i3wm/comments/9w64j1/can_i_should_i_use_i3_as_a_floating_window_manager/)
