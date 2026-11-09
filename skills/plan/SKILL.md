---
description: Turn an idea into an approved spec and a task-by-task implementation plan, with codebase exploration, competing architecture proposals, library and kit selection, in as few user interactions as possible.
argument-hint: <what you want to build or change>
disable-model-invocation: true
---

# lbdev plan

Request: $ARGUMENTS

Plugin root: `${CLAUDE_PLUGIN_ROOT}`
Plugin data: `${CLAUDE_PLUGIN_DATA}`
Plans directory: `${user_config.plans_dir}`
Kit limit per role: `${user_config.max_kits_per_role}`
Autonomy: `${user_config.autonomy}`

Read `${CLAUDE_PLUGIN_ROOT}/shared/principles.md`, `${CLAUDE_PLUGIN_ROOT}/shared/dispatch.md`, `${CLAUDE_PLUGIN_ROOT}/shared/output.md`, `${CLAUDE_PLUGIN_ROOT}/shared/feedback.md` and `${CLAUDE_PLUGIN_ROOT}/shared/kits.md` now and follow them for the whole command.

The goal is an approved plan file. Write no production code in this command.

## Interaction budget

With autonomy `ask`, the user answers at most two boxes in this command: one questionnaire (phase 3) and one validation (phase 6). With autonomy `auto`, the user answers a box only for blocking questions (phase 3), and none otherwise: the plan is approved by running `/lbdev:build`. Use the multiple-choice question tool (AskUserQuestion): up to 4 questions per box, 2 to 4 options each, your recommendation first and marked "(Recommended)". The user can always type a free answer instead. Start the subagents of a phase in the background before asking, so they work while the user answers. A second questionnaire is allowed only when answers open a question that changes what gets built.

Between boxes, chat messages follow `output.md`: a few lines, no prose.

## 1. Understand the request

If the request is empty, ask what the user wants to build and why, in one open question, and wait.

Project docs: read `docs/architecture.md` and the ADRs in `docs/adr/` when they exist; a plan never contradicts an accepted ADR silently (propose a superseding one instead).

Roadmap: if the project has one (`docs/roadmap.md`, or `ROADMAP.md`), read it. Note which axis this work belongs to and which axes come later. Every design choice must keep those later axes possible without rework; a choice that would block one is a decision to raise, not to take silently. No roadmap: note it, and suggest `/lbdev:init` in `Remaining:`.

Sources: if the work reproduces, redesigns, recodes or extends something that is not in the repository (a mockup, a visual design, an original application or site, a specification, an external API, a document format), ask for that source before anything else: files, links, screenshots or access. This is a blocking question in every autonomy mode. Read every source given before exploring further.

Judge the size:

- Small and clear (one obvious way to do it, a few files): skip phases 3 and 4, write a short plan directly, and go to phase 6.
- Anything else: run every phase.

## 2. Look before asking

In an existing codebase, dispatch 2 or 3 explorer subagents in parallel, each with a different angle relevant to the request (for example: similar existing features, the architecture of the area to change, the test and build setup and the existing dependencies). In an empty project, skip this.

When they report, read the key files they list. Summarise in at most 5 lines what exists and what the request would touch.

## 3. Questionnaire

List the questions whose answer changes what gets built and that neither the request nor the code answers: goals and non-goals, edge cases, error behaviour, data, compatibility, performance, security, what "done" means, and in an empty project the stack. Keep the 4 that matter most for one box; settle the others yourself with your recommendation and record them as decisions in the plan.

With autonomy `auto`, ask only blocking questions: those where a wrong guess is structural and expensive to undo, and that the code cannot answer. Examples: the stack or language of an empty project, an irreversible data decision, an external constraint (an API, a deadline, a platform) the request implies but does not name. Settle everything else with your recommendation and record it in the plan as a decision marked `(assumed)`. No blocking question: no box.

## 4. Approaches, libraries and kits (in parallel)

Dispatch together:

- 2 architect subagents with different lenses: "minimal change, maximum reuse" and "clean and scalable for the next features". Give each the requirements, the answers, the sources, the explorers' findings and the later roadmap axes. Each must apply "Reuse before building" and keep the later axes possible.
- If the work needs know-how that no kit in `${CLAUDE_PLUGIN_ROOT}/kits/index.md` covers for the roles involved (for example a diagram style, a framework's conventions, a document format): run "Finding" from `kits.md` for each such need. Skip when nothing is missing.

## 5. Write the plan

Write `${user_config.plans_dir}/<YYYY-MM-DD>-<short-kebab-name>.md` with the recommended approach. It is a working file: if its folder is not git-ignored, add `.lbdev/` to `.gitignore` and say so. Content:

- Goal: one sentence.
- Context: why, for whom, and the roadmap axis it serves.
- Sources: what was provided (files, links) and how it is used.
- Future axes: the later roadmap axes and how this design keeps them possible.
- Decisions: each choice made in this command, including the ones you settled yourself, with the reason.
- Non-goals.
- Libraries: each new dependency with its purpose and why it beats custom code; existing dependencies and helpers to reuse.
- Global constraints: rules every task must respect (conventions, compatibility, limits).
- Verification: the exact build, test, lint and type-check commands, with where they come from.
- Tasks, in dependency order. Each task has:
  - a title;
  - files to create or modify (exact paths);
  - interfaces it consumes from earlier tasks and produces for later ones (names, parameters, return types);
  - the libraries it uses;
  - acceptance criteria, written as the tests that prove them;
  - the commands that verify it.

Size each task so that it carries its own tests and a reviewer could accept it while rejecting its neighbour. Fold setup and docs into the task that needs them.

Check the plan before showing it: every requirement maps to a task, no task says "TBD" or "handle edge cases" without saying which, no task uses a name that no task defines, the order respects dependencies, nothing is hand-written that a chosen library does. Fix what fails.

## 6. Validation

Show in the chat, per `output.md`: the two approaches as a short table (idea, effort, trade-off), the new libraries, the kit candidates with their audit verdict, the assumed decisions, the task list, the plan file path.

### Autonomy `auto`

No box.

- Kits: integrate every candidate whose verdict is ACCEPT or ADAPT with no security finding, as "Integrating" in `kits.md` describes, with `approved: auto (skill-auditor)` in its registry entry. Never integrate scripts, PARTIAL or REJECT candidates, and never replace an existing kit to stay under the limit: list those as `Remaining`. Without an editable plugin source, list them as `Remaining` too.
- End with two lines: `next: /lbdev:build <plan file>` and `to change the plan, reply with the change`.

### Autonomy `ask`

One box with only the questions that apply:

- Approach: recommended / other.
- Kits: each acceptable candidate / none.
- Plan: approve / adjust.

After the answers:

- Other approach: rewrite the plan for it and show the new task list. The choice counts as approval.
- Kits chosen: integrate them as "Integrating" in `kits.md` describes. Without an editable plugin source, list them as `Remaining`.
- Adjust: apply the user's text, show what changed, and ask once more only if the change is structural.

End with one line: `next: /lbdev:build <plan file>`.
