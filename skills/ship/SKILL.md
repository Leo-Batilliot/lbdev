---
description: Ship the current work according to the configured git mode - branch, commit, push and open or update a pull request (never merge), with no AI attribution.
argument-hint: "[short description of the work]"
disable-model-invocation: true
hooks:
  PreToolUse:
    - matcher: "Bash|PowerShell"
      hooks:
        - type: command
          command: 'bash "${CLAUDE_PLUGIN_ROOT}/scripts/guard-git.sh"'
---

# lbdev ship

Description: $ARGUMENTS

Plugin root: `${CLAUDE_PLUGIN_ROOT}`
Plugin data: `${CLAUDE_PLUGIN_DATA}`
Git mode: `${user_config.git_mode}`

Read `${CLAUDE_PLUGIN_ROOT}/shared/principles.md`, `${CLAUDE_PLUGIN_ROOT}/shared/output.md` and `${CLAUDE_PLUGIN_ROOT}/shared/feedback.md` now and follow them. Read `${CLAUDE_PLUGIN_ROOT}/shared/git.md` and follow it for mode `${user_config.git_mode}`.

## Steps

1. Read `git status`, the current branch, the default branch and the remote. If there is nothing to ship, say so and stop.
2. Group the changes into coherent commits (one per logical change). Show the planned commits (files and messages) in a few lines, then proceed unless something looks unrelated or sensitive: then ask.
3. Before committing, read `${CLAUDE_PLUGIN_ROOT}/shared/dispatch.md` and dispatch a verifier (light tier) with the project's fast checks (linter, type checks, tests if quick). If it reports FAIL, show the failures and ask whether to ship anyway.
4. Branch, commit and push as the mode allows.
5. In `pr` mode, read `${CLAUDE_PLUGIN_ROOT}/roles/teacher.md` and write the PR body's plain-language summary at the `detailed` level, from the conversation and the diff, then open or update the pull request. Never merge.
6. In `none` mode, print the exact commands instead.
7. Report: commits created, push result, PR link or commands to run.
