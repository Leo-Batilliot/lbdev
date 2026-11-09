# lbdev

An on-demand engineering workflow for Claude Code: plan, build with orchestrated subagents, review, security audit, plain-language explanations and git shipping.

It injects nothing into Claude's context until you run one of its commands. Installed but unused, it costs zero tokens and changes no behaviour.

## Commands

- `/lbdev:init [project description]`: setup phase. Captures the final goal, writes the roadmap and the standard documentation (README, CONTRIBUTING, AGENTS.md, SECURITY, architecture, ADRs). For an existing project: `adopt` keeps its conventions and adds what is missing, `align` brings it to the lbdev norms and plans the code-level alignment. Nothing existing is rewritten without confirmation.
- `/lbdev:plan <idea>`: explores the codebase, asks one questionnaire, compares two architecture proposals, picks libraries over custom code, finds missing kits, and writes a task-by-task plan approved in one box.
- `/lbdev:build <plan file | small task>`: the orchestrator. One implementer subagent per task, review and fix loops, a final review and security audit with validated findings, a plain-language summary, then commits, pushes and a pull request depending on the git mode.
- `/lbdev:implement <change>`: a small change done directly in the session, test-first, without orchestration.
- `/lbdev:review [scope]`: three independent reviewers (correctness, conventions, maintainability), every finding checked by a validator. Read-only.
- `/lbdev:security [scope | all]`: code and supply-chain audits, every finding checked by a validator. Read-only.
- `/lbdev:explain [simple | detailed | pro] [scope] [save]`: explains what changed with a diagram of the system. `simple`: diagram and at most 10 short lines. `detailed`: for a quick PR review (libraries, techniques, metrics). `pro`: function-by-function walkthrough with quantified impact.
- `/lbdev:ship [description]`: commits, pushes and opens or updates the pull request for the current work.
- `/lbdev:improve [list | fix | prune]`: reads the plugin's feedback log and fixes the plugin's own skills, roles and scripts.
- `/lbdev:kits [find <need> | list | prune | check]`: finds external skills for a need, audits them (malicious instructions, license, fit), and adds the one you choose as a kit.

Once per project: `/lbdev:init`. Then per roadmap axis, about 4 interactions: `/lbdev:plan <goal>`, answer one questionnaire, approve in one box, `/lbdev:build <plan>`. The build then runs to the pull request without asking, unless a stop condition occurs. For small things: `/lbdev:implement`, `/lbdev:review`, `/lbdev:ship`.

## Configuration

Claude Code asks for these in a dialog when the plugin is enabled; leaving a field empty keeps its default. Change them later in the `/config` panel of an interactive `claude` session. Values are saved under `pluginConfigs` in `~/.claude/settings.json`.

- `git_mode` (default `pr`): `pr` branches, commits, pushes and opens a pull request; `push` stops before the PR; `commit` stays local; `none` writes nothing and prints the commands.
- `autonomy` (default `ask`): `ask` makes `/lbdev:plan` ask one questionnaire and one validation box. `auto` asks only blocking questions (such as the stack of an empty project), skips the validation (running `/lbdev:build` approves the plan), and integrates kits the auditor accepted without security findings. Two interactions per phase in `auto`.
- `plans_dir` (default `.lbdev/plans`): working files (plans, ledgers, boards, saved explanations), git-ignored. Lasting content is promoted to ADRs, the roadmap and the pull request.
- `max_fix_rounds` (default `2`, from 0 to 5): review-then-fix rounds per task before a finding is parked.
- `max_kits_per_role` (default `5`, from 1 to 20): how many kits one role may use.
- `source_dir` (optional): local checkout of this plugin, so `/lbdev:improve` can edit it. Not needed with `--plugin-dir`.

The project's own instructions (CLAUDE.md, AGENTS.md, CONTRIBUTING, linter configs, commit history) take precedence over the plugin's defaults, so each team keeps its conventions. A project rule that forbids git writes makes the plugin behave as in `none` mode.

## Design

- Every command is a skill with `disable-model-invocation: true`: its description is not loaded into context and Claude never triggers it on its own.
- No `agents/`, no plugin-wide hooks, no MCP server: these would be loaded in every session. Roles live in `roles/` as plain files; commands spawn general-purpose subagents that read them. One file per role, shared by every command.
- Each subagent gets a model and an effort level chosen for its load: light for mechanical work, heavy for architecture, correctness and security. The tiers are defined once, in `shared/dispatch.md`.
- The agent that writes code never proves it works: a separate verifier subagent runs the tests, linter and build.
- Read-only roles are checked, not trusted: `scripts/worktree-fingerprint.sh` hashes the working tree before and after them, including edits to files that were already modified.
- `scripts/guard-git.sh` is a hook registered only by `/lbdev:build` and `/lbdev:ship`, for the rest of that session. It blocks AI attribution in commits and PRs, identity changes, PR merges and approvals, force pushes, pushes to `main` or `master`, and git writes beyond the configured mode.
- `/lbdev:build` shows a progress board (bar and checklist) driven by `scripts/progress.sh`: every state change goes through the script, and a hook shows the board whenever it changes, so it never depends on the model ticking boxes.
- Chat output is terse by rule (`shared/output.md`): statuses, checklists and tables, `Remaining` always last.
- Self-improvement: commands log their own failures (errors, loops, user complaints, guard blocks) to `feedback.md` in the plugin data directory, which survives updates. `/lbdev:improve` groups them by cause and fixes the plugin.
- Reuse before building: planners, implementers and reviewers must prefer project helpers, the standard library, current dependencies and well-known libraries over custom code. New libraries are approved with the plan.
- Documentation norms (`shared/docs.md`), based on Google's documentation guide and the layout of NVIDIA, Microsoft, Kubernetes, JAX and rust-analyzer repositories: minimal but accurate docs, updated in the same pull request as the code, ADRs for structural decisions, a roadmap whose future axes every plan must keep possible, doc comments on public APIs. Templates in `templates/`. `/lbdev:build` updates ADRs, roadmap, architecture and README at the end of each run.
- `kits/` holds know-how that roles load on demand, listed in `kits/index.md` (for example `diagrams.md` for the teacher). External skills enter only through `/lbdev:kits`: scout, audit by a separate agent, then the user's choice. They are pinned to a version, never auto-updated, and their scripts never run during the audit.
- `shared/` holds the rules every command follows: `principles.md` (precedence, scope, verification, when to stop), `output.md` (chat format), `dispatch.md` (how subagents are spawned and checked), `git.md` (git policy), `feedback.md` (self-improvement log), `kits.md` (finding, adding and pruning kits).

## Layout

```
plugin/
  .claude-plugin/plugin.json   manifest and user configuration
  skills/<command>/SKILL.md    the ten commands
  roles/                       explorer, architect, implementer, verifier, reviewer, security-auditor, validator, teacher, scout, skill-auditor
  shared/                      principles, output, dispatch, git, feedback, kits, docs
  kits/                        on-demand know-how and its registry (index.md)
  templates/                   README, CONTRIBUTING, AGENTS, SECURITY, architecture, roadmap, ADR, PR template
  scripts/guard-git.sh         git guard hook
  scripts/progress.sh          progress board and its hook
  scripts/worktree-fingerprint.sh   working tree hash used to check read-only roles
  tests/run.sh                 tests for the scripts
```

## Try it locally

```bash
claude --plugin-dir ./plugin
```

Then run `/lbdev:plan` in a project. `claude plugin validate ./plugin` checks the manifest and the skills. `bash plugin/tests/run.sh` tests the scripts.

## Requirements and limits

- `bash` and `awk` for the hooks (Git Bash on Windows). Without them, the hooks do not run and only the written rules apply. `jq` makes the guard more precise but is optional.
- `gh`, authenticated, for pull requests. Without it, the plugin prints the command to run.
- The guard only sees messages passed inline (`-m`, `--body`), which the plugin's rules require.
- Read-only roles run as general-purpose subagents, so their restriction is checked after the fact rather than prevented. This is the price of injecting nothing into context.
- The security audit is a static review of the code, not a penetration test.
- The skill-auditor reads untrusted content: it runs on the strongest tier, is told to treat it as data, and its verdict still goes to the user before anything is added.
