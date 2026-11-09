#!/usr/bin/env bash
# Progress board for /lbdev:build. The state lives in a small TSV file; every change prints the board.
#
#   progress.sh init <file> <title> <id|label>...   create the board (kept if it already exists)
#   progress.sh set  <file> <id> <status> [note]    status: todo, active, done, parked
#   progress.sh show [file]                         print the board
#   progress.sh hook                                PostToolUse hook: show the board to the user when it changed

pointer_dir() {
  local dir
  dir=$(git rev-parse --git-dir 2>/dev/null) || dir="${TMPDIR:-/tmp}"
  printf '%s' "$dir"
}

remember() { printf '%s\n' "$1" > "$(pointer_dir)/lbdev-board"; }

active_file() {
  local p
  p="$(pointer_dir)/lbdev-board"
  [ -f "$p" ] && head -n 1 "$p"
}

render() {
  local file=$1
  [ -f "$file" ] || { echo "lbdev: no board at $file" >&2; return 1; }
  awk -F '\t' '
    $1 == "#title" { title = $2; next }
    $1 ~ /^#/ { next }
    NF >= 3 {
      n++; id[n] = $1; st[n] = $2; label[n] = $3; note[n] = $4
      if ($2 == "done") done++
      if (length($3) > w) w = length($3)
    }
    END {
      if (n == 0) { print "lbdev | " title " | no tasks"; exit }
      width = 20; filled = int(done * width / n)
      bar = ""; for (i = 0; i < width; i++) bar = bar (i < filled ? "#" : "-")
      printf "lbdev | %s\n[%s] %d/%d  %d%%\n", title, bar, done, n, int(done * 100 / n)
      for (i = 1; i <= n; i++) {
        mark = "[ ]"
        if (st[i] == "done") mark = "[x]"
        else if (st[i] == "active") mark = "[>]"
        else if (st[i] == "parked") mark = "[!]"
        line = sprintf("%s %-4s %-" w "s", mark, id[i], label[i])
        if (note[i] != "") line = line "  " note[i]
        sub(/ +$/, "", line)
        print line
      }
    }' "$file"
}

cmd=$1; shift 2>/dev/null

case "$cmd" in
  init)
    file=$1; title=$2; shift 2
    mkdir -p "$(dirname "$file")"
    if [ ! -f "$file" ]; then
      {
        printf '#title\t%s\n' "$title"
        for entry in "$@"; do
          printf '%s\ttodo\t%s\t\n' "${entry%%|*}" "${entry#*|}"
        done
      } > "$file"
    fi
    remember "$file"
    render "$file"
    ;;
  set)
    file=$1; id=$2; status=$3; note=$4
    case "$status" in todo|active|done|parked) ;; *) echo "lbdev: unknown status '$status'" >&2; exit 1 ;; esac
    grep -q "^${id}	" "$file" 2>/dev/null || { echo "lbdev: no task '$id' in $file" >&2; exit 1; }
    tmp="$file.tmp"
    awk -F '\t' -v OFS='\t' -v id="$id" -v st="$status" -v note="$note" \
      '$1 == id { $2 = st; $4 = note } { print }' "$file" > "$tmp" && mv "$tmp" "$file"
    remember "$file"
    render "$file"
    ;;
  show)
    file=${1:-$(active_file)}
    [ -n "$file" ] || { echo "lbdev: no active board" >&2; exit 1; }
    render "$file"
    ;;
  hook)
    cat > /dev/null
    file=$(active_file)
    [ -n "$file" ] && [ -f "$file" ] || exit 0
    board=$(render "$file") || exit 0
    seen="$(pointer_dir)/lbdev-board.shown"
    hash=$(printf '%s' "$board" | cksum)
    [ -f "$seen" ] && [ "$(cat "$seen")" = "$hash" ] && exit 0
    printf '%s' "$hash" > "$seen"
    printf '%s' "$board" | awk '
      { gsub(/\\/, "\\\\"); gsub(/"/, "\\\""); gsub(/\t/, " "); out = out (NR > 1 ? "\\n" : "") $0 }
      END { printf "{\"systemMessage\": \"%s\"}\n", out }'
    ;;
  *)
    echo "usage: progress.sh init|set|show|hook ..." >&2
    exit 1
    ;;
esac
exit 0
