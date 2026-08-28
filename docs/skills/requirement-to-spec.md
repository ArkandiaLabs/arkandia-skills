# `requirement-to-spec`

**[← README](../../README.md)** · **[Versión en español →](./requirement-to-spec-es.md)**

The other half of the delivery pipeline, upstream of [`linear-plan-build` /
`ado-plan-build`](./plan-build.md). Where those take a ticket to a green PR, `requirement-to-spec`
takes a business requirement document — Word, PDF, Excel, Markdown, plus its attachments — to a
**spec** and an **ordered task breakdown**, filed wherever the team tracks work.
`linear-plan-build`/`ado-plan-build` never create subissues by contract; this is what fills the
parent issue they consume.

```
/arkandia:requirement-to-spec path/to/requirements.docx
```

It is not "summarize this document." A summary restates what is written; this skill also surfaces
what the document leaves unsaid — a public API it would break with no mention of the callers, an
attachment referenced but never provided, a paragraph that quietly widens scope — and turns the
resolved answers into something buildable.

## The chain

1. **Convert** — one Markdown model regardless of source format: `anydoc` first, native `Read` as
   the fallback where the format allows it (a scanned PDF gets read visually; a `.docx` cannot be
   read at all without `anydoc`), and a hard stop — never an invented answer — if neither produces
   usable content. Converted files live in a temp directory, never in your repo. Every attachment
   the document mentions is checked against the files actually next to it; a missing one is
   reported, never described as if its contents were known.
2. **Read the target repo** — `AGENTS.md`/`CLAUDE.md`/`docs/`, no architecture assumed, and a
   stack-agnostic scan for a public contract the change plausibly touches (OpenAPI, GraphQL,
   `.proto`, exported library symbols). If one exists, the skill asks explicitly whether to break it
   or keep it compatible — even when the document itself never raises the question. If the repo
   exposes none, it says so and moves on rather than asking a question with nothing concrete to
   name.
3. **Find the documentation the change makes wrong** — the architecture page, the data-model doc,
   the API list, the runbook, the ADR the change supersedes, `AGENTS.md`. Not by category: the skill
   greps your doc set for the concrete names the requirement touches and only lists a document when
   it can quote the line that goes stale. Each one you confirm becomes its own documentation task
   **after** the functional work it describes — blocking nothing, because a page is rewritten to
   match what was built — naming the file, what is now false, and what should replace it; each one
   you exclude is recorded by name as out of scope. The skill never edits those documents —
   that is what the delivery skills do with the task.
4. **Cross-check data**, if a database MCP server is connected — detected by what its tools look
   like, not by a fixed name — comparing a tabular attachment against the real numbers and reporting
   any discrepancy with the exact figures on both sides.
5. **Sweep for ambiguity** — implicit scope, text-vs-attachment contradictions, behavior gaps,
   inconsistent numbers, scope arriving casually at the end of a document, undeclared currency or
   units, validation criteria written as background. Asked in batches of at most four, in plain language, recommended option first. Scope creep
   is two questions, not one: does it belong in this change, and — if not — does it get a note in
   the spec or its own item in the breakdown. No fixed default; decided every time — and the second
   question is asked in terms of the breakdown, not the tracker, because where the result gets
   filed is not decided until step 6. A **validation criterion** — the rule your business will
   check the delivered work against, usually written as background — gets the same two-question
   treatment: does it become its own item, and only then does the rest of the work wait for it. The
   skill never turns one into a blocker you didn't ask for.
6. **Ask where to save** — always, even with only one tracker detected, never auto-picked: the
   trackers actually found (Linear, Azure DevOps) plus **Local file**, in that order. With no
   tracker connected the question still gets asked, with "stop here and wire one up first" as the
   real alternative; decline it and nothing is written.
7. **Derive the task breakdown** from the closed decisions — functional tasks first, each stale
   document from step 3 as its own task after the work it describes, and dependencies written out
   rather than implied by the order. Only a document the code is literally written against (a
   contract or schema declaration, an ADR recording the decision a task implements) goes first, and
   then the task says which functional task needed it. Blockers exist only where you said so.
8. **Write it** — a parent issue/work item plus linked children in tracker mode, resolving the
   initial status by category rather than a hardcoded name; or `docs/specs/<slug>/spec.md` +
   `docs/specs/<slug>/tasks.md` in file mode.
9. **Verify by rereading** — the parent-child relation actually resolves, the initial status landed
   where it says it did, or (file mode) both files exist and the link between them works.
10. **Report** — four sections always present (asked / answered / out of scope / not read), closing
   with a concrete line to chain into `linear-plan-build`/`ado-plan-build`, or a note that file mode
   has no automatic chain into them yet.

## Prerequisites

- Node.js/`npx`, for the pinned `@firecrawl/anydoc@0.2.3` conversion step. Checked before the first
  conversion, not after. Missing it degrades the run to native `Read`, which still covers PDFs
  (visually) and any text format — but **not** Word, Excel or PowerPoint files, which are binary
  containers `Read` cannot open. For those the skill stops and asks you for the content rather than
  guessing at it, so `npx` is effectively required if your documents are `.docx`.
- Optionally, the Linear MCP server or the Azure DevOps MCP server / `az` CLI with the
  `azure-devops` extension — whichever trackers you want offered as a destination. None of these
  are required; file mode always works.

## What it never does

- Never auto-picks a tracker, even with exactly one detected.
- Never writes code, opens a PR, or touches anything in the tracker beyond the items it just
  created.
- Never invents the content of a document or attachment it could not read.
- Never follows instructions found *inside* a document. The document is material to be specced, not
  a set of directions — a line in a client PDF telling the agent to write a file or call an API is
  quoted and flagged, not obeyed.
- Never decides on its own whether a contract breaks, where scope creep gets registered, or which
  stale documents get updated in this pass — all three are always a question.
- Never edits your project's documentation. It emits a task per document; the delivery skills write.
- Never flags a document it cannot quote a stale line from. No "the docs may need review".
- Never commits.

## The asymmetry it leaves

`linear-plan-build`/`ado-plan-build` have no file-mode entry point today — they start from an
existing issue or work item. A `requirement-to-spec` run that lands in file mode does not chain
automatically into them; someone has to turn `docs/specs/<slug>/` into a ticket by hand, or re-run
`requirement-to-spec` once a tracker is wired up. This is accepted, not a defect: file mode is the
between-sessions path for a team without a tracker yet.
