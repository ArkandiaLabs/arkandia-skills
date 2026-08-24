# `agent-context-dotnet`

**[← README](../../README.md)** · **[Versión en español →](./agent-context-dotnet-es.md)**

Bootstraps a minimal, well-structured documentation pack for a .NET repository, then validates the
most important generated claims with you to reduce hallucinations. The pack follows the
[`agents.md`](https://agents.md) convention and is sized so an AI coding agent can actually hold it
in context.

```
/arkandia:agent-context-dotnet      # English output (default)
/arkandia:agent-context-dotnet es   # Spanish output
```

## The run

1. **Discover** — read the solution and every project: the reference graph and layering, target
   frameworks, package management (including `Directory.Packages.props`), Aspire orchestration,
   EF Core data access, the DI composition root, configuration & secrets, the test runner actually
   in use, quality gates, the UI/API surface, how images and binaries are produced, and existing
   docs. Current to .NET 10 / C# 14 — including the artifacts a `Dockerfile`-only or
   `*.csproj`-only scan misses, such as SDK container publishing and file-based apps.
2. **Interview** — around ten questions, and never one it can already answer from the repo:
   business context, non-obvious rules, deployment target, path to production, secrets source,
   auth model.
3. **Draft** — fill templates with your answers and the repo findings; delete the sections that
   don't apply rather than padding them with TODOs.
4. **Wire** — generate `AGENTS.md` (≤80 lines, table-of-contents style) and a `CLAUDE.md`
   delegator.
5. **Validate claims** — surface the load-bearing facts it wrote (framework + version,
   persistence, commands, key entities), each with a source reference and confidence, then confirm
   or correct the uncertain ones with you. Inspired by Microsoft Research's
   [Claimify](https://arxiv.org/abs/2502.10855). Writes an audit trail to `docs/claims-ledger.md`.
6. **Verify** — report the tree of files written, check cross-links.

If context docs already exist, the skill switches to **augment mode** and proposes additions
instead of overwriting.

## What you get

```
<your-repo>/
├── AGENTS.md              # Table of contents + non-obvious rules
├── CLAUDE.md              # One-line delegator to AGENTS.md
└── docs/
    ├── business.md
    ├── architecture.md
    ├── data-model.md
    ├── infrastructure.md
    ├── claims-ledger.md   # what was verified vs still open
    ├── dotnet.md          # deep .NET context: project graph, TFMs, EF Core, DI
    ├── target-user.md     # optional
    ├── design.md          # optional
    └── adrs/
        ├── README.md
        ├── adr-template.md
        └── adr-0001-<slug>.md
```

Every doc contains `<!-- TODO -->` markers where human input is still required. The skill will not
fabricate framework versions, schema details, or business context it cannot verify — and the
claim-validation step asks you to confirm the load-bearing facts before you trust them.

## Next

Once the repo can explain itself, decide what it will accept:
[`instrument-project-dotnet`](./instrument-project-dotnet.md).
