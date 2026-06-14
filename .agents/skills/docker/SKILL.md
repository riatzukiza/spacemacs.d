# Skill: agent-i3-sandbox

Provision an isolated workspace for an autonomous agent with its own X11 display,
i3 instance, and named Emacs daemon so it can manipulate windows, run editor
automations, and inspect i3 IPC state without touching the operator's live
desktop.

## Use when

- an agent must hack on i3 config safely,
- an agent needs background Emacs automation,
- window-manager integration or E2E testing is required,
- the operator must keep using their own desktop uninterrupted.

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
