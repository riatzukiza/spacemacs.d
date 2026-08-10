---
uuid: "agent-i3-sandbox-review-fixes"
title: "Address CodeRabbit review comments on PR #1"
status: "review"
priority: "P1"
labels: ["infrastructure", "docker", "spacemacs", "review"]
created_at: "2026-06-13T00:00:00Z"
source: ".spacemacs.d/spec/agent-i3-sandbox-review-fixes.md"
points: 5
category: "infrastructure"
---

# Spec: Address CodeRabbit review comments on PR #1

## PR under review

- Repository: `riatzukiza/spacemacs.d`
- PR: https://github.com/riatzukiza/spacemacs.d/pull/1
- Branch: `feat/agent-i3-sandbox`
- Fix branch: `fix/agent-i3-sandbox-review`
- Base: `main`

## Review source

CodeRabbit auto-generated review, run ID `3105d30a-ddf6-41b2-ab96-56dcdf5c0d30`.
Actionable comments posted: 8 (plus 1 nitpick).

## Requirements

Address each actionable comment that is still valid in the current code. Keep changes minimal and validated.

### 1. `docker/.spacemacs.agent` — layer registration and path fallback

Current code (`docker/.spacemacs.agent:19-24`):

```elisp
(defun dotspacemacs/user-config ()
  (let ((layer-dir (expand-file-name "private/agent-sandbox" user-emacs-directory)))
    (load-file (expand-file-name "config.el" layer-dir))
    (load-file (expand-file-name "funcs.el" layer-dir))
    (when (fboundp 'spacemacs/set-leader-keys)
      (load-file (expand-file-name "keybindings.el" layer-dir)))))
```

Issues:

- The `agent-sandbox` layer is not listed in `dotspacemacs-configuration-layers`.
- `dotspacemacs/user-config` hard-codes `private/agent-sandbox`, which only exists in the dev image mount (`docker/docker-compose.yml:43`). In the spacemacs image the layer files are not mounted there, so loading would fail.

Required change:

- Register `agent-sandbox` in `dotspacemacs-configuration-layers`.
- In `dotspacemacs/user-config`, try `layers/agent-sandbox` under `user-emacs-directory` first, then fall back to `private/agent-sandbox`; only `load-file` existing files; keep the `fboundp` guard for keybindings.

### 2. `docker/docker-compose.yml` and `docker/Dockerfile.spacemacs` — mount the layer for Spacemacs

The spacemacs service uses `.spacemacs.agent`, which now registers `agent-sandbox`. The layer must be available inside the container or Spacemacs will fail to find it.

Required change:

- In `docker-compose.yml`, add `../layers/agent-sandbox:/home/agent/.emacs.d/private/agent-sandbox` to the spacemacs service volumes.
- In `Dockerfile.spacemacs`, remove the `COPY private/ ...` line because `private/` does not exist in the Docker build context; the layer is now provided at runtime via the volume mount.

### 3. `docker/Dockerfile.dev` and `docker/Dockerfile.spacemacs` — pin Spacemacs ref

Current code (`docker/Dockerfile.dev:36`, `docker/Dockerfile.spacemacs:36`):

```dockerfile
RUN git clone --depth 1 https://github.com/syl20bnr/spacemacs .emacs.d
```

Issue: clones the default branch; build is not reproducible.

Required change:

- Add `ARG SPACEMACS_REF` with a sensible default tag/commit.
- Clone and checkout the pinned ref in both files.

### 4. `docker/scripts/agent-entrypoint` — Xvfb readiness check

Current code (`docker/scripts/agent-entrypoint:12-15`):

```bash
for _ in $(seq 1 50); do
  xdpyinfo -display "$DISPLAY" >/dev/null 2>&1 && break
  sleep 0.1
done
```

Issue: if the loop times out, the script continues.

Required change:

- After the loop, run `xdpyinfo` again; if it fails, print an error and `exit 1`.

### 5. `docker/scripts/agentctl` — `up all` handling

Current code (`docker/scripts/agentctl:8-10`):

```bash
case "$cmd" in
  up)
    docker compose up -d --build "$target"
```

Issue: `down` treats `all` specially but `up` does not, conflicting with the usage line.

Required change:

- In the `up` case, if `"$target" == "all"`, run `docker compose up -d --build` without a service argument; otherwise run it with `"$target"`.

### 6. `docker/scripts/smoke-i3` — assert XTerm appears

Current code (`docker/scripts/smoke-i3:9`):

```bash
i3-msg -t get_tree | jq '.. | objects | select(.window_properties? and .window_properties.class? == "XTerm") | {name, focused, floating}'
```

Issue: `jq` returns success even with no matches.

Required change:

- Add `jq -e` so the script exits non-zero if no XTerm window is found.

### 7. `docker/scripts/snapshot-i3` — unique timestamps

Current code (`docker/scripts/snapshot-i3:5`):

```bash
ts="$(date +%Y%m%d-%H%M%S)"
```

Issue: rapid invocations can collide.

Required change:

- Include nanoseconds and PID, e.g. `ts="$(date +%Y%m%d-%H%M%S-%N)-$$"`.

### 8. `layers/agent-sandbox/funcs.el` — error handling and timestamped output

Current code (`layers/agent-sandbox/funcs.el:1-7`):

```elisp
(defun agent/snapshot-i3-tree ()
  (interactive)
  (make-directory agent-sandbox-artifact-dir t)
  (shell-command
   (format "i3-msg -t get_tree > %s/tree.json && i3-msg -t get_workspaces > %s/workspaces.json"
           (shell-quote-argument agent-sandbox-artifact-dir)
           (shell-quote-argument agent-sandbox-artifact-dir))))
```

Issues:

- Overwrites the same files.
- No error handling for `i3-msg` failures.

Required change:

- Generate a timestamp inside `agent/snapshot-i3-tree` and write to `tree-<ts>.json` / `workspaces-<ts>.json`.
- Use `shell-command` with an exit-status check (e.g. via `call-process` or by inspecting the return value) and signal an error on failure, including the artifact dir and subcommand.

## Definition of done

- All files above are modified according to the requirements.
- `make test` passes (or is skipped if no relevant tests exist; no new failures introduced).
- `make` lint/check commands pass if available.
- Changes are committed to `fix/agent-i3-sandbox-review` with a clear message referencing the review.
