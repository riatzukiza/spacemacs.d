---
uuid: "agent-i3-e2e-snapshot-assertions"
title: "Add E2E snapshot assertions over i3 IPC tree"
status: "pending"
priority: "P1"
labels: ["agent-i3-sandbox", "testing", "i3", "ipc", "snapshot"]
created_at: "2026-06-14T00:00:00Z"
source: ".spacemacs.d/docs/notes/agent-i3-sandbox/01-core-container-harness.md"
points: 5
category: "testing"
---

# Add E2E snapshot assertions over i3 IPC tree

Replace ad-hoc smoke checks with normalized `i3-msg -t get_tree` snapshot assertions that verify WM behavior after scripted actions.

## Tasks

- Add a test harness script that runs inside the agent container.
- Perform actions (open terminal, focus window, change workspace).
- Capture `get_tree` and `get_workspaces` after each action.
- Compare against expected JSON shapes (window class, focused state, workspace name, layout).
- Wire into CI via `make test` or GitHub Actions.

## Acceptance

- A failing WM behavior causes a test failure with a diff against expected tree shape.
- Tests run in the container without host dependencies.
- At least one end-to-end flow is covered: open XTerm -> assert it appears focused on the expected workspace.

---

Synthesized from note on 2026-06-14.
