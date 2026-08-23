# Hook 5 — audit log. PreToolUse, every tool, async. Never decides anything.
H=audit-log.sh
LOGREPO="$WORK/logrepo"; mkdir -p "$LOGREPO"; ( cd "$LOGREPO" && git init -q )
LOG="$LOGREPO/logs/audit.log"

log_hook() { ( cd "$LOGREPO" && printf '%s' "$1" | bash "$WORK/hooks/audit-log.sh" ); }

log_hook '{"session_id":"s1","hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"make check","description":"gates"}}'
# Nested braces inside a string must not fool the brace balancer.
log_hook '{"session_id":"s1","hook_event_name":"PreToolUse","tool_name":"Write","tool_input":{"file_path":"/r/a.cs","content":"var s = \"{ nested }\";"}}'
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
}'
log_hook '{"session_id":"s2","hook_event_name":"PreToolUse","tool_name":"Glob"}'

rows()      { wc -l < "$LOG" | tr -d ' '; }
cols()      { awk -F'\t' '{print NF}' "$LOG" | sort -u | tr '\n' ' ' | sed 's/ $//'; }
empty_in()  { awk -F'\t' '$4 != "Glob" && $5 == "-" {n++} END {print n+0}' "$LOG"; }

assert() { if [ "$2" = "$3" ]; then PASS=$((PASS+1)); [ -n "${VERBOSE:-}" ] && printf '  ok   %s\n' "$1"
           else FAIL=$((FAIL+1)); FAILED_CASES="$FAILED_CASES
    [audit-log] $1 — expected $3, got $2"; printf '  FAIL %s — expected %s, got %s\n' "$1" "$3" "$2"; fi; }

assert 'one row per tool call'              "$(rows)"     4
assert 'exactly five columns, every row'    "$(cols)"     5
assert 'tool_input captured on every row'   "$(empty_in)" 0
assert 'nested braces survive'              "$(awk -F'\t' 'NR==2 {print ($5 ~ /nested/) ? "yes" : "no"}' "$LOG")" yes
assert 'pretty-printed payload captured'    "$(awk -F'\t' 'NR==3 {print ($5 ~ /b\.cs/) ? "yes" : "no"}' "$LOG")" yes
assert 'the event is recorded'              "$(awk -F'\t' 'NR==3 {print $3}' "$LOG")" PostToolUse

# It must never decide anything, whatever it is handed.
check $H silent 'never denies'   '{"session_id":"s1","hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"rm -rf /"}}'
check $H silent 'empty payload'  ''
