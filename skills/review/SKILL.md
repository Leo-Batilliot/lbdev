---
description: Review changes with independent subagents (correctness, conventions, maintainability), validate every finding, and report only confirmed issues. Changes nothing.
argument-hint: "[scope: uncommitted | branch | <base>..<head> | <paths>]"
disable-model-invocation: true
---

# lbdev review

Scope requested: $ARGUMENTS

Plugin root: `${CLAUDE_PLUGIN_ROOT}`
Plugin data: `${CLAUDE_PLUGIN_DATA}`
Plans directory: `${user_config.plans_dir}`

Read `${CLAUDE_PLUGIN_ROOT}/shared/principles.md`, `${CLAUDE_PLUGIN_ROOT}/shared/dispatch.md`, `${CLAUDE_PLUGIN_ROOT}/shared/output.md` and `${CLAUDE_PLUGIN_ROOT}/shared/feedback.md` now and follow them. This command is read-only: you and every subagent leave the files and the git state exactly as they are.

## 1. Define the scope

- Empty scope: the current branch against the default branch, plus uncommitted changes. If the branch is the default branch, only uncommitted changes.
- Otherwise use the scope given.

If the scope has no changes, say so and stop. Otherwise list the changed files and the diff size, and collect the project instruction files that apply to them (root and parent-directory CLAUDE.md, AGENTS.md, CONTRIBUTING, lint configs).

## 2. Independent reviews

Look for the intent of the change: a plan in `${user_config.plans_dir}/` that matches the branch, a PR description (`gh pr view` if available), or this conversation.

Take the working tree fingerprint, then dispatch reviewer subagents in parallel, each with the scope, the list of changed files, the instruction files and one focus:

- always `correctness`, `conventions` and `maintainability`;
- `spec` when an intent was found: give it the plan's tasks or the PR description;
- `integration` when the scope spans several commits that build on each other.

Give every reviewer the intent in one or two sentences when there is one. Compare the fingerprint when they have all reported.

## 3. Validate

Merge duplicate findings. Dispatch one validator per finding, in parallel. Keep CONFIRMED findings; mention UNCERTAIN ones separately; drop REJECTED ones.

## 4. Report

Confirmed findings, most severe first, each with: severity, `file:line`, the problem, the scenario or the broken rule, the suggested fix. Then uncertain findings. Then the checks that ran. If nothing survived, say so in one line.

Finish by offering to fix the confirmed findings. Do not fix anything unless the user says so.
