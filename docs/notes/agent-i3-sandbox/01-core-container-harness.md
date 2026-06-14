---
subject: agent-i3-sandbox
tags: [agent-i3-sandbox, docker, i3, xvfb, emacs-daemon, container]
created: 2026-06-12
---

## Facts

- Fact: Xvfb provides a virtual X display buffer so GUI programs can run headlessly, which makes it a good fit for a containerized i3 session. [tobyho](https://tobyho.com/2015/01/09/headless-browser-testing-xvfb/)
- Fact: Emacs supports named daemons such as `emacs --daemon=my-other-daemon`, and clients can target a specific daemon/socket, which is exactly what you want for agent-local editor state. [systemcrafters](https://systemcrafters.net/emacs-tips/using-the-emacs-daemon/)
- Fact: Emacs socket locations vary by setup, so explicitly naming the daemon/socket is more reliable than depending on defaults. [reddit](https://www.reddit.com/r/emacs/comments/9zdluh/emacs_daemon_does_not_work_but_serverstart_does/)

## Interpretation

You want two isolation layers:

- Human session: your real i3, your real Emacs daemon, your real focus.
- Agent session: disposable container, its own X11 display, its own i3, its own Emacs daemon, optional browser/rofi/file manager, snapshotable tree state.

That means the core loop should be:

1. Start agent container.
2. Boot Xvfb.
3. Boot i3 inside that display.
4. Boot `emacs --fg-daemon=<agent-name>`.
5. Run agent commands through `docker exec`.
6. Snapshot i3 via IPC.
7. Destroy or recycle the container.

## Layout

I’d structure it like this:

```text
agent-i3-sandbox/
├── SKILL.md
├── docker-compose.yml
├── Dockerfile
├── i3.config
├── init.el
└── scripts/
    ├── agent-entrypoint
    ├── agent-emacsclient
    ├── snapshot-i3
    ├── smoke-i3
    └── agentctl
```

This keeps the boundaries clean:
- Docker owns lifecycle.
- `agent-entrypoint` owns boot order.
- `i3.config` owns WM behavior.
- `init.el` owns agent-local Emacs behavior.
- `agentctl` is the human control plane.

## Starter files

### `SKILL.md`

```md
# Skill: agent-i3-sandbox

Provision an isolated workspace for an autonomous agent with its own X11 display,
i3 instance, and Emacs daemon so it can manipulate windows, run editor automations,
and inspect i3 IPC state without touching the operator's live desktop.

## Use when

- an agent must hack on i3 config safely,
- an agent needs background Emacs automation,
- window-manager integration or E2E testing is required,
- the operator must keep using their own desktop uninterrupted.

## Architecture

Each agent gets:

- its own container,
- its own X11 display via Xvfb,
- its own i3 process,
- its own named Emacs daemon,
- an isolated HOME,
- a mounted project workspace,
- helper scripts for launching, inspecting, and testing.

## Defaults

- Display: `:99`
- Emacs daemon name: `agent`
- Workspace mount: `/workspace`
- i3 config: `/home/agent/.config/i3/config`
- Snapshot dir: `/workspace/.artifacts/i3`

## Operating loop

1. Start the container.
2. Wait for Xvfb, Emacs, and i3 readiness.
3. Execute agent commands through `docker exec`.
4. Snapshot `i3-msg -t get_tree` and `i3-msg -t get_workspaces`.
5. Assert on normalized JSON.
6. Tear down the container.

## Safety rules

- Do not mount the host X socket into the agent container by default.
- Use named Emacs daemons and explicit clients.
- Treat the container as disposable.
- Prefer i3 IPC snapshots over screenshots.

## Commands

```bash
docker compose up -d --build
docker compose exec agent bash
docker compose exec agent snapshot-i3
docker compose exec agent smoke-i3
docker compose exec agent agent-emacsclient /workspace/path/to/file
```
```

### `docker-compose.yml`

```yaml
services:
  agent:
    build: .
    container_name: agent-i3-sandbox
    environment:
      DISPLAY: ":99"
      XDG_RUNTIME_DIR: /tmp/runtime-agent
      EMACS_DAEMON_NAME: agent
    volumes:
      - ./:/workspace
    working_dir: /workspace
    tty: true
    stdin_open: true
```

### `Dockerfile`

```dockerfile
FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:99 \
    XDG_RUNTIME_DIR=/tmp/runtime-agent \
    HOME=/home/agent \
    SHELL=/bin/bash \
    EMACS_DAEMON_NAME=agent

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    dbus-x11 \
    emacs \
    i3-wm \
    jq \
    procps \
    rofi \
    rxvt-unicode \
    x11-apps \
    xdotool \
    xvfb \
    xterm \
 && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash agent \
 && mkdir -p /workspace /tmp/runtime-agent \
 && chown -R agent:agent /workspace /tmp/runtime-agent /home/agent

USER agent
WORKDIR /workspace

RUN mkdir -p /home/agent/.config/i3 /home/agent/.emacs.d /home/agent/bin

COPY --chown=agent:agent i3.config /home/agent/.config/i3/config
COPY --chown=agent:agent init.el /home/agent/.emacs.d/init.el
COPY --chown=agent:agent scripts/ /home/agent/bin/
RUN chmod +x /home/agent/bin/*

ENTRYPOINT ["/home/agent/bin/agent-entrypoint"]
```

### `i3.config`

```i3
set $mod Mod4
font pango:monospace 10

default_border pixel 1
focus_follows_mouse no
workspace_auto_back_and_forth yes

exec --no-startup-id urxvtd -q -o -f

bindsym $mod+Return exec urxvtc
bindsym $mod+d exec rofi -show drun

bindsym $mod+Shift+c reload
bindsym $mod+Shift+r restart
bindsym $mod+Shift+e exec "i3-nagbar -t warning -m 'Exit agent i3?' -B 'yes' 'i3-msg exit'"

bar {
  mode hide
}
```

### `init.el`

This is intentionally minimal. If this grows, it should probably become a private Spacemacs layer rather than staying as ad hoc init glue.

```elisp
(setq inhibit-startup-screen t
      initial-scratch-message nil
      make-backup-files nil
      auto-save-default nil)

(require 'server)
(unless (server-running-p)
  (server-start))

(defun agent/open-workspace ()
  (interactive)
  (dired "/workspace"))
```

### `scripts/agent-entrypoint`

```bash
#!/usr/bin/env bash
set -euo pipefail

export DISPLAY="${DISPLAY:-:99}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/runtime-agent}"
export EMACS_DAEMON_NAME="${EMACS_DAEMON_NAME:-agent}"

mkdir -p "$XDG_RUNTIME_DIR"

Xvfb "$DISPLAY" -screen 0 1600x1000x24 -nolisten tcp >/tmp/xvfb.log 2>&1 &
XVFB_PID=$!

for _ in $(seq 1 50); do
  xdpyinfo -display "$DISPLAY" >/dev/null 2>&1 && break
  sleep 0.1
done

emacs --fg-daemon="$EMACS_DAEMON_NAME" >/tmp/emacs.log 2>&1 &
EMACS_PID=$!

i3 >/tmp/i3.log 2>&1 &
I3_PID=$!

cleanup() {
  kill "$I3_PID" "$EMACS_PID" "$XVFB_PID" >/dev/null 2>&1 || true
}
trap cleanup EXIT INT TERM

wait -n "$I3_PID" "$EMACS_PID" "$XVFB_PID"
```

### `scripts/agent-emacsclient`

```bash
#!/usr/bin/env bash
set -euo pipefail
exec emacsclient -s "${EMACS_DAEMON_NAME:-agent}" -n "$@"
```

### `scripts/snapshot-i3`

```bash
#!/usr/bin/env bash
set -euo pipefail

out_dir="${1:-/workspace/.artifacts/i3}"
mkdir -p "$out_dir"
ts="$(date +%Y%m%d-%H%M%S)"

i3-msg -t get_tree > "$out_dir/tree-$ts.json"
i3-msg -t get_workspaces > "$out_dir/workspaces-$ts.json"

printf '%s\n' "$out_dir/tree-$ts.json" "$out_dir/workspaces-$ts.json"
```

### `scripts/smoke-i3`

```bash
#!/usr/bin/env bash
set -euo pipefail

i3-msg -t get_version >/dev/null
emacsclient -s "${EMACS_DAEMON_NAME:-agent}" -e '(progn (find-file "/workspace") t)' >/dev/null

xterm -display "$DISPLAY" -e sh -lc 'sleep 2' >/tmp/smoke-xterm.log 2>&1 &
sleep 1

i3-msg -t get_tree \
  | jq '.. | objects
        | select(.window_properties? and .window_properties.class? == "XTerm")
        | {name, focused, floating}'
```

### `scripts/agentctl`

```bash
#!/usr/bin/env bash
set -euo pipefail

case "${1:-}" in
  up)
    docker compose up -d --build
    ;;
  down)
    docker compose down -v
    ;;
  shell)
    docker compose exec agent bash
    ;;
  logs)
    docker compose logs -f agent
    ;;
  snapshot)
    docker compose exec agent snapshot-i3
    ;;
  smoke)
    docker compose exec agent smoke-i3
    ;;
  emacs)
    shift
    docker compose exec agent agent-emacsclient "$@"
    ;;
  *)
    echo "usage: $0 {up|down|shell|logs|snapshot|smoke|emacs ...}" >&2
    exit 1
    ;;
esac
```

## Why this belongs here

### Facts

- Container boot and WM lifecycle are not Spacemacs concerns; they belong in shell and Docker.
- Emacs daemon naming and editor-side helper code belong in Emacs config.
- Reusable, cross-package behavior in Spacemacs usually deserves a real layer instead of growing a giant dotfile. [reddit](https://www.reddit.com/r/i3wm/comments/9w64j1/can_i_should_i_use_i3_as_a_floating_window_manager/)

### Suggested change

Start with the container kit above as external infrastructure, then add a private Spacemacs layer only for agent-facing editor commands, for example:
- `agent/open-workspace`
- `agent/snapshot-i3`
- `agent/send-path-to-opencode`
- `agent/new-vterm-in-project`

That preserves package ownership and keeps your dotfile from turning into an orchestration dump. [reddit](https://www.reddit.com/r/i3wm/comments/9w64j1/can_i_should_i_use_i3_as_a_floating_window_manager/)

## Next evolution

Once the base loop works, I’d add these in order:

- **Per-agent names**: `EMACS_DAEMON_NAME=agent-1`, `agent-2`, etc., so multiple agents can run concurrently. Named daemons are explicitly supported by Emacs. [systemcrafters](https://systemcrafters.net/emacs-tips/using-the-emacs-daemon/)
- **Visual attach**: Xpra as an optional inspection layer when you want to peek into the agent’s desktop without binding it to your host X session. Xpra is used to expose GUI applications from containers, including browser access in some setups. [mybyways](https://mybyways.com/blog/running-linux-gui-applications-in-a-docker-container-using-xpra)
- **E2E assertions**: snapshot normalized `get_tree` JSON and compare against expected shapes rather than screenshots, because i3 IPC exposes the tree directly. [reddit](https://www.reddit.com/r/i3wm/comments/9w64j1/can_i_should_i_use_i3_as_a_floating_window_manager/)

## Verification

- `docker compose up -d --build`
- `docker compose exec agent bash`
- `docker compose exec agent smoke-i3`
- `docker compose exec agent snapshot-i3`
- `docker compose exec agent agent-emacsclient /workspace/README.md`

If the next move is implementation, I’d do one of two paths:

1. Minimal path: turn the above into actual files verbatim.
2. Better path: add a private Spacemacs layer `agent-sandbox` plus `bats` or `pytest` integration tests around the helper scripts.
