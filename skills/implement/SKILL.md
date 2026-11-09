---
description: Implement a small, well-defined change directly in this session, test-first, with full verification and no orchestration.
argument-hint: <change to make>
disable-model-invocation: true
---

# lbdev implement

Change: $ARGUMENTS

Plugin root: `${CLAUDE_PLUGIN_ROOT}`
Plugin data: `${CLAUDE_PLUGIN_DATA}`

Read `${CLAUDE_PLUGIN_ROOT}/shared/principles.md`, `${CLAUDE_PLUGIN_ROOT}/shared/output.md`, `${CLAUDE_PLUGIN_ROOT}/shared/feedback.md` and `${CLAUDE_PLUGIN_ROOT}/roles/implementer.md` now. You act as the implementer yourself, in this conversation, so you can ask the user directly instead of returning NEEDS_ANSWERS.

## Steps

1. If the change is empty, ask what to implement and wait.
2. If the change spans several components, needs design choices, or touches many files, recommend `/lbdev:plan` and stop unless the user insists.
3. Learn the local conventions and the verification commands as `principles.md` describes.
4. State in two or three lines what you will change and how you will prove it, then do it, following the implementer process.
5. Run the full verification and show the results.
6. Do not touch git. End with the files changed, the verification results, and the suggested next steps: `/lbdev:review`, then `/lbdev:ship`.
