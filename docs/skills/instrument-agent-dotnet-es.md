# `instrument-agent-dotnet`

**[← README](../../README-es.md)** · **[English version →](./instrument-agent-dotnet.md)**

Donde [`instrument-project-dotnet`](./instrument-project-dotnet-es.md) instala los controles que
una máquina evalúa sola, este instala la mitad que aplica el **criterio** del equipo: a qué
sistemas puede llegar el agente, qué archivos puede abrir, y qué le pasa a un archivo en el momento
en que se escribe.

```
/arkandia:instrument-agent-dotnet
```

## Dos artefactos, en este orden

| Orden | Artefacto | Qué cambia |
|---|---|---|
| 1 | `.mcp.json` | A qué **llega** el agente — los trackers, la documentación y los datos del equipo, consultados directamente en vez de pegados en el chat |
| 2 | `.claude/settings.json` + `scripts/agent-hooks/*.sh` | Qué **no puede saltarse** — controles que corren haya pensado o no en correrlos |

MCP primero, hooks después. El MCP solo agrega capacidad; los hooks la quitan. Instalar primero la
mitad aditiva significa que, cuando un hook empiece a negar cosas, ya se sabe qué mitad mirar.

## Los siete hooks

**El 1 y el 2 vienen por defecto.** Del 3 al 7 se ofrecen, y el 6 y el 7 solo cuando el repositorio
realmente contiene el artefacto que protegen.

| # | Hook | Evento | Bloquea | Qué evita |
|---|---|---|---|---|
| 1 | Guard de lectura de secretos | `PreToolUse` | **sí** | Que el agente abra un `.env`, una llave privada o `secrets.json` |
| 2 | Formato al editar | `PostToolUse` | no | Turnos gastados en indentación, y ruido de estilo en el diff |
| 3 | Bloqueador de comandos peligrosos | `PreToolUse: Bash` | **sí** | `rm -rf ~`, `sudo`, un force-push a `main`, `dotnet nuget push` |
| 4 | Barrido de dependencias | `SessionStart` | no | Escribir una integración contra un paquete con un aviso vigente |
| 5 | Log de auditoría | `PreToolUse` (async) | no | Que nadie pueda decir qué ejecutó el agente sin supervisión |
| 6 | Guard de versiones de paquete | `PostToolUse` | no | Que un proyecto fije su propia versión y reintroduzca la deriva |
| 7 | Guard de archivos generados | `PreToolUse` | **sí** | Editar a mano `packages.lock.json` o una migración de EF Core |

El hook 1 cierra el círculo con la mitad determinística: gitleaks atrapa una credencial antes de
que llegue a un commit; este la atrapa antes de que el agente la haya leído. Mismo control, dos
momentos, dos motores.

## La ejecución

1. **Descubrir** — la solución, el `.claude/` y el `.mcp.json` existentes, los targets reales del
   Makefile, el formateador, el remote y la rama por defecto, el proveedor de base de datos, y qué
   precondiciones de hooks se cumplen.
2. **Verificar prerequisitos** — por sistema operativo. En Windows el que importa es Git Bash.
3. **Preguntar solo lo que no pudo inferir** — qué servidores, qué hooks, qué ramas proteger, y una
   confirmación explícita para el log de auditoría.
4. **Aplicar** — `.mcp.json`, luego los scripts, luego el registro, fusionando con lo que ya exista.
5. **Disparar cada hook a propósito** — y revertir. Un guard con un patrón roto sale con código 0 y
   se ve exactamente igual que un guard que no encontró nada.
6. **Actualizar la documentación que la instalación invalidó**, y reportar.

## El menú sale del repositorio

Los dos menús. Los hooks 6 y 7 se **ocultan** cuando su artefacto no está, diciendo por qué — sin
Central Package Management, un atributo `Version` es la forma correcta de declarar un paquete, así
que ese hook dispararía en cada `dotnet add package` y el equipo apagaría el conjunto completo.

Los servidores MCP se derivan igual: Azure DevOps desde un `azure-pipelines.yml`, GitHub desde el
remote, DBHub desde la cadena de conexión en el código, Playwright y Chrome DevTools desde un
proyecto web. Microsoft Learn y Context7 se ofrecen en cualquier repo .NET — son la respuesta a un
modelo que escribe una API que cambió de nombre hace dos versiones.

## Lo que no hace

- **Tocar `.claude/settings.local.json`, ni la clave `permissions` en ningún lado.** El archivo
  local es personal y está en el gitignore; los permisos son decisión del usuario. Escribe
  exactamente una clave: `hooks`.
- **Reemplazar un bloque `hooks` o `mcpServers` existente.** Agrega. Dos grupos de matcher en un
  mismo evento disparan los dos, así que casi nunca hay nada que resolver — solo pregunta cuando ya
  hay un handler apuntando a un script con el mismo nombre.
- **Escribir una credencial en `.mcp.json`.** Todo secreto es una referencia `${ENV_VAR}` **sin
  valor por defecto** — `${TOKEN:-}` convertiría "no está definida" en "se pasó un token vacío" — y
  el nombre de la variable va al README. Una ruta específica de la máquina se trata igual:
  `${CLAUDE_PROJECT_DIR}` no sirve en un archivo de proyecto, porque Claude Code la define en el
  entorno del *servidor*, así que siempre cae al valor por defecto `.` y una cadena de conexión de
  SQLite lo rechaza.
- **Fijar una versión.** `npx -y <paquete>`, nunca `<paquete>@1.2.3`.
- **Reportar un hook como funcionando sin haberlo visto negar algo.**

## Dos asimetrías que dice en voz alta

**Los hooks quedan comprobados; los servidores MCP solo quedan escritos.** Un `.mcp.json` recién
escrito deja sus servidores en `⏸ Pending approval` hasta que el usuario confía el workspace — y un
`enableAllProjectMcpServers` commiteado se ignora hasta entonces, así que un repositorio clonado no
puede aprobar sus propios servidores. El reporte dice *escrito, pendiente de aprobación*, con los
dos pasos para activarlos.

**Los scripts son portables; el registro no.** `scripts/agent-hooks/*.sh` es bash puro, escrito
para bash 3.2 y sin `jq`, y corre sin cambios en macOS, Linux y Git Bash. Pero
`.claude/settings.json` es exclusivo de Claude Code — hoy ningún otro agente lo lee, así que en
Codex, Cursor o Copilot estos hooks no corren. El reporte final lo dice, en vez de dejar que te
enteres en otra herramienta.

Y una frase que aparece en todo reporte que produce este skill: **los hooks no son un límite de
seguridad.** Corren con tu shell y tus permisos, y hacen coincidencia de texto, no de intención.
Son una baranda contra un error plausible. Para un límite real, usa reglas de negación de permisos.
