# arkandia-skills

> *La IA no lee tu mente. Lee archivos.*

Una colección de skills para agentes de código de IA, desde Arkandia, para un SDLC agéntico. Siguen
un mismo arco: darle al repositorio el **contexto** que el agente necesita para decidir, instalar la
**instrumentación** que no puede saltarse, y **entregar** tickets sobre ambas.

La capa de instrumentación se parte en dos, como en el Método Arkandia. `instrument-project-dotnet`
cubre la mitad **determinística** — lo que la máquina verifica sola, sin ambigüedad: el build, el
estilo, los secretos, las pruebas de arquitectura, el CI. `instrument-agent-dotnet` cubre la mitad
**no determinística** — las herramientas a las que el agente puede llegar y los límites dentro de
los que trabaja, como servidores MCP y hooks.

Funciona con Claude Code, OpenCode, Codex, Cursor y los demás agentes soportados por
[`skills.sh`](https://skills.sh).

**[English version →](./README.md)**

## Por qué

Los agentes de código se portan bien cuando el repositorio les dice lo que necesitan saber, y mal
cuando el contexto crítico vive en la cabeza de alguien, en Slack o en un Google Doc que nadie
abrió. Ese es el primer problema que resuelven estos skills.

El segundo es más nuevo: los agentes ya escriben código más rápido de lo que un equipo puede
revisarlo. La documentación sola no alcanza contra eso — una regla que el agente puede leer es una
sugerencia; una regla que rompe el build es una regla. Así que la verificación tiene que volverse
mecánica, y la revisión humana tiene que reservarse para lo que las máquinas de verdad no pueden
juzgar: intención, diseño, trade-offs, alineación de producto.

El diseño está informado por los escritos de harness engineering de OpenAI (*"AGENTS.md es una
tabla de contenidos, no una enciclopedia"*, *"el repositorio es el sistema de registro"*) y por el
marco del *Método Arkandia* del taller de *Desarrollo Guiado por IA*.

## Skills

| Skill | Qué hace | Docs |
|---|---|---|
| `agent-context-dotnet` | **Contexto** — genera `AGENTS.md`, arquitectura, ADRs, modelo de datos, infraestructura y un análisis profundo en `docs/dotnet.md` para un repo .NET, y valida contigo las afirmaciones que sostienen el resto | [→](./docs/skills/agent-context-dotnet-es.md) |
| `instrument-project-dotnet` | **Instrumentación determinística** — instala los ocho controles contra los que el agente choca solo, en el build, los hooks y el pipeline, y comprueba que cada uno falla antes de reportar éxito | [→](./docs/skills/instrument-project-dotnet-es.md) |
| `instrument-agent-dotnet` | **Instrumentación no determinística** — registra los servidores MCP del equipo y luego instala un catálogo de hooks de Claude Code (guard de lectura de secretos, formato acotado, bloqueador de comandos peligrosos, barrido de avisos, log de auditoría y guards de Central Package Management y archivos generados), disparando cada uno antes de reportar éxito | [→](./docs/skills/instrument-agent-dotnet-es.md) |
| `requirement-to-spec` | **Spec** — convierte un documento de requerimiento de negocio (Word/PDF/Excel/Markdown + adjuntos) en una spec y un desglose de tareas ordenado, escrito en Linear, Azure Boards o un archivo local — siempre preguntando dónde | [→](./docs/skills/requirement-to-spec-es.md) |
| `linear-plan-build` · `ado-plan-build` | **Entrega** — de un ticket a un PR en verde: elegir subissues → interrogar → explorar → planear → revisión adversarial → construir con tests primero, un commit y push por subissue → tus gates → un PR → cuidar el CI. Linear + GitHub, o Azure Boards + Azure Repos + Pipelines | [→](./docs/skills/plan-build-es.md) |

## Instalación

### Opción A — Marketplace nativo de Claude Code (plugin)

Dentro de Claude Code:

```
/plugin marketplace add ArkandiaLabs/arkandia-skills
/plugin install arkandia@arkandia
```

### Opción B — `npx skills` ([skills.sh](https://skills.sh) de Vercel Labs)

Desde tu terminal, en cualquier lado:

```bash
npx skills add ArkandiaLabs/arkandia-skills
```

El CLI descubre los skills en `skills/` y lee el manifiesto `.claude-plugin/marketplace.json`.
Flags útiles:

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
/arkandia:agent-context-dotnet                      # salida en inglés (por defecto)
/arkandia:agent-context-dotnet es                   # salida en español

/arkandia:instrument-project-dotnet      # determinística: los ocho controles
/arkandia:instrument-agent-dotnet        # no determinística: servidores MCP + hooks
```

En cualquier repositorio, sea cual sea el stack — estas cuatro no asumen arquitectura:

```
/arkandia:requirement-to-spec requerimiento.docx     # un documento de requerimiento → spec + desglose

/arkandia:linear-plan-build ABC-123                 # un issue de Linear → PR en verde
/arkandia:linear-plan-build ABC-123 skip-checkpoint # issue rutinario: sin parada de aprobación
/arkandia:ado-plan-build 42                         # un work item de Azure Boards → PR en verde
```

## Los ocho controles

En lo que `instrument-project-dotnet` convierte un repo .NET normal: uno donde un agente
no puede entregar trabajo que viole las reglas del equipo. De cada uno se comprueba que falla antes
de terminar la corrida.

| # | Control | Qué impide |
|---|---------|------------|
| 1 | Entradas reproducibles | Que dos máquinas resuelvan distinto SDK o distinto árbol de dependencias |
| 2 | Build estricto | Que un warning llegue a `main` |
| 3 | Estilo | Ruido de formato en cada diff |
| 4 | Punto de entrada | Que nadie sepa cómo se verifica el repo |
| 5 | Shift-left | Que el error aparezca en el review |
| 6 | Secretos | Que una credencial llegue a la historia |
| 7 | Pruebas de arquitectura | Que se rompa la regla de dependencias en silencio |
| 8 | CI | Que se salten los gates locales |

El control 7 es el que cambia la conversación: la arquitectura que documentaron se vuelve
ejecutable. Las reglas se derivan del propio grafo de referencias del repositorio, y toda regla
tiene que pasar contra el código actual antes de escribirse —
[detalles](./docs/skills/instrument-project-dotnet-es.md).

## Agradecimientos

- La convención [`agents.md`](https://agents.md).
- *Harness engineering: leveraging Codex in an agent-first world*, de OpenAI.
- *Claimify* de Microsoft Research (*Towards Effective Extraction and Evaluation of Factual
  Claims*, [arXiv:2502.10855](https://arxiv.org/abs/2502.10855)) — la base del paso de validación
  de afirmaciones.
- Los principios del *Método Arkandia* que se enseñan en el taller de *Desarrollo Guiado por IA*.

## Changelog

Ver [CHANGELOG.md](./CHANGELOG.md).

## Licencia

MIT — ver [LICENSE](./LICENSE).
