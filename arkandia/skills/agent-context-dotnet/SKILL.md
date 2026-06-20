---
name: agent-context-dotnet
description: Specialized .NET deep-dive that augments an agent-context pack with a `docs/dotnet.md` covering the solution/project graph, target frameworks, EF Core data access, DI, configuration & secrets, analyzers, and CI. Run after `/arkandia:agent-context`; works standalone too. Invoke with `/arkandia:agent-context-dotnet [en|es]`.
argument-hint: '[en|es]'
disable-model-invocation: true
---

# agent-context-dotnet — Deep .NET Context

You are producing a **.NET deep-dive** that a generalist documentation pass cannot: the
solution/project graph, per-project target frameworks, EF Core data access, the DI composition
root, configuration & secrets strategy, analyzer/arch-lint posture, the UI stack, and CI. Your
primary output is `docs/dotnet.md`. You MUST NOT write application code, install packages, or run
destructive commands. Your only outputs are Markdown files at the repo root and under `docs/`.

This skill is the **companion** to `agent-context`:

- It does not re-state what the base pack already covers — it adds .NET depth.
- It **never** duplicates the base pipeline or templates.
- It **degrades gracefully**: if the base pack is missing (e.g. only this skill was installed) it
  still produces a useful, self-contained result instead of dead-ending. See Phase 0.

## Philosophy (same spirit as agent-context)

- **The repository is the system of record.** Document only what you can read in the repo.
- **Context is scarce.** `docs/dotnet.md` carries only .NET-shaped facts with no home in the
  generic docs. Do not restate the architecture/data-model/infrastructure docs.
- **TODOs over fabrication.** Never invent a framework version, NuGet version, or schema detail.
- **No application code.** This skill documents; it does not build.

## Input: language

`$ARGUMENTS` is either `en`, `es`, or empty.

- If `$ARGUMENTS == "es"` → output docs in Spanish. Load templates from `templates/es/`.
- If `$ARGUMENTS == "en"` or empty → output docs in English (default). Load templates from `templates/en/`.

The skill's own instructions (this file) stay in English regardless.

---

## Phase 0 — Preconditions & mode

Do this silently with Glob/Read.

### 0a. Confirm this is a .NET repo

Look for `*.csproj`, `*.sln`, `*.slnx`, `*.fsproj`, `*.vbproj`, `global.json`, or
`Directory.Build.props`. If **none** exist, stop and tell the user this skill only applies to
.NET repositories (suggest `/arkandia:agent-context` for the generic pack).

### 0b. Detect the base pack and pick a mode

The base pack is identified by **`AGENTS.md` at the repo root** — that is the `agent-context`
signature. A bare `docs/` directory is **not** a base pack: many repos keep their own docs
(`docs/architecture/`, design notes, etc.) that this skill did not create and must not overwrite.
So decide purely on `AGENTS.md`:

- **`AGENTS.md` present → companion mode.** Treat the existing `docs/*.md` as the `agent-context`
  pack and **enrich** them (Phase 3b).
- **`AGENTS.md` absent → graceful-fallback mode.** Do **not** dead-end, and do **not** generate the
  full base pack (that is `agent-context`'s job, and copying its templates here would duplicate
  them). Produce `docs/dotnet.md` plus a **minimal `AGENTS.md` stub + `CLAUDE.md` delegator
  generated inline** (Phase 3c), so the deep-dive is reachable. Tell the user once:
  *"No base context pack found. I'll generate the .NET deep-dive and a minimal AGENTS.md now. For
  the general (non-.NET) context, install the `arkandia` plugin/repo and run
  `/arkandia:agent-context`."*

**Either mode — note pre-existing docs.** Separately, scan for docs the repo already ships (a
`docs/` tree, `ARCHITECTURE.md`, `README` deep-dives). These are **not** yours to edit, but DO
cross-link them from `docs/dotnet.md` ("Related docs") and from the stub `AGENTS.md` so the
generated context points at what's already there instead of ignoring or duplicating it.

Resolve the output language (Phase 2 asks if `$ARGUMENTS` was empty). When pre-existing docs are in
one language, prefer matching it.

---

## Phase 1 — Deep .NET discovery (silent)

Run the full checklist in `references/dotnet-inspection.md`. In brief, gather:

- **Solution & projects.** Read every `*.sln` / `*.slnx`; list projects, classify each (Web API,
  Class Library, Blazor, MAUI, Worker, Test…), and build the `ProjectReference` graph (who depends
  on whom) to reveal layering.
- **Target frameworks & language.** Per `*.csproj`: `<TargetFramework(s)>`, `<LangVersion>`,
  `<Nullable>`, `<UserSecretsId>`; shared settings in `Directory.Build.props`/`.targets`.
- **Dependencies.** Collect `<PackageReference>` across projects; highlight the load-bearing ones
  (web framework, ORM, mediator, mapping, logging, auth). Note version freshness / known-vuln risk
  if signals exist; do not invent CVE data.
- **Data access.** Find `DbContext` subclasses, the provider (`UseSqlServer`/`UseNpgsql`/…),
  `Migrations/` folders and how migrations are applied.
- **Composition root / DI.** `Program.cs` / `Startup.cs` / Autofac modules: where services are
  registered and notable lifetimes (singleton/scoped/transient) or conventions.
- **Configuration & secrets.** `appsettings*.json` layering, `UserSecretsId`, environment
  variables, Key Vault. Flag any secret that looks committed.
- **Quality gates.** `.editorconfig`, analyzers (`StyleCop.Analyzers`,
  `Microsoft.CodeAnalysis.NetAnalyzers`), arch-linting (`NsDepCop`, `ArchUnitNET`),
  `TreatWarningsAsErrors`. Record present/absent.
- **Tests.** Test projects and framework (xUnit / NUnit / MSTest); how they are organized.
- **CI/CD.** `azure-pipelines*.yml`, `.github/workflows/`; whether build/test/lint steps exist.
- **UI / platform.** `.cshtml` (Razor Pages/MVC), `.razor` (Blazor), `.xaml` + `Platforms/Android`
  & `Platforms/iOS` (MAUI).
- **Hotspots.** Unusually large files (e.g. a multi-thousand-line `DbContext`) worth flagging.

Read real files. Where a fact isn't readable, you'll leave a TODO — do not guess.

---

## Phase 2 — Interview

Ask only what you could **not** infer. Batch structured choices into one `AskUserQuestion`
(≤4 options each), and keep the whole interview to ~5 questions max:

1. **Output language** — only if `$ARGUMENTS` was empty. Options: `English (default)`, `Spanish`.
2. **DB provider** — only if ambiguous from `DbContext`/packages. Offer the top candidates.
3. **Production secrets source** — e.g. `Azure Key Vault`, `Environment variables`,
   `User-secrets only (dev)`, `Other`.
4. **Layering rule** (free-text, plain chat) — "Any dependency rule between projects an agent must
   respect that isn't enforced by a tool? (e.g. `Core` must not reference `Infrastructure`). Reply
   'skip' if none."

Skip any question whose answer you already have.

---

## Phase 3 — Draft & enrich

### 3a. Always: write `docs/dotnet.md`

Read `templates/<lang>/dotnet.md.template`, substitute the `{{PLACEHOLDERS}}`, and write
`docs/dotnet.md`. Fill what you read; leave `<!-- TODO: ... -->` for the rest. Keep the project
table and the reference graph concrete (use real project names).

### 3b. Companion mode: enrich the base docs (augment, never blind-overwrite)

Only fill `<!-- TODO -->` slots or append clearly-marked `## .NET` subsections — never clobber
user content:

- `docs/data-model.md` — set the migration tool to EF Core, the `DbContext` location, the
  provider, and the migrations workflow.
- `docs/infrastructure.md` — Azure Pipelines / GitHub Actions specifics; configuration & secrets
  layering.
- `docs/architecture.md` — add a one-line pointer to `docs/dotnet.md` for the project graph and
  layering; name framework + EF Core in the stack if still a TODO.
- `AGENTS.md` — under "Where to find things", add a bullet pointing to `docs/dotnet.md`; add the
  key `dotnet` commands (build/test/run/ef) if the Commands block is thin; add async/cancellation
  or layering rules to "Non-obvious rules"; note analyzers under "Code style". Respect the
  ~80-line ceiling — push detail into `docs/dotnet.md`.

### 3c. Graceful-fallback mode: emit a minimal stub inline

There is no `agent-context` base pack to enrich, so **skip 3b** — but the repo may still ship its
own docs (found in Phase 0b). Do **not** copy base templates and do **not** edit those pre-existing
docs. Generate inline:

- `AGENTS.md` — ~10–15 lines: project name + one-line purpose; a "Where to find things" section
  that points to `docs/dotnet.md` ("Deep .NET context") **and lists any pre-existing docs you
  found** (e.g. `docs/architecture/`, `docs/database/`); 2–3 "Non-obvious rules" worth surfacing
  (e.g. the layering rule, run migrations before start); a short "Security" section (no secrets
  committed, `.env`/user-secrets not in VCS). Add a note: *"Generated by agent-context-dotnet. Run
  `/arkandia:agent-context` for general (non-.NET) context."*
- `CLAUDE.md` — one line: `@AGENTS.md` with a comment that it delegates.

`docs/dotnet.md` should likewise cross-link the pre-existing docs in its "Related docs" section
rather than restate them.

### 3d. ADR seeds (optional)

If a decision is clearly evident, seed an ADR under `docs/adrs/` (create the folder + a short
`README.md` if missing) — e.g. target framework, or EF Core as the data-access approach. Each ADR:
Status, Context (with alternatives), Decision, Consequences. Never fabricate the rationale.

---

## Phase 4 — Validate claims (Claimify-inspired)

Apply `references/claim-validation.md` to the .NET claims you just wrote — target frameworks,
provider, DI lifetimes, package versions, commands, layering rules. Confirm the `medium`/`low`/
ambiguous ones with the user, apply corrections (downgrade unconfirmed ones to
`<!-- TODO: verify -->`), and write/append `docs/claims-ledger.md`.

---

## Phase 5 — Verify

1. Print a tree of files written (or augmented).
2. Check that every link you added (e.g. the `docs/dotnet.md` pointer) resolves (use Read).
3. Remind the user:
   - Commit: `git add AGENTS.md CLAUDE.md docs/ && git commit -m "docs: add .NET deep-dive context"`
   - Fill remaining `<!-- TODO -->` markers and skim `docs/claims-ledger.md`.
   - If quality gates were absent, consider adopting `.editorconfig` + analyzers
     (`StyleCop.Analyzers`, `Microsoft.CodeAnalysis.NetAnalyzers`) and an arch-linting tool
     (`NsDepCop` / `ArchUnitNET`).
   - Re-run `/arkandia:agent-context-dotnet` later; it augments, not overwrites.

---

## Reference

- `references/dotnet-inspection.md` — the full .NET discovery checklist (Phase 1).
- `references/claim-validation.md` — the Claimify-inspired claim-validation procedure (Phase 4).
- `templates/en/` and `templates/es/` — the `dotnet.md` skeleton.

## Rules

- Do NOT write application code.
- Do NOT overwrite existing docs without explicit user opt-in; enrich by filling TODOs / appending.
- Do NOT fabricate framework or package versions, providers, or schema you haven't read.
- DO leave `<!-- TODO -->` markers where human input is needed.
- DO keep `docs/dotnet.md` focused on .NET-shaped facts the generic docs can't hold.
