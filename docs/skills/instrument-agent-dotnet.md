# `instrument-agent-dotnet`

**[← README](../../README.md)** · **[Versión en español →](./instrument-agent-dotnet-es.md)**

Where [`instrument-project-dotnet`](./instrument-project-dotnet.md) installs the controls a machine
can evaluate on its own, this one installs the half that applies the team's **judgement** — which
systems the agent may reach, which files it may open, and what happens to a file the moment it is
written.

```
/arkandia:instrument-agent-dotnet
```

## Two artifacts, in this order

| Order | Artifact | What it changes |
|---|---|---|
| 1 | `.mcp.json` | What the agent can **reach** — the team's trackers, docs and data, queried directly instead of pasted into chat |
| 2 | `.claude/settings.json` + `scripts/agent-hooks/*.sh` | What the agent **cannot get past** — checks that run whether or not it thought to run them |

MCP first, hooks second. MCP only adds capability; hooks take it away. Installing the additive half
first means that when a hook starts refusing things, you know which half to look at.

## The seven hooks

**1 and 2 are the default.** 3 to 7 are offered, and 6 and 7 only when the repository actually
contains the artifact they protect.

| # | Hook | Event | Blocks | What it prevents |
|---|---|---|---|---|
| 1 | Secret read-guard | `PreToolUse` | **yes** | The agent opening a `.env`, a private key or `secrets.json` |
| 2 | Format on edit | `PostToolUse` | no | Turns spent on indentation, and style noise in the diff |
| 3 | Dangerous-command blocker | `PreToolUse: Bash` | **yes** | `rm -rf ~`, `sudo`, a force-push to `main`, `dotnet nuget push` |
| 4 | Dependency sweep | `SessionStart` | no | Writing an integration against a package with a live advisory |
| 5 | Audit log | `PreToolUse` (async) | no | Nobody being able to say what the agent ran unattended |
| 6 | Package-version guard | `PostToolUse` | no | A project file pinning its own package version, re-introducing drift |
| 7 | Generated-file guard | `PreToolUse` | **yes** | Hand-editing `packages.lock.json` or an EF Core migration |

Hook 1 closes the circle with the deterministic half: gitleaks catches a credential before it
reaches a commit, this catches it before the agent has read it at all. Same concern, two moments,
two engines.

## The run

1. **Discover** — the solution, the existing `.claude/` and `.mcp.json`, the Makefile's real
   targets, the formatter, the git remote and default branch, the database provider, and which
   hooks' preconditions hold.
2. **Check prerequisites** — per OS. Git Bash is the one that matters on Windows.
3. **Ask only what it could not infer** — which servers, which hooks, protected branches, and an
   explicit confirmation for the audit log.
4. **Apply** — `.mcp.json`, then the scripts, then the registration, merging with whatever is there.
5. **Fire every hook on purpose** — and revert. A guard with a broken pattern exits 0 and looks
   exactly like a guard that found nothing.
6. **Update the documentation the install invalidated**, then report.

## The menu comes from the repo

Both menus. Hooks 6 and 7 are **hidden** when their artifact is absent, with the reason stated —
without central package management a `Version` attribute is the correct way to declare a package,
so that hook would fire on every `dotnet add package` and the team would switch the whole set off.

MCP servers are derived the same way: Azure DevOps from an `azure-pipelines.yml`, GitHub from the
remote, DBHub from the connection string in the code, Playwright and Chrome DevTools from a web
project. Microsoft Learn and Context7 are offered in any .NET repository — they are the answer to a
model writing an API that was renamed two releases ago.

## What it will not do

- **Touch `.claude/settings.local.json`, or the `permissions` key anywhere.** The local file is
  personal and gitignored; permissions are the user's decision. It writes exactly one key: `hooks`.
- **Replace an existing `hooks` or `mcpServers` block.** It appends. Two matcher groups on one
  event both fire, so there is usually nothing to resolve — it asks only when a handler already
  points at a script with the same name.
- **Write a credential into `.mcp.json`.** Every secret is an `${ENV_VAR}` reference with **no
  default** — `${TOKEN:-}` would turn "not set" into "empty token supplied" — and the variable
  name goes in the README. A machine-specific path is treated the same way: `${CLAUDE_PROJECT_DIR}`
  does not help in a project-scoped file, because Claude Code sets it in the *server's*
  environment, so it always falls back to `.` and a SQLite connection string rejects that.
- **Leave an MCP package floating.** Versions are resolved with `npm view <package> version`
  when the file is written and then pinned — `npx -y <package>@1.2.3`. A bare `npx -y
  <package>` in a committed `.mcp.json` runs whatever was published since, unreviewed, with
  the user's permissions. The resolved versions are reported back to you, to bump like any
  other dependency.
- **Report a hook as working without having seen it refuse something.**

## Two asymmetries it states out loud

**The hooks are proven; the MCP servers are only written.** A newly written `.mcp.json` leaves its
servers at `⏸ Pending approval` until the user trusts the workspace — and a committed
`enableAllProjectMcpServers` is ignored until then, so a cloned repository cannot approve its own
servers. The report says *written, pending approval*, with the two steps to activate them.

**The scripts are portable; the registration is not.** `scripts/agent-hooks/*.sh` is plain bash,
written to bash 3.2 with no `jq`, running unchanged on macOS, Linux and Git Bash. But
`.claude/settings.json` is Claude Code's alone — no other agent reads it today, so on Codex, Cursor
or Copilot these hooks do not run. The final report says so rather than letting you find out on
another tool.

And one sentence that belongs in every report this skill produces: **hooks are not a security
boundary.** They run with your shell and your permissions, and they match text, not intent. They
are a guardrail against a plausible mistake. For a real boundary, use permission deny rules.
