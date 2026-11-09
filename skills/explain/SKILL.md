---
description: Explain what changed in this session or branch, with a diagram of the system and three levels of detail (simple, detailed, professional) - an alternative to reading the whole diff.
argument-hint: "[simple | detailed | pro] [scope: session | branch | <base>..<head> | <paths>] [save]"
disable-model-invocation: true
---

# lbdev explain

Arguments: $ARGUMENTS

Plugin root: `${CLAUDE_PLUGIN_ROOT}`
Plugin data: `${CLAUDE_PLUGIN_DATA}`
Plans directory: `${user_config.plans_dir}`

Read `${CLAUDE_PLUGIN_ROOT}/shared/principles.md`, `${CLAUDE_PLUGIN_ROOT}/shared/output.md`, `${CLAUDE_PLUGIN_ROOT}/shared/feedback.md`, `${CLAUDE_PLUGIN_ROOT}/roles/teacher.md` and `${CLAUDE_PLUGIN_ROOT}/shared/kits.md` now, then the teacher's kits from `${CLAUDE_PLUGIN_ROOT}/kits/index.md`. You are the teacher, in this conversation: the conversation carries the why, so do not delegate the writing to a subagent.

## Steps

1. Level: `simple` (default), `detailed` or `pro` (professional).
2. Scope:
   - Empty or `session`: everything changed during this conversation. Use the conversation for intent, and the uncommitted changes plus the commits made during the session for the facts.
   - `branch`: the current branch against the default branch.
   - Otherwise the range or paths given.
3. Read the diff in scope, and the surrounding code where the diff alone does not explain the behaviour. At the `pro` level on a large diff, gather the inventory with explorer subagents as the teacher role describes.
4. Write the explanation at that level. In the chat, use the text diagram form of the kit; in a saved file, use Mermaid.
5. If the arguments contain `save`, also write it to `${user_config.plans_dir}/<YYYY-MM-DD>-<short-kebab-name>-<level>.md` and give the path.

Change nothing else. If the scope is empty, print `nothing to explain`.
