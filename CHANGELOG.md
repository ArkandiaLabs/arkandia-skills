# Changelog

All notable changes to the `arkandia` plugin. Versions follow the `version` field in
`arkandia/.claude-plugin/plugin.json`. Dates are the date the work landed on `main`.

## [0.4.0] — unreleased

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
