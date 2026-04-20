# agent-context

> *The AI can't read your mind. It reads files.*

A Claude Code plugin that bootstraps a minimal, well-structured documentation pack — `AGENTS.md`, architecture, ADRs, data model, infrastructure — for any repository. The generated pack follows the [`agents.md`](https://agents.md) convention and is sized so an AI coding agent can actually hold it in context.

**[Versión en español →](./README-es.md)**

## Why

Coding agents behave well when the repository tells them what they need to know. They flail when critical context lives in someone's head, in Slack, or in an unread Google Doc. This plugin walks you through producing the minimum viable context pack so an agent can reason about your codebase on day one.

The design is informed by OpenAI's harness-engineering writing (*"AGENTS.md is a table of contents, not an encyclopedia"*, *"the repository is the system of record"*) and by the *Método Arkandia* framework from the *Desarrollo Guiado por IA* workshop.

## Install

### Option A — Claude Code plugin marketplace (native)

Inside Claude Code:

```
/plugin marketplace add ArkandiaLabs/agent-context-plugin
/plugin install agent-context@agent-context
```

### Option B — `npx skills` ([skills.sh](https://skills.sh) by Vercel Labs)

From your terminal, anywhere:

```bash
npx skills add ArkandiaLabs/agent-context-plugin
```

The CLI auto-discovers skills in `skills/` and reads the `.claude-plugin/marketplace.json` manifest. Useful flags:

```bash
# Install globally instead of into the current project
npx skills add ArkandiaLabs/agent-context-plugin -g

# Target Claude Code specifically (the CLI supports several agents)
npx skills add ArkandiaLabs/agent-context-plugin -a claude-code

# Non-interactive (CI-friendly)
npx skills add ArkandiaLabs/agent-context-plugin -y
```

## Use

Inside any repository:

```
/agent-context          # English output (default)
/agent-context es       # Spanish output
```

The skill will:

1. **Discover** — scan the repo for language, framework, persistence, CI, IaC, and existing docs. Supports Java (Maven/Gradle/Spring), .NET (ASP.NET Core/EF Core), PHP (Laravel/Symfony/WordPress), Python, Node, Go, Ruby, Rust, plus enterprise infra signals (Liquibase, Flyway, Jenkins, Azure DevOps, Kubernetes, Terraform).
2. **Interview** — ask only what can't be inferred: business context, non-obvious rules, optional docs.
3. **Draft** — fill templates with your answers and the repo findings.
4. **Wire** — generate `AGENTS.md` (≤80 lines, table-of-contents style) and `CLAUDE.md` delegator.
5. **Verify** — report the tree of files written, check cross-links.

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
    ├── target-user.md     # optional
    ├── design.md          # optional
    └── adrs/
        ├── README.md
        ├── adr-template.md
        └── adr-0001-<slug>.md
```

Every doc contains `<!-- TODO -->` markers where human input is still required. The skill will not fabricate framework versions, schema details, or business context it cannot verify.

## Acknowledgements

- The [`agents.md`](https://agents.md) convention.
- OpenAI's *Harness engineering: leveraging Codex in an agent-first world*.
- The *Método Arkandia* principles taught in the *Desarrollo Guiado por IA* workshop.

## License

MIT — see [LICENSE](./LICENSE).
