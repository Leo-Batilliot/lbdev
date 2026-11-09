---
description: Find, audit and add external skills as kits for lbdev roles, or list, prune and update the existing kits. Nothing is added without the user's choice.
argument-hint: "[find <need> | list | prune | check]"
disable-model-invocation: true
---

# lbdev kits

Arguments: $ARGUMENTS

Plugin root: `${CLAUDE_PLUGIN_ROOT}`
Plugin data: `${CLAUDE_PLUGIN_DATA}`
Plugin source setting: `${user_config.source_dir}`
Kit limit per role: `${user_config.max_kits_per_role}`

Read `${CLAUDE_PLUGIN_ROOT}/shared/principles.md`, `${CLAUDE_PLUGIN_ROOT}/shared/output.md`, `${CLAUDE_PLUGIN_ROOT}/shared/dispatch.md`, `${CLAUDE_PLUGIN_ROOT}/shared/feedback.md` and `${CLAUDE_PLUGIN_ROOT}/shared/kits.md` now and follow them.

## Commands

- `list` (or no argument): print `kits/index.md` as a table (kit, roles, source, version, last use from the usage log).
- `find <need>`: run "Finding" from `kits.md`, then ask the user with one multiple-choice box: each acceptable candidate (recommended first), and "none". Integrate the choice as "Integrating" describes.
- `prune`: run "Pruning", confirm with one multiple-choice box, apply.
- `check`: run "Checking for updates", confirm with one box, apply.

Report per `output.md`. Do not commit: shipping the plugin change is the user's call.
