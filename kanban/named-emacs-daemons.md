---
uuid: "named-emacs-daemons"
title: "Use named Emacs daemons per agent target"
status: "review"
priority: "P2"
labels: ["emacs", "daemon", "i3", "docker"]
created_at: "2026-06-12T22:40:00Z"
source: ".spacemacs.d/docs/notes/agent-i3-sandbox/01-core-container-harness.md"
points: 2
category: "infrastructure"
---

# Use named Emacs daemons per agent target

Allow multiple agent sandboxes to run concurrently by using named Emacs daemons:

- `EMACS_DAEMON_NAME=agent-core` for core target.
- `EMACS_DAEMON_NAME=agent-spacemacs` for Spacemacs target.
- `EMACS_DAEMON_NAME=agent-dev` for dev target.
- All `emacsclient` calls use `-s <name>` explicitly.
- Document socket location behavior in `SKILL.md`.

## Acceptance

- Two targets can run at the same time without socket collision.
- `agentctl emacs <target> <path>` connects to the correct daemon.

---

Extracted from note on 2026-06-12.
