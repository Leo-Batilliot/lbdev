# lbdev project documentation norms

Based on what large, well-run engineering organisations do (Google's documentation guide and design-doc practice, the root layout of NVIDIA, Microsoft, Kubernetes, JAX and rust-analyzer repositories, ADRs, Keep a Changelog). Templates are in `<plugin-root>/templates/` (`agents-md.md` and `claude-md.md` produce `AGENTS.md` and `CLAUDE.md`; they are renamed so that agents working on the plugin itself do not load them as instructions).

## Principles

- Minimum viable documentation: a few accurate documents beat many stale ones.
- Docs change in the same pull request as the code they describe.
- Dead documentation is deleted, not left to rot.
- Link, do not duplicate: one fact lives in one place.
- Working documents (plans, ledgers) are temporary and never committed; what must last is promoted to a permanent document.

## Permanent documents

Repository root:

- `README.md`: what the project is, why, quickstart, usage, configuration, links to the docs.
- `CONTRIBUTING.md`: setup, workflow (branches, commits, pull requests), tests, code style, documentation rules.
- `AGENTS.md`: instructions for coding agents (commands, structure, conventions, boundaries). `CLAUDE.md` contains only `@AGENTS.md`, so every agent reads the same file.
- `SECURITY.md`: how to report a vulnerability.
- `LICENSE`: when the project is distributed; the user chooses it.
- `CHANGELOG.md`: only when the project publishes versions (Keep a Changelog format, Semantic Versioning).
- `.editorconfig`, `.gitignore`, `.env.example` (every configuration key, placeholder values).
- `.github/`: `CODEOWNERS` and `pull_request_template.md` when the project is on GitHub.

`docs/`:

- `docs/architecture.md`: bird's-eye view, code map, data flow, invariants, cross-cutting concerns. Updated when the structure changes.
- `docs/roadmap.md`: vision, then the axes that lead to the final result, each with goal, done criteria, status and dependencies. A release or production axis when the project ships somewhere.
- `docs/adr/NNNN-short-title.md`: one Architecture Decision Record per structural decision (stack, storage, architecture, major dependency, public contract). Never rewritten: a later ADR supersedes it.
- More docs only when needed, split by purpose: tutorials, how-to guides, reference, explanation.

## Working documents

`.lbdev/` (git-ignored): plans, progress ledgers, boards, saved explanations. They help agents and the user during a run. At the end of a build, structural decisions become ADRs, the roadmap and architecture are updated, and the summary goes into the pull request. Nothing in `.lbdev/` is committed.

## Code comments

- Clear names first: a good name replaces a comment.
- Every public API (exported function, class, module, endpoint) has a doc comment in the language's standard form (TSDoc or JSDoc, Google-style Python docstrings, Rustdoc, GoDoc, Javadoc): what it does, parameters, return value, errors, and an example when usage is not obvious.
- Inline comments explain why, never what the code already says.
- No commented-out code, no banners, no comment that paraphrases the code.

## Existing projects

An existing project keeps its own conventions unless the user chooses to align it with these norms through `/lbdev:init`. Nothing existing is rewritten without the user's confirmation.
