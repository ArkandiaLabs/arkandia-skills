# Reference exemplar: campus-prep

A real-world implementation of the same context pattern this skill generates. If you ever wonder "what should a *filled-in* `AGENTS.md` look like?", read these files side-by-side with what the skill produces.

| Doc | Exemplar path |
|---|---|
| AGENTS.md (table of contents + non-obvious rules) | [`AGENTS.md`](https://github.com/ArkandiaLabs/campus-prep/blob/main/AGENTS.md) |
| Architecture | [`docs/architecture.md`](https://github.com/ArkandiaLabs/campus-prep/blob/main/docs/architecture.md) |
| Business | [`docs/business.md`](https://github.com/ArkandiaLabs/campus-prep/blob/main/docs/business.md) |
| Target user | [`docs/target-user.md`](https://github.com/ArkandiaLabs/campus-prep/blob/main/docs/target-user.md) |
| Development | [`docs/development.md`](https://github.com/ArkandiaLabs/campus-prep/blob/main/docs/development.md) |
| ADRs | [`docs/adrs/`](https://github.com/ArkandiaLabs/campus-prep/tree/main/docs/adrs) |
| Data model | [`database/docs/data-model.md`](https://github.com/ArkandiaLabs/campus-prep/blob/main/database/docs/data-model.md) |
| Infrastructure | [`infra/docs/infrastructure.md`](https://github.com/ArkandiaLabs/campus-prep/blob/main/infra/docs/infrastructure.md) |

> Note: update these links if the upstream repo moves. They are pointers, not copies — the exemplar lives in its own project.

## What to notice

- **AGENTS.md is short.** It lists where things live and what rules agents must know. It does not explain the rules themselves — those live in their own docs.
- **"Non-obvious rules" is load-bearing.** Rules linters can't catch go here and nowhere else.
- **ADRs list alternatives.** Each decision explains what was *not* chosen and why.
- **Personas map to implications.** `target-user.md` turns traits into development consequences, not just demographics.
