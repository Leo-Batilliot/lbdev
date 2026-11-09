---
description: Set up a project for lbdev - capture the global goal, create the roadmap and the standard documentation, and for an existing project either adopt its conventions or plan its alignment with the lbdev norms. Nothing existing is rewritten without confirmation.
argument-hint: "[what the project is about]"
disable-model-invocation: true
hooks:
  PreToolUse:
    - matcher: "Bash|PowerShell"
      hooks:
        - type: command
          command: 'bash "${CLAUDE_PLUGIN_ROOT}/scripts/guard-git.sh"'
---

# lbdev init

Project description: $ARGUMENTS

Plugin root: `${CLAUDE_PLUGIN_ROOT}`
Plugin data: `${CLAUDE_PLUGIN_DATA}`
Configuration: git_mode=`${user_config.git_mode}`, autonomy=`${user_config.autonomy}`, plans_dir=`${user_config.plans_dir}`

Read `${CLAUDE_PLUGIN_ROOT}/shared/principles.md`, `${CLAUDE_PLUGIN_ROOT}/shared/output.md`, `${CLAUDE_PLUGIN_ROOT}/shared/dispatch.md`, `${CLAUDE_PLUGIN_ROOT}/shared/git.md`, `${CLAUDE_PLUGIN_ROOT}/shared/feedback.md` and `${CLAUDE_PLUGIN_ROOT}/shared/docs.md` now and follow them. Templates: `${CLAUDE_PLUGIN_ROOT}/templates/`.

This is the setup phase: understand the final goal, lay down the norms, write the roadmap. Product code is not written here; tooling and code alignment become roadmap axes built later with `/lbdev:plan` and `/lbdev:build`.

## 1. Detect

Empty project (no source code) or existing one. For an existing project, dispatch in parallel 3 explorer subagents (read-only, see `dispatch.md`):

- structure and stack: languages, frameworks, entry points, build, test and lint commands, existing dependencies;
- conventions: naming, folder layout, commit and branch history, configuration mechanism, hard-coded values (count and examples), comment and doc-comment practice;
- documentation: every existing doc file, what it covers, what is stale or duplicated, compared with `docs.md`.

Take the working tree fingerprint before and compare after.

## 2. Interview (one box, per the plan command's interaction budget)

Ask only what the description, the code and the docs do not answer:

- vision: the final result and who it serves;
- the axes leading there, and whether the project ships somewhere (release axis);
- constraints: stack (empty project), platforms, deadlines, compliance;
- sources: mockups, an original to recode, specifications, external APIs. Ask for them; they are blocking.

For an existing project, the same box asks the mode, with your recommendation from the audit:

- adopt: keep the project's conventions; add only what is missing (roadmap, architecture, ADR folder, agent instructions, `.lbdev/` ignored).
- align: bring the project to the lbdev norms (`docs.md` and `principles.md`): documentation restructured, conventions documented, and the code-level gaps (hard-coded values, missing doc comments, configuration mechanism, tooling) planned as a first roadmap axis.

With autonomy `auto`, ask only blocking questions; the mode question is always asked for an existing project.

## 3. Proposal

Build the list of changes, grouped:

- documentation: files to create from the templates, filled with real project facts; for align, existing docs to merge, move or delete;
- agent instructions: `AGENTS.md` from `templates/agents-md.md` (header stating it is the single source of agent instructions) and `CLAUDE.md` from `templates/claude-md.md` (points to `AGENTS.md` with `@AGENTS.md`); an existing `CLAUDE.md` or other agent file (`.cursorrules`, `.github/copilot-instructions.md`) is merged into `AGENTS.md`, not lost;
- repository hygiene: `.gitignore` (adds `.lbdev/` and `.env`), `.env.example`, `.editorconfig`, `.github/` templates when on GitHub;
- roadmap: the axes, in order, with a first axis "Foundation" when tooling or configuration is missing (linter, formatter, tests, CI, config module), an "Alignment" axis for align mode, and a release axis when relevant.

Show it per `output.md`: one line per file, `new`, `merge`, `move`, `delete` or `rewrite`, and the reason in a few words.

Then one confirmation box: one question per group (accept or skip), up to 4. A file that already exists is changed only if its group is accepted. `delete` and `rewrite` of an existing file are listed by name in the question.

## 4. Write

- Fill every template with facts from the audit and the interview. No placeholder left: an unknown fact becomes a question in `Remaining:`, not a `<...>` in a file.
- `docs/adr/0000-template.md` from the ADR template, then one ADR per structural fact already decided (stack, architecture, storage), status `accepted`.
- `docs/roadmap.md` from the interview, every axis `planned` except what already exists (`done`).
- Align mode: write the alignment plan in `${user_config.plans_dir}/` in the plan format of `/lbdev:plan` (tasks with files, acceptance criteria, verification), from the audit's code-level gaps. Do not apply it here.

## 5. Ship

Apply `git.md` for mode `${user_config.git_mode}` on a branch such as `chore/project-setup`: one commit for docs and hygiene, pull request in `pr` mode.

## 6. Report

Per `output.md`: files created, merged, moved, deleted; roadmap axes; mode. `Remaining:` the next command (`/lbdev:build <alignment plan>` in align mode, otherwise `/lbdev:plan <first axis>`), open questions, and any manual step (license choice, repository settings) as detailed steps.
