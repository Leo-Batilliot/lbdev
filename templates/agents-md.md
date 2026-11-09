# AGENTS.md

Instructions for coding agents working on this project (Claude Code, Codex, Copilot, Cursor and others). This is the single source of agent instructions: tool-specific files such as `CLAUDE.md` only point here. Human contributors: see `CONTRIBUTING.md`.

## Project

<One paragraph: what this project is, who it serves, its main constraints. Roadmap: `docs/roadmap.md`.>

## Commands

- Install: `<command>`
- Run: `<command>`
- Test: `<command>`
- Lint and format: `<command>`
- Type check and build: `<command>`

## Structure

<Code map: each top-level folder in one line. Details in `docs/architecture.md`.>

## Conventions

- <Language, framework and style rules that are not enforced by tools.>
- Configuration: <where settings live>. No hard-coded values; secrets only from the environment; new keys go into `.env.example`.
- Reuse existing helpers and dependencies before writing new code.
- Public APIs have doc comments in the language's standard form; inline comments explain why.
- Docs change in the same pull request as the code (`CONTRIBUTING.md`). Structural decisions get an ADR in `docs/adr/`.

## Boundaries

- <What agents must never do: for example touch generated files, edit migrations already applied, change public APIs without an ADR, commit secrets.>
