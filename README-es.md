# arkandia-skills

> *La IA no lee tu mente. Lee archivos.*

Una colección de skills para agentes de código de IA, desde Arkandia, en dos familias.

**Contexto** — **`agent-context-dotnet`** genera un paquete de documentación mínimo y bien estructurado para un repositorio .NET (`AGENTS.md`, arquitectura, ADRs, modelo de datos, infraestructura) más un análisis profundo en `docs/dotnet.md`, y termina validando contigo las afirmaciones más importantes que generó, para reducir alucinaciones. El paquete generado sigue la convención [`agents.md`](https://agents.md) y está dimensionado para que un agente de IA pueda mantenerlo en contexto.

**Entrega** — **`plan-and-build`** lleva un brief de feature pequeña desde *léelo* hasta *implementado, gates en verde, listo para commit* a través de una cadena explícita y enseñable (explorar → planear → revisión adversarial → tu aprobación → construir con tests primero → gates → commit), una fase a la vez, y **`plan-and-build-dotnet`** conecta esa misma cadena con work items de Azure Boards y gates de .NET/Make.

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

Para llevar una feature desde un brief hasta un commit, mira [Plan → Build](#plan--build) más abajo.

El skill va a:

1. **Descubrir** — lee la solución y cada proyecto: el grafo de referencias y las capas, los target frameworks **y si todavía tienen soporte**, la gestión de paquetes (incluyendo `Directory.Packages.props`), la orquestación con Aspire, el acceso a datos con EF Core, la raíz de composición de DI, configuración y secretos, el runner de pruebas que realmente se usa, las puertas de calidad, la superficie de UI/API, cómo se producen las imágenes y binarios, y los docs existentes. Actualizado a .NET 10 / C# 14 — incluyendo los artefactos que un escaneo basado solo en `Dockerfile` o solo en `*.csproj` se pierde, como la publicación de contenedores con el SDK y las apps basadas en archivo.
2. **Entrevistar** — alrededor de diez preguntas, y nunca una que ya pueda responder leyendo el repo: contexto de negocio, reglas no obvias, target de despliegue, fuente de secretos, postura de actualización cuando un framework está cerca del fin de soporte.
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

Donde `agent-context-dotnet` *escribe* el contexto de tu repo, `plan-and-build` lo *consume* para entregar un cambio. Dale un brief corto de la feature — un archivo Markdown o una descripción en línea — y maneja el trabajo **una fase a la vez**, deteniéndose después de cada una para que mantengas el control:

```
/arkandia:plan-and-build "agrega un flag --dry-run al comando de exportación"
/arkandia:plan-and-build docs/briefs/dry-run.md
```

Para repositorios .NET en Azure DevOps, el especialista además acepta un id de work item de Boards y corre gates de .NET/Make (`make check`, `dotnet test`, ArchUnitNET), enlazando el commit de vuelta al item:

```
/arkandia:plan-and-build-dotnet 42        # un work item de Azure Boards
/arkandia:plan-and-build-dotnet docs/briefs/dry-run.md
```

La cadena, cada fase con tu visto bueno:

1. **Leer el brief** — desde un archivo, texto en línea o (en el especialista .NET) un work item de Azure Boards; reformula el objetivo.
2. **Explorar** — despliega subagentes de solo lectura por las áreas que toca la feature y arma un solo mapa; lee tu `AGENTS.md` / `docs/` para conocer las convenciones si existen.
3. **Redactar el plan** — pasos pequeños, cada uno con su propia verificación; el primer paso es un test que falla.
4. **Revisión adversarial** — tres subagentes critican el plan desde distintos lentes (convenciones, correctitud, alcance) *antes* de escribir código.
5. **Tu aprobación** — el plan revisado se somete vía plan mode; no se construye nada hasta que apruebes.
6. **Implementar con tests primero** — RED → GREEN por paso, paralelizando solo donde las ediciones no chocan.
7. **Gates** — corre el comando de gate propio de tu repo más `/code-review`; nunca avances en rojo.
8. **Commit** — agrega solo lo que cambió, referenciando el brief.

A diferencia de los skills de contexto, `plan-and-build` escribe código, no docs — así que no tiene registro de afirmaciones; la correctitud se prueba con la revisión adversarial y el gate real.

## Agradecimientos

- La convención [`agents.md`](https://agents.md).
- *Harness engineering: leveraging Codex in an agent-first world* de OpenAI.
- *Claimify* de Microsoft Research (*Towards Effective Extraction and Evaluation of Factual Claims*, [arXiv:2502.10855](https://arxiv.org/abs/2502.10855)) — la base del paso de validación de afirmaciones.
- Los principios del *Método Arkandia* enseñados en el workshop *Desarrollo Guiado por IA*.

## Licencia

MIT — ver [LICENSE](./LICENSE).
