# `instrument-project-dotnet`

**[← README](../../README.md)** · **[Versión en español →](./instrument-project-dotnet-es.md)**

Where [`agent-context-dotnet`](./agent-context-dotnet.md) tells the agent what the repo *is*, this
one decides what it is *allowed to ship*. It installs the gates a coding agent hits by itself,
before any human reads the diff.

```
/arkandia:instrument-project-dotnet
```

## The eight controls

| # | Control | Artifact | What it prevents |
|---|---------|----------|------------------|
| 1 | Reproducible inputs | `global.json`, `Directory.Packages.props`, lock files | Two machines resolving a different SDK or dependency tree |
| 2 | Strict build | `Directory.Build.props` | A warning reaching `main` |
| 3 | Style | `.editorconfig` | Formatting noise in every diff |
| 4 | Entry point | `Makefile` | Nobody knowing how the repo is verified |
| 5 | Shift-left | `lefthook.yml` | Errors surfacing at review time |
| 6 | Secrets | `gitleaks` | A credential reaching the history |
| 7 | Architecture tests | Arch-test project (ArchUnitNET) | The dependency rule silently breaking |
| 8 | CI | GitHub Actions or Azure DevOps | Local gates being skipped |

## The run

1. **Discover** — the solution and project graph, target frameworks, test framework and runner,
   package management, which controls already exist, the CI platform, the context docs, and the
   **real architecture**, read off the `<ProjectReference>` graph rather than assumed.
2. **Check prerequisites** — per OS, reporting the install command. It never installs for you.
3. **Ask only what it could not infer** — CI platform, secret scanning, warning debt, and the
   migrations that touch every `.csproj`.
4. **Apply** — adapting every template to this repository, in dependency order.
5. **Verify by breaking** — introduce each violation, confirm the gate catches it, restore.
6. **Update the documentation the install invalidated**, then report.

## Architecture rules come from the repo, not from a template

The rules are derived from what the repository already does, in whatever shape it has — layered,
vertical slices, modular monolith, n-tier, or flat. Every candidate rule is evaluated against the
current code **before** it is written:

| Result | What happens |
|---|---|
| Passes | It becomes a test |
| Fails on one or two types | You are asked: fix the code, or skip the rule |
| Fails broadly | It becomes a **finding**, not a test |

A suite that goes red on install is a refactoring proposal, not a sensor.

## What it will not do

- **Hardcode a version.** The SDK pin is derived from what is installed — the lowest feature band
  of the installed `major.minor`, so a teammate one band behind still builds. Packages come from
  NuGet's own resolution, and the resolved versions are reported back to you.
- **Overwrite a config file it has not read and merged.** An existing `global.json` keeps its
  `test` and `msbuild-sdks` blocks.
- **Touch a `.csproj`** for anything that can live in `Directory.Build.props`. The migrations that
  genuinely require it — central package management, lock files, centralising the target framework
  — are offered explicitly, with the file count, never applied as a side effect.
- **Report success with a gate in the red.**
- **Commit.** The changes are left for you to review.

## Documentation

Installing eight controls makes parts of the repo's documentation wrong: a setup section with no
`make hooks`, a prerequisites table with no `make`, a quality-controls table that says "missing"
for something you just installed. The skill updates what exists and reports what is missing — it
does not create the doc pack, that is `agent-context-dotnet`'s job.

One rule governs the edits: **each fact lives in one document and the others link to it.** Copying
the CI steps into three files means two of them are wrong within a month, and an agent reading the
stale copy acts on it.

## Prerequisites

Checked and reported, never installed:

| Tool | macOS | Windows | Linux |
|---|---|---|---|
| [Lefthook](https://lefthook.dev) | `brew install lefthook` | `winget install evilmartians.lefthook` | `go install github.com/evilmartians/lefthook@latest` |
| `make` | ships with Xcode CLT | `winget install ezwinports.make` | ships with the distro |
| [gitleaks](https://gitleaks.io) (if enabled) | `brew install gitleaks` | `winget install gitleaks` | `apt install gitleaks` on Debian trixie+ / Ubuntu 25.04+, otherwise the release binary |

`make` does not ship with Windows. The skill surfaces the `winget` command as a documented
prerequisite rather than silently switching to another task runner — `make check` is the
convention across Arkandia material.
