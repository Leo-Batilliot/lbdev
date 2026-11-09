# Architecture

## Bird's-eye view

<What the system does, its main parts and how they talk, in a few sentences. One overview diagram (see the diagram kit).>

## Code map

<Each important folder or module: what it holds, what it depends on, what must not depend on it.>

## Data flow

<The path of a typical request or job, from entry point to storage and back.>

## Invariants

<Rules the code relies on and that a change must not break: for example "the domain layer never imports the web layer".>

## Cross-cutting concerns

- Configuration: <where settings live, how they are loaded>.
- Errors and logging: <conventions>.
- Security: <authentication, authorisation, secrets, trust boundaries>.
- Testing: <levels of tests and where they live>.
