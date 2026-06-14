---
uuid: "agent-multi-daemon-names"
title: "Support multiple concurrent named agent daemons"
status: "pending"
priority: "P2"
labels: ["agent-i3-sandbox", "emacs", "daemon", "concurrency"]
created_at: "2026-06-14T00:00:00Z"
source: ".spacemacs.d/docs/notes/agent-i3-sandbox/01-core-container-harness.md"
points: 3
category: "infrastructure"
---

# Support multiple concurrent named agent daemons

Scale the agent i3 sandbox from one default daemon to multiple named agent instances running concurrently.

## Tasks

- Parameterize compose services and scripts on `AGENT_NAME` / `EMACS_DAEMON_NAME`.
- Default examples: `agent-1`, `agent-2`, `agent-core`, `agent-spacemacs`, `agent-dev`.
- Ensure i3 IPC socket and display are isolated per agent instance.
- Update `agentctl` to accept an agent name argument.
- Document how to run `agentctl up core agent-1` alongside `agentctl up core agent-2`.

## Acceptance

- Two agents can run at the same time without socket/display collisions.
- `emacsclient -s agent-1` and `emacsclient -s agent-2` connect to distinct daemons.
- Smoke tests pass for each named instance.

---

Synthesized from note on 2026-06-14.
