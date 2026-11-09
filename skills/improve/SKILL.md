---
description: Read the lbdev feedback log, group the problems by cause, and fix the plugin's own skills, roles and scripts after approval.
argument-hint: "[list | fix [entry slugs] | prune]"
disable-model-invocation: true
---

# lbdev improve

Arguments: $ARGUMENTS

Plugin root: `${CLAUDE_PLUGIN_ROOT}`
Plugin data: `${CLAUDE_PLUGIN_DATA}`
Plugin source setting: `${user_config.source_dir}`

Read `${CLAUDE_PLUGIN_ROOT}/shared/principles.md`, `${CLAUDE_PLUGIN_ROOT}/shared/output.md`, `${CLAUDE_PLUGIN_ROOT}/shared/dispatch.md` and `${CLAUDE_PLUGIN_ROOT}/shared/feedback.md` now and follow them.

## 1. Load

- Read `${CLAUDE_PLUGIN_DATA}/feedback.md`. Missing or no `open` entry: print `lbdev feedback: 0 open` and stop.
- Find the plugin source to edit:
  - the plugin source setting above, when it is set;
  - otherwise the plugin root, when it is not inside `.claude/plugins/` (the plugin was loaded with `--plugin-dir` from a source checkout);
  - otherwise there is no editable source: you can only `list`. Say so in one line: set `source_dir` in the plugin configuration.

## 2. Group

Group the open entries by suspected cause (same file and section, or same root problem). For each group: count, kinds, the plugin files involved, and the fix you propose in one line. Discard entries that are about the user's project rather than the plugin, and mark them `dismissed`.

`list` (or no argument): print the groups as a table and stop.

## 3. Fix (`fix`, optionally limited to some entries)

1. Show the planned changes, one line per file, and wait for approval.
2. Edit the plugin source. Smallest change that removes the cause. Keep the plugin's rules intact: zero context until a command runs, roles as plain files, git guard, output format.
3. Check consistency: dispatch one reviewer (heavy tier) with focus `spec` on the plugin diff, giving it the entries as the spec and asking it to also report contradictions between plugin files. Fix what it confirms.
4. Run the plugin's tests: `bash "<plugin source>/tests/run.sh"`. All must pass.
5. Bump the patch version in `<plugin source>/.claude-plugin/plugin.json`.
6. In the feedback log, change each fixed entry's status from `open` to `fixed <new version>`.

Do not commit: shipping the plugin change is the user's call (`/lbdev:ship` from the plugin repository).

## 4. Prune (`prune`)

Remove `fixed` and `dismissed` entries older than 30 days from the log.

## Report

Per `output.md`: groups fixed, files changed, tests result, new version, entries still open in `Remaining`.
