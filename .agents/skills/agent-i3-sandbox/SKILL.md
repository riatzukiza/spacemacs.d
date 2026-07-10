---
name: agent-i3-sandbox
description: Provision an isolated X11/i3/Emacs agent sandbox in Docker. Use when an agent needs a headless desktop, window-manager automation, i3 config testing, or named Emacs daemon isolation without touching the operator's live session.
---

# Skill: agent-i3-sandbox

Provision an isolated workspace for an autonomous agent with its own X11 display,
i3 instance, and named Emacs daemon so it can manipulate windows, run editor
automations, and inspect i3 IPC state without touching the operator's live
desktop.

## Location

This skill is self-contained under:

```
~/.spacemacs.d/.agents/skills/agent-i3-sandbox/
├── SKILL.md
├── docker-compose.yml
├── Dockerfile
├── Dockerfile.spacemacs
├── Dockerfile.dev
├── i3.config
├── init.el
├── .spacemacs.agent
└── scripts/
    ├── agentctl
    ├── agent-entrypoint
    ├── agent-emacsclient
    ├── snapshot-i3
    ├── smoke-i3
    └── warmup-spacemacs
```

All scripts are here. Do not assume they need to be created elsewhere.

## Use when

- an agent must hack on i3 config safely,
- an agent needs background Emacs automation,
- window-manager integration or E2E testing is required,
- the operator must keep using their own desktop uninterrupted,
- validating i3 keybindings, Helm/Consult popups, emacsclient bridges, or any window-manager/Emacs integration that would normally require interacting with the operator's live X session.

## Important

Do not iterate on i3 or Emacs window-manager integrations directly in the
operator's live session. Use this sandbox to reproduce the setup, run the
commands, take screenshots or i3 IPC snapshots, and only then apply the proven
changes to the operator's real config.

The intended workflow for WM/Emacs integration work is:

1. Copy or mount the operator's i3/Spacemacs config into the sandbox (use the
   `dev` target or bind-mount from the host).
2. Reproduce the issue inside the container.
3. Apply candidate fixes and verify with `agentctl smoke`, `agentctl snapshot`,
   `import` screenshots, or `xdotool`/key simulations.
4. Once the behavior is correct, copy the final config back to the operator's
   live paths and reload.

## Architecture

Each agent target gets:

- its own container,
- its own X11 display via Xvfb,
- its own i3 process,
- its own named Emacs daemon,
- an isolated HOME,
- a mounted project workspace,
- helper scripts for launching, inspecting, and testing.

## Targets

| Target | Purpose | Emacs daemon name |
|---|---|---|
| `core` | Fast Xvfb + i3 + Emacs daemon + scripts. | `agent-core` |
| `spacemacs` | Same as core, plus Spacemacs and the `agent-sandbox` private layer. | `agent-spacemacs` |
| `dev` | Mounts local layer files and configs for iterative layer development. | `agent-dev` |

## Named Emacs daemon behavior

Emacs daemon sockets are created relative to `$XDG_RUNTIME_DIR` when the
daemon is named and `server-socket-dir` is left at its default:

- Inside the container: `$XDG_RUNTIME_DIR/emacs/<name>`.
- Default container value: `/tmp/runtime-agent/emacs/<name>`.

All `emacsclient` calls in the scripts use `-s <name>` explicitly, so multiple
targets can run concurrently without socket collision.

| Target | `EMACS_DAEMON_NAME` | `emacsclient` invocation |
|---|---|---|
| `core` | `agent-core` | `emacsclient -s agent-core ...` |
| `spacemacs` | `agent-spacemacs` | `emacsclient -s agent-spacemacs ...` |
| `dev` | `agent-dev` | `emacsclient -s agent-dev ...` |

## Operating loop

1. Build the base image: `docker compose build core`
2. Build higher-fidelity targets: `docker compose build spacemacs dev`
3. Start a target: `./scripts/agentctl up <target>`
4. Verify readiness: `./scripts/agentctl smoke <target>`
5. Snapshot i3 state: `./scripts/agentctl snapshot <target>`
6. Open a file through the daemon: `./scripts/agentctl emacs <target> /workspace/path/to/file`
7. Tear down: `./scripts/agentctl down <target>`

## Safety rules

- Do not mount the host X socket into the agent container by default.
- Use named Emacs daemons and explicit clients.
- Treat the container as disposable.
- Prefer i3 IPC snapshots over screenshots.

## Commands

```bash
./scripts/agentctl up core
./scripts/agentctl smoke core
./scripts/agentctl snapshot core
./scripts/agentctl emacs core /workspace/README.md
./scripts/agentctl up spacemacs
./scripts/agentctl smoke spacemacs
./scripts/agentctl emacs spacemacs /workspace/README.md
```
