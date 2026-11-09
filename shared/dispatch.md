# Dispatching role subagents

lbdev ships no agent definitions, so that nothing reaches the context until a command runs. Roles are plain files in `<plugin-root>/roles/`, and a command turns one into a subagent by spawning a general-purpose agent that reads the role file first. The command that loaded this file gives you the absolute `<plugin-root>`.

## Spawning

Use the Agent tool with the general-purpose agent type and this prompt shape:

```
You are the <role> of the lbdev workflow.
Before anything else, read <plugin-root>/roles/<role>.md and <plugin-root>/shared/principles.md, and follow them.

Project brief:
<stack, key conventions, instruction files to respect, verification commands>

Task:
<exactly what this agent must do, with every fact it needs>

Scope:
<files, diff range or area it may look at>

Return the output format defined in your role file.
```

- If `<plugin-root>/kits/index.md` lists kits for the role, add their paths to the "Before anything else, read" line and log their use, as "Loading" in `<plugin-root>/shared/kits.md` describes.
- A subagent sees nothing of this conversation. Put every fact, decision and constraint it needs in the prompt. Never write "as discussed".
- Keep the project brief short: the facts a newcomer needs, not a dump of files.
- Ask for findings with `file:line` references, never for whole file contents.

## Model and effort

Choose a model and an effort level for every dispatch, and pass them as the Agent tool's `model` and `effort` parameters. Decide from two things: the size and risk of the whole piece of work, and the load of this particular agent. A security audit of a payment flow and a test run on the same branch do not deserve the same model.

Tiers (the only place where model names are set):

- light: `model: "haiku"`, `effort: "low"`. Mechanical work with a checkable answer: run commands and report results, list files, check a precise claim that one read settles.
- standard: `model: "sonnet"`, `effort: "medium"`. Work that needs understanding but follows a clear brief: exploring an area, implementing a small well-specified task, conventions or maintainability review.
- heavy: `model: "opus"` (or omit `model` when the session already runs a stronger model), `effort: "high"`, or `"xhigh"` for the riskiest cases. Work where a miss is expensive: architecture, correctness review of non-trivial logic, every security audit, validating bug and security findings, implementing complex tasks.

Adjust from that starting point:

- One tier up when the task touches authentication, permissions, money, personal data, data integrity or migrations, concurrency, a public API, or when the diff is large.
- One tier up for the next attempt when an agent failed, returned BLOCKED, or its work was rejected in review.
- One tier down for a trivial instance of a role (a one-line fix, a review of a tiny diff), except for the security-auditor and for validators of security findings, which never go below heavy.

When you change the model, always set `effort` too: the session's effort level does not carry over to another model. If the Agent tool rejects a parameter or a model is unavailable, retry without it and note it.

Record each choice in one line where the command tracks its work (the progress ledger for `/lbdev:build`): role, tier, reason.

## Parallelism

- Independent subagents go out in the same message, so they run at the same time.
- Subagents that touch the same files never run at the same time. Implementers run one at a time.
- Subagents may run in the background: wait until every one you dispatched has reported before using their results. Never guess a result.

## Read-only roles

explorer, architect, reviewer, security-auditor, validator and verifier must not modify any file. This is enforced by checking, not by trust:

1. Before dispatching them, run `bash "<plugin-root>/scripts/worktree-fingerprint.sh"` and keep the hash it prints. It covers tracked changes, staged changes and the content of untracked files, so an edit to a file that was already modified is caught too.
2. After they report, run it again.
3. If the hash changed, stop, show the user what changed (`git status`, `git diff --stat`), and ask how to proceed. Do not revert on your own.

The verifier runs tests and builds: outputs that the project's `.gitignore` covers do not change the hash. If a run legitimately creates files that are not ignored, say so to the user instead of treating it as a violation.

## Verification

The agent that wrote the code never proves it works. After an implementer reports, dispatch a verifier (light tier) with the exact verification commands, and act on its report. Never accept "tests pass" from an implementer as evidence.

## Using the results

- Reports are claims. Open the files they cite before acting on them.
- When several reviewers report the same issue, merge it into one finding.
