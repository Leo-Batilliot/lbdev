#!/usr/bin/env bash
# Prints one hash of the working tree state: tracked changes, staged changes and untracked file contents.
# Two equal outputs mean nothing changed in between. Writes nothing to the repository.

cd "${1:-.}" || exit 1
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "not a git repository" >&2; exit 1; }

{
  git rev-parse HEAD 2>/dev/null
  git status --porcelain=v1 --untracked-files=all
  git diff HEAD --binary 2>/dev/null || git diff --cached --binary
  git ls-files --others --exclude-standard | git hash-object --stdin-paths
} | git hash-object --stdin
