---
uuid: "agent-script-integration-tests"
title: "Add integration tests for agent sandbox helper scripts"
status: "pending"
priority: "P2"
labels: ["agent-i3-sandbox", "testing", "bats", "docker"]
created_at: "2026-06-14T00:00:00Z"
source: ".spacemacs.d/docs/notes/agent-i3-sandbox/01-core-container-harness.md"
points: 3
category: "testing"
---

# Add integration tests for agent sandbox helper scripts

Add a lightweight integration test suite around the shell helper scripts, runnable in CI.

## Tasks

- Choose `bats-core` or `pytest` for shell-script testing.
- Add tests for `agent-entrypoint` readiness behavior.
- Add tests for `agentctl` argument dispatch.
- Add tests for `snapshot-i3` output format and uniqueness.
- Add tests for `smoke-i3` pass/fail behavior.
- Wire into `make test`.

## Acceptance

- `make test` runs the script integration suite.
- Each helper script has at least one happy-path and one error-path test.
- CI fails when a script regresses.

---

Synthesized from note on 2026-06-14.
