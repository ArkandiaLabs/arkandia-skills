# Interview — the ambiguity sweep and the task breakdown

Same discipline the delivery skills (`linear-plan-build`/`ado-plan-build`) apply when they grill you
about a ticket — ask only what the source material does not already answer, record answers as quoted
**Decisions** and self-settled calls as written **Assumptions** — but aimed at a business document
read by a business reader instead of a ticket read by an engineer. The categories are generic
analysis-of-requirements
categories that this or that document happens to illustrate well — not a checklist tuned to any one
document. If a category never fires on a given document, that is expected; it exists for the
documents where it does.

## Categories to sweep

- **Implicit scope** — what the document clearly implies but never states outright.
- **Text vs. attachment contradictions** — a number, a name, or a rule in the prose that disagrees
  with what an attachment (spreadsheet, screenshot, prior spec) actually shows.
- **Behavior gaps** — "what happens when…", "what about the ones that don't have…" — cases the
  document's happy path never addresses.
- **Numbers that look inconsistent** — totals that don't sum, a count mentioned twice with two
  different values, a date range that overlaps another.
- **Scope that arrives casually** — an ask folded into a closing paragraph in a conversational tone,
  easy to read past because it doesn't look like a requirement.
- **Undeclared currency or unit** — a price, a weight, a duration with no unit stated, where the
  team's context does not make the default obvious.

## The requirements that are always active

Never conditional on the agent "deciding to look" — these run every time, whether or not the
document itself raises them:

1. **Public-contract impact** — resolved in `references/repo-context-impact.md`, turned into a
   question here if a contract was detected.
2. **The tabular cross-check** — if Phase 1 detected a database MCP server and the document or an
   attachment carries data that should exist in that database, run the comparison
   (`references/repo-context-impact.md`) **before** the sweep below, and turn every discrepancy into
   one of its questions, with the concrete numbers on both sides. This is the step that catches "the
   spreadsheet says 11, the database says 25" — it is worthless if it runs after the questions are
   already asked, and dishonest if the report claims it ran when it did not.
3. **Documentation impact** — resolved in `references/repo-context-impact.md`, turned into one
   question here: which of the documents the change leaves stale get updated in this pass. Ask it
   with the quoted evidence attached, never as a bare list of filenames; "`docs/database.md` line 40
   documents the `stock` table this change adds columns to" is answerable, "the docs may need
   review" is not.
4. **Missing attachments** — resolved in `references/document-conversion.md`. This is a **fact to
   report**, not a question — do not ask the user whether an attachment is missing; you already
   know. State it in the report.
5. **Grouped questions** — `AskUserQuestion`, **at most 4 per call**, recommended option first, no
   jargon without one clause of explanation. The person answering is in the business, more reliably
   than in `instrument-*`'s already-strict rule for that — do not let a technical term slip through
   unexplained.

## Scope creep: two questions, not one

When a category-sweep item turns out to be new scope arriving mid-document (the casual-ask case
above), it is **two separate questions**, asked in order:

1. **"Does this belong in this change, or is it separate?"** — a scope decision.
2. **Only if separate: "Should I just note it in the spec, or make it its own item in the
   breakdown?"** — there is **no default** for this. It is decided per case, every time; do not
   reuse the answer from a previous run or a previous item in the same run.

Q2 only makes sense once Q1 has been answered "separate", so it goes in a **later
`AskUserQuestion` call** — never bundled with Q1, which would ask the follow-up before knowing
whether it applies. Batch it with the next round's questions.

**Phrase Q2 in terms of the breakdown, not the tracker.** The destination question has not been
asked yet at this point in the phase, and it may well come back "Local file" — an option that says
"register it in the tracker" writes a promise the run may not be able to keep. "Its own item in the
breakdown" is true in both modes: in tracker mode that item becomes a real subissue/work item, in
file mode a row in `tasks.md` — the destination chosen later decides which, and neither is the
skill deciding scope on its own.

The result must match what was actually chosen: "note in the spec" ends as a line in the spec;
"its own item" ends as a real item in the breakdown, never folded into another one regardless of
how minor it looks.

## Recording the outcome

Two lists, carried forward into the spec exactly as the delivery skills carry them into a plan:

- **Decisions** — quoted, not paraphrased. What the user actually answered.
- **Assumptions** — what was resolved without asking, because it was minor. Write these down even
  when confident; they are what Phase 5/6 and the user's own read of the spec are there to catch.

## Deriving the task breakdown

This is its own activity once the Decisions are closed — not something that falls out of the
interview as a side effect.

1. **Documentation-only tasks first** — declaring a typed contract, writing an ADR for a breaking
   change, **updating each project document the user confirmed in requirement 3**, any task whose
   entire output is prose or a declaration with no code and no test cycle. Each gets **its own
   subissue/work item**, never folded as a note inside the first functional task.

   A confirmed documentation task names three things or it is not actionable: **which file**, **what
   in it is now false** (the quoted line from Phase 1), and **what it should say instead** once the
   functional work lands. A task that says "update the docs" is the failure this whole step exists
   to prevent. For a superseded ADR the task is "write a new ADR superseding `ADR-00N`" — never
   "edit `ADR-00N`".
2. **Functional tasks that depend on a documentation-only task come after it**, and the dependency
   is explicit in the breakdown — not merely implied by ordering.
3. Everything else follows in the order the spec's own sections present it, grouped so that a
   `linear-plan-build`/`ado-plan-build` run against any single item has what it needs without
   reading the others first.

Batch the ambiguity questions across rounds of ≤4; there is no cap on the number of rounds, only on
the size of each `AskUserQuestion` call.
