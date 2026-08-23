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

### Changed

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
