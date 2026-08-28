# Changelog

All notable changes to the `arkandia` plugin. Versions follow the `version` field in
`arkandia/.claude-plugin/plugin.json`. Dates are the date the work landed on `main`.

## [0.5.0] — unreleased

### Added

- **`requirement-to-spec`** — the other half of the delivery pipeline, upstream of
  `linear-plan-build`/`ado-plan-build`. Turns a business requirement document (Word, PDF, Excel,
  Markdown, plus its attachments) into a spec and an ordered task breakdown. Converts any source
  format to one Markdown model through a pinned `@firecrawl/anydoc@0.2.3`, with native multimodal
  `Read` as the fallback where the format allows one — PDFs and text, not the binary Office
  containers `Read` cannot open — and a hard stop, never an invented answer, when neither produces
  usable content. Reads the target repo's conventions and scans, stack-agnostically, for a public
  contract the change would touch (OpenAPI, GraphQL, `.proto`, exported library symbols), asking
  explicitly whether to break it or keep it compatible even when the document itself never raises
  the question. Finds the project documentation the change leaves stale — architecture, data model,
  API list, runbooks, ADRs, `AGENTS.md` — by grepping the doc set for the concrete names the
  requirement touches and listing a document only when it can quote the line that goes false, then
  asks which of them belong in this pass and turns each confirmed one into its own documentation
  task naming the file, what is now wrong, and what should replace it — placed **after** the
  functional work it describes and blocking nothing, since a page is rewritten to match what was
  built. It never edits those documents itself. Sweeps the document for ambiguity across seven categories, in batches of at most
  four jargon-free questions, and always asks where to save the result — the trackers actually
  detected (Linear, Azure DevOps) plus a local file, never auto-picked even with exactly one
  tracker found. Every validation criterion it surfaces — the rule the business will check the
  result against, usually written as background — gets asked about rather than assumed: whether it
  becomes its own item in the breakdown, and only then whether the rest of the work waits for it.
  Derives an ordered task breakdown from the closed decisions — functional work first, dependencies
  written out rather than implied by order — and rereads what it wrote — the parent-child relation, the initial status, or the
  file links — before reporting success. Never writes code, never opens a PR, never commits. The
  asymmetry it leaves: `linear-plan-build`/`ado-plan-build` have no file-mode entry point today, so
  a run that lands in file mode does not chain automatically into them.

### Changed

- **`linear-plan-build` / `ado-plan-build` now deliver a ticket subissue by subissue.** Step A
  opens by asking which children this run covers — all of them by default, and whatever is left
  out is named in the final report rather than quietly dropped. Each selected subissue is then
  implemented, committed and pushed on its own, carrying **its own** link token so the tracker
  attaches the commit to the child and not just to the parent, and is commented and **moved to the
  team's completed state** as it closes — a child that is implemented, gated and pushed is finished
  as a unit of work, and leaving it in progress makes the board claim there is work left that
  nobody is doing. The **parent** is the one that waits: it goes to the review state at Step J and
  stays there until someone merges the PR. The full gate set, `/code-review` and
  `/security-review` run **once** over the complete branch diff, and one PR is opened for the
  whole ticket. If anything on the work list was not implemented — blocked, escalated, abandoned
  — there is no PR at all: the run reports what is missing and leaves the branch pushed so nothing
  built is lost. Both skills keep one branch and one PR per ticket, so no worktree isolation is
  involved.
- **The run narrates itself in plain language.** The build loop gained a standing rule: one line
  when a step opens and one when it closes, every state change announced as it happens — the
  branch, each tracker status and which state was picked, each commit and push, the PR URL, the CI
  run being waited on — written for the person who filed the ticket rather than for the diff
  reviewer, and never printed ahead of the fact. A long autonomous run whose only output is tool
  noise is a run nobody can follow.
- **Implementation is delegated by default; the main session orchestrates.** Step F now hands the
  editing to subagents that report what they changed instead of returning file contents, keeping
  the orchestrator's context for the plan, the gates, the pushes and the user. Steps that must run
  in order still do — in one subagent, rather than in the main session.
- **Comments follow the repo, not the agent.** Step F carries an explicit restraint: match the
  surrounding comment density (usually none), write one only where a reader would otherwise ask
  *why*, never narrate your own change, apply the same rule to config and project files, and write
  them in the language the repo's code already uses.
- **The plan is now a file.** Step C writes `.claude/plans/<TICKET>.md` and keeps it current while
  the work runs — the work list with each item's state, the Decisions, the Assumptions and the
  test verdicts. It is a working notebook, not the archive: it survives a session that dies or
  gets compacted so a resumed run continues instead of re-deriving everything, it is never staged
  and never committed on the skill's initiative, and Step J asks whether to delete it, keep it, or
  move it into the repo's own documentation. The permanent record stays where people look for it:
  the PR body and the tracker comment.
- **Assumptions now carry provenance.** Each one is written with its source — `file:line`,
  `inferred`, or `none` — plus what would falsify it, and an assumption sourced `none` about a
  public contract, a data schema, auth or a money path is reclassified as what it actually is: a
  Step A question that was never asked. This is the lightweight answer to the question of whether
  the delivery skills needed `agent-context-dotnet`'s claim ledger; they did not, they needed
  sourced assumptions.
- **Tests the change invalidates are settled before any code is written.** The Step B exploration
  now also returns the existing tests over every symbol in play, and each gets a verdict in the
  plan: **update** in the same step that changes the code, **delete** while naming what stopped
  being covered, or **escalate** — a test asserting something the ticket never mentioned means
  either the change breaks more than anyone said, or that test is the only place the requirement
  was ever written down. Previously this surfaced at Step I, as a red CI job, which is exactly
  where "the test is in the way" turns into loosening it.
- **`linear-plan-build` checks the GitHub half of its bindings up front.** Phase 0 gained a
  prerequisites step — `gh --version`, `gh auth status`, and that `origin` is actually a GitHub
  remote — with per-OS install commands and the same install-nothing-yourself posture as the
  `instrument-*` skills. An unauthenticated `gh` used to surface at Step H, after a full
  implementation had already been paid for.
- **Both delivery skills gained the family's canonical sections** — `Philosophy`, `References` and
  `Troubleshooting` — which until now only the context and instrumentation skills carried. The
  troubleshooting tables are per-tracker: MCP pending-approval vs absent, `AB#<id>` as the only
  link syntax Boards honours, acceptance criteria that the Basic process does not define, HTML
  descriptions, states that differ per process, and a CI watch that returns instantly because no
  run has registered yet.

### Fixed

- **`instrument-agent-dotnet`'s secret read-guard: four bypasses the 0.4.0 tokeniser opened.** That
  tokeniser exists for a good reason — the whitespace split before it denied prose, and a denial
  that looks like the guard working gets worked around rather than reported — but each of its four
  drops was drawn one inch too wide, and each inch was a payload that `main` had denied and 0.4.0
  allowed. `echo "$(cat .env)"` — the operand of a text emitter was dropped whole, substitution
  included, while the unquoted `echo $(cat .env)` still denied, so a quick check made the guard look
  intact. `cat -t .env` and `sort -b .env` — `-t` and `-b` were on the message-flag list, so the
  file after them was skipped as if it were a commit subject. `python -c "open('.env')"` — the
  re-scan of a `-c` argument was gated on the argument containing a space, so anything fitting in
  one word walked through, `node -e` included. And an unterminated `<<EOF` ran the body skip to end
  of input, which switched the guard off for every command after it. Now: the text inside `$(…)` or
  backticks is re-scanned as its own command in a suppressed segment too (the text inside only —
  nesting the whole token would put the sentence's own words back in the operand list); short
  message flags are gated on the command being `git`/`gh`/`hub`/`glab` while the long forms stay
  unconditional; a quoted `-c` argument is re-scanned whether or not it holds a space, and an
  interpreter's `-e` counts as one; and a heredoc with no delimiter fails closed, rewinding and
  tokenising its body as ordinary commands. Fifteen cases added to `tests/run.sh`, nine of which
  fail against 0.4.0 — the other six pin the legitimate cases each fix could have re-denied.
  `AGENTS.md`'s standing caveat is unchanged and still true: this hook runs with the user's shell
  and matches text, not intent. It is a guardrail against mistakes, not a security barrier — but a
  guardrail that appears to cover a case and does not is worse than one known to be incomplete.

- **The same guard again: two false positives the fixes above introduced, and the five paths they
  did not reach.** Closing four bypasses moved the line, and the line landed on ordinary work.
  `sudo git commit -m "chore: ignore .env"` was denied — and `timeout`, `nohup`, `env` and `xargs`
  the same way: the command name was read off the first word of the segment, so a wrapper answered
  for the command it runs, `git` never set the message-flag gate, and the commit message came back
  as a command to re-scan. `echo "$(date) adds .env to .gitignore (see PR)"` was denied too: the
  substitution re-scan closed at the **last** `)` in the token instead of the balanced one, so a
  single parenthesis of prose dragged the sentence back into the operand list — re-denying, exactly,
  the case the tokeniser was written to allow. Both were silent against the suite, because every
  "must not fire" case it had used `git`/`gh` as the first word and prose with no parentheses in it.
  Now: `$(…)` closes on the balanced paren; wrappers are walked past — their flags, a `timeout`
  duration, an `env` assignment — and the word they actually run is what classifies the segment.

  With the line back where it belongs, the re-scan was widened to where it had always claimed to
  reach. It now runs on **every** token before any rule can drop it, so `git commit -m "$(cat
  .env)"`, `gh pr create --body "$(cat .env)"`, `cat <<< "$(cat .env)"` and `KEY="$(cat .env)"` are
  denied instead of allowed; a substitution in a heredoc **body** is scanned unless a quoted
  delimiter (`<<'EOF'`) turned expansion off; both substitution forms in one token are found rather
  than only the first; and `,` joins `/` and `=` as an anchor in `SECRET_PATTERNS`, which is what
  `perl -e "open(F,'.env')"` needs — putting the comma in the tokeniser's separators instead would
  have broken brace expansion, which needs its commas inside the token.

  The re-scan budget is now spent in **bytes appended** rather than in a count of four calls. Four
  ordinary substitutions — `cd "$(git rev-parse --show-toplevel)"` and three like it — used to
  exhaust it, after which the rest of the command went unscanned in silence. The bound is still
  finite; it is no longer reachable by commands an agent writes all day. Twenty-three cases added,
  pinning both the false positives and the paths.

- **`linear-plan-build` / `ado-plan-build`: a ticket with no subissues no longer goes Done and then
  backwards.** The work list falls back to the ticket itself when it has no children, and Step F.6.4
  closed "the sub-ticket" without an exception for that case — so the board showed Done before a PR
  existed and Step J then walked it back to In Review, a state the binding tables define as the
  parent's alone. F.6.4 now comments and leaves the status alone when the item is the parent.
  Two more gaps around the same move: fixes made in Step G and Step I had no commit rule at all once
  commit and push moved into F.6 — Step H then demanded a clean tree that nothing was allowed to
  produce — and a gate finding against a child already at Done left the tracker permanently
  asserting a verification that had failed. Step G and Step I now point at the F.6.1–F.6.3 rules,
  and a red gate sends the affected child back through F.6.4. `Bash(rm .claude/plans/*)` is granted,
  scoped to that path, so Step J's recommended "Delete it" is an option the run can actually carry
  out.

- **`requirement-to-spec`: the database cross-check can no longer be reported as "not connected".**
  A database MCP server is detected by the *shape* of its tools, so it cannot be named in
  `allowed-tools` ahead of time and the first query prompts. That prompt is the run working; what is
  now forbidden in writing is folding a refused or failed query into "no database connected" when
  Phase 1 recorded that one is. The report separates the two and names the tool that was tried. The
  Azure DevOps write path gains an explicit floor of tool names past the two attested readers —
  a guess at the spelling, marked as one, since a name the server does not expose costs nothing and
  one it spells differently costs a single prompt.

## [0.4.0] — 2026-08-25

### Added

- **`instrument-project-dotnet`** — a third skill family. Installs eight deterministic
  controls in a .NET repository: reproducible inputs (SDK pin, central package management, lock
  files), a strict build with analyzers, verifiable style, a single `make check` entry point,
  Lefthook pre-commit/pre-push gates, gitleaks secret scanning, ArchUnitNET architecture fitness
  functions derived from the repository's own reference graph, and a CI pipeline (GitHub Actions or
  Azure DevOps) that runs the same command as your laptop. Every gate is proven to fail before the
  run reports success, and the documentation the install invalidates is updated.

- **`instrument-agent-dotnet`** — the other half of the instrumentation layer. Registers the
  team's MCP servers in `.mcp.json`, derived from what the repository actually uses, then installs
  a catalogue of seven Claude Code hooks in `.claude/settings.json`, backed by portable bash
  scripts in `scripts/agent-hooks/`: a secret read-guard, `dotnet format` scoped to the file that
  changed, a dangerous-command blocker, a `SessionStart` advisory sweep, an audit log, and guards
  for central package management and generated files. Two hooks are installed by default and the
  rest are offered — the two that protect an artifact are hidden when the repository does not have
  it. Every installed hook is fired on purpose before the run reports success, and the report
  states the two asymmetries the layer carries: the MCP servers are written but pending workspace
  approval, and the hooks run under Claude Code alone.

### Changed

- **`instrument-project-dotnet` now pins gitleaks in CI and verifies the download.** Both pipeline
  templates resolved `releases/latest` on every run and extracted the archive with `sudo` into
  `/usr/local/bin`, so the gate meant to catch problems ran an unverified binary that could change
  between runs with nothing recording it. The version is now resolved once, when the file is
  written, and pinned; the archive is checked against the project's published `checksums.txt`
  before extraction; and the install no longer escalates privileges.

- **`instrument-agent-dotnet` now pins the MCP packages too.** `.mcp.json` launched every stdio
  server with a bare `npx -y <package>`, so a committed, session-start config executed whatever npm
  had published since, with the user's own permissions and nothing recording the change. Versions
  are now resolved with `npm view` when the file is written, pinned in the `args`, and reported —
  the same "resolve once, then pin" rule the gitleaks change above applies in CI.

- **The dangerous-command blocker no longer claims to cover PowerShell.** Its matcher was
  `Bash|PowerShell`, but the script parses shell syntax and dispatches on `rm`, `git`, `dotnet`,
  `nuget` and `sudo` — `Remove-Item -Recurse -Force C:\` reached the end of the loop and exited 0.
  The matcher is now `Bash`. Hook 1 keeps `PowerShell`, because it matches a path rather than
  syntax.

- **The secret read-guard tells opening a file from naming one.** It split the Bash command on
  whitespace and treated every word as a path, so a commit message, a PR body (`gh pr create
  --body "... .env ..."`) or an `echo` that mentioned `.env` was denied — a denial that reads as
  the guard working, so it gets worked around instead of reported, and the workaround ends at
  turning the hook off. The command is now tokenised by a small shell tokeniser that follows
  quoting, separators, heredocs and redirections, and drops what nothing opens: `echo`/`printf`
  operands, heredoc bodies, the value of `-m`/`--body`/`--title`, and the pattern of a `grep` or
  `sed`. A quoted argument with spaces is kept whole rather than split, so prose cannot match the
  anchored patterns while `cat "my dir/.env"` still does — unless a shell runs it, and then
  `bash -c "cat .env"` or `ssh host "cat .env"` is re-scanned as the command it is. Brace
  expansion is expanded, so `cat {.env,.env.local}` is denied. What redirection opens is still
  checked: `echo x > .env` stays denied. 161 cases → 185, and one old case changed meaning:
  `cat .env,other` opens a file of that literal name and is now allowed. What the tokeniser
  still does not see is written down as cases of its own rather than left to be rediscovered:
  an `echo` feeding a real reader (`echo .env | xargs cat` — denied by the old split, allowed
  now, and that is the price of not denying prose), a `-c` nested inside a `-c`, a second brace
  group, and `curl -F file=@.env`, which misses because `@` is not an anchor character. All four
  are evasion rather than error, and this guard is a barrier against error.

- **The `settings.json`/`.mcp.json` parse checks use `node`, not `python3`.** The skill already
  requires Node for its MCP servers and the README already asks for it; Python was an undeclared
  prerequisite in a .NET workflow. Four one-liners in `SKILL.md`, `mcp-servers.md` and
  `verification.md`.

- **The hook regression suite no longer writes outside its own fixture.** Two `audit-log` cases
  ran the hook from the runner's directory instead of `$LOGREPO`, and the hook resolves its log
  path from `repo_root` — so every run appended audit rows to the checkout itself. `.gitignore`
  carries `*.log`, so the stray file never appeared in `git status`. All four fixture payloads now
  also assert exit status and silence, which the previous helper discarded. 150 cases → 161.

- **Lock files are their own Phase 3 question in `instrument-project-dotnet`.** They were generated
  as part of the reproducible-inputs step while Phase 6 already offered to restate them as a
  declined migration — a decision the user was never asked to make. Declining them also drops
  `--locked-mode` from the Makefile and the pipeline in the same run.

- **README restructured.** It is now a catalogue: each skill's detail moved to
  `docs/skills/<name>.md`, with a Spanish counterpart at `docs/skills/<name>-es.md`. A new skill is
  now one file and one table row instead of a section in two long README files.
- Plugin and marketplace descriptions shortened to one line, so they stop being rewritten every
  time a skill is added.
- Author and marketplace owner changed from an individual to **Arkandia**.

## [0.3.0] — 2026-08-08

### Changed

- **`agent-context` and `agent-context-dotnet` merged into one skill.** The base pack and the .NET
  deep-dive used to be two runs; they are now `agent-context-dotnet` alone.
- **The delivery family was retargeted to specific trackers**, and both skills renamed:

  | Before | Now |
  |---|---|
  | `plan-and-build` (Markdown brief, stopped at commit) | `linear-plan-build` (Linear issue → green PR) |
  | `plan-and-build-dotnet` (.NET + Clean Architecture + Azure Boards) | `ado-plan-build` (Azure Boards → green PR, stack- and architecture-agnostic) |

### Removed

- **The old skill names are gone, not aliased.**
- **The tracker-less path was retired.** A `.md` brief or inline text is no longer an entry point;
  both delivery skills now start from a ticket.
- **`ado-plan-build` no longer checks for or suggests Clean Architecture**, `dotnet`-specific
  gates, or any named architectural pattern.

## [0.2.0] — 2026-07-13

### Added

- **The `plan-and-build` skill family** — `plan-and-build` (generic) and `plan-and-build-dotnet`
  (.NET specialist). Ticket or brief → explore → plan → adversarial review → test-first build.

## [0.1.0] — 2026-04-20

### Added

- **Initial release** — the `agent-context` skill, generating a minimal `AGENTS.md`-convention
  documentation pack.
- The plugin became the `arkandia` umbrella and the repository became `arkandia-skills`,
  restructured into a subdirectory to satisfy the marketplace schema.
- Install path via `npx skills` ([skills.sh](https://skills.sh)) alongside the native Claude Code
  marketplace.

### Added — 2026-06-20 (shipped under 0.1.0, no version bump)

- **`agent-context-dotnet`** — the .NET specialist skill.
- **Claim validation**, inspired by Microsoft Research's
  [Claimify](https://arxiv.org/abs/2502.10855): the load-bearing generated facts are surfaced with
  a source and a confidence level, confirmed with the user, and recorded in `docs/claims-ledger.md`.
