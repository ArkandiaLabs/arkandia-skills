#!/usr/bin/env bash
#
# Regression suite for the instrument-agent-dotnet hook templates.
#
#   bash tests/run.sh              # summary only
#   VERBOSE=1 bash tests/run.sh    # every case
#
# WHAT THIS IS FOR. A hook's failure mode is silence: a guard with a broken pattern exits 0 and is
# indistinguishable from a guard that looked and found nothing. Three real bugs shipped that way
# and were caught only by executing the scripts against synthetic payloads — `set -o pipefail`
# converting a short-circuiting filter into a fall-through to allow; JSON escapes stripped before
# they were translated, fusing a multi-line command into one token; and `[;|&\n]` in sed, which
# POSIX reads as including the letter n. None of the three is visible by reading the code.
#
# WHO RUNS IT. Maintainers of this repository, after touching a hook template. It tests the
# TEMPLATES. The team that installs the skill verifies their own INSTALLATION in the skill's
# Phase 5, against their own repo — a different thing.
#
# WHAT IT COVERS. The five hooks that need nothing installed. `format-on-edit` and
# `dependency-sweep` need the .NET SDK and a solution that restores; testing them here would make
# this repository depend on .NET, so they stay in Phase 5. Every silent-failure bug found so far
# lives in the five that are covered.
#
# THE DATA IS SYNTHETIC. The payloads are JSON strings; no credential, no path from anyone's
# machine, no network. `/repo/.env` is never created and never needs to be — the guards decide
# from the payload, they do not open the file.
set -u

REPO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

. "$REPO/tests/lib.sh"

materialize

for c in "$REPO"/tests/cases/*.sh; do
  printf '\n%s\n' "$(basename "$c" .sh)"
  . "$c"
done

printf '\n────────────────────────────────\n'
if [ "$FAIL" -eq 0 ]; then
  printf '%s passed, 0 failed\n' "$PASS"
  exit 0
else
  printf '%s passed, %s FAILED%s\n' "$PASS" "$FAIL" "$FAILED_CASES"
  exit 1
fi
