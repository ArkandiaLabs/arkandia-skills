# Plan — construir la skill `spec-build`

**Repo:** `arkandia-skills` · rama `f-planning-skills` · hoy 2026-08-26, debut viernes 2026-08-28.

**Fuentes de verdad:** `~/Downloads/decasa ws - s4 recursos/v3/skill-spec-build-context.md`
(autoritativo), `plan-sesion4.md` (logística), memoria
`spec-build-skill-spec.md` (decisiones cerradas con el usuario). Fixtures reales del demo en
`~/Downloads/decasa ws - s4 recursos/v3/Dev Requirement/`
(`theoffice-requirements-v3.md`/`.pdf`, `theoffice-requirements-notes-v3.md`, `almacen-existencias.csv`).

`theoffice-requirements-notes-v3.md` es la clave de respuestas del facilitador. **No debe copiarse
a este repo ni al del workshop.** Se usa solo para ensayar (Fase 8) y para verificar que la skill
detecta lo que debe detectar.

**Frontera dura: el documento y las notas son oráculo de prueba, nunca contenido de la skill.**
`SKILL.md` y `references/*.md` no mencionan a TheOffice, sillas, ni ningún dato de este caso — sus
instrucciones son genéricas (categorías de ambigüedad, cadena de conversión, bindings por gestor).
Los nombres/números específicos del demo aparecen **solo** en las secciones "Pruebas / calidad" de
cada fase y en la Batería final, igual que un repo .NET real sirve para verificar
`instrument-project-dotnet` sin quedar copiado dentro de la skill. Riesgo a vigilar en las Fases 3 y
5: que las categorías de ambigüedad terminen ajustadas solo a los patrones de este documento
(sobreajuste) en vez de ser categorías genéricas de análisis de requerimientos que este caso
simplemente ilustra bien — de ahí la prueba con fixture no-.NET que se agregó en Fase 3.

**Repo del demo** (`consulting/decasa/ws-decasa-theoffice-prep`): no tocar sin autorización
explícita del usuario — ya quedó así de una sesión anterior. Los ensayos de este plan usan una
copia descartable o piden permiso antes de tocar el repo real.

## Decisiones cerradas que este plan da por hechas

1. Stack-agnóstica desde el diseño (como `linear-plan-build`/`ado-plan-build`).
2. La skill **siempre** pregunta dónde guardar la spec: lo detectado (0, 1 o 2 gestores) +
   "Archivo local", nunca auto-elige aunque solo haya un gestor.
3. Modo archivo, ruta fija: `docs/specs/<slug>/spec.md` + `docs/specs/<slug>/tasks.md`. `<slug>` =
   kebab-case del asunto/título del documento, con el nombre del archivo de entrada como respaldo.
4. Estado inicial de subissues/work items creados: auto-resuelto por **tipo** (igual que
   `plan-build` resuelve in-progress/in-review), nunca preguntado cada vez.
5. Alcance colado (ej. promociones): se detecta y se **pregunta al usuario** si quiere registrarlo
   en el documento (nota en la spec) o en el sistema gestor (item aparte) — no hay default fijo,
   cada caso se decide en el momento.
6. Tareas documentales puras (ej. ADR, declarar contrato): subissue propio, sin código ni pruebas.
7. Esqueleto de fases tipo `instrument-project-dotnet`/`instrument-agent-dotnet` (Discover →
   Prerequisites → Agree on scope → Apply → Verify → Report), no el Step A-J de `build-loop.md`.
8. Nunca hace commit. `anydoc` verificado corriendo local (`npx -y @firecrawl/anydoc --help`,
   sin OCR, exit 0/1/2 documentados).
9. **No se toca `plan-build` ni `references/build-loop.md`.** `spec-build` crea los items de
   trabajo porque `plan-build` no lo hace (contrato de autonomía: solo escribe estado/comentarios
   del ticket que trabaja) — eso no cambia. Ningún archivo bajo `arkandia/skills/linear-plan-build/`
   o `arkandia/skills/ado-plan-build/` se edita en este plan.

## Estructura de archivos objetivo

```
arkandia/skills/spec-build/
  SKILL.md
  references/
    document-conversion.md      # Fase 2
    repo-context-impact.md      # Fase 3
    tracker-bindings.md         # Fase 4
    interview.md                # Fase 5
    verification-and-report.md  # Fase 6
docs/skills/
  spec-build.md
  spec-build-es.md
README.md            (fila nueva en la tabla + sección de la pareja spec-build → plan-build)
README-es.md          (idem)
CHANGELOG.md          (entrada 0.5.0 unreleased)
```

No hay `templates/`: a diferencia de `instrument-*` (que escribe archivos de configuración con
forma fija), el contenido de la spec varía por documento — no hay skeleton que valga la pena
templatizar más allá de los encabezados de sección, que van embebidos en
`references/tracker-bindings.md`.

---

## Fase 0 — Andamiaje

**Actividades**
- Crear `arkandia/skills/spec-build/` y `arkandia/skills/spec-build/references/`.
- Confirmar en `.claude-plugin/marketplace.json` que no hace falta registrar nada a mano — el CLI
  auto-descubre `skills/*` (ya verificado leyendo `README.md` §"El CLI auto-discovers...").
- Decidir y anotar aquí el nombre final de cada `references/*.md` (tabla de arriba) para que las
  fases siguientes no floten.

**Pruebas / calidad**
- `ls arkandia/skills/spec-build/references` muestra los 5 archivos planeados, vacíos o con un
  encabezado `# TODO`.
- `git status` muestra solo archivos nuevos, nada modificado — confirma que no se tocó otra skill
  por accidente.

---

## Fase 1 — `SKILL.md`: frontmatter + esqueleto de fases

**Actividades**
- Frontmatter: `name: spec-build`, `description` (una oración larga, mismo estilo que
  `linear-plan-build`: qué hace, en qué se diferencia de "resumir un Word", con qué se empareja),
  `argument-hint: "<ruta al documento de requerimiento>"`, `disable-model-invocation: true`.
- `allowed-tools`: partir de la lista de `linear-plan-build`/`ado-plan-build` y recortar/ajustar:
  - `Read, Glob, Grep, Write, AskUserQuestion, Agent`
  - `Bash(npx -y @firecrawl/anydoc*)` — **con la versión resuelta y fijada** en el propio comando
    (ver Fase 2), no `npx -y @firecrawl/anydoc` a secas.
  - `Bash(az boards *)`, `Bash(az devops*)`, `Bash(az account show*)`, `Bash(az extension list*)`
    — ruta CLI de Azure DevOps, sin `az repos`/`az pipelines` (spec-build no toca PRs ni pipelines).
  - Los `mcp__linear__*` / `mcp__linear-server__*` y `mcp__azure-devops__*` que Fase 4 confirme
    necesarios — **solo lectura + creación de issues**, nunca los de PR/CI que sí usa `plan-build`.
  - Nada de `git` — esta skill no crea ramas ni hace commits, a diferencia de sus hermanas de
    entrega.
- Escribir la sección **Philosophy** (bullets cortos, estilo `instrument-*`): nunca inventar
  contenido no leído; un hecho, un hogar; resolver el prefijo del gestor en ejecución, no asumirlo;
  decir dónde vas en cada fase; nunca hacer commit; hablar en el idioma del documento de entrada
  para la spec, pero mantener las instrucciones de la skill en inglés (mismo criterio que
  `instrument-*` para "everything you write is in English" — aquí la excepción es más amplia
  porque la salida completa (spec/tasks) es prosa de negocio en el idioma del documento).
- Escribir los encabezados de Fase 1 a 6 con una frase de propósito cada uno y el `references/*.md`
  que cada una consume (tabla "References" al final, como hacen los dos `instrument-*`).
- Escribir una sección **Autonomy contract**, igual que `linear-plan-build`/`ado-plan-build` la
  llevan: qué está pre-autorizado (crear el issue padre y sus subissues/work items, escribir
  `docs/specs/<slug>/`), qué nunca hace (tocar otro issue, mover código, hacer commit), y que
  incluso lo pre-autorizado pasa primero por la pregunta de dónde guardar (decisión 2) — spec-build
  es más consecuente que sus hermanas en este punto porque *crea* items nuevos, no solo actualiza
  uno ya existente.
- Escribir una sección **Rules** (DO / DO NOT) al final, y una tabla de **Troubleshooting** para
  los síntomas ya conocidos de este build (anydoc sin red, MCP en `⏸ Pending approval`, nombre de
  tool de creación no atestiguado) — mismos dos fixtures estructurales que llevan ambos
  `instrument-*`.

**Pruebas / calidad**
- El frontmatter parsea como YAML válido: `python3 -c "import yaml,sys; yaml.safe_load(open('arkandia/skills/spec-build/SKILL.md').read().split('---')[1])"` (o el linter YAML que el repo ya use).
- **Cruce de `allowed-tools` contra el cuerpo real: es la última pasada, no la primera.** Los
  `Bash(...)`/`mcp__...` exactos solo se estabilizan al cerrar las Fases 2-4 (versión fijada de
  `anydoc`, comandos `az` verificados, nombre real de la tool de creación). Repetir este grep en
  cada fase siguiente que toque `allowed-tools`, y darlo por cerrado recién en Fase 6.
- `argument-hint` coincide con lo que Fase 1 del cuerpo describe que hace con `$ARGUMENTS`.
- Comparar longitud/tono de la `description` contra las tres skills hermanas — no debe sonar
  distinta en registro.
- La sección Autonomy contract nombra explícitamente que crear issues nuevos pasa siempre por la
  pregunta de dónde guardar — no la deja implícita.

---

## Fase 2 — Conversión de documentos (`references/document-conversion.md`)

**Actividades**
- Resolver y fijar la versión publicada de `anydoc`: `npm view @firecrawl/anydoc version`, y
  escribir `npx -y @firecrawl/anydoc@<versión>` en el comando que la skill ejecuta — mismo
  criterio "resolver una vez, fijar, reportar" que `instrument-agent-dotnet` aplica a los paquetes
  MCP y `instrument-project-dotnet` a gitleaks. Anotar la versión resuelta en el propio archivo de
  referencia para que sea visible qué se está fijando.
- Documentar la cadena de respaldo obligatoria (§4 del doc de contexto), en este orden:
  1. `npx -y @firecrawl/anydoc@<versión> <archivo> -o <tmp>.md` — capturar exit code.
  2. Exit 1 o salida vacía → `Read` nativo sobre el archivo original (PDF/imagen), máx. 20 páginas
     por llamada; si el documento excede 20 páginas, paginar con llamadas sucesivas y concatenar.
  3. Si tampoco produce contenido usable (protegido con contraseña, corrupto, o el resultado sigue
     vacío) → detener, decir exactamente qué archivo no se pudo leer y por qué, pedir el contenido
     al usuario. **Nunca** inventar.
- Documentar la verificación de adjuntos (requisito obligatorio 2): tras convertir el documento
  principal, extraer toda mención de archivo adjunto del texto (nombres de archivo, "les anexo",
  "la captura de", etc.), verificar con `Glob`/`ls` que exista junto al documento principal, y
  listar los que falten **sin describir su contenido supuesto**.
- Formato de salida: un único modelo de documento (Markdown) sin importar si la entrada fue
  `.pdf`, `.xlsx`, `.docx`, etc. — el resto de la skill nunca debe ramificar por formato de origen.
- **Contenido de la Fase 2 de la skill misma ("Prerequisites"), no solo la conversión:** verificar
  `npx`/node disponible (`npx --version`) y reportar por SO el comando de instalación si falta
  (`brew install node` / `winget install OpenJS.NodeJS` / paquete de la distro) — **nunca instalar
  solo**. Si falta, ofrecer seguir en modo degradado (solo `Read` nativo, sin `anydoc`) en vez de
  bloquear la corrida. Mismo criterio que `instrument-agent-dotnet` Fase 2.

**Pruebas / calidad**
- **Caso feliz real:** correr la cadena contra
  `~/Downloads/decasa ws - s4 recursos/v3/Dev Requirement/theoffice-requirements-v3.pdf` (ruta
  completa — ver cabecera del plan) — confirmar que produce Markdown razonable y que el contenido
  cuadra con `theoffice-requirements-v3.md` (la versión ya convertida, usada como oráculo).
- **CSV real:** correr contra `almacen-existencias.csv` (`--format csv` si hace falta) — confirmar
  filas y columnas legibles.
- **Adjunto faltante:** confirmar que la skill reporta la captura de pantalla mencionada como
  faltante, **sin** inventar su contenido — este es el caso que, si falla, para el demo entero
  (ambigüedad 9 de las notas del facilitador).
- **Fallback OCR:** generar un PDF sintético solo-imagen (ej. `screenshot.pdf` de una captura sin
  texto) y confirmar que `anydoc` sale con exit 1 y que la skill cae al `Read` nativo — y que
  describe lo que ve, marcado como leído visualmente, no como texto extraído.
- **Sin red / anydoc no disponible:** simular fallo de `npx` (sin conexión) y confirmar que la
  skill cae directo al `Read` nativo sin bloquear la corrida, y lo dice en el reporte.
- **Sin `npx`/node instalado:** confirmar que reporta el comando de instalación por SO y ofrece
  continuar en modo degradado, sin instalar nada por su cuenta.
- **PDF protegido con contraseña:** confirmar que llega al paso 3 de la cadena de respaldo —
  detenerse, decir exactamente qué archivo no pudo leer y por qué, pedir el contenido al usuario.
  Este caso lo nombra explícitamente §4 del doc de contexto como límite conocido de `anydoc`.

---

## Fase 3 — Contexto del repo + impacto en consumidores (`references/repo-context-impact.md`)

**Actividades**
- Lectura de contexto: `AGENTS.md`, `CLAUDE.md`, `docs/` (incluyendo ADRs) del repo destino, igual
  que el Step B de `build-loop.md` — sin asumir arquitectura.
- **Detección genérica de contratos públicos** (requisito obligatorio 1, agnóstica de stack):
  OpenAPI/Swagger (`openapi.yaml`, `/openapi/v1.json` si el repo expone un endpoint de
  documentación, controladores/handlers), GraphQL schema, `.proto`, símbolos exportados de un
  paquete/librería. Para cada contrato tocado por el cambio: listar quién lo consume (otros
  proyectos en el mismo repo, clientes generados, `docs/` que los mencionen) y **preguntar
  explícitamente si romper o mantener compatibilidad** — este paso no es condicional a que el
  documento lo mencione.
  **Alcance de este paso: contratos públicos, no "cualquier impacto de negocio"** — eso último ya
  lo cubre el barrido general de la Fase 5. Si el repo **no expone ninguna forma reconocible** de
  contrato público, el paso **no pregunta nada genérico**: reporta "no se detectó contrato público,
  paso omitido" y sigue. Una pregunta sin un contrato concreto que nombrar no es accionable para el
  usuario, y es el mismo criterio que `build-loop.md` usa para un gate que el repo no define — se
  nombra que se omitió, no se inventa un sustituto.
- **Cruce de adjuntos contra datos reales**: si hay un MCP de base de datos disponible (detectado
  por la **forma** de sus tools — `query`/`execute`/`list_tables`-like —, no por nombre fijo como
  `ark_dbhub`), consultar los datos reales relevantes a lo que el documento describe y contrastar
  contra el adjunto. Reportar discrepancias con números concretos, nunca en abstracto.
- Fan-out opcional de subagentes `Explore` (como el Step B de `build-loop.md`) solo si el repo es
  grande — para un contrato o una tabla, hacerlo en línea sin fan-out.

**Pruebas / calidad**
- **Contrato no declarado:** contra un repo .NET fixture (o el propio `theoffice-prep` si el
  usuario autoriza), confirmar que detecta que las acciones devuelven `Task<IActionResult>` sin
  tipo y que el `ProductResponse` no aparece en `components.schemas` — y que **pregunta** romper
  vs. mantener compatibilidad sin que el documento lo haya mencionado (ambigüedad 3, la que
  sostiene el demo).
- **Cruce CSV-BD:** con el MCP de base de datos disponible, confirmar que detecta la discrepancia
  real (25 en catálogo vs. 11 en el archivo de Almacén para la silla) con los números exactos, no
  una afirmación vaga de "hay diferencias".
- **Sin MCP de BD:** confirmar que la skill sigue adelante, dice que no pudo cruzar los datos, y no
  bloquea el resto de la corrida.
- **Repo sin `AGENTS.md`/`docs/`:** confirmar que no falla — infiere lo que pueda del código y lo
  marca como inferencia provisional, igual que hace `build-loop.md` Step B.
- **Repo no-.NET (prueba de la decisión "stack-agnóstica desde ya"):** contra un fixture con
  GraphQL schema o símbolos exportados de un paquete (no OpenAPI, no .NET), confirmar que la
  detección de contrato público igual funciona — sin este caso, la decisión 1 queda sin ninguna
  prueba que la sostenga.

---

## Fase 4 — Bindings de gestor (`references/tracker-bindings.md`)

**Actividades**
- Detección en orden MCP → CLI → ninguno, resolviendo el prefijo real de Linear
  (`mcp__linear__*` / `mcp__linear-server__*`) igual que `linear-plan-build` Fase 0, y la ruta de
  Azure DevOps igual que `ado-plan-build`/`ado-access.md` (MCP, o `az` con la extensión
  `azure-devops` autenticada).
- **Prompt siempre presente**, con `AskUserQuestion`: opciones = exactamente lo detectado (0, 1 o 2
  gestores) + "Archivo local", en ese orden. Nunca se auto-elige.
- Tabla de bindings, calcada del patrón de `build-loop.md` pero para creación en vez de lectura:

  | Binding | Linear | Azure DevOps | Archivo |
  |---|---|---|---|
  | `CREATE-PARENT` | crear issue en el team/proyecto resuelto | crear work item (tipo del proceso: Issue/PBI/User Story) | `docs/specs/<slug>/spec.md` |
  | `CREATE-CHILD` | crear issue con `parentId` | crear work item + `System.Parent` relation | fila en `docs/specs/<slug>/tasks.md` |
  | `LINK-PARENT` | `parentId` al crear | relación `parent` — comando exacto **sin verificar aún**, ver nota abajo | encabezado `## Desglose` enlazando a `spec.md` |
  | `SET-INITIAL-STATUS` | primer estado tipo `unstarted`/backlog vía `list_issue_statuses` | primer estado del proceso resuelto por categoría, no por nombre (ver nota abajo) | N/A — un archivo no tiene estado |

**ADO: no hardcodear el nombre del estado inicial — pero es técnica nueva, no un precedente ya
probado.** ADO tiene tres plantillas de proceso y cada una nombra distinto el estado de "recién
creado, sin arrancar": Basic dice `To Do`, Agile dice `New`, Scrum dice `New` con otro flujo
detrás. La **filosofía** (resolver por categoría, no por nombre) es la misma que
`ado-plan-build` usa para in-progress/in-review, pero la **técnica es distinta y nueva para esta
skill**: `ado-plan-build` solo transiciona el estado de un item que *ya existe* (lee su
`System.State` actual y lo mapea); nunca ha tenido que derivar el listado completo de estados de un
work-item *type* para elegir cuál es el inicial de un item que aún no existe. Construir y probar
esa derivación aquí, no asumirla como "ya resuelta en otro lado".

**Comandos `az` de esta fase: verificar contra `--help` antes de fijarlos, no asumirlos.**
`ado-access.md` deja atestiguados solo dos comandos; todo lo demás en esa tabla está marcado
"discover". El comando correcto para leer los estados de un tipo de work item es
`az boards work-item-type show --type <tipo>` (con guion, no `work-item type`), y **no está** en la
lista atestiguada — verificarlo con `az boards work-item-type show --help` al construir esta fase.
Lo mismo para enlazar `LINK-PARENT`: `az boards work-item relation add --relation-type parent` es
plausible pero **no está verificado** contra `--help` — confirmarlo ahí, no darlo por bueno porque
suena correcto. Aplica también en el camino MCP: listar las tools reales del servidor antes de
llamar nada.

- **No asumir el nombre de la tool de creación.** El precedente de `ado-access.md` aplica igual
  aquí: `save_issue`/`save_comment` (los únicos atestiguados en las skills hermanas) son para
  status/comentarios, no necesariamente para crear. **Listar las tools reales del servidor MCP en
  ejecución antes de llamar nada más allá de lo ya atestiguado**, y usar el nombre real, no uno
  plausible.
- Workspace/team/proyecto de Linear: nunca hardcodeado — el que el caller nombre, el que resuelva
  del contexto, o preguntado si no hay señal (mismo criterio que `ado-plan-build` Fase 1 para
  proyecto de ADO).
- Espacio para decidir: **si el proceso de ADO es Basic** (sin campo de criterios de aceptación,
  como advierte `ado-plan-build` Fase 1), la spec completa va en `System.Description` igual que en
  Linear va en `description` — no se pierde nada, solo cambia dónde vive.
- **Prerequisito de la ruta CLI**: verificar `az` instalado, la extensión `azure-devops` presente,
  y `az account show` exitoso (sesión iniciada) — reportar el comando de instalación/login si falta
  alguno, nunca instalarlo ni autenticar por su cuenta. Mismo contenido que la Fase 2 ("Prerequisites")
  de la skill, aplicado a la ruta ADO.

**Pruebas / calidad**
- **0 gestores:** confirmar que el prompt solo ofrece "Archivo local" y no pregunta nada más
  redundante.
- **1 gestor (Linear o ADO):** confirmar que el prompt igual aparece con esa opción + archivo
  local — el caso que corrige la regla original del doc de contexto.
- **2 gestores:** confirmar que aparecen ambos + archivo local, sin preferencia por orden
  alfabético.
- **Creación real en un espacio de prueba** (Linear sandbox o ADO sandbox, nunca en el espacio del
  demo): confirmar que el subissue queda enlazado al padre, que el estado inicial resuelto por tipo
  es efectivamente uno de tipo backlog/unstarted, y que la skill dice cuál eligió.
- **Modo archivo:** confirmar la ruta exacta `docs/specs/<slug>/spec.md` + `tasks.md`, el `<slug>`
  correcto, y que **no se hace commit**.
- **Comandos `az` verificados:** correr `az boards work-item-type show --help` y
  `az boards work-item relation add --help` (o los que resulten correctos) contra una organización
  de prueba antes de fijarlos en `references/tracker-bindings.md` — no queda ningún comando en el
  archivo final sin haber sido corrido al menos una vez.
- **Sin `az` / sin sesión:** confirmar que reporta el comando de instalación/login y sigue sin
  bloquear — igual que el caso equivalente de Fase 2.

---

## Fase 5 — Entrevista / ambigüedades (`references/interview.md`)

**Actividades**
- Barrido de categorías de ambigüedad (adaptado del Step A de `build-loop.md` a un documento de
  negocio, no un ticket): alcance implícito, contradicciones entre el texto y los adjuntos,
  vacíos de comportamiento (qué pasa cuando..., qué pasa con los que no tienen...), cifras que
  parecen contradecirse, alcance que se cuela en tono casual al final del documento, moneda/unidad
  no declarada.
- Los tres requisitos obligatorios viven aquí, siempre activos, nunca condicionados a que el
  agente "decida mirar":
  1. Impacto en consumidores (viene resuelto desde Fase 3, se convierte en pregunta aquí).
  2. Adjuntos faltantes (viene resuelto desde Fase 2, se reporta aquí, no se pregunta — es un
     hecho, no una decisión del usuario).
  3. Preguntas agrupadas: `AskUserQuestion`, **máximo 4 por llamada**, opción recomendada primero,
     preguntas escritas sin jerga técnica (mismo criterio de `instrument-*` Fase 3 — quien responde
     es alguien de negocio, con más razón aquí que en las skills de instrumentación).
- Alcance colado detectado (ej. promociones): dos preguntas distintas, no una. Primero "¿esto entra
  o va aparte?" (decisión de alcance). Si va aparte, una segunda: "¿lo registro en el documento
  (nota en la spec) o en el sistema gestor (item aparte)?" — sin default fijo, se pregunta cada vez
  (decisión cerrada 5). Puede ir en la misma tanda de `AskUserQuestion` si el conteo de preguntas de
  esa ronda lo permite (máximo 4).
- Registrar el resultado en las mismas dos listas que `build-loop.md` Step A: **Decisiones**
  (citadas, no parafraseadas) y **Asunciones** (lo que se resolvió sin preguntar, por ser menor).
- **Derivar el desglose de tareas a partir de las Decisiones — actividad propia, no un efecto
  colateral de la entrevista.** Con las Decisiones ya cerradas, construir la lista de tareas en
  orden: primero cualquier tarea documental pura (declarar un contrato, escribir un ADR — decisión
  cerrada 6, **subissue propio**, sin código ni pruebas), luego las tareas funcionales que dependen
  de ella. Esta regla no vivía en ningún activity hasta esta revisión — es la que produce el
  `CREATE-CHILD` que la Fase 4 ejecuta.

**Pruebas / calidad**
- **Caso real completo:** correr contra `theoffice-requirements-v3.md` + `almacen-existencias.csv`
  y contar cuántas de las 11 ambigüedades reales el agente detecta sin ver las notas del
  facilitador. Las notas cubren las ambigüedades 3 y 9 con los requisitos obligatorios 1 y 2, así
  que quedan **9** ambigüedades generales (1, 2, 4, 5, 6, 7, 8, 10, 11), no 8. **Piso aceptable: las
  3 obligatorias siempre** (impacto en consumidores, adjunto faltante, agrupación en tandas de 4)
  **más al menos 5 de las 9 restantes**, con una nota de por qué cada una sí o no sale — la 8 no
  destapa ningún problema (es la ambigüedad que enseña que preguntar también vale cuando no
  encuentra nada), y la 10 y la 11 son las dos que las notas marcan como aparecidas por accidente al
  armar el CSV, no puestas a propósito — señal más débil, no exigir que ambas salgan para pasar el
  piso.
- **Desglose derivado correctamente:** confirmar que una tarea documental pura (ej. declarar el
  contrato) sale como su propio item, **antes** que las tareas funcionales que dependen de ella —
  no como nota dentro de la primera tarea de código.
- **Conteo de tandas:** con las ambigüedades que sí salgan, confirmar que se preguntan en grupos de
  ≤4, nunca una por una — con 11 posibles, deben caber en 3 rondas.
- **Jerga:** revisar manualmente el texto de cada pregunta generada — ninguna debe usar un término
  técnico sin explicarlo (contrato, API, endpoint, esquema) porque quien responde es de negocio.
- **Alcance colado:** confirmar que el párrafo de promociones se detecta y se preguntan las dos
  cosas (¿entra? / ¿dónde se registra?) — y que el resultado respeta la respuesta: si el usuario
  eligió documento, termina como nota en la spec; si eligió gestor, termina como item aparte
  (nunca lo decide la skill por su cuenta).

---

## Fase 6 — Verificación y reporte (`references/verification-and-report.md`)

**Actividades**
- Fase 5 de la skill (nombrada "Verify" en el esqueleto de Fase 1): no hay gate que romper, así que
  se **relee lo escrito** — con gestor, volver a consultar el issue padre y sus subissues y
  confirmar `parentId`/`System.Parent` y el estado; en archivo, confirmar que ambos archivos
  existen y que los links entre ellos resuelven.
- Reporte final (paso 8 de §5 del doc de contexto — no confundir con la Fase 8 *de este plan*, que
  es otra cosa): qué se preguntó, qué se respondió,
  qué quedó fuera de alcance, qué no se pudo leer (documento parcial, adjunto faltante, contrato no
  cruzable por falta de MCP de BD, etc.).
- Cierre con una línea "Try it" concreta, igual que hacen `instrument-*`: el comando exacto para
  encadenar con `plan-build` (`/arkandia:linear-plan-build <PADRE>` / `ado-plan-build <id>` / "lee
  `docs/specs/<slug>/`" si cayó a archivo — con la advertencia de que `plan-build` hoy no acepta
  modo archivo como entrada).

**Pruebas / calidad**
- **Relectura con gestor:** provocar a propósito un fallo de enlace (crear el padre, simular que el
  subissue no quedó con `parentId`) y confirmar que la skill lo detecta en esta fase y no reporta
  éxito con un enlace roto.
- **Relectura en archivo:** borrar a propósito un link interno entre `spec.md` y `tasks.md` y
  confirmar que la fase de verificación lo atrapa antes del reporte final.
- **Reporte completo:** confirmar que el reporte final trae las 4 categorías (preguntado /
  respondido / fuera de alcance / no leído) incluso cuando alguna está vacía — decirlo vacío, no
  omitir la sección.

---

## Fase 7 — Documentación de este repo (`arkandia-skills`)

Esta es la fase que cubre **todo lo que hay que generar en este repositorio**, aparte del propio
`SKILL.md` y sus `references/` (ya cubiertos en Fases 1-6).

**Actividades**
1. `docs/skills/spec-build.md` — mismo formato que `docs/skills/plan-build.md`: qué es, dónde
   encaja en la cadena `spec-build → plan-build`, la lista de pasos (calcada de la Fase 1-6 de
   arriba, en prosa para el lector), prerequisitos (`anydoc` vía `npx`, opcionalmente el MCP del
   gestor), y qué NO hace (no crea código, no toca `plan-build`, no hace commit).
2. `docs/skills/spec-build-es.md` — misma estructura, español, con el link cruzado
   `[← README](../../README.md)` / `[English version →]` que ya usan los demás pares.
3. `README.md` — nueva fila en la tabla de skills (mismo estilo de la fila de `plan-build`), y
   actualizar la sección de la cadena `spec-build → plan-build` si el README no la menciona ya
   como diagrama (`/arkandia:spec-build <doc> → /arkandia:linear-plan-build <ISSUE>` del propio
   doc de contexto §1).
4. `README-es.md` — espejo del punto 3.
5. `CHANGELOG.md` — nueva entrada bajo la versión `0.5.0` (confirmado), siguiendo el mismo tono que las entradas de
   `instrument-project-dotnet`/`instrument-agent-dotnet`: qué instala/produce, qué prueba antes de
   reportar éxito, qué asimetría deja (aquí: modo archivo no encadena con `plan-build`).
6. Revisar si `docs/skills/plan-build.md`/`-es.md` necesitan una frase que apunte de vuelta a
   `spec-build` (ya mencionan "Where `agent-context-dotnet` writes... these consume it" — agregar
   la mención simétrica de que `spec-build` es lo que normalmente llena el issue padre que
   `plan-build` consume).
7. **Bump de `arkandia/.claude-plugin/plugin.json`** — `version` a `0.5.0`, coherente con
   `CHANGELOG.md` (cuya cabecera dice explícitamente que las versiones siguen ese campo). Revisar
   también su arreglo `keywords` — falta un término relacionado con specs/requerimientos.

**Pruebas / calidad**
- Todo link interno (`[→ ...]`, `[← README]`) resuelve a un archivo que existe —
  `grep -oE '\]\([^)]+\)' docs/skills/spec-build*.md README*.md` contra `ls`.
- El tono y la extensión de `docs/skills/spec-build.md` calzan con `docs/skills/plan-build.md` —
  comparar longitud de línea y estructura de encabezados.
- `CHANGELOG.md` sigue el formato Keep-a-Changelog que ya usa el archivo (`### Added` con bullets
  en negrita al inicio de cada ítem).
- La fila nueva en `README.md`/`README-es.md` no rompe la tabla Markdown (columnas alineadas,
  mismo número de `|`).
- `arkandia/.claude-plugin/plugin.json` parsea como JSON válido y su `version` coincide con la
  entrada nueva de `CHANGELOG.md`.

---

## Fase 8 — Entrega para ensayo manual

**El usuario ensaya esta fase a mano, no el agente.** Una vez la skill está construida (Fases 0-7),
el trabajo del agente aquí es dejarla lista para correr y dar feedback, no ejecutar la corrida real
contra `ws-decasa-theoffice-prep` ni contra Linear/ADO por su cuenta.

**Actividades**
1. Confirmar que `arkandia/skills/spec-build/` está completo y que `SKILL.md` referencia todos los
   `references/*.md` que existen (sin links rotos, sin fase huérfana).
2. Dejar una copia de los fixtures reales (`theoffice-requirements-v3.pdf`,
   `almacen-existencias.csv`) accesible para el ensayo, sin moverlos de
   `~/Downloads/decasa ws - s4 recursos/v3/Dev Requirement/`.
3. Escribir una guía corta de ensayo (puede vivir al final de este archivo o en un archivo aparte)
   con: el comando exacto a correr, qué se espera ver en cada fase, y la batería de abajo como
   checklist a marcar durante la corrida. Incluir como ítem a vigilar explícitamente: cómo maneja
   `plan-build` una tarea documental pura sin ciclo de pruebas (decisión cerrada 6) — es algo que
   solo un ensayo real contra el gestor puede confirmar.
4. Esperar el feedback del usuario tras su ensayo manual (modo archivo primero, luego con gestor si
   ya está cableado) y aplicar los ajustes que reporte.

**Pruebas / calidad** — la batería de abajo es lo que el usuario marca durante su ensayo manual,
no algo que el agente verifique de antemano.

---

## Batería de pruebas de validación end-to-end

Checklist final, atado a lo que el Demo 1 necesita mostrar (§8 del doc de contexto). Cada fila debe
poder marcarse **con evidencia concreta** (una captura, una línea de log, un archivo escrito), no
"pareció funcionar".

| # | Prueba | Evidencia esperada |
|---|---|---|
| 1 | Convierte el PDF y el CSV sin que el cambio de formato se note en la calidad de la spec | Los 6 productos y sus columnas del CSV aparecen correctamente atribuidos en la spec, verificado fila por fila contra el CSV original |
| 2 | Reporta el adjunto faltante (captura de pantalla) sin describir su contenido | Línea explícita "no se pudo leer / no existe", cero menciones inventadas de lo que mostraría |
| 3 | Lee `AGENTS.md`/`docs/` del repo antes de concluir nada | La spec cita al menos una convención o regla real del repo destino |
| 4 | Pregunta romper vs. mantener compatibilidad **sin que el documento lo mencione** | La pregunta aparece y ninguna parte del documento de entrada la sugiere |
| 5 | Cruza el CSV contra la base real y detecta la discrepancia de la silla (25 vs 11) | Los dos números exactos aparecen en el reporte/spec |
| 6 | Detecta el párrafo de promociones como alcance colado y pregunta si entra, y dónde registrarlo | Dos preguntas explícitas ("¿entra?" / "¿documento o gestor?"), resultado final coincide con lo que el usuario eligió en la segunda |
| 7 | Descubre que el contrato de la API no está declarado y lo vuelve prerrequisito | Task 1 del desglose es "declarar el contrato tipado", antes que cualquier tarea funcional |
| 8 | Pregunta las ambigüedades en tandas de ≤4 | Nunca más de 4 preguntas en una sola llamada de `AskUserQuestion` |
| 9 | Siempre pregunta dónde guardar, incluso con un solo gestor detectado | El prompt aparece aun cuando solo Linear (o solo ADO) esté disponible |
| 10 | Modo archivo escribe exactamente en `docs/specs/<slug>/spec.md` + `tasks.md` | Los dos archivos existen en esa ruta con el slug esperado |
| 11 | Nunca hace commit | `git status` tras la corrida muestra los archivos como *untracked/modified*, no commiteados |
| 12 | El desglose queda listo para que `plan-build` lo tome en una sola corrida | Con gestor: los 4 items son subissues del padre con estado tipo backlog/unstarted |
| 13 | El reporte final trae las 4 categorías (preguntado/respondido/fuera de alcance/no leído) | Las 4 secciones aparecen, incluso vacías cuando corresponda |
| 14 | La cadena completa cabe en ~25 minutos (piso del Demo 1) | Tiempo real cronometrado del ensayo de Fase 8 |
| 15 | Sin `npx`/`az` disponible, guía la instalación en vez de fallar en seco | Comando de instalación por SO en el reporte, corrida sigue en modo degradado |
| 16 | La tarea documental pura (declarar el contrato) queda como subissue propio, antes que las tareas funcionales | Item independiente en el desglose, con dependencia explícita hacia las tareas que lo requieren |

---

## Preguntas sin resolver

Ninguna pendiente. La última —el choque entre la decisión 5 y la clave de respuestas del
facilitador sobre "solicitud aparte" (promociones)— se cerró así: **la skill nunca decide por su
cuenta; detecta el alcance colado y pregunta al usuario si lo registra en el documento (nota en la
spec) o en el sistema gestor (item aparte)**. Reconcilia las dos fuentes sin forzar ninguna
lectura — decisión 5 actualizada arriba, y Fases 5 + Batería fila 6 ajustadas.

Cerradas el 2026-08-26 (primera ronda) y en la doble pasada de revisión (segunda ronda, 16
hallazgos aplicados — ver diffs de esta fecha):

- CHANGELOG: `0.5.0`, confirmado, y propagado al `version` de `plugin.json` (Fase 7).
- Fase 3: sin contrato público reconocible → reporta "paso omitido" y sigue, no pregunta genérico.
- Fase 4: estado inicial en ADO se resuelve por categoría — técnica nueva a construir y probar
  aquí, no un precedente ya resuelto en `ado-plan-build`; comandos `az` marcados "verificar antes de
  fijar", no dados por buenos.
- Fase 5: el desglose de tareas (incluida la regla de tarea documental → subissue propio) ahora
  tiene actividad y prueba propias, y el piso de ambigüedades detectadas se corrigió a 9 restantes.
- Fase 8: el usuario ensaya manualmente contra sus propios fixtures/repo y da feedback; el agente
  no ejecuta la corrida real.
