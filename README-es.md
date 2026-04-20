# agent-context

> *La IA no lee tu mente. Lee archivos.*

Un plugin de Claude Code que genera un paquete de documentación mínimo y bien estructurado — `AGENTS.md`, arquitectura, ADRs, modelo de datos, infraestructura — para cualquier repositorio. El paquete generado sigue la convención [`agents.md`](https://agents.md) y está dimensionado para que un agente de IA pueda mantenerlo en contexto.

**[English version →](./README.md)**

## Por qué

Los agentes de código se portan bien cuando el repositorio les dice lo que necesitan saber. Se pierden cuando el contexto crítico vive en la cabeza de alguien, en Slack, o en un Google Doc que nadie leyó. Este plugin te guía para producir el paquete de contexto mínimo viable, para que un agente pueda razonar sobre tu codebase desde el primer día.

El diseño está informado por el artículo de *harness engineering* de OpenAI (*"AGENTS.md es una tabla de contenidos, no una enciclopedia"*, *"el repositorio es el sistema de registro"*) y por el *Método Arkandia* del workshop *Desarrollo Guiado por IA*.

## Instalación

### Opción A — Marketplace nativo de Claude Code

Dentro de Claude Code:

```
/plugin marketplace add ArkandiaLabs/agent-context-plugin
/plugin install agent-context@agent-context
```

### Opción B — `npx skills` ([skills.sh](https://skills.sh) de Vercel Labs)

Desde tu terminal, en cualquier directorio:

```bash
npx skills add ArkandiaLabs/agent-context-plugin
```

El CLI auto-descubre skills en `skills/` y lee el manifiesto `.claude-plugin/marketplace.json`. Flags útiles:

```bash
# Instalar globalmente en vez de en el proyecto actual
npx skills add ArkandiaLabs/agent-context-plugin -g

# Apuntar específicamente a Claude Code (el CLI soporta varios agentes)
npx skills add ArkandiaLabs/agent-context-plugin -a claude-code

# No interactivo (amigable para CI)
npx skills add ArkandiaLabs/agent-context-plugin -y
```

## Uso

Dentro de cualquier repositorio:

```
/agent-context          # Salida en inglés (default)
/agent-context es       # Salida en español
```

El skill va a:

1. **Descubrir** — escanea el repo buscando lenguaje, framework, persistencia, CI, IaC y docs existentes. Soporta Java (Maven/Gradle/Spring), .NET (ASP.NET Core/EF Core), PHP (Laravel/Symfony/WordPress), Python, Node, Go, Ruby, Rust, y señales de infra empresarial (Liquibase, Flyway, Jenkins, Azure DevOps, Kubernetes, Terraform).
2. **Entrevistar** — pregunta solo lo que no se puede inferir: contexto de negocio, reglas no obvias, docs opcionales.
3. **Redactar** — llena plantillas con tus respuestas y los hallazgos del repo.
4. **Conectar** — genera `AGENTS.md` (≤80 líneas, estilo tabla de contenidos) y `CLAUDE.md` delegador.
5. **Verificar** — reporta el árbol de archivos escritos, valida los enlaces.

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
    ├── target-user.md     # opcional
    ├── design.md          # opcional
    └── adrs/
        ├── README.md
        ├── adr-template.md
        └── adr-0001-<slug>.md
```

Cada doc tiene marcadores `<!-- TODO -->` donde aún se requiere input humano. El skill no va a inventar versiones de framework, detalles de esquema, ni contexto de negocio que no pueda verificar.

## Agradecimientos

- La convención [`agents.md`](https://agents.md).
- *Harness engineering: leveraging Codex in an agent-first world* de OpenAI.
- Los principios del *Método Arkandia* enseñados en el workshop *Desarrollo Guiado por IA*.

## Licencia

MIT — ver [LICENSE](./LICENSE).
