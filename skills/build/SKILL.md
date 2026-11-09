---
description: Orchestrate the implementation of a plan with subagents - an implementer per task, review and fix loops, a final review and security audit, a plain-language summary, and git shipping.
argument-hint: <plan file | small task description>
disable-model-invocation: true
hooks:
  PreToolUse:
    - matcher: "Bash|PowerShell"
      hooks:
        - type: command
          command: 'bash "${CLAUDE_PLUGIN_ROOT}/scripts/guard-git.sh"'
  PostToolUse:
    - matcher: "Agent|Bash|PowerShell"
      hooks:
        - type: command
          command: 'bash "${CLAUDE_PLUGIN_ROOT}/scripts/progress.sh" hook'
---

# lbdev build (orchestrator)

Input: $ARGUMENTS

Plugin root: `${CLAUDE_PLUGIN_ROOT}`
Plugin data: `${CLAUDE_PLUGIN_DATA}`
Configuration: git_mode=`${user_config.git_mode}`, plans_dir=`${user_config.plans_dir}`, max_fix_rounds=`${user_config.max_fix_rounds}`

Read `${CLAUDE_PLUGIN_ROOT}/shared/principles.md`, `${CLAUDE_PLUGIN_ROOT}/shared/output.md`, `${CLAUDE_PLUGIN_ROOT}/shared/dispatch.md`, `${CLAUDE_PLUGIN_ROOT}/shared/git.md`, `${CLAUDE_PLUGIN_ROOT}/shared/feedback.md` and `${CLAUDE_PLUGIN_ROOT}/shared/docs.md` now and follow them for the whole command.

You are the orchestrator. You coordinate, check and decide; subagents write the code. Keep your own context for coordination: do not read whole files a subagent already summarised unless you need to check a claim.

## Progress board

The user follows the run on a board, never on your prose. The board is driven by a script, so it cannot drift:

- Create it once the tasks are known: `bash "${CLAUDE_PLUGIN_ROOT}/scripts/progress.sh" init "<board file>" "<plan title>" "T1|<task title>" "T2|<task title>" ... "G|Final gate" "D|Docs" "S|Explain and ship"`. Board file: `${user_config.plans_dir}/<plan-name>.board.tsv`.
- Every state change goes through `progress.sh set "<board file>" <id> <todo|active|done|parked> "<short note>"`: when a task starts, at each stage (`implement`, `verify`, `review 1/2`, `fix 1/2`), when it is committed (note: short commit hash), when it is parked (note: why, in three words).
- A hook shows the board to the user whenever it changes. Between updates, your chat messages stay at one line each, per `output.md`.

## 1. Load the work

- If the input is a plan file, read it.
- If it is a task description: when it is small and clear, write a short plan for it (goal, tasks with acceptance criteria, verification commands) in `${user_config.plans_dir}/`. When it is not, recommend `/lbdev:plan` and stop.
- If there is no input, look for the most recent plan in `${user_config.plans_dir}/` and ask the user to confirm it.

Build the project brief described in `dispatch.md` from the plan and the project's instruction files. Confirm the verification commands exist by reading the manifests.

If `${CLAUDE_PLUGIN_DATA}/feedback.md` has open entries, show one line: `lbdev feedback: <n> open (/lbdev:improve)`. Do not act on them here.

## 2. Ledger and board

Keep `${user_config.plans_dir}/<plan-name>.progress.md` up to date. It survives context compaction, the todo list does not. It holds: the branch, each task's commit, every ruling you made, every parked finding, and the model and effort chosen for each dispatch. Task status lives in the board file.

Before the first dispatch, rate each task of the plan (trivial, standard or critical) from its size and what it touches. These ratings drive the model and effort of every agent working on that task, as `dispatch.md` describes.

If the ledger and board already exist, resume from them: never redo a task marked done. Check its commit exists before trusting it.

## 3. Prepare git

Apply `git.md` for mode `${user_config.git_mode}`: check the working tree, create or reuse the branch. Plan, ledger and board are working files (`docs.md`): never commit them. If `${user_config.plans_dir}` is not git-ignored, add `.lbdev/` to `.gitignore` in the first commit and say so.

## 4. For each task, in order

1. Board: task `active`, note `implement`. Dispatch one implementer subagent with: the task text, its interfaces, the relevant decisions and global constraints, the libraries the plan approved, the project brief, and the verification commands. Never send the whole plan.
2. If it returns NEEDS_ANSWERS or BLOCKED: answer from the plan, the spec and the code when you can (record a ruling), otherwise ask the user. A missing library for security-sensitive code is always a question for the user. Then dispatch a new implementer with the answers.
   A library outside the plan reported under Concerns does not stop the run: note it in the ledger and list it in the final report. The same goes for a know-how gap that a kit could fill (`/lbdev:kits find` later).
3. Board note `verify`. Take the working tree fingerprint, then dispatch a verifier with the verification commands. A FAIL goes back to an implementer with the extracted failure lines.
4. Board note `review`. Dispatch reviewer subagents in parallel on this task's changes: one with focus `spec`, one with focus `correctness`. Give them the task text and the list of changed files. Compare the fingerprint afterwards: it must not have changed since step 3.
5. Blocking or important findings: board note `fix <round>/${user_config.max_fix_rounds}`, dispatch an implementer to fix exactly those, then verify and review again. After `${user_config.max_fix_rounds}` rounds, park the remaining findings in the ledger, log a feedback entry, and move on. Minor findings go to the ledger for the final report.
6. Commit the task (and push, depending on the mode) as `git.md` describes. Board: task `done`, note = short commit hash (or `parked` with the reason). Update the ledger.

Do not stop between tasks to ask whether to continue. Only the stop conditions of `principles.md` interrupt the run.

## 5. Final gate

Board: `G` active.

1. Take the working tree fingerprint, then dispatch in parallel, on the whole branch diff against the base:
   - a reviewer with focus `integration`;
   - a reviewer with focus `conventions`;
   - a reviewer with focus `maintainability`;
   - a security-auditor with focus `code`;
   - a security-auditor with focus `supply`.
   Compare the fingerprint when they have all reported.
2. For every finding they report, dispatch a validator (in parallel, one per finding). Keep only CONFIRMED findings.
3. Fix confirmed blocking, important, critical and high findings through an implementer, have a verifier run the verification, review the fix once, commit and push. List the others in the report.
4. Dispatch a verifier for the full verification one last time.

Board: `G` done, note = `<fixed> fixed, <open> open`.

## 6. Documentation

Board: `D` active.

Docs change with the code (`docs.md`). Dispatch one implementer (standard tier) with the plan, the ledger's rulings and the branch diff summary, to update what this work affects:

- one ADR in `docs/adr/` per structural decision of the plan or the ledger (stack, architecture, storage, major dependency, public contract), from `${CLAUDE_PLUGIN_ROOT}/templates/adr.md`;
- `docs/roadmap.md`: status of the axis this plan serves;
- `docs/architecture.md` when the structure, data flow or invariants changed;
- `README.md`, `CONTRIBUTING.md`, `AGENTS.md`, `.env.example` when usage, commands, configuration or conventions changed;
- `CHANGELOG.md` when the project has one.

Only files the project already has, plus ADRs when `docs/adr/` exists. Then a verifier, then commit and push as `git.md` describes.

Board: `D` done, note = files updated (count).

## 7. Explain and ship

Board: `S` active.

1. Read `${CLAUDE_PLUGIN_ROOT}/roles/teacher.md` and write the explanation yourself: you hold the conversation and the ledger, which carry the why. Chat: level `simple`. PR body: level `detailed`.
2. In `pr` mode, open or update the pull request as `git.md` describes, with the `detailed` explanation as the plain-language summary. In `none` mode, print the exact git commands to run.

Board: `S` done, note = PR number or `commands printed`.

## 8. Final report

Follow `output.md`. Content:

- Done: tasks done/total, PR link or commands.
- Verification: each check with OK or FAIL.
- Review and security: fixed, parked, false positives (counts).
- Decisions: rulings you made on your own, one line each.
- Models: one line, for example `heavy x3, standard x6, light x5; 1 escalation`.
- Feedback: entries logged during this run (count), if any.
- Remaining: parked findings, then every manual action (setup, deploy, checks) as detailed steps per `output.md`.
