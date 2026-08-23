# arkandia-skills

> *The AI can't read your mind. It reads files.*

A collection of AI coding-agent skills from Arkandia for an agentic SDLC. They follow one arc:
give the repository the **context** an agent needs to decide, install the **instrumentation** it
cannot ship past, then **deliver** tickets on top of both.

The instrumentation layer splits in two, as the Arkandia Method does. `instrument-project-dotnet`
covers the **deterministic** half — what a machine verifies on its own, with no ambiguity: the
build, style, secrets, architecture tests, CI. `instrument-agent-dotnet` covers the
**non-deterministic** half — the tools the agent may reach and the limits it works inside, as MCP
servers and hooks.

Works with Claude Code, OpenCode, Codex, Cursor, and the other agents supported by
[`skills.sh`](https://skills.sh).

**[Versión en español →](./README-es.md)**

## Why

Coding agents behave well when the repository tells them what they need to know, and badly when
critical context lives in someone's head, in Slack, or in an unread Google Doc. That is the first
problem these skills solve.

The second is newer: agents now write code faster than a team can review it. Documentation alone
does not scale against that — a rule an agent can read is a suggestion, a rule that fails the build
is a rule. So verification has to become mechanical, and human review has to be reserved for what
machines genuinely cannot judge: intent, design, trade-offs, product alignment.

The design is informed by OpenAI's harness-engineering writing (*"AGENTS.md is a table of contents,
not an encyclopedia"*, *"the repository is the system of record"*) and by the **Arkandia Method**
framework from the *AI-Driven Development* workshop.

## Skills

| Skill | What it does | Docs |
|---|---|---|
| `agent-context-dotnet` | **Context** — bootstraps `AGENTS.md`, architecture, ADRs, data model, infrastructure and a `docs/dotnet.md` deep-dive for a .NET repo, then validates the load-bearing claims with you | [→](./docs/skills/agent-context-dotnet.md) |
| `instrument-project-dotnet` | **Deterministic instrumentation** — installs the eight gates a coding agent hits by itself, in the build, the hooks and the pipeline, and proves each one fails before reporting success | [→](./docs/skills/instrument-project-dotnet.md) |
| `instrument-agent-dotnet` | **Non-deterministic instrumentation** — registers the team's MCP servers, then installs a catalogue of Claude Code hooks (secret read-guard, scoped auto-format, dangerous-command blocker, advisory sweep, audit log, and guards for central package management and generated files), firing every one of them before reporting success | [→](./docs/skills/instrument-agent-dotnet.md) |
| `linear-plan-build` · `ado-plan-build` | **Delivery** — a ticket to a green PR: grill → explore → plan → adversarial review → test-first build → your gates → PR → babysit CI. Linear + GitHub, or Azure Boards + Azure Repos + Pipelines | [→](./docs/skills/plan-build.md) |

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

The CLI auto-discovers skills in `skills/` and reads the `.claude-plugin/marketplace.json`
manifest. Useful flags:

```bash
# Install globally instead of into the current project
npx skills add ArkandiaLabs/arkandia-skills -g

# Target Claude Code specifically (the CLI supports several agents)
npx skills add ArkandiaLabs/arkandia-skills -a claude-code

# Non-interactive (CI-friendly)
npx skills add ArkandiaLabs/arkandia-skills -y
```

## Use

Inside any .NET repository:

```
/arkandia:agent-context-dotnet                      # English output (default)
/arkandia:agent-context-dotnet es                   # Spanish output

/arkandia:instrument-project-dotnet      # deterministic: the eight controls
/arkandia:instrument-agent-dotnet        # non-deterministic: MCP servers + hooks

/arkandia:linear-plan-build ABC-123                 # a Linear issue → green PR
/arkandia:linear-plan-build ABC-123 skip-checkpoint # routine issue: no approval stop
/arkandia:ado-plan-build 42                         # an Azure Boards work item → green PR
```

## The eight controls

What `instrument-project-dotnet` turns a normal .NET repo into — a repo where an agent
cannot ship work that breaks the team's rules. Each one is proven to fail before the run ends.

| # | Control | What it prevents |
|---|---------|------------------|
| 1 | Reproducible inputs | Two machines resolving a different SDK or dependency tree |
| 2 | Strict build | A warning reaching `main` |
| 3 | Style | Formatting noise in every diff |
| 4 | Entry point | Nobody knowing how the repo is verified |
| 5 | Shift-left | Errors surfacing at review time |
| 6 | Secrets | A credential reaching the history |
| 7 | Architecture tests | The dependency rule silently breaking |
| 8 | CI | Local gates being skipped |

Control 7 is the one that changes the conversation: the architecture you documented becomes
executable. The rules are derived from the repository's own reference graph, and every rule must
pass against the current code before it is written —
[details](./docs/skills/instrument-project-dotnet.md).

## Acknowledgements

- The [`agents.md`](https://agents.md) convention.
- OpenAI's *Harness engineering: leveraging Codex in an agent-first world*.
- Microsoft Research's *Claimify* (*Towards Effective Extraction and Evaluation of Factual
  Claims*, [arXiv:2502.10855](https://arxiv.org/abs/2502.10855)) — the basis for the
  claim-validation step.
- The **Arkandia Method** principles taught in the *AI-Driven Development* workshop.

## Changelog

See [CHANGELOG.md](./CHANGELOG.md).

## License

MIT — see [LICENSE](./LICENSE).
