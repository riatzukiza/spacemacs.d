---
uuid: "agent-xpra-visual-attach"
title: "Add optional Xpra visual attach for agent sandbox inspection"
status: "pending"
priority: "P3"
labels: ["agent-i3-sandbox", "xpra", "docker", "observability"]
created_at: "2026-06-14T00:00:00Z"
source: ".spacemacs.d/docs/notes/agent-i3-sandbox/01-core-container-harness.md"
points: 3
category: "infrastructure"
---

# Add optional Xpra visual attach for agent sandbox inspection

Provide an optional Xpra layer so an operator can peek into an agent's headless desktop without binding it to the host X session.

## Tasks

- Add an `xpra` service or mode to the Docker compose setup.
- Expose the agent's X display through Xpra (HTML5 or local client).
- Ensure Xpra is opt-in and does not start by default for the fast loop.
- Document how to attach: `agentctl attach agent-1` or browser URL.

## Acceptance

- Running agent desktop is viewable via Xpra without host X socket mount.
- Default `agentctl up core` path remains fast and headless.
- Attach command is documented in the agent-i3-sandbox README/SKILL.

---

Synthesized from note on 2026-06-14.
