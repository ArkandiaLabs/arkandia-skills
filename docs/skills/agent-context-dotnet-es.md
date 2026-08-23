# `agent-context-dotnet`

**[← README](../../README-es.md)** · **[English version →](./agent-context-dotnet.md)**

Genera un paquete de documentación mínimo y bien estructurado para un repositorio .NET, y termina
validando contigo las afirmaciones más importantes que generó, para reducir alucinaciones. El
paquete sigue la convención [`agents.md`](https://agents.md) y está dimensionado para que un agente
de IA pueda mantenerlo en contexto.

```
/arkandia:agent-context-dotnet      # salida en inglés (por defecto)
/arkandia:agent-context-dotnet es   # salida en español
```

## El recorrido

1. **Descubrir** — lee la solución y cada proyecto: el grafo de referencias y las capas, target
   frameworks, gestión de paquetes (incluido `Directory.Packages.props`), orquestación con Aspire,
   acceso a datos con EF Core, la raíz de composición de DI, configuración y secretos, el runner de
   tests que realmente se usa, los gates de calidad, la superficie de UI/API, cómo se producen
   imágenes y binarios, y la documentación existente. Actualizado a .NET 10 / C# 14 — incluidos los
   artefactos que un escaneo solo de `Dockerfile` o solo de `*.csproj` se pierde, como la
   publicación de contenedores del SDK y las apps basadas en archivo.
2. **Entrevistar** — unas diez preguntas, y nunca una que ya pueda responder desde el repo:
   contexto de negocio, reglas no obvias, destino de despliegue, camino a producción, origen de los
   secretos, modelo de autenticación.
3. **Redactar** — llenar las plantillas con tus respuestas y los hallazgos del repo; borrar las
   secciones que no aplican en vez de rellenarlas con TODOs.
4. **Conectar** — generar `AGENTS.md` (≤80 líneas, estilo tabla de contenidos) y un `CLAUDE.md`
   delegador.
5. **Validar afirmaciones** — exponer los hechos que sostienen el resto (framework + versión,
   persistencia, comandos, entidades clave), cada uno con su fuente y su nivel de confianza, y
   confirmar o corregir contigo los inciertos. Inspirado en
   [Claimify](https://arxiv.org/abs/2502.10855) de Microsoft Research. Deja el rastro en
   `docs/claims-ledger.md`.
6. **Verificar** — reportar el árbol de archivos escritos y revisar los enlaces cruzados.

Si ya existen docs de contexto, el skill entra en **modo aumentar** y propone adiciones en vez de
sobrescribir.

## Qué obtienes

```
<tu-repo>/
├── AGENTS.md              # Tabla de contenidos + reglas no obvias
├── CLAUDE.md              # Delegador de una línea hacia AGENTS.md
└── docs/
    ├── business.md
    ├── architecture.md
    ├── data-model.md
    ├── infrastructure.md
    ├── claims-ledger.md   # qué se verificó vs. qué sigue abierto
    ├── dotnet.md          # contexto .NET profundo: grafo de proyectos, TFMs, EF Core, DI
    ├── target-user.md     # opcional
    ├── design.md          # opcional
    └── adrs/
        ├── README.md
        ├── adr-template.md
        └── adr-0001-<slug>.md
```

Cada doc tiene marcadores `<!-- TODO -->` donde aún se requiere input humano. El skill no va a
inventar versiones de framework, detalles de esquema, ni contexto de negocio que no pueda verificar
— y el paso de validación de afirmaciones te pide confirmar los hechos clave antes de que confíes
en ellos.

## Siguiente paso

Una vez que el repo puede explicarse solo, define qué va a aceptar:
[`instrument-project-dotnet`](./instrument-project-dotnet-es.md).
