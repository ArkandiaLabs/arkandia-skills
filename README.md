# arkandia-skills

> *The AI can't read your mind. It reads files.*

A collection of AI coding-agent skills from Arkandia. Two skills today: **`agent-context`** bootstraps a minimal, well-structured documentation pack (`AGENTS.md`, architecture, ADRs, data model, infrastructure) for any repository, and **`agent-context-dotnet`** adds a specialized .NET deep-dive on top. Both end by validating the most important generated claims with you, to reduce hallucinations. The generated pack follows the [`agents.md`](https://agents.md) convention and is sized so an AI coding agent can actually hold it in context. Works with Claude Code, OpenCode, Codex, Cursor, and the other agents supported by [`skills.sh`](https://skills.sh).

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

## Acknowledgements

- The [`agents.md`](https://agents.md) convention.
- OpenAI's *Harness engineering: leveraging Codex in an agent-first world*.
- Microsoft Research's *Claimify* (*Towards Effective Extraction and Evaluation of Factual Claims*, [arXiv:2502.10855](https://arxiv.org/abs/2502.10855)) — the basis for the claim-validation step.
- The *Método Arkandia* principles taught in the *Desarrollo Guiado por IA* workshop.

## License

MIT — see [LICENSE](./LICENSE).
