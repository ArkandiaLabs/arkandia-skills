# arkandia-skills

> *La IA no lee tu mente. Lee archivos.*

Una colección de skills para agentes de código de IA, desde Arkandia, en dos familias.

**Contexto** — **`agent-context-dotnet`** genera un paquete de documentación mínimo y bien estructurado para un repositorio .NET (`AGENTS.md`, arquitectura, ADRs, modelo de datos, infraestructura) más un análisis profundo en `docs/dotnet.md`, y termina validando contigo las afirmaciones más importantes que generó, para reducir alucinaciones. El paquete generado sigue la convención [`agents.md`](https://agents.md) y está dimensionado para que un agente de IA pueda mantenerlo en contexto.

**Entrega** — **`linear-plan-build`** y **`ado-plan-build`** llevan un ticket desde *léelo* hasta *PR abierto, CI en verde, comentarios de revisión atendidos, tracker actualizado*. Comparten un mismo motor — te interrogan sobre las decisiones de diseño que el ticket dejó abiertas → explorar → planear → revisión adversarial → tu aprobación (solo cuando el cambio lo amerita) → construir con tests primero → los gates propios de tu repo → PR → cuidar el CI hasta el verde — y difieren solo en sus conexiones: **Linear + GitHub** uno, **Azure Boards + Azure Repos + Pipelines** el otro. Ambos son agnósticos del stack y no asumen ninguna arquitectura.

Funciona con Claude Code, OpenCode, Codex, Cursor y los demás agentes soportados por [`skills.sh`](https://skills.sh).

**[English version →](./README.md)**

## Por qué

Los agentes de código se portan bien cuando el repositorio les dice lo que necesitan saber. Se pierden cuando el contexto crítico vive en la cabeza de alguien, en Slack, o en un Google Doc que nadie leyó. Este plugin te guía para producir el paquete de contexto mínimo viable, para que un agente pueda razonar sobre tu codebase desde el primer día.

El diseño está informado por el artículo de *harness engineering* de OpenAI (*"AGENTS.md es una tabla de contenidos, no una enciclopedia"*, *"el repositorio es el sistema de registro"*) y por el *Método Arkandia* del workshop *Desarrollo Guiado por IA*.

## Instalación

### Opción A — Marketplace nativo de Claude Code (plugin)

Dentro de Claude Code:

```
/plugin marketplace add ArkandiaLabs/arkandia-skills
/plugin install arkandia@arkandia
```

### Opción B — `npx skills` ([skills.sh](https://skills.sh) de Vercel Labs)

Desde tu terminal, en cualquier directorio:

```bash
npx skills add ArkandiaLabs/arkandia-skills
```

El CLI auto-descubre skills en `skills/` y lee el manifiesto `.claude-plugin/marketplace.json`. Flags útiles:

```bash
# Instalar globalmente en vez de en el proyecto actual
npx skills add ArkandiaLabs/arkandia-skills -g

# Apuntar específicamente a Claude Code (el CLI soporta varios agentes)
npx skills add ArkandiaLabs/arkandia-skills -a claude-code

# No interactivo (amigable para CI)
npx skills add ArkandiaLabs/arkandia-skills -y
```

## Uso

Dentro de cualquier repositorio .NET:

```
/arkandia:agent-context-dotnet      # Salida en inglés (default)
/arkandia:agent-context-dotnet es   # Salida en español
```

Para llevar un ticket desde el tracker hasta un PR en verde, mira [Plan → Build](#plan--build) más abajo.

El skill va a:

1. **Descubrir** — lee la solución y cada proyecto: el grafo de referencias y las capas, los target frameworks, la gestión de paquetes (incluyendo `Directory.Packages.props`), la orquestación con Aspire, el acceso a datos con EF Core, la raíz de composición de DI, configuración y secretos, el runner de pruebas que realmente se usa, las puertas de calidad, la superficie de UI/API, cómo se producen las imágenes y binarios, y los docs existentes. Actualizado a .NET 10 / C# 14 — incluyendo los artefactos que un escaneo basado solo en `Dockerfile` o solo en `*.csproj` se pierde, como la publicación de contenedores con el SDK y las apps basadas en archivo.
2. **Entrevistar** — alrededor de diez preguntas, y nunca una que ya pueda responder leyendo el repo: contexto de negocio, reglas no obvias, target de despliegue, ruta a producción, fuente de secretos, modelo de autenticación.
3. **Redactar** — llena plantillas con tus respuestas y los hallazgos del repo; borra las secciones que no aplican en vez de rellenarlas de TODOs.
4. **Conectar** — genera `AGENTS.md` (≤80 líneas, estilo tabla de contenidos) y un `CLAUDE.md` delegador.
5. **Validar afirmaciones** — expone los hechos clave que escribió (framework + versión, persistencia, comandos, entidades principales), cada uno con su fuente y nivel de confianza, y luego confirma o corrige contigo los inciertos. Inspirado en [Claimify](https://arxiv.org/abs/2502.10855) de Microsoft Research. Escribe un registro de auditoría en `docs/claims-ledger.md`.
6. **Verificar** — reporta el árbol de archivos escritos, valida los enlaces.

Si ya existen docs de contexto, el skill entra en **modo aumentar** y propone adiciones en vez de sobrescribir.

## Qué obtienes

```
<tu-repo>/
├── AGENTS.md              # Tabla de contenidos + reglas no obvias
├── CLAUDE.md              # Delegador de una línea a AGENTS.md
└── docs/
    ├── business.md
    ├── architecture.md
    ├── data-model.md
    ├── infrastructure.md
    ├── claims-ledger.md   # qué se verificó vs qué queda pendiente
    ├── dotnet.md          # contexto .NET profundo: grafo de proyectos, TFMs, EF Core, DI
    ├── target-user.md     # opcional
    ├── design.md          # opcional
    └── adrs/
        ├── README.md
        ├── adr-template.md
        └── adr-0001-<slug>.md
```

Cada doc tiene marcadores `<!-- TODO -->` donde aún se requiere input humano. El skill no va a inventar versiones de framework, detalles de esquema, ni contexto de negocio que no pueda verificar — y el paso de validación de afirmaciones te pide confirmar los hechos clave antes de que confíes en ellos.

## Plan → Build

Donde `agent-context-dotnet` *escribe* el contexto de tu repo, los skills de entrega lo *consumen* para entregar un cambio. Dale a uno el id de un ticket y corre hasta un PR en verde:

```
/arkandia:linear-plan-build ABC-123                 # un issue de Linear
/arkandia:linear-plan-build ABC-123 skip-checkpoint # issue de rutina: sin parada de aprobación
/arkandia:ado-plan-build 42                         # un work item de Azure Boards
```

La cadena que corren ambos skills:

1. **Leer el ticket** — el issue o work item, sus subissues/hijos y su discusión. Los requerimientos casi siempre se negocian en los comentarios, no se escriben en un campo.
2. **Interrogarte** — el skill pregunta por las decisiones de diseño que el ticket dejó abiertas: límite del alcance, modelo de datos y migraciones, contrato y cambios que rompen, comportamiento ante fallas, autorización, escala, rollout, profundidad de los tests. Pregunta solo lo que el ticket, el código y tu `AGENTS.md` no responden ya. Las respuestas quedan como **Decisiones**; lo que resolvió por su cuenta queda escrito como **Supuesto**.
3. **Explorar** — despliega subagentes de solo lectura por las costuras propias de tu repo y arma un solo mapa. No asume ninguna arquitectura ni recomienda adoptar una.
4. **Redactar el plan** — pasos pequeños, cada uno con su verificación en los comandos de tu repo; el primer paso es un test que falla.
5. **Revisión adversarial** — tres subagentes critican el plan desde distintos lentes (convenciones, correctitud, alcance) *antes* de escribir código. El lente de alcance ataca específicamente la lista de Supuestos.
6. **Tu aprobación — solo si el cambio lo amerita.** El plan mode se abre para cualquier cosa de más de ~3 pasos o ~3 archivos, o que toque un contrato, un esquema, autorización o dinero, o que se apoye en supuestos, o que sea difícil de revertir. Los cambios pequeños, reversibles y bien especificados imprimen el plan y siguen.
7. **Implementar con tests primero** — RED → GREEN por paso, paralelizando solo donde las ediciones no chocan.
8. **Gates** — resuelve los comandos de gate propios de tu repo (`.claude/gates.sh` → `AGENTS.md` → detección por manifiesto), luego `/code-review`, más `/security-review` cuando el diff toca autorización, secretos o parseo de entrada. Nunca avanza en rojo. Los gates que tu repo no define se reportan como omitidos, no se cuentan en silencio como verdes.
9. **Commit, push y abrir el PR** — agregando solo lo que cambió, con el token de enlace del tracker en el mensaje (`ABC-123`, `AB#42`).
10. **Cuidar el PR hasta el verde** — observa el CI, reintenta una vez un job flaky, arregla las fallas reales en su origen, y luego atiende los comentarios de revisión en ciclo hasta que el PR esté verde y limpio. Se detiene tras tres intentos fallidos sobre el mismo job.
11. **Cerrar** — publica el resumen en el tracker y mueve el ticket a su estado de revisión.

Prerrequisitos: el [servidor MCP de Linear](https://linear.app/docs/mcp) y `gh` para `linear-plan-build`; el servidor MCP de Azure DevOps **o** la CLI `az` con la extensión `azure-devops` para `ado-plan-build` (detecta cuál y te lo dice).

**Lo que están pre-autorizados a hacer, para que decidas si es demasiado:** leer y escribir archivos, correr los comandos de build/test de tu repo, escribir en *el único ticket que están trabajando*, hacer push de su rama y abrir un PR. Nunca hacen merge ni completan un PR, nunca saltan una branch policy, nunca despliegan, y nunca escriben nada más en tu tracker. Omite `skip-checkpoint` y detente en el checkpoint de aprobación si quieres la correa más corta.

A diferencia de los skills de contexto, estos escriben código, no docs — así que no tienen registro de afirmaciones; la correctitud se prueba con la revisión adversarial y el gate real.

### Renombrados en 0.3.0

| Antes | Ahora |
|---|---|
| `plan-and-build` (brief en Markdown, paraba en el commit) | `linear-plan-build` (issue de Linear → PR en verde) |
| `plan-and-build-dotnet` (.NET + Clean Architecture + Azure Boards) | `ado-plan-build` (Azure Boards → PR en verde, agnóstico del stack y de la arquitectura) |

Los nombres viejos desaparecieron, no quedaron como alias. Con ellos cambiaron dos comportamientos: se retiró el camino sin tracker (un brief `.md` o texto en línea) — ambos skills arrancan ahora desde un ticket — y `ado-plan-build` ya no revisa ni sugiere Clean Architecture, gates específicos de `dotnet`, ni ningún patrón arquitectónico con nombre.

## Agradecimientos

- La convención [`agents.md`](https://agents.md).
- *Harness engineering: leveraging Codex in an agent-first world* de OpenAI.
- *Claimify* de Microsoft Research (*Towards Effective Extraction and Evaluation of Factual Claims*, [arXiv:2502.10855](https://arxiv.org/abs/2502.10855)) — la base del paso de validación de afirmaciones.
- Los principios del *Método Arkandia* enseñados en el workshop *Desarrollo Guiado por IA*.

## Licencia

MIT — ver [LICENSE](./LICENSE).
