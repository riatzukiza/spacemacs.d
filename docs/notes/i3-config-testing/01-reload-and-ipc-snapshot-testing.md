---
subject: i3-config-testing
tags: [i3, testing, xephyr, ipc, snapshot, reload]
created: 2026-06-13
---

The best way is to treat i3 config work like systems programming: fast local reloads for the edit loop, a nested X server for risky changes, and snapshot-based assertions over the i3 IPC tree for integration tests. i3 explicitly supports config reload/restart, exposes the full layout tree over IPC, and its IPC docs even call out remote control as useful for writing test cases. [github](https://github.com/i3/i3/discussions/5775)

## Facts

- Fact: i3 can reload its configuration with `reload` and restart in place with `restart`, so your normal dev loop should be “edit, reload, inspect,” not “log out and pray.” [github](https://github.com/i3/i3/discussions/5775)
- Fact: i3 has an IPC socket and exposes commands such as `GET_TREE` and `GET_WORKSPACES`, returning JSON that represents containers, layouts, focus, geometry, and workspace state. [reddit](https://www.reddit.com/r/i3wm/comments/9w64j1/can_i_should_i_use_i3_as_a_floating_window_manager/)
- Fact: `i3-msg -t get_tree` dumps the full layout tree, and `i3-msg -t subscribe -m '[ "window" ]'` can monitor window changes; the i3 IPC tooling and `i3ipc-python` are intended exactly for querying and driving WM state. [man.archlinux](https://man.archlinux.org/man/i3-msg.1.en)

## Model

### Facts

For i3 and WM automation, unit tests are usually low value unless you have real pure functions, parsers, or Emacs Lisp decision logic. The high-value tests are integration tests that launch i3 in a controlled X11 environment, perform actions, and assert against the resulting tree/workspace JSON. [github](https://github.com/budRich/xwmplay)

### Interpretation

So I’d split the stack into three layers:
- Shell/config layer: lint-ish checks, smoke reload, snapshot assertions.
- Emacs Lisp layer: actual unit tests plus integration tests for i3 bridge functions.
- End-to-end layer: nested Xephyr/Xephyr-like X server, disposable i3 config, scripted window creation, then assert on `get_tree`.

## Workflow

The practical loop I’d recommend:

1. Keep your i3 config modular with `include` and `config.d/*.conf`, so experiments stay isolated and reversible. i3 supports `include`, loads files depth-first, and reports loaded config files via `i3 --moreversion`. [github](https://github.com/i3/i3/discussions/5775)
2. Use the host session only for quick changes: save, then `i3-msg reload` or `i3-msg restart`. [reddit](https://www.reddit.com/r/i3wm/comments/temkjz/how_to_reload_i3_when_saving_config_file_in_vim/)
3. For anything that can strand input, break bindings, or alter workspace behavior, run i3 inside Xephyr. Xephyr is specifically used for WM development because it gives you a nested, resettable X server while leaving your real editor/browser session intact. [ongardie](https://ongardie.net/blog/i3-manual-placement2/)
4. Record snapshots with `i3-msg -t get_tree` and `i3-msg -t get_workspaces`, then compare normalized JSON rather than raw pixels. [man.archlinux](https://man.archlinux.org/man/i3-msg.1.en)

## Test shapes

The best assertions are not “did the screen look right,” but “did the tree become what I intended.” The IPC tree includes container names, layout, orientation, rects, focus, floating nodes, and workspace structure, which makes it suitable as a behavioral snapshot format. [reddit](https://www.reddit.com/r/i3wm/comments/9w64j1/can_i_should_i_use_i3_as_a_floating_window_manager/)

A good progression:

- **Smoke**: config parses, i3 starts in Xephyr, keybindings reload.
- **Integration**: run `i3-msg` commands or synthesize keys, then assert tree/workspaces JSON.
- **E2E**: launch real apps like `emacsclient`, browser, terminal; validate assignments, floating rules, workspace creation, focus transitions, and named-window routing through IPC snapshots. [reddit](https://www.reddit.com/r/i3wm/comments/9w64j1/can_i_should_i_use_i3_as_a_floating_window_manager/)

Example shell probes:

```bash
i3-msg -t get_tree | jq .
i3-msg -t get_workspaces | jq .
i3-msg -t subscribe -m '[ "window", "workspace" ]'
```

Example focused container query shape:

```bash
i3-msg -t get_tree \
  | jq '.. | objects | select(.focused? == true) | {id, name, layout, rect, window_rect}'
```

That style is usually more robust than screenshot diffing, because it asserts semantics, not theme noise. [reddit](https://www.reddit.com/r/i3wm/comments/b2sgqv/i3msg_is_it_possible_to_get_the_current_layout/)

## Spacemacs fit

This belongs in two places.

In `.spacemacs` or `~/.spacemacs.d/init.el`, put only the Emacs-side helper code and tests, because that is user customization after layers load, so `dotspacemacs/user-config` is the correct hook for bridge functions, interactive commands, and ERT bindings. [reddit](https://www.reddit.com/r/i3wm/comments/9w64j1/can_i_should_i_use_i3_as_a_floating_window_manager/)
Outside Emacs, keep the WM harness as standalone shell or Python so it can launch nested X, start i3 with a temp config, and inspect IPC without depending on editor state. That keeps ownership clear and failures easier to localize.

A clean repository shape would be:

- `~/.config/i3/config`
- `~/.config/i3/config.d/*.conf`
- `~/bin/i3-dev-reload`
- `~/bin/i3-test-xephyr`
- `~/bin/i3-snapshot`
- `~/.spacemacs.d/lisp/i3-bridge.el`
- `~/.spacemacs.d/tests/i3-bridge-test.el`

## Suggested changes

I’d recommend this operating doctrine:

- Use **unit tests** only for Emacs Lisp that transforms state, builds commands, parses tree JSON, or decides routing.
- Use **integration tests** for i3 rules, modes, workspace naming, and Emacs/i3 handoff.
- Use **nested-X E2E** for anything involving key grabs, rofi, floating windows, focus, or startup ordering.
- Prefer **tree snapshots** over screenshots; use screenshots only when geometry/visual overlap is the behavior under test. [ongardie](https://ongardie.net/blog/i3-manual-placement2/)

Minimal validation checklist:
- `i3-msg reload` works after every config edit. [github](https://github.com/i3/i3/discussions/5775)
- `i3 --moreversion` shows the expected included files. [github](https://github.com/i3/i3/discussions/5775)
- `i3-msg -t get_tree` returns sane JSON in both host and nested sessions. [man.archlinux](https://man.archlinux.org/man/i3-msg.1.en)
- Every i3 mode has `Escape` and `Return` back to `default`. [github](https://github.com/i3/i3/discussions/5775)
- Emacs bridge code passes ERT before running nested-X tests. [reddit](https://www.reddit.com/r/i3wm/comments/9w64j1/can_i_should_i_use_i3_as_a_floating_window_manager/)

If you want, next I can sketch a concrete harness: a `i3-test-xephyr` script, a temp i3 config layout, and one sample E2E spec that asserts “launch Emacs popup -> window lands floating on named workspace -> tree matches snapshot.”
