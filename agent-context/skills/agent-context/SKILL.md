---
name: agent-context
description: Generate a minimal documentation pack (AGENTS.md, architecture, ADRs, data model, infrastructure) for the current repository so AI coding agents can reason about it. Invoke with `/agent-context [en|es]`.
argument-hint: '[en|es]'
disable-model-invocation: true
---

# agent-context — Bootstrap Repository Context

You are generating a **context pack**: a small, cross-linked set of Markdown docs that makes an unfamiliar repository legible to an AI coding agent. You MUST NOT write application code, install dependencies, or run destructive commands. Your only outputs are Markdown files at the repo root and under `docs/`.

## Philosophy (hold these in mind throughout)

- **AGENTS.md is a table of contents, not an encyclopedia.** Keep it under ~80 lines.
- **The repository is the system of record.** Anything not in the repo is invisible to the agent.
- **Context is a scarce resource.** Every line in every doc must earn its place.
- **Progressive disclosure.** AGENTS.md points to specialized docs; each specialized doc delegates further.
- **No manually-written code here either.** This skill is itself that philosophy applied to onboarding.

## Input: language

`$ARGUMENTS` is either `en`, `es`, or empty.

- If `$ARGUMENTS == "es"` → output docs in Spanish. Load templates from `templates/es/`.
- If `$ARGUMENTS == "en"` or empty → output docs in English (default). Load templates from `templates/en/`.

The skill's own instructions (this file) stay in English regardless.

---

## Phase 1 — Discover (silent)

Do this without talking to the user. Use Glob, Grep, and Read.

### 1a. Detect prior context. If ANY of these exist, switch to **augment mode**:
- `AGENTS.md`, `CLAUDE.md` at repo root
- `docs/` directory with `.md` files
- `ARCHITECTURE.md`, `ARCHITECTURE.rst`
- `ADR/`, `adrs/`, `decisions/`, `doc/adr/`

In augment mode: read what exists, report it to the user in Phase 2, and only create **missing** docs. Never overwrite.

### 1b. Detect stack via filesystem signals

Glob the repo root and a couple levels deep. Map detected signals to stack notes you'll include in `architecture.md` and `infrastructure.md`:

| Signal | Infer |
|---|---|
| `pom.xml`, `build.gradle`, `build.gradle.kts`, `settings.gradle`, `mvnw`, `.mvn/` | Java (Maven / Gradle) |
| `application.properties`, `application.yml`, `bootstrap.yml` | Spring Boot / Spring Cloud |
| `*.sbt`, `project/build.properties` | Scala / SBT |
| `AndroidManifest.xml` + Kotlin `build.gradle.kts` | Kotlin / Android |
| `*.csproj`, `*.sln`, `*.fsproj`, `*.vbproj`, `global.json`, `Directory.Build.props`, `nuget.config`, `appsettings.json` | .NET (ASP.NET Core, EF Core, F#, VB) |
| `Migrations/*.Designer.cs` | Entity Framework Core migrations |
| `composer.json`, `composer.lock` | PHP |
| `artisan`, `config/app.php` | Laravel |
| `bin/console`, `symfony.lock`, `config/packages/` | Symfony |
| `wp-config.php`, `wp-content/` | WordPress |
| `package.json`, `pnpm-workspace.yaml`, `turbo.json`, `nx.json`, `lerna.json` | Node / JS monorepo |
| `pyproject.toml`, `requirements.txt`, `setup.py`, `manage.py`, `alembic.ini` | Python (Django, Flask, FastAPI, Alembic) |
| `Gemfile`, `config/application.rb` | Ruby / Rails |
| `go.mod` | Go |
| `Cargo.toml` | Rust |
| `db/changelog.xml`, `db/changelog/` | Liquibase migrations |
| `db/migration/V*__*.sql` | Flyway migrations |
| `prisma/schema.prisma`, `drizzle.config.*` | JS/TS ORM schema |
| `Dockerfile`, `docker-compose*.yml`, `compose.yaml` | Containerization |
| `Chart.yaml`, `values.yaml`, `k8s/`, `kustomization.yaml` | Kubernetes / Helm |
| `*.tf`, `terraform.tfvars`, `*.bicep`, `cdk.json`, `serverless.yml`, `template.yaml` | Infrastructure as Code |
| `Jenkinsfile`, `azure-pipelines.yml`, `.gitlab-ci.yml`, `.github/workflows/`, `bitbucket-pipelines.yml`, `.circleci/config.yml` | CI/CD |
| `*.wsdl`, `*.xsd`, `*.proto`, `openapi.yaml`, `swagger.json` | API contract style (SOAP, gRPC, REST) |
| `sonar-project.properties`, `checkstyle.xml`, `.editorconfig`, `.eslintrc*`, `ruff.toml`, `.rubocop.yml` | Quality gates |

If multiple languages are detected, treat it as a polyglot monorepo — `architecture.md` should list each with its own subsection.

### 1c. Read the README

Read `README.md` / `README.rst` if present. Use it to seed the one-line project summary. Do NOT copy large chunks — just extract the purpose.

### 1d. Scan for obvious domain cues

Grep for model / entity / schema files. Note dominant domain nouns (e.g. `Order`, `Invoice`, `Patient`, `Course`). Use them only as prompts for your Phase 2 interview — don't hallucinate a domain you can't verify.

---

## Phase 2 — Interview

Two kinds of questions, used in order.

### 2a. Structured choices — use `AskUserQuestion`

Batch these into a single `AskUserQuestion` call (up to 4 options per question):

1. **Output language** — only if `$ARGUMENTS` was empty. Options: `English (default)`, `Spanish`.
2. **Optional docs** — "Generate also `target-user.md` and/or `design.md`?" multiSelect: `true`. Options: `target-user.md`, `design.md`.
3. **Augment-mode confirmation** — if Phase 1 found existing docs, ask: "Existing docs detected: [list]. Only generate missing ones?" Options: `Yes (augment only)`, `Overwrite matching docs`, `Cancel`.
4. **Framework confirmation** — only if Phase 1 inference was ambiguous (e.g., multiple language signatures). Offer the top 2–3 candidates.

Skip any question whose answer is already known.

### 2b. Free-text answers — ask in plain chat

`AskUserQuestion` does not fit long-form input. For these, output a short chat message and wait for the user's reply:

5. **Business context** — "In one or two sentences: what does this product do, and who pays for it?"
6. **Non-obvious rules** — "List up to 3 invariants or gotchas an AI coding agent must know that are NOT enforceable by linters/tests. Examples: *'never bypass the tenant filter', 'always run migrations inside a transaction', 'do not touch legacy module X'*. If none come to mind, reply 'skip'."

Do not proceed to Phase 3 until both 2a and 2b are complete. Keep the whole interview under six questions total — users hate long forms.

---

## Phase 3 — Draft

For each doc to generate, read the template at `templates/<lang>/<doc>.md.template`, substitute the placeholders, and write to the target path.

Placeholders use `{{UPPER_SNAKE}}` syntax, e.g., `{{PROJECT_NAME}}`, `{{STACK_SUMMARY}}`, `{{BUSINESS_SUMMARY}}`, `{{NON_OBVIOUS_RULES}}`. Each template declares its placeholders at the top.

Target paths:
- `AGENTS.md` (repo root)
- `CLAUDE.md` (repo root)
- `docs/business.md`
- `docs/architecture.md`
- `docs/data-model.md`
- `docs/infrastructure.md`
- `docs/adrs/README.md` + `docs/adrs/adr-template.md` + `docs/adrs/adr-0001-<slug>.md` (1–3 seed ADRs inferred from detected stack)
- `docs/target-user.md` (only if opted in)
- `docs/design.md` (only if opted in)

Rules for filling templates:
- Short sentences. Sacrifice grammar for clarity.
- If you don't have info for a section, leave a `<!-- TODO: fill in -->` marker — don't hallucinate.
- For ADR seed content: use detected stack to propose 1–3 decisions that were clearly made (e.g., `adr-0001-language-framework.md` naming the language/framework, `adr-0002-deployment-target.md` if a Dockerfile or IaC was detected). Each ADR must include Status, Context (with alternatives considered), Decision, Consequences (easier / harder).
- Architecture doc must name the detected framework + migration tool explicitly (e.g., "Spring Boot 3 + Flyway", "ASP.NET Core 8 + EF Core", "Laravel 11 + Doctrine").

---

## Phase 4 — Wire (AGENTS.md + CLAUDE.md)

Generate `AGENTS.md` strictly as a **table of contents**:

- Opening: 2 lines max (project name + one-line purpose).
- Section **"Where to find things"**: bulleted list of every doc with a one-line description of each.
- Section **"Commands"**: the 3–5 commands a developer runs most often (infer from `Makefile`, `package.json` scripts, `pom.xml` / `build.gradle` tasks, `composer.json` scripts, `*.csproj` targets, `manage.py`, `Rakefile`). If unsure, leave as TODO.
- Section **"Non-obvious rules"**: populate with the user's Phase 2 answers. Format each as a bullet with a short rationale.
- Section **"Testing"** and **"Code style"**: one paragraph each, referencing tools detected in Phase 1.
- Section **"Security"**: generic bullets (no secrets in logs, `.env` not committed). Students can extend.

Enforce the ~80-line ceiling. If you exceed it, move content into a specialized doc.

`CLAUDE.md` is one line: `@AGENTS.md` with a comment explaining it delegates.

---

## Phase 5 — Verify

1. Print a tree of files written (or augmented).
2. Check that every link in AGENTS.md resolves to a file that exists (use Read).
3. Remind the user:
   - Commit: `git add AGENTS.md CLAUDE.md docs/ && git commit -m "docs: bootstrap context pack for AI coding agents"`
   - Next suggested step: fill in `<!-- TODO -->` markers and review ADRs.
   - Re-run `/agent-context` later; it will augment, not overwrite.

---

## Reference

- `templates/en/` and `templates/es/` — doc skeletons.

## Rules

- Do NOT write application code.
- Do NOT overwrite existing docs without explicit user opt-in.
- Do NOT fabricate framework versions, endpoint names, or schema details you haven't read.
- DO leave `<!-- TODO -->` markers where human input is needed.
- DO keep every doc focused: each has one job, delegated from AGENTS.md.
