# Contributing

## Setup

<Commands to install dependencies and run the project locally, with tool versions.>

## Workflow

- Branches: <naming convention, for example `feat/short-summary`>.
- Commits: <convention, for example Conventional Commits `type(scope): summary`>.
- Pull requests: small and focused, description filled from the template, CI green before review.

## Checks

<The exact commands for tests, linter, formatter, type checks and build. All must pass before a pull request.>

## Code style

- <Formatter and linter used, and their configs.>
- No hard-coded settings: configuration, environment variables or design tokens. Secrets only from the environment.
- Public APIs have doc comments in the language's standard form; inline comments explain why.

## Documentation

- Update the docs in the same pull request as the code.
- A structural decision gets an ADR in `docs/adr/` (template: `docs/adr/0000-template.md`).
- Structure changes update `docs/architecture.md`.
