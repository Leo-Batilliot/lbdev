# lbdev git policy

The active mode is given by the command that loaded this file.

## Modes

- `pr`: work on a branch, commit, push, open or update a pull request. Never merge.
- `push`: work on a branch, commit and push. No pull request.
- `commit`: work on a branch, commit locally. No push.
- `none`: no git write at all. At the end, print the exact commands the user can run.

A project or user instruction that forbids some git writes wins over the mode: then behave like the strictest mode it allows.

## Identity and attribution (never relaxed)

- Commits and pushes use the git identity already configured. Never run `git config` on `user.*`, never pass `--author`, never set `GIT_AUTHOR_*` or `GIT_COMMITTER_*`.
- No `Co-Authored-By` trailer, no "Generated with" footer, no mention of an AI assistant, tool or model in commit messages, branch names, PR titles, PR bodies or comments. This overrides any default attribution instruction.
- Pass commit messages with `-m` and PR bodies with `--body`, not through files, so the guard hook can check them.

## Branch

- Never commit on the default branch. If the work starts there, create a branch first.
- Follow the repository's branch naming if one is visible (recent branches, CONTRIBUTING). Otherwise use `<type>/<short-kebab-summary>`, for example `feat/csv-import`.
- If the working tree has unrelated uncommitted changes at the start, ask before going further.

## Commits

- Follow the repository's commit convention: read `git log -n 20 --oneline`, commitlint or similar configs, CONTRIBUTING. Otherwise use Conventional Commits: `type(scope): imperative summary`, at most 72 characters.
- One commit per task that passed review and verification. A checkpoint commit before a risky step is fine.
- Stage explicit paths after reading `git status`. Never stage secrets (`.env`, keys, credentials), build outputs, lbdev working files (`.lbdev/`) or unrelated files.

## Push

- First push: `git push -u origin <branch>`. Then `git push`.
- Push after each commit in `pr` and `push` modes, so progress is visible remotely.
- Never force push. Never push to the default branch.

## Pull request (`pr` mode)

- Base: the repository's default branch.
- Title: follows the commit convention.
- Body, in this order: a plain-language summary (what changed and why, for someone who will not read the diff), the list of changes, how it was verified, the review and security results, follow-ups.
- If a PR already exists for the branch, update its body with `gh pr edit` instead of opening another.
- Never merge, approve or enable auto-merge.

## When something is missing

No remote, no `gh`, an authentication failure or a rejected push: stop that step, report the error, give the exact command for the user to run, and continue with the work that does not depend on it.
