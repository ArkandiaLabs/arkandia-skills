---
name: plan-and-build
description: >
  Take a small feature brief — a Markdown file or an inline description — from
  "read it" to "implemented, gates green, ready to commit" through an explicit,
  teachable chain: read brief → explore → draft plan → adversarial plan review →
  your approval → test-first implementation → gates → commit. Exploration and plan
  review fan out to parallel subagents; implementation fans out only where the work
  is genuinely disjoint. Runs one phase at a time so the seams stay visible. For
  .NET repos and Azure Boards work items, use `/arkandia:plan-and-build-dotnet`.
  Invoke with `/arkandia:plan-and-build [brief.md | inline description]`.
argument-hint: "[brief-file.md | inline description]"
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(git status*), Bash(git diff*), Bash(git add*), Bash(git commit*), Bash(git log*), Bash(git rev-parse*), Agent, Skill, TaskCreate, TaskUpdate, TaskList, TaskGet, EnterPlanMode, ExitPlanMode
---

# Plan → Build

Drive a feature from a brief to green gates through a chain of phases where **each
phase's output is the next phase's input**: brief → exploration → plan → vetted plan
→ approved plan → tested code → green gates → commit.

Two things make this workflow legible on purpose:

1. **Loosely coupled.** The "ticket" is a Markdown brief or an inline description, so
   the chain runs against your repo with no issue tracker required. Gates stay your
   repo's own checks; nothing calls out to CI or the cloud. (For a fully-wired
   example that reads Azure Boards work items and runs .NET/Make gates, see
   `/arkandia:plan-and-build-dotnet`.)
2. **One phase at a time.** **After each phase, summarize what happened and stop.**
   Wait for the user to say continue before starting the next phase. Make the seams
   visible; never run phases together. This is what makes the workflow teachable and
   keeps you in control of the *what* before the agent commits to the *how*.

## Arguments

`$ARGUMENTS` is one of two things. Resolve it in this order:

1. **Brief file** — a path ending in `.md`. Read it.
2. **Inline description** — anything else. Use it as the brief.

If `$ARGUMENTS` is empty, ask for the feature. If a brief is present but too thin to
act on (no observable behavior, no acceptance criteria), say so and ask for the
missing detail — a one-line brief is a prompt, not a specification.

Whichever path you took, restate the goal in one or two sentences and name the source
you resolved it from (`example-brief-...md`, inline).
**[stop — confirm the goal before exploring]**

## Phase 1 — Explore (make the codebase legible), fanned out

1. **Establish the repo's conventions first.** If the repo has an `AGENTS.md`,
   `CLAUDE.md`, or a `docs/` context pack (for example one produced by
   `/arkandia:agent-context`), read it — that is the fastest path to this repo's
   patterns, commands, and non-obvious rules. If none exists, infer the conventions
   from the code as you explore, and treat that inference as provisional.
2. **Fan out `Explore` subagents by the repo's own seams**, all in a single message so
   they run concurrently. Pick the partition that fits the codebase — modules,
   packages, layers, or services — and scope each agent to the area the feature
   touches. Ask each to return the files that exist, the exact symbols involved, and
   any edge case it can see in its area (an unguarded parse, a missing uniqueness
   check, a swallowed error). Tell each one to **read, not judge** — no plans, no
   fixes. Their combined output is a map, not an opinion.
3. Synthesize their reports into one short map yourself: which files exist, which
   you'll touch, and the edge cases now visible. Where two subagents disagree about
   the same file, open it and settle it — do not average their claims. If the feature
   is a single-file change, skip the fan-out; several agents to read one function is
   waste, and saying so out loud is part of the discipline.
   **[stop — this is the "understand before you touch" beat]**

## Phase 2 — Draft the plan

4. Write a step-by-step plan: **small steps**, each naming the exact file(s) and its
   own verification, expressed in **your repo's own commands** (the lint/test/build
   commands from `AGENTS.md`'s "Commands" section, `Makefile`, `package.json` scripts,
   or whatever the repo uses). The **first implementation step is a failing test**
   that proves the behavior is missing. Note dependencies, risks, and anything you
   chose to leave out of scope.
   **[stop — show the draft plan]**

## Phase 3 — Adversarial plan review, fanned out

5. Critique the draft **before** any code. Fan out **three `general-purpose`
   subagents in one message**, each with a *different lens* rather than three copies
   of the same reviewer — redundancy catches less than diversity does. Pass each the
   brief and the full draft plan:

   > **Conventions lens.** Critique this plan against this repo's conventions as
   > documented in `AGENTS.md`/`docs/` (or the patterns observed while exploring):
   > error-handling style, layering and dependency rules, where validation belongs,
   > naming, and any non-obvious rule the docs call out. Flag any step that would
   > violate an established pattern or put logic in the wrong place.

   > **Correctness lens.** Hunt for unhandled edge cases and wrong behavior: inputs
   > the plan never validates, states it never reaches, tests that would pass while
   > the bug survives. For each, give the concrete input and the wrong result.

   > **Scope lens.** Find what is missing and what does not belong: steps absent from
   > the plan that the acceptance criteria demand, steps present that no criterion
   > asks for, and anything requiring a migration or a product decision the brief
   > never answers.

   Each returns a short structured list of concrete issues with a suggested fix, and
   **writes no code**.

6. Fold the three critiques into one revised plan. **Judge, don't tally** — a single
   reviewer naming a real convention violation outranks two that found nothing, and a
   confidently-argued finding that is simply wrong gets dropped with a reason.
   Deduplicate where lenses overlap. State plainly what each lens flagged and how you
   resolved it, including what you rejected and why. If a critique surfaced a genuine
   product-judgment gap with no answer in the brief, that is a question for the user,
   not a decision to make quietly. **[stop — show the revised plan + the review
   summary]**

## Phase 4 — Human checkpoint (the one gate)

7. Present the vetted plan through **plan mode**: call `EnterPlanMode`, then
   `ExitPlanMode` to submit for approval. This is the single explicit checkpoint —
   the human decides the **what**; the agent will execute the **how**. Do not write
   code until it is approved.

## Phase 5 — Implement (on approval), test-first, fanned out where it's safe

8. Break the plan into 3–8 steps with `TaskCreate`; mark `in_progress`/`completed` as
   you go — state lives in the task list.

9. **Partition the steps by the files they touch.** This decides what can fan out,
   and it is the whole judgment call:

   - Steps whose file sets are **disjoint** (a new validator in one module, an
     unrelated fix in another, a config change) can run as **parallel subagents**,
     one step each, dispatched in a single message.
   - Steps that **converge on the same file** must stay **serial**, in one agent.
     This is the common case: N acceptance criteria usually become N checks in the
     *same* function, plus N tests in the *same* test file. Two agents editing that
     file in parallel will overwrite each other — and a format-on-save hook, if your
     repo has one, makes the race worse, not better.

   When steps converge, you can still parallelize the thinking: fan out one subagent
   per acceptance criterion to **return a proposed test and change as a diff, writing
   nothing**, then apply them yourself, serially, RED → GREEN. You get the breadth
   without the write conflict. Say which mode you chose and why.

   Only reach for `isolation: "worktree"` if agents genuinely must write the same
   paths concurrently; usually they shouldn't, and the merge cost is not worth it.

10. For each step, **RED → GREEN**: write the failing test first, run it and watch it
    fail, then write the minimal code to pass. After each step run the **targeted**
    check (a single-test filter and/or the linter), not the whole suite yet.
    Subagents report results; **you** run the checks, so one agent's green is never
    taken on faith.
11. Keep steps small (split anything past ~8 files / ~200 lines). On 3 repeated
    failures of the same check, stop guessing — classify the cause (test, code,
    environment, plan drift), fix it at the source, and continue. **[stop after the
    implementation is complete, before the full gate]**

## Phase 6 — Gates (mandatory, never proceed on red)

12. Run the **full gate**: your repo's own gate command (for example a `make check`
    target, `npm test && npm run lint`, `pytest`, `go test ./...`, or the combined
    command named in `AGENTS.md`). Then run **`/code-review`** on the diff at medium
    effort (review only). Treat correctness/security findings as red. The gate is
    **never** delegated to a subagent: run it yourself and paste the real output. A
    subagent reporting "tests pass" is a claim; the gate's own output is evidence.
13. **Never** call it done on red. Fix and re-run from step 12. **[stop — report the
    gate result]**

## Phase 7 — Commit

14. Stage only the files you changed (never `git add -A`; never anything secret-like),
    and commit with a message that references the brief. Show the diff stat.

## Phase 8 — Close the loop

15. Summarize: what was built, the tests added, the gate result, the commit.
16. **Name the bridge to production.** This workflow is the same shape as a
    production chain — only the tool bindings change per stack. The brief could be a
    tracker work item; the gate could also run in CI; the commit could be followed by
    a push-and-open-PR step, a review-comment step, and a wrap-up step that posts back
    to the tracker. Composition is literal: in production, one planning skill
    **invokes** the commit/PR, review-comment, and wrap-up skills — the output of one
    is the input of the next. For a concrete wired example (Azure Boards work item →
    Pipelines gate → Azure Repos PR), see `/arkandia:plan-and-build-dotnet`. Do **not**
    push or open a PR unless the user asks; the point is to show the seam, not to ship.

## Notes

- **Fan-out is a tool, not a goal.** Parallel subagents buy breadth on reading and
  critiquing, where the work is independent and read-only. They cost correctness on
  writing, where it usually isn't. When in doubt, fan out the analysis and keep the
  edits serial.
- **Keep secrets out of the shell and the commit.** Don't stage `.env` files, keys, or
  tokens, and don't echo secret values into commands or commit messages.
