# `linear-plan-build` y `ado-plan-build`

**[← README](../../README-es.md)** · **[English version →](./plan-build.md)**

Dos skills, un mismo motor. Llevan un ticket desde *léelo* hasta *PR abierto, CI en verde,
comentarios de revisión atendidos, tracker actualizado*, y difieren solo en sus conexiones:
**Linear + GitHub** uno, **Azure Boards + Azure Repos + Pipelines** el otro. Ambos son agnósticos
del stack y no asumen ninguna arquitectura.

Donde [`agent-context-dotnet`](./agent-context-dotnet-es.md) *escribe* el contexto de tu repo,
estos lo *consumen* para entregar un cambio.

```
/arkandia:linear-plan-build ABC-123                 # un issue de Linear
/arkandia:linear-plan-build ABC-123 skip-checkpoint # issue rutinario: sin parada de aprobación
/arkandia:ado-plan-build 42                         # un work item de Azure Boards
```

## La cadena

1. **Leer el ticket** — el issue o work item, sus subissues/hijos, y su discusión. Los requisitos
   casi siempre se negocian en comentarios, no se escriben en un campo.
2. **Interrogarte** — el skill pregunta por las decisiones de diseño que el ticket dejó abiertas:
   límite del alcance, modelo de datos y migraciones, contrato y cambios rompientes, comportamiento
   ante fallos, autenticación, escala, despliegue, profundidad de pruebas. Solo pregunta lo que ni
   el ticket, ni el código, ni tu `AGENTS.md` ya responden. Las respuestas se vuelven
   **Decisiones**; lo que resolvió por su cuenta queda escrito como **Supuesto**.
3. **Explorar** — despliega subagentes de solo lectura por las costuras propias de tu repo y arma
   un solo mapa. No asume ninguna arquitectura ni recomienda ninguna.
4. **Redactar el plan** — pasos pequeños, cada uno con su verificación en los comandos de tu repo;
   el primer paso es un test que falla.
5. **Revisión adversarial** — tres subagentes critican el plan desde lentes distintas
   (convenciones, correctitud, alcance) *antes* de escribir código. La lente de alcance ataca
   específicamente la lista de Supuestos.
6. **Tu aprobación — solo si el cambio lo amerita.** El modo plan se abre para cualquier cosa de
   más de ~3 pasos o ~3 archivos, o que toque un contrato, un esquema, autenticación o dinero, o
   que descanse en supuestos, o que sea difícil de revertir. Los cambios pequeños, reversibles y
   completamente especificados imprimen el plan y siguen.
7. **Implementar, tests primero** — RED → GREEN por paso, paralelizando solo donde las ediciones no
   chocan.
8. **Gates** — resuelve los comandos de gate propios de tu repo (una sección Gates/Commands en
   `CLAUDE.md`/`AGENTS.md` → detección por manifiesto → preguntar), luego `/code-review`, más
   `/security-review` cuando el diff toca autenticación, secretos o parsing de entrada. Nunca
   avanza en rojo. Los gates que tu repo no define se reportan como saltados, no se cuentan en
   verde en silencio.
9. **Commit, push, abrir el PR** — poniendo en el índice solo lo que cambió, con el token de enlace
   del tracker en el mensaje (`ABC-123`, `AB#42`).
10. **Cuidar el PR hasta el verde** — vigilar CI, reintentar una vez un job flaky, arreglar en la
    fuente los fallos reales, y luego atender comentarios de revisión en bucle hasta que el PR esté
    verde y limpio. Se detiene tras tres intentos fallidos sobre el mismo job.
11. **Cerrar** — publicar el resumen en el tracker y mover el ticket a su estado de revisión.

## Prerrequisitos

- `linear-plan-build`: el [servidor MCP de Linear](https://linear.app/docs/mcp) y `gh`.
- `ado-plan-build`: el servidor MCP de Azure DevOps **o** el CLI `az` con la extensión
  `azure-devops`. Detecta cuál tienes y te lo dice.

## Qué están pre-aprobados a hacer

Para que decidas si es demasiado: leer y escribir archivos, correr los comandos de build/test de tu
repo, escribir en *el único ticket que están trabajando*, hacer push de su rama y abrir un PR.

Nunca hacen merge ni completan un PR, nunca se saltan una política de rama, nunca despliegan, y
nunca escriben nada más en tu tracker. Quita `skip-checkpoint` y detente en la parada de aprobación
si quieres la correa más corta.

A diferencia del skill de contexto, estos escriben código, no docs — así que no tienen ledger de
afirmaciones; la correctitud se prueba con la revisión adversarial y con el gate real. Esos gates
son exactamente lo que instala
[`instrument-project-dotnet`](./instrument-project-dotnet-es.md).
