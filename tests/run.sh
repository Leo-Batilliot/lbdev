#!/usr/bin/env bash
# Tests for the plugin scripts. Run: bash tests/run.sh
# Needs bash, git and awk. Creates a throwaway git repository in a temporary directory.

root=$(cd "$(dirname "$0")/.." && pwd)
guard="$root/scripts/guard-git.sh"
progress="$root/scripts/progress.sh"
fingerprint="$root/scripts/worktree-fingerprint.sh"
fails=0; total=0

check() {
  total=$((total + 1))
  if [ "$2" = "$3" ]; then return; fi
  fails=$((fails + 1)); printf 'FAIL %s (expected %s, got %s)\n' "$1" "$2" "$3"
}

json_escape() { printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'; }

guard_case() {
  local mode=$1 expected=$2 cmd=$3 rc
  printf '{"tool_name":"Bash","tool_input":{"command":"%s","description":"x"}}' "$(json_escape "$cmd")" |
    CLAUDE_PLUGIN_OPTION_GIT_MODE="$mode" bash "$guard" >/dev/null 2>&1
  rc=$?
  check "guard[$mode] $cmd" "$expected" "$rc"
}

guard_case pr 0 'git status'
guard_case pr 0 'git commit -m "feat: add csv import"'
guard_case pr 2 'git commit -m "feat: x" -m "Co-Authored-By: Bot <noreply@anthropic.com>"'
guard_case pr 2 'gh pr create --title "feat: x" --body "Generated with some tool"'
guard_case pr 0 'gh pr create --title "feat: x" --body "Adds import"'
guard_case pr 2 'gh pr merge 12 --squash'
guard_case pr 2 'gh pr review 12 --approve'
guard_case pr 2 'git push --force origin feat/x'
guard_case pr 2 'git push -f'
guard_case pr 0 'git push -u origin feat/main-menu'
guard_case pr 2 'git push origin main'
guard_case pr 2 'git config user.email bot@x.com'
guard_case pr 2 'git commit --author="Bot <b@x>" -m "x"'
guard_case pr 0 'cd src && npm test'
guard_case pr 0 'echo "digit commit"'
guard_case pr 0 'git -C repo log --oneline'
guard_case pr 2 'git -C repo commit -m "x" -m "Co-authored-by: a <b>"'
guard_case commit 2 'git push -u origin feat/x'
guard_case commit 0 'git commit -m "fix: y"'
guard_case push 2 'gh pr create --title t --body b'
guard_case push 0 'git push'
guard_case none 2 'git add src/a.ts'
guard_case none 2 'git checkout -b feat/x'
guard_case none 0 'git log --oneline -n 5'
guard_case none 0 'git diff main...HEAD'
guard_case none 0 'git branch -a'
guard_case none 0 'git stash list'
guard_case none 2 'git stash'
guard_case none 2 'git status && git commit -m "x"'
guard_case '' 0 'git push -u origin feat/x'

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
repo="$tmp/repo"
mkdir -p "$repo" && cd "$repo" || exit 1
git init -q . && git config user.email t@t && git config user.name t && git config core.autocrlf false
echo a > tracked.txt && git add tracked.txt && git commit -qm init

h0=$(bash "$fingerprint"); check "fingerprint stable" "$h0" "$(bash "$fingerprint")"
echo x > new.txt; h1=$(bash "$fingerprint"); [ "$h1" != "$h0" ]; check "fingerprint new untracked" 0 $?
echo y >> new.txt; h2=$(bash "$fingerprint"); [ "$h2" != "$h1" ]; check "fingerprint untracked edited" 0 $?
rm new.txt
echo b >> tracked.txt; h3=$(bash "$fingerprint"); [ "$h3" != "$h0" ]; check "fingerprint tracked modified" 0 $?
echo c >> tracked.txt; h4=$(bash "$fingerprint"); [ "$h4" != "$h3" ]; check "fingerprint modified again" 0 $?
git checkout -q -- tracked.txt; check "fingerprint restored" "$h0" "$(bash "$fingerprint")"

board="$repo/plans/demo.board.tsv"
out=$(bash "$progress" init "$board" "Demo" "T1|Parser" "T2|Rules" "G|Final gate"); check "progress init" 0 $?
printf '%s' "$out" | grep -q '0/3'; check "progress init shows 0/3" 0 $?
out=$(bash "$progress" set "$board" T1 done abc1234)
printf '%s' "$out" | grep -q '^\[x\] T1 .*abc1234'; check "progress set done" 0 $?
printf '%s' "$out" | grep -q '1/3  33%'; check "progress counts" 0 $?
bash "$progress" set "$board" T9 done >/dev/null 2>&1; check "progress unknown task" 1 $?
bash "$progress" set "$board" T2 weird >/dev/null 2>&1; check "progress unknown status" 1 $?
bash "$progress" set "$board" T2 active 'say "hi"' >/dev/null
hook1=$(echo '{}' | bash "$progress" hook)
printf '%s' "$hook1" | grep -q '^{"systemMessage": ".*\[>\] T2 .*say \\"hi\\"'; check "progress hook json" 0 $?
hook2=$(echo '{}' | bash "$progress" hook); check "progress hook silent when unchanged" "" "$hook2"

index="$root/kits/index.md"
for f in $(awk '/^- file: / { print $3 }' "$index"); do
  [ -f "$root/$f" ]; check "kit file exists: $f" 0 $?
done
limit=$(awk '/"max_kits_per_role"/ { on = 1 } on && /"default"/ { gsub(/[^0-9]/, ""); print; exit }' "$root/.claude-plugin/plugin.json")
over=$(awk -v max="$limit" '/^- roles: / { sub(/^- roles: /, ""); n = split($0, r, /, */); for (i = 1; i <= n; i++) c[r[i]]++ }
  END { for (k in c) if (c[k] > max) print k }' "$index")
check "kits per role within $limit" "" "$over"
for r in $(awk '/^- roles: / { sub(/^- roles: /, ""); gsub(/, */, " "); print }' "$index"); do
  [ -f "$root/roles/$r.md" ]; check "kit role exists: $r" 0 $?
done

printf '%s/%s passed\n' "$((total - fails))" "$total"
[ "$fails" -eq 0 ]
