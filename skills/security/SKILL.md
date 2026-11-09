---
description: Audit changes for exploitable security weaknesses with independent subagents (code and supply chain), validate every finding, and report only confirmed ones. Changes nothing.
argument-hint: "[scope: uncommitted | branch | <base>..<head> | <paths> | all]"
disable-model-invocation: true
---

# lbdev security

Scope requested: $ARGUMENTS

Plugin root: `${CLAUDE_PLUGIN_ROOT}`
Plugin data: `${CLAUDE_PLUGIN_DATA}`

Read `${CLAUDE_PLUGIN_ROOT}/shared/principles.md`, `${CLAUDE_PLUGIN_ROOT}/shared/dispatch.md`, `${CLAUDE_PLUGIN_ROOT}/shared/output.md` and `${CLAUDE_PLUGIN_ROOT}/shared/feedback.md` now and follow them. This command is read-only: you and every subagent leave the files and the git state exactly as they are, install nothing and contact no external service.

## 1. Define the scope

- Empty scope: the current branch against the default branch, plus uncommitted changes.
- `all`: the whole repository. Warn the user that it is slower, and split the repository into 2 to 4 areas (by entry point or component).
- Otherwise use the scope given.

Identify the stack and the trust boundaries in scope: where user input, files, network data and environment variables come in.

## 2. Independent audits

Take the working tree fingerprint, then dispatch in parallel two security-auditor subagents, one with focus `code` and one with focus `supply` (for `all`, one `code` auditor per area plus one `supply` auditor). Give each the scope, the stack and the trust boundaries. Compare the fingerprint when they have all reported.

## 3. Validate

Merge duplicates, then dispatch one validator per finding in parallel. Keep CONFIRMED findings; list UNCERTAIN ones separately; drop REJECTED ones.

## 4. Report

Confirmed findings, most severe first: severity, category, `file:line`, attack scenario, impact, suggested fix. Then uncertain findings, the areas covered, and the scanners that ran. State the limits plainly: this is a static review of the code, not a penetration test of a running system.

Offer to fix the confirmed findings. Do not fix anything unless the user says so.
