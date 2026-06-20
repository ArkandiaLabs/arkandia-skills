# arkandia-skills

> *La IA no lee tu mente. Lee archivos.*

Una colección de skills para agentes de código de IA, desde Arkandia. Hoy son dos skills: **`agent-context`** genera un paquete de documentación mínimo y bien estructurado (`AGENTS.md`, arquitectura, ADRs, modelo de datos, infraestructura) para cualquier repositorio, y **`agent-context-dotnet`** agrega encima un análisis profundo especializado en .NET. Ambos terminan validando contigo las afirmaciones más importantes que generaron, para reducir alucinaciones. El paquete generado sigue la convención [`agents.md`](https://agents.md) y está dimensionado para que un agente de IA pueda mantenerlo en contexto. Funciona con Claude Code, OpenCode, Codex, Cursor y los demás agentes soportados por [`skills.sh`](https://skills.sh).

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

Dentro de cualquier repositorio:

```
/arkandia:agent-context          # Salida en inglés (default)
/arkandia:agent-context es       # Salida en español
```

Para repositorios .NET, continúa con el especialista (córrelo después de `agent-context`, o por su cuenta):

```
/arkandia:agent-context-dotnet      # Salida en inglés (default)
/arkandia:agent-context-dotnet es   # Salida en español
```

El skill `agent-context` va a:

1. **Descubrir** — escanea el repo buscando lenguaje, framework, persistencia, CI, IaC y docs existentes. Soporta Java (Maven/Gradle/Spring), PHP (Laravel/Symfony/WordPress), Python, Node, Go, Ruby, Rust, .NET, y señales de infra empresarial (Liquibase, Flyway, Jenkins, Azure DevOps, Kubernetes, Terraform). Cuando detecta .NET te remite a `agent-context-dotnet` para un análisis más profundo.
2. **Entrevistar** — pregunta solo lo que no se puede inferir: contexto de negocio, reglas no obvias, docs opcionales.
3. **Redactar** — llena plantillas con tus respuestas y los hallazgos del repo.
4. **Conectar** — genera `AGENTS.md` (≤80 líneas, estilo tabla de contenidos) y `CLAUDE.md` delegador.
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
    ├── dotnet.md          # agregado por agent-context-dotnet (repos .NET)
    ├── target-user.md     # opcional
    ├── design.md          # opcional
    └── adrs/
        ├── README.md
        ├── adr-template.md
        └── adr-0001-<slug>.md
```

Cada doc tiene marcadores `<!-- TODO -->` donde aún se requiere input humano. Los skills no van a inventar versiones de framework, detalles de esquema, ni contexto de negocio que no puedan verificar — y el paso de validación de afirmaciones te pide confirmar los hechos clave antes de que confíes en ellos.

`agent-context-dotnet` funciona mejor junto a `agent-context` (instalar el plugin/repo trae ambos), pero también funciona **por su cuenta**: si no existe un paquete base, produce `docs/dotnet.md` más un `AGENTS.md` mínimo para que el análisis profundo siga siendo accesible.

## Agradecimientos

- La convención [`agents.md`](https://agents.md).
- *Harness engineering: leveraging Codex in an agent-first world* de OpenAI.
- *Claimify* de Microsoft Research (*Towards Effective Extraction and Evaluation of Factual Claims*, [arXiv:2502.10855](https://arxiv.org/abs/2502.10855)) — la base del paso de validación de afirmaciones.
- Los principios del *Método Arkandia* enseñados en el workshop *Desarrollo Guiado por IA*.

## Licencia

MIT — ver [LICENSE](./LICENSE).
