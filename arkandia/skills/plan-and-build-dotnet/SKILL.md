---
name: plan-and-build-dotnet
description: >
  .NET + Azure Boards specialization of `plan-and-build`. Same brief → explore →
  plan → adversarial review → approval → test-first → gates → commit chain, but it
  also accepts an Azure Boards work-item id as the brief, explores by Clean-
  Architecture layer, runs .NET/Make gates (e.g. `make check`, `dotnet test`,
  ArchUnitNET layer tests), reads `docs/dotnet.md` for conventions, and links commits
  to the work item with `AB#`. Run in a .NET repo; works standalone too. Invoke with
  `/arkandia:plan-and-build-dotnet [work item id | brief.md | inline description]`.
argument-hint: "[ADO work item id (2, #2, or its URL) | brief-file.md | inline description]"
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(make *), Bash(dotnet *), Bash(git status*), Bash(git diff*), Bash(git add*), Bash(git commit*), Bash(git log*), Bash(git rev-parse*), Agent, Skill, TaskCreate, TaskUpdate, TaskList, TaskGet, EnterPlanMode, ExitPlanMode, mcp__azure-devops__wit_get_work_item, mcp__azure-devops__wit_list_work_item_comments
---

# Plan → Build (.NET + Azure Boards)

This is the **companion** to `plan-and-build`. It runs the **same chain** — do not
restate or re-derive it — and specializes only the bindings for a .NET solution and
an Azure DevOps tracker. The chain, one line per phase:

> **Args** → **1 Explore** (fanned out) → **2 Draft plan** → **3 Adversarial review**
> (three lenses, fanned out) → **4 Human checkpoint** (plan mode) → **5 Implement**
> (test-first, fanned out only where files are disjoint) → **6 Gates** (never proceed
> on red) → **7 Commit** → **8 Close the loop**.

The stop-after-each-phase discipline, the fan-out judgment (parallel on read/critique,
serial on writes), and the RED → GREEN loop are **identical** to `plan-and-build` —
read that skill for the full rationale. Below are only the deltas.

## Delta — Arguments: an Azure Boards work item is a valid brief

`$ARGUMENTS` resolves in this order (the first two extend `plan-and-build`):

1. **Azure Boards work item** — bare digits (`2`), digits with a leading `#` (`#2`), or
   an Azure DevOps work item URL (`.../_workitems/edit/2`). Extract the integer id and
   fetch it with `wit_get_work_item`. **The project is not hardcoded**: use the project
   the caller names, or one configured for the repo; if you can't determine it, ask
   before fetching. Read `System.Title`, `System.Description`, `System.State`,
   `System.WorkItemType`, and `System.Tags`, then the discussion via
   `wit_list_work_item_comments` — requirements are often negotiated in comments rather
   than written in a field.

   **Acceptance criteria live in different places per process.** The **Basic** process
   `Issue` type has **no** acceptance-criteria field — the whole requirement is in
   `System.Description`. Only Agile/Scrum types (`User Story`, `Product Backlog Item`)
   define `Microsoft.VSTS.Common.AcceptanceCriteria`. Read `System.WorkItemType` and
   ask for that field **only when the type defines it**; never assume it exists, and
   never treat its absence as an empty requirement.

   `System.Description` (and acceptance criteria, where present) come back as **HTML**,
   not Markdown — render to text before reasoning over them, and don't let stray tags
   leak into the plan.
2. **Brief file** — a path ending in `.md`. Read it.
3. **Inline description** — anything else.

Two failure modes to handle rather than paper over. If the work-item fetch fails,
**stop and report the error verbatim** — do not invent a brief from the id alone, and
do not proceed on a partially-read work item. If the description is empty (and there's
no acceptance-criteria field, or it's empty too), say so and ask; an id is a pointer,
not a specification.

## Delta — Phase 1: explore by Clean-Architecture layer, conventions from `docs/dotnet.md`

- **Conventions source.** Prefer `docs/dotnet.md` (for example one produced by
  `/arkandia:agent-context-dotnet`) plus `AGENTS.md`; fall back to inferring from the
  code. Common Clean-Architecture .NET patterns to confirm against the repo (don't
  assume — verify what the repo actually does): a `Result`/`Either` type instead of
  exceptions for flow control, not exposing an internal `Id` outside the boundary,
  validation in the Application layer, and a dependency rule enforced by arch tests.
- **Fan-out charges** — one `Explore` subagent per layer, adapted to the solution's
  actual projects (this four-way split is illustrative):
  - **Domain** — the entity, its enums and `Result` helpers.
  - **Application** — port, DTO, mapper, service; where validation would live.
  - **Persistence** — EF model, mapper, repository; existing data annotations.
  - **Api** — controller; how a failure result becomes a status code.

## Delta — Phase 2 & 5: .NET verifications, converging edits stay serial

- Each plan step names its verification as a **targeted `dotnet test --filter <Name>`**
  and/or the linter; the first implementation step is a failing test.
- N acceptance criteria typically become N guard clauses in the **same** service method
  plus N tests in the **same** test class — the classic *converging* case: keep the
  edits serial (optionally fan out subagents that each return a proposed test + guard
  as a diff, then apply them yourself RED → GREEN). A `PostToolUse` auto-format hook on
  changed `.cs` files, if present, makes a parallel-write race worse.
- **Migrations**, if the feature needs one: `make migrate name=<Name>` then
  `make db-update` (or `dotnet ef migrations add <Name>` + `dotnet ef database update`
  if the repo doesn't wrap these in Make). Don't assume they run on startup.

## Delta — Phase 6: the .NET gate

- Run the repo's full gate — commonly **`make check`** (lint + build with
  warnings-as-errors + tests, **including ArchUnitNET / NsDepCop layer tests**) — then
  `/code-review` on the diff at medium effort. Run the gate yourself and paste the real
  output; never delegate it to a subagent. Never proceed on red.

## Delta — Phase 7: link the commit to the work item

- When the run started from a work item, include the Boards link token **`AB#<id>`**
  (e.g. `AB#2`) in the commit message — that exact syntax is what makes Azure Boards
  attach the commit to the item; a bare `#2` does nothing. Stage only changed files;
  never `git add -A`; never anything secret-like.

## Delta — Phase 8: the wired bridge

The production chain this maps to, per binding:

| This skill | Wired to an Azure DevOps stack |
|---|---|
| Brief `.md` / inline — **or a Boards work item id, already wired** | **Azure Boards** work item |
| the repo's `make check` gate | same `make check`, also run by **Azure Pipelines** |
| `git commit` (stop here) | a `commit-push-pr` step opens an **Azure Repos** PR |
| — | branch policy: **CI green + 1 reviewer** to complete |
| — | an `address-pr-comments` step resolves review feedback |
| — | a `session-wrapup` step posts back to the **Boards** work item |

Do **not** push or open a PR unless the user asks.

## Notes — configuring the Azure DevOps MCP server

- The work-item path needs the `azure-devops` MCP server configured in the repo's
  `.mcp.json`. If a `wit_*` call fails with *"Identity … has not been materialized,
  please use interactive login over the browser first,"* the server is on
  `--authentication azcli` and the Azure CLI is handing it a guest token the org won't
  resolve. Switch to `--authentication pat`, which reads `PERSONAL_ACCESS_TOKEN` as
  `base64("<anything>:<PAT>")` and needs the **Work Items (Read)** scope. A git-only
  PAT will read repos but 401 on every `wit_*` call.
- Everything else — fan-out discipline, RED → GREEN, "gates are evidence," secret
  hygiene — follows `plan-and-build` unchanged.
