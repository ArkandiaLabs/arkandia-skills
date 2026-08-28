# `linear-plan-build` and `ado-plan-build`

**[← README](../../README.md)** · **[Versión en español →](./plan-build-es.md)**

Two skills, one engine. They take a ticket from *read it* to *PR open, CI green, review comments
addressed, tracker updated*, and differ only in their bindings: **Linear + GitHub** for one,
**Azure Boards + Azure Repos + Pipelines** for the other. Both are stack-agnostic and assume no
particular architecture.

Where [`agent-context-dotnet`](./agent-context-dotnet.md) *writes* your repo's context, these
*consume* it to ship a change. And [`requirement-to-spec`](./requirement-to-spec.md) is normally
what fills the parent issue they consume: by contract these two never create subissues themselves.
They build the ones you hand them — and ask which of them a given run should cover.

```
/arkandia:linear-plan-build ABC-123                 # a Linear issue
/arkandia:linear-plan-build ABC-123 skip-checkpoint # routine issue: no approval stop
/arkandia:ado-plan-build 42                         # an Azure Boards work item
```

## The chain

1. **Read the ticket** — the issue or work item, its subissues/children, and its discussion.
   Requirements are usually negotiated in comments, not written in a field.
2. **Pick the work list** — if the ticket has subissues, it asks which ones this run covers
   (*all of them* is the recommended default). What you leave out is named in the final report, so
   nobody assumes it shipped. No subissues means the work list is the ticket itself.
3. **Grill you** — the skill asks about the design decisions the ticket left open: scope boundary,
   data model and migrations, contract and breaking changes, failure behavior, auth, scale,
   rollout, test depth. It asks only what the ticket, the code, and your `AGENTS.md` don't already
   answer. Answers become **Decisions**; anything it settled itself becomes a written
   **Assumption**, each carrying its source — `file:line`, `inferred`, or `none`. An assumption
   sourced `none` about a contract, a schema, auth or money isn't an assumption at all: it's a
   question the skill has to go back and ask.
4. **Explore** — fan out read-only subagents along your repo's own seams and build one map. They
   also report the tests that already cover the symbols in play. No architecture is assumed and
   none is recommended.
5. **Settle the tests the change invalidates — before writing code.** Every existing test over a
   symbol the change touches gets a verdict: **update** it in the same step that changes the code,
   **delete** it and say what stopped being covered, or **escalate** — because a test asserting
   something the ticket never mentioned means either the change breaks more than anyone said, or
   that test is the only place the requirement was ever written down. Discovering this when CI
   goes red is how "the test is in the way" turns into loosening it.
6. **Draft the plan** — small steps, each with its own verification in your repo's commands; the
   first step is a failing test. The plan is written to `.claude/plans/<TICKET>.md` and kept
   current as the work runs: a working notebook you can read while it works, and one that survives
   a session that dies or fills up. It is never staged and never committed on the skill's
   initiative.
7. **Adversarial review** — three subagents critique the plan through different lenses
   (conventions, correctness, scope) *before* any code is written. The scope lens specifically
   attacks the Assumptions list.
8. **Your approval — only if the change warrants it.** Plan mode opens for anything over ~3 steps
   or ~3 files, or that touches a contract, a schema, auth, or money, or that rests on
   assumptions, or that is hard to reverse. Small, reversible, fully-specified changes print the
   plan and keep going.
9. **Implement, test-first — one subissue at a time.** RED → GREEN per step, with the editing
   delegated to subagents that report what they changed, so the main session keeps its context for
   the plan, the gates and you. Fan-out only where edits don't collide; comments follow your repo's
   own density and language rather than the agent's habits. As each subissue closes: stage only its
   files, commit with **that subissue's** link token, push, then comment on it and **move it to
   your team's completed state** — a child that is implemented, gated and pushed is finished. The
   **parent** is what waits on the PR.
10. **Gates** — once, over the complete branch diff. It resolves your repo's own gate commands (a
    Gates/Commands section in `CLAUDE.md`/`AGENTS.md` → manifest detection → ask), then
    `/code-review`, plus `/security-review` when the diff touches auth, secrets, or input parsing.
    Never proceeds on red. Gates your repo doesn't define are reported as skipped, not silently
    counted as green.
11. **Open the PR** — one PR for the whole ticket, listing each subissue and the verification
    commands actually run. **If anything on the work list wasn't implemented — blocked, escalated,
    abandoned — there is no PR:** it reports what's missing and why, and leaves the branch pushed
    so nothing built is lost.
12. **Babysit the PR to green** — watch CI, rerun a flaky job once, fix real failures at the
    source, then address review comments in a loop until the PR is green and clean. It stops after
    three failed attempts on the same job.
13. **Wrap up** — post the summary on the parent ticket and move it to its review state, where it
    stays until someone merges the PR; ask what to do with the plan file (delete, keep, or move it
    into your docs); and report which subissues were built and which were left out of the run.

Throughout, it narrates itself in plain language: one line as each step opens and closes, and
every state change announced as it happens — the branch, each tracker status and which state it
picked, each commit and push, the PR URL, the CI run it is waiting on.

## Prerequisites

- `linear-plan-build`: the [Linear MCP server](https://linear.app/docs/mcp), plus `gh` installed
  and authenticated against a GitHub `origin`. Linear is a tracker only — it hosts no code, no
  pull requests and no CI — so the code half of this skill is GitHub's. Both are checked **before**
  any work starts, because an unauthenticated `gh` discovered at push time costs a whole
  implementation to find out.
- `ado-plan-build`: either the Azure DevOps MCP server **or** the `az` CLI with the `azure-devops`
  extension. It detects which and tells you.

## What they're pre-approved to do

So you can decide if that's too much: read and write files (including the plan notebook under
`.claude/plans/`), run your repo's build/test commands, write to *the one ticket they're working*
and the subissues of it you selected, push its branch, and open one PR for it.

They never merge or complete a PR, never bypass a branch policy, never deploy, and never write
anything else in your tracker. Leave off `skip-checkpoint` and stop at the approval checkpoint if
you want a tighter leash.

Unlike the context skill, these write code, not docs — so they have no claim-ledger; correctness is
proven by the adversarial review and the real gate instead. Those gates are exactly what
[`instrument-project-dotnet`](./instrument-project-dotnet.md) installs.
