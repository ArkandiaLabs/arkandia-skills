# Hook 5 — audit log. PreToolUse, every tool, async. Never decides anything.
H=audit-log.sh
LOGREPO="$WORK/logrepo"; mkdir -p "$LOGREPO"; ( cd "$LOGREPO" && git init -q )
LOG="$LOGREPO/logs/audit.log"

assert() { if [ "$2" = "$3" ]; then PASS=$((PASS+1)); [ -n "${VERBOSE:-}" ] && printf '  ok   %s\n' "$1"
           else FAIL=$((FAIL+1)); FAILED_CASES="$FAILED_CASES
    [audit-log] $1 — expected $3, got $2"; printf '  FAIL %s — expected %s, got %s\n' "$1" "$3" "$2"; fi; }

# EVERY payload runs inside the fixture, and every one is checked for exit status and silence.
#
# Two bugs lived in the four lines this replaces, and neither was visible from the output:
#
#   - The exit status was discarded. This hook's contract is that it never decides anything and
#     always exits 0; a version that wrote the right row and then died would have passed every
#     assertion below.
#   - The `check` helper in tests/lib.sh runs the hook from the RUNNER's directory, not from
#     $LOGREPO, and this hook resolves its log path from `repo_root`. So the two "never decides"
#     cases appended audit rows to the arkandia-skills checkout itself — and `.gitignore` carries
#     `*.log`, so the stray file never appeared in `git status`. A test suite writing outside its
#     fixture, invisibly, is the exact failure shape this suite exists to catch.
run_in_repo() { OUT_="$( cd "$LOGREPO" && printf '%s' "$1" | bash "$WORK/hooks/$H" 2>&1 )"; RC_=$?; }

log_hook() {
  run_in_repo "$1"
  assert "$2 — exits 0"                 "$RC_"             0
  assert "$2 — decides nothing"         "${OUT_:-SILENT}"  SILENT
}

log_hook '{"session_id":"s1","hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"make check","description":"gates"}}' 'bash payload'
# Nested braces inside a string must not fool the brace balancer.
log_hook '{"session_id":"s1","hook_event_name":"PreToolUse","tool_name":"Write","tool_input":{"file_path":"/r/a.cs","content":"var s = \"{ nested }\";"}}' 'nested braces payload'
# A pretty-printed payload defeats every line-oriented extractor unless the reader folds the
# structural newlines first. It used to log a bare `-` here while the column count stayed at 5,
# so counting fields signed off on an empty log.
log_hook '{
  "session_id": "s1",
  "hook_event_name": "PostToolUse",
  "tool_name": "Read",
  "tool_input": {
    "file_path": "/r/b.cs"
  }
}' 'pretty-printed payload'
log_hook '{"session_id":"s2","hook_event_name":"PreToolUse","tool_name":"Glob"}' 'payload with no tool_input'

rows()      { wc -l < "$LOG" | tr -d ' '; }
cols()      { awk -F'\t' '{print NF}' "$LOG" | sort -u | tr '\n' ' ' | sed 's/ $//'; }
empty_in()  { awk -F'\t' '$4 != "Glob" && $5 == "-" {n++} END {print n+0}' "$LOG"; }

assert 'one row per tool call'              "$(rows)"     4
assert 'exactly five columns, every row'    "$(cols)"     5
assert 'tool_input captured on every row'   "$(empty_in)" 0
assert 'nested braces survive'              "$(awk -F'\t' 'NR==2 {print ($5 ~ /nested/) ? "yes" : "no"}' "$LOG")" yes
assert 'pretty-printed payload captured'    "$(awk -F'\t' 'NR==3 {print ($5 ~ /b\.cs/) ? "yes" : "no"}' "$LOG")" yes
assert 'the event is recorded'              "$(awk -F'\t' 'NR==3 {print $3}' "$LOG")" PostToolUse

# It must never decide anything, whatever it is handed. In the fixture, not in the runner's repo:
# see the note on run_in_repo above.
log_hook '{"session_id":"s1","hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"rm -rf /"}}' 'never denies'
log_hook '' 'empty payload'

# Nothing was written outside the fixture. This is the assertion that would have caught the bug.
assert 'writes nothing outside the fixture' "$( [ -e "$PWD/logs/audit.log" ] && echo leaked || echo clean )" clean
