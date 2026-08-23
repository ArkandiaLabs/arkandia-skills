# `linear-plan-build` and `ado-plan-build`

**[← README](../../README.md)** · **[Versión en español →](./plan-build-es.md)**

Two skills, one engine. They take a ticket from *read it* to *PR open, CI green, review comments
addressed, tracker updated*, and differ only in their bindings: **Linear + GitHub** for one,
**Azure Boards + Azure Repos + Pipelines** for the other. Both are stack-agnostic and assume no
particular architecture.

Where [`agent-context-dotnet`](./agent-context-dotnet.md) *writes* your repo's context, these
*consume* it to ship a change.

```
/arkandia:linear-plan-build ABC-123                 # a Linear issue
/arkandia:linear-plan-build ABC-123 skip-checkpoint # routine issue: no approval stop
/arkandia:ado-plan-build 42                         # an Azure Boards work item
```

## The chain

1. **Read the ticket** — the issue or work item, its subissues/children, and its discussion.
   Requirements are usually negotiated in comments, not written in a field.
2. **Grill you** — the skill asks about the design decisions the ticket left open: scope boundary,
   data model and migrations, contract and breaking changes, failure behavior, auth, scale,
   rollout, test depth. It asks only what the ticket, the code, and your `AGENTS.md` don't already
   answer. Answers become **Decisions**; anything it settled itself becomes a written
   **Assumption**.
3. **Explore** — fan out read-only subagents along your repo's own seams and build one map. No
   architecture is assumed and none is recommended.
4. **Draft the plan** — small steps, each with its own verification in your repo's commands; the
   first step is a failing test.
5. **Adversarial review** — three subagents critique the plan through different lenses
   (conventions, correctness, scope) *before* any code is written. The scope lens specifically
   attacks the Assumptions list.
6. **Your approval — only if the change warrants it.** Plan mode opens for anything over ~3 steps
   or ~3 files, or that touches a contract, a schema, auth, or money, or that rests on
   assumptions, or that is hard to reverse. Small, reversible, fully-specified changes print the
   plan and keep going.
7. **Implement, test-first** — RED → GREEN per step, fanning out only where edits don't collide.
8. **Gates** — resolve your repo's own gate commands (a Gates/Commands section in
   `CLAUDE.md`/`AGENTS.md` → manifest detection → ask), then `/code-review`, plus
   `/security-review` when the diff touches auth, secrets, or input parsing. Never proceed on red.
   Gates that your repo doesn't define are reported as skipped, not silently counted as green.
9. **Commit, push, open the PR** — staging only what changed, with the tracker's link token in the
   message (`ABC-123`, `AB#42`).
10. **Babysit the PR to green** — watch CI, rerun a flaky job once, fix real failures at the
    source, then address review comments in a loop until the PR is green and clean. It stops after
    three failed attempts on the same job.
11. **Wrap up** — post the summary to the tracker and move the ticket to its review state.

## Prerequisites

- `linear-plan-build`: the [Linear MCP server](https://linear.app/docs/mcp) and `gh`.
- `ado-plan-build`: either the Azure DevOps MCP server **or** the `az` CLI with the `azure-devops`
  extension. It detects which and tells you.

## What they're pre-approved to do

So you can decide if that's too much: read and write files, run your repo's build/test commands,
write to *the one ticket they're working*, push its branch, and open a PR.

They never merge or complete a PR, never bypass a branch policy, never deploy, and never write
anything else in your tracker. Leave off `skip-checkpoint` and stop at the approval checkpoint if
you want a tighter leash.

Unlike the context skill, these write code, not docs — so they have no claim-ledger; correctness is
proven by the adversarial review and the real gate instead. Those gates are exactly what
[`instrument-project-dotnet`](./instrument-project-dotnet.md) installs.
