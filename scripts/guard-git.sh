#!/usr/bin/env bash
# PreToolUse guard registered by the lbdev build and ship skills.
# Reads the hook JSON on stdin, exits 2 with a reason on stderr to block the command.

input=$(cat)
cmd=""
if command -v jq >/dev/null 2>&1; then
  cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)
fi
# Without jq, match against the raw JSON: the patterns below only target git and gh commands.
[ -z "$cmd" ] && cmd=$input

mode=${CLAUDE_PLUGIN_OPTION_GIT_MODE:-}

has() { printf '%s' "$cmd" | grep -Eiq -- "$1"; }
block() { printf 'lbdev guard: %s Log a feedback entry of kind guard.\n' "$1" >&2; exit 2; }

GIT='(^|[^[:alnum:]_./-])git[[:space:]]+([^;&|]*[[:space:]])?'
GH='(^|[^[:alnum:]_./-])gh[[:space:]]+([^;&|]*[[:space:]])?'
# End of a word: a space, the end of the command, or the closing quote of the raw JSON value.
END='([[:space:]"]|$)'
EOC='("|$)'

has "${GIT}|${GH}" || exit 0

if has "${GIT}(commit|tag|notes)${END}|${GH}(pr|issue|release)[[:space:]]+(create|edit|comment|review)"; then
  has 'co-authored-by|generated (with|by)|noreply@anthropic\.com' &&
    block "AI attribution is not allowed in commits, tags or PR text. Remove the trailer or footer and retry."
fi

has "${GIT}config[^;&|]*user\.(name|email)" &&
  block "changing the git identity is not allowed. Use the identity already configured."
has "${GIT}commit[^;&|]*--author|GIT_(AUTHOR|COMMITTER)_(NAME|EMAIL)=" &&
  block "overriding the commit author is not allowed. Use the identity already configured."

has "${GH}pr[[:space:]]+merge" &&
  block "merging pull requests is not allowed. The user merges by hand."
has "${GH}pr[[:space:]]+review[^;&|]*--approve" &&
  block "approving pull requests is not allowed."

has "${GIT}push[^;&|]*(--force|[[:space:]]-f${END}|[[:space:]]\+[^[:space:]])" &&
  block "force push is not allowed."
has "${GIT}push[^;&|]*[[:space:]:](main|master)${END}" &&
  block "pushing to the default branch is not allowed. Push a feature branch instead."

case "$mode" in
  none)
    has "${GIT}(add|commit|push|merge|rebase|reset|restore|rm|mv|clean|cherry-pick|revert|checkout|switch)${END}|${GIT}branch[[:space:]]+[^-[:space:]]|${GIT}tag[[:space:]]+([^-[:space:]]|-[ads])|${GIT}stash([[:space:]]+(push|pop|apply|drop|clear|save)|[[:space:]]*${EOC})|${GH}(pr|release|issue)[[:space:]]+(create|edit|merge|comment|close)" &&
      block "git_mode is none: no git writes. Give the user the exact commands to run instead."
    ;;
  commit)
    has "${GIT}push${END}|${GH}(pr|release)[[:space:]]+(create|edit)" &&
      block "git_mode is commit: commit locally, no push and no pull request."
    ;;
  push)
    has "${GH}pr[[:space:]]+(create|edit)" &&
      block "git_mode is push: no pull request."
    ;;
esac

exit 0
