# .NET inspection checklist

The discovery work behind `docs/dotnet.md`. Each section says **what to read**, **what to
extract**, and **how to record it**. Read real files (Glob/Grep/Read). Where a fact isn't
readable, leave a `<!-- TODO -->` — never guess.

The signal set here is grounded in what static analysis of real .NET solutions surfaces
(multi-project solutions, per-project TFMs, NuGet graphs with vuln scanning, EF Core `DbContext`
hotspots, absent analyzers/arch-linting, Azure Pipelines, MAUI `Platforms/` splits, secrets in
`appsettings`). Treat the list as the floor, not the ceiling.

---

## 1. Solution & projects

- **Read:** `*.sln` (text) and `*.slnx` (newer XML format — handle both). Then every `*.csproj` /
  `*.fsproj` / `*.vbproj`.
- **Extract:**
  - Solution file name(s) and the project list.
  - Classify each project. Heuristics:
    - `Microsoft.NET.Sdk.Web` + `Controllers/` or `Program.cs` mapping endpoints → **Web API / MVC**.
    - `.cshtml` present → **Razor Pages / MVC**.
    - `Microsoft.NET.Sdk.Razor` + `.razor` → **Blazor / Razor Class Library**.
    - `<UseMaui>true</UseMaui>` or `net*-android`/`net*-ios` TFMs → **MAUI app**.
    - `Microsoft.NET.Sdk.Worker` / `IHostedService` → **Worker / background service**.
    - test packages (xUnit/NUnit/MSTest) → **Test project**.
    - otherwise → **Class Library / Console**.
  - **Project-reference graph:** parse `<ProjectReference>` to see who depends on whom. This reveals
    layering (e.g. `Api → Core → Infrastructure`) and proxy/shared libraries.
- **Record:** a project table (name · type · TFM · one-line purpose) and a small Mermaid graph of
  the project references.

## 2. Target frameworks & language

- **Read:** each `*.csproj`; `Directory.Build.props` / `Directory.Build.targets` (shared settings);
  `global.json` (pinned SDK).
- **Extract:** `<TargetFramework>` / `<TargetFrameworks>` (multi-targeting, incl. `net8.0-android`,
  `net8.0-ios`), `<LangVersion>`, `<Nullable>` (`enable`/`disable`), `<ImplicitUsings>`,
  `<TreatWarningsAsErrors>`, `<UserSecretsId>`.
- **Record:** the TFM(s), the C# language posture (nullable on/off, implicit usings), and any
  pinned SDK. Flag inconsistent TFMs across projects (an ambiguity for claim validation).

## 3. Key NuGet dependencies

- **Read:** `<PackageReference>` across all projects; `packages.lock.json` or
  `Directory.Packages.props` (central package management) if present.
- **Extract:** the **load-bearing** packages, grouped — web framework (ASP.NET Core), ORM
  (`Microsoft.EntityFrameworkCore.*`, `Dapper`), mediator (`MediatR`), mapping (`AutoMapper`),
  logging (`Serilog`, `NLog`), auth (`Microsoft.Identity*`, `IdentityServer`), messaging,
  resilience (`Polly`). Note versions.
- **Record:** a short highlights list (not the full dump). Note version freshness or known-vuln
  risk **only** if you have a concrete signal (e.g. a lockfile audit) — do not invent CVEs.

## 4. Composition root / DI

- **Read:** `Program.cs` (minimal hosting) and/or `Startup.cs`; any Autofac `Module` classes;
  `*Extensions.cs` files with `AddXxx(this IServiceCollection)` patterns.
- **Extract:** where services are registered, the container (built-in vs Autofac/others), and
  notable lifetimes (`AddSingleton`/`AddScoped`/`AddTransient`) or conventions (assembly scanning,
  options pattern, hosted services).
- **Record:** where the composition root lives and any DI convention an agent must follow.

## 5. Data access (EF Core)

- **Read:** classes deriving from `DbContext`; `OnModelCreating`; `Migrations/` folders;
  `UseSqlServer` / `UseNpgsql` / `UseSqlite` / `UseCosmos` calls; connection-string config.
- **Extract:** the provider, the `DbContext` location(s), how the model is configured (data
  annotations vs Fluent API vs `IEntityTypeConfiguration<>`), where migrations live and how they
  are applied (`dotnet ef database update`, `context.Database.Migrate()` on startup, or in CI).
- **Record:** provider + `DbContext` location + migration workflow. **Flag a very large
  `DbContext`** (thousands of LOC) as a hotspot. Cross-link `docs/data-model.md` for the schema.

## 6. Configuration & secrets

- **Read:** `appsettings.json` and `appsettings.{Environment}.json`; `launchSettings.json`;
  `<UserSecretsId>`; Key Vault / environment-variable usage; `.env` files.
- **Extract:** the configuration layering (base → env → user-secrets/env vars → Key Vault), and
  what each environment overrides.
- **Record:** the secrets strategy. **Flag any secret that appears committed** (connection strings,
  API keys, storage keys in `appsettings`) — recommend moving to user-secrets / Key Vault and an
  `appsettings.example.json`. Do not reproduce the secret value in the docs.

## 7. Build, run, test

- **Read:** `*.sln`, test projects, CI files, any `Makefile`/`*.ps1`/`*.sh` wrappers.
- **Extract:** the everyday commands — `dotnet build`, `dotnet run --project <…>`, `dotnet test`,
  `dotnet ef migrations add` / `database update`, `dotnet watch`.
- **Record:** the 3–6 commands a developer actually runs, plus the test framework(s) and how tests
  are organized (by layer? by domain? separate integration/automation projects?).

## 8. Quality gates

- **Read:** `.editorconfig`; analyzer packages in `*.csproj` (`StyleCop.Analyzers`,
  `Microsoft.CodeAnalysis.NetAnalyzers`, `SonarAnalyzer.CSharp`); arch-linting (`NsDepCop` config,
  `ArchUnitNET` test projects); `<TreatWarningsAsErrors>`, `<EnforceCodeStyleInBuild>`.
- **Extract:** which gates are **present** vs **absent**.
- **Record:** a present/absent table. Where absent, add a recommendation (these are commonly
  missing): adopt `.editorconfig`, add Roslyn analyzers, add an arch-linting rule to enforce the
  layering found in §1.

## 9. UI / platform

- **Read:** `.cshtml` (Razor Pages/MVC), `.razor` + `.razor.cs` (Blazor), `.xaml` + `.xaml.cs`
  (MAUI/WPF); `wwwroot/`; `Platforms/Android/` and `Platforms/iOS/`.
- **Extract:** the UI stack(s) in play and, for MAUI, the platform-specific service split
  (e.g. push notifications / analytics implemented per platform), renderers/handlers, deep-linking
  config.
- **Record:** the UI technology and any platform-specific wiring an agent must respect. Omit this
  section entirely for headless services.

## 10. Gotchas / hotspots

- **Read/Grep:** unusually large files (e.g. `wc -l` on `*.cs`), high-churn files if git history is
  available, `async` methods, `CancellationToken` usage, `// TODO` / `// FIXME` density.
- **Extract:** monolithic classes (a 9k-LOC `DbContext`, a 2k-LOC service), async/cancellation
  conventions (are cancellation tokens threaded through?), and notable TODO clusters.
- **Record:** a short "gotchas" list — the non-obvious things that will trip up an agent editing
  this solution.
