# arkandia-skills

> *The AI can't read your mind. It reads files.*

A collection of AI coding-agent skills from Arkandia, in two families.

**Context** — **`agent-context`** bootstraps a minimal, well-structured documentation pack (`AGENTS.md`, architecture, ADRs, data model, infrastructure) for any repository, and **`agent-context-dotnet`** adds a specialized .NET deep-dive on top. Both end by validating the most important generated claims with you, to reduce hallucinations. The generated pack follows the [`agents.md`](https://agents.md) convention and is sized so an AI coding agent can actually hold it in context.

**Delivery** — **`linear-plan-build`** and **`ado-plan-build`** take a ticket from *read it* to *PR open, CI green, review comments addressed, tracker updated*. They share one engine — grill you on the design decisions the ticket left open → explore → plan → adversarial review → approval (only when the change warrants it) → test-first build → your repo's gates → PR → babysit CI to green — and differ only in their bindings: **Linear + GitHub** for one, **Azure Boards + Azure Repos + Pipelines** for the other. Both are stack-agnostic and assume no particular architecture.

Works with Claude Code, OpenCode, Codex, Cursor, and the other agents supported by [`skills.sh`](https://skills.sh).

**[Versión en español →](./README-es.md)**

## Why

Coding agents behave well when the repository tells them what they need to know. They flail when critical context lives in someone's head, in Slack, or in an unread Google Doc. This plugin walks you through producing the minimum viable context pack so an agent can reason about your codebase on day one.

The design is informed by OpenAI's harness-engineering writing (*"AGENTS.md is a table of contents, not an encyclopedia"*, *"the repository is the system of record"*) and by the *Método Arkandia* framework from the *Desarrollo Guiado por IA* workshop.

## Install

### Option A — Native Claude Code plugin marketplace

Inside Claude Code:

```
/plugin marketplace add ArkandiaLabs/arkandia-skills
/plugin install arkandia@arkandia
```

### Option B — `npx skills` ([skills.sh](https://skills.sh) by Vercel Labs)

From your terminal, anywhere:

```bash
npx skills add ArkandiaLabs/arkandia-skills
```

The CLI auto-discovers skills in `skills/` and reads the `.claude-plugin/marketplace.json` manifest. Useful flags:

```bash
# Install globally instead of into the current project
npx skills add ArkandiaLabs/arkandia-skills -g

# Target Claude Code specifically (the CLI supports several agents)
npx skills add ArkandiaLabs/arkandia-skills -a claude-code

# Non-interactive (CI-friendly)
npx skills add ArkandiaLabs/arkandia-skills -y
```

## Use

Inside any repository:

```
/arkandia:agent-context          # English output (default)
/arkandia:agent-context es       # Spanish output
```

For .NET repositories, follow up with the specialist (run it after `agent-context`, or on its own):

```
/arkandia:agent-context-dotnet      # English output (default)
/arkandia:agent-context-dotnet es   # Spanish output
```

To drive a ticket from the tracker to a green PR, see [Plan → Build](#plan--build) below.

The `agent-context` skill will:

1. **Discover** — scan the repo for language, framework, persistence, CI, IaC, and existing docs. Supports Java (Maven/Gradle/Spring), PHP (Laravel/Symfony/WordPress), Python, Node, Go, Ruby, Rust, .NET, plus enterprise infra signals (Liquibase, Flyway, Jenkins, Azure DevOps, Kubernetes, Terraform). When it detects .NET it points you to `agent-context-dotnet` for a deeper pass.
2. **Interview** — ask only what can't be inferred: business context, non-obvious rules, optional docs.
3. **Draft** — fill templates with your answers and the repo findings.
4. **Wire** — generate `AGENTS.md` (≤80 lines, table-of-contents style) and `CLAUDE.md` delegator.
5. **Validate claims** — surface the load-bearing facts it wrote (framework + version, persistence, commands, key entities), each with a source reference and confidence, then confirm or correct the uncertain ones with you. Inspired by Microsoft Research's [Claimify](https://arxiv.org/abs/2502.10855). Writes an audit trail to `docs/claims-ledger.md`.
6. **Verify** — report the tree of files written, check cross-links.

If context docs already exist, the skill switches to **augment mode** and proposes additions instead of overwriting.

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
    ├── dotnet.md          # added by agent-context-dotnet (.NET repos)
    ├── target-user.md     # optional
    ├── design.md          # optional
    └── adrs/
        ├── README.md
        ├── adr-template.md
        └── adr-0001-<slug>.md
```

Every doc contains `<!-- TODO -->` markers where human input is still required. The skills will not fabricate framework versions, schema details, or business context they cannot verify — and the claim-validation step asks you to confirm the load-bearing facts before you trust them.

`agent-context-dotnet` pairs best with `agent-context` (installing the plugin/repo gets both), but it also works **standalone**: if no base pack exists it produces `docs/dotnet.md` plus a minimal `AGENTS.md` so the deep-dive is still reachable.

## Plan → Build

Where `agent-context` *writes* your repo's context, the delivery skills *consume* it to ship a change. Give one a ticket id and it runs to a green PR:

```
/arkandia:linear-plan-build ABC-123                 # a Linear issue
/arkandia:linear-plan-build ABC-123 skip-checkpoint # routine issue: no approval stop
/arkandia:ado-plan-build 42                         # an Azure Boards work item
```

The chain both skills run:

1. **Read the ticket** — the issue or work item, its subissues/children, and its discussion. Requirements are usually negotiated in comments, not written in a field.
2. **Grill you** — the skill asks about the design decisions the ticket left open: scope boundary, data model and migrations, contract and breaking changes, failure behavior, auth, scale, rollout, test depth. It asks only what the ticket, the code, and your `AGENTS.md` don't already answer. Answers become **Decisions**; anything it settled itself becomes a written **Assumption**.
3. **Explore** — fan out read-only subagents along your repo's own seams and build one map. No architecture is assumed and none is recommended.
4. **Draft the plan** — small steps, each with its own verification in your repo's commands; the first step is a failing test.
5. **Adversarial review** — three subagents critique the plan through different lenses (conventions, correctness, scope) *before* any code is written. The scope lens specifically attacks the Assumptions list.
6. **Your approval — only if the change warrants it.** Plan mode opens for anything over ~3 steps or ~3 files, or that touches a contract, a schema, auth, or money, or that rests on assumptions, or that is hard to reverse. Small, reversible, fully-specified changes print the plan and keep going.
7. **Implement, test-first** — RED → GREEN per step, fanning out only where edits don't collide.
8. **Gates** — resolve your repo's own gate commands (`.claude/gates.sh` → `AGENTS.md` → manifest detection), then `/code-review`, plus `/security-review` when the diff touches auth, secrets, or input parsing. Never proceed on red. Gates that your repo doesn't define are reported as skipped, not silently counted as green.
9. **Commit, push, open the PR** — staging only what changed, with the tracker's link token in the message (`ABC-123`, `AB#42`).
10. **Babysit the PR to green** — watch CI, rerun a flaky job once, fix real failures at the source, then address review comments in a loop until the PR is green and clean. It stops after three failed attempts on the same job.
11. **Wrap up** — post the summary to the tracker and move the ticket to its review state.

Prerequisites: the [Linear MCP server](https://linear.app/docs/mcp) and `gh` for `linear-plan-build`; either the Azure DevOps MCP server **or** the `az` CLI with the `azure-devops` extension for `ado-plan-build` (it detects which and tells you).

**What they're pre-approved to do, so you can decide if that's too much:** read and write files, run your repo's build/test commands, write to *the one ticket they're working*, push its branch, and open a PR. They never merge or complete a PR, never bypass a branch policy, never deploy, and never write anything else in your tracker. Leave off `skip-checkpoint` and stop at the approval checkpoint if you want a tighter leash.

Unlike the context skills, these write code, not docs — so they have no claim-ledger; correctness is proven by the adversarial review and the real gate instead.

### Renamed in 0.3.0

| Before | Now |
|---|---|
| `plan-and-build` (Markdown brief, stopped at commit) | `linear-plan-build` (Linear issue → green PR) |
| `plan-and-build-dotnet` (.NET + Clean Architecture + Azure Boards) | `ado-plan-build` (Azure Boards → green PR, stack- and architecture-agnostic) |

The old names are gone, not aliased. Two behaviors changed with them: the tracker-less path (a `.md` brief or inline text) was retired — both skills now start from a ticket — and `ado-plan-build` no longer checks for or suggests Clean Architecture, `dotnet`-specific gates, or any named architectural pattern.

## Acknowledgements

- The [`agents.md`](https://agents.md) convention.
- OpenAI's *Harness engineering: leveraging Codex in an agent-first world*.
- Microsoft Research's *Claimify* (*Towards Effective Extraction and Evaluation of Factual Claims*, [arXiv:2502.10855](https://arxiv.org/abs/2502.10855)) — the basis for the claim-validation step.
- The *Método Arkandia* principles taught in the *Desarrollo Guiado por IA* workshop.

## License

MIT — see [LICENSE](./LICENSE).
