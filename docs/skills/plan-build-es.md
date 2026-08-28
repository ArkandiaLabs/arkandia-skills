# `linear-plan-build` y `ado-plan-build`

**[← README](../../README-es.md)** · **[English version →](./plan-build.md)**

Dos skills, un mismo motor. Llevan un ticket desde *léelo* hasta *PR abierto, CI en verde,
comentarios de revisión atendidos, tracker actualizado*, y difieren solo en sus conexiones:
**Linear + GitHub** uno, **Azure Boards + Azure Repos + Pipelines** el otro. Ambos son agnósticos
del stack y no asumen ninguna arquitectura.

Donde [`agent-context-dotnet`](./agent-context-dotnet-es.md) *escribe* el contexto de tu repo,
estos lo *consumen* para entregar un cambio. Y
[`requirement-to-spec`](./requirement-to-spec-es.md) es normalmente lo que llena el issue padre que
estos consumen: por contrato, estos dos nunca crean subissues. Construyen los que les entregas
— y preguntan cuáles de ellos cubre cada ejecución.

```
/arkandia:linear-plan-build ABC-123                 # un issue de Linear
/arkandia:linear-plan-build ABC-123 skip-checkpoint # issue rutinario: sin parada de aprobación
/arkandia:ado-plan-build 42                         # un work item de Azure Boards
```

## La cadena

1. **Leer el ticket** — el issue o work item, sus subissues/hijos, y su discusión. Los requisitos
   casi siempre se negocian en comentarios, no se escriben en un campo.
2. **Elegir la lista de trabajo** — si el ticket tiene subissues, pregunta cuáles cubre esta
   ejecución (*todos* es la opción recomendada). Lo que dejes fuera queda nombrado en el reporte
   final, para que nadie asuma que se entregó. Sin subissues, la lista de trabajo es el ticket
   mismo.
3. **Interrogarte** — el skill pregunta por las decisiones de diseño que el ticket dejó abiertas:
   límite del alcance, modelo de datos y migraciones, contrato y cambios rompientes, comportamiento
   ante fallos, autenticación, escala, despliegue, profundidad de pruebas. Solo pregunta lo que ni
   el ticket, ni el código, ni tu `AGENTS.md` ya responden. Las respuestas se vuelven
   **Decisiones**; lo que resolvió por su cuenta queda escrito como **Supuesto**, cada uno con su
   fuente — `archivo:línea`, `inferido` o `ninguna`. Un supuesto con fuente `ninguna` sobre un
   contrato, un esquema, autenticación o dinero no es un supuesto: es una pregunta que el skill
   tiene que volver a hacerte.
4. **Explorar** — despliega subagentes de solo lectura por las costuras propias de tu repo y arma
   un solo mapa. También reportan los tests que ya cubren los símbolos en juego. No asume ninguna
   arquitectura ni recomienda ninguna.
5. **Decidir qué pasa con los tests que el cambio invalida — antes de escribir código.** Cada test
   existente sobre un símbolo que el cambio toca recibe un veredicto: **actualizar**, en el mismo
   paso que cambia el código; **borrar**, diciendo qué dejó de cubrirse; o **escalar** — porque un
   test que afirma algo que el ticket nunca mencionó significa que o el cambio rompe más de lo que
   alguien dijo, o ese test es el único lugar donde se escribió el requisito. Descubrir esto cuando
   el CI se pone rojo es justo como "el test estorba" termina en aflojarlo.
6. **Redactar el plan** — pasos pequeños, cada uno con su verificación en los comandos de tu repo;
   el primer paso es un test que falla. El plan se escribe en `.claude/plans/<TICKET>.md` y se
   mantiene al día mientras corre el trabajo: una libreta que puedes leer sobre la marcha y que
   sobrevive a una sesión que se cae o se llena. Nunca se pone en el índice ni se commitea por
   iniciativa del skill.
7. **Revisión adversarial** — tres subagentes critican el plan desde lentes distintas
   (convenciones, correctitud, alcance) *antes* de escribir código. La lente de alcance ataca
   específicamente la lista de Supuestos.
8. **Tu aprobación — solo si el cambio lo amerita.** El modo plan se abre para cualquier cosa de
   más de ~3 pasos o ~3 archivos, o que toque un contrato, un esquema, autenticación o dinero, o
   que descanse en supuestos, o que sea difícil de revertir. Los cambios pequeños, reversibles y
   completamente especificados imprimen el plan y siguen.
9. **Implementar, tests primero — un subissue a la vez.** RED → GREEN por paso, con la edición
   delegada a subagentes que reportan qué cambiaron, para que la sesión principal conserve su
   contexto para el plan, los gates y para ti. Paraleliza solo donde las ediciones no chocan; los
   comentarios en el código siguen la densidad y el idioma que ya usa tu repo, no las costumbres
   del agente. Al cerrar cada subissue: pone en el índice solo sus archivos, commitea con el token
   de enlace **de ese subissue**, hace push, lo comenta y **lo mueve al estado de terminado de tu
   equipo** — un hijo implementado, con sus gates en verde y con push hecho está terminado como
   unidad de trabajo. El **padre** es el que queda esperando el PR. Un ticket **sin** subissues es
   su propia lista de trabajo: su clave va en todos los commits, y se deja para que Step J lo mueva
   a revisión en vez de cerrarlo aquí.
10. **Gates** — una sola vez, sobre el diff completo de la rama. Resuelve los comandos de gate
    propios de tu repo (una sección Gates/Commands en `CLAUDE.md`/`AGENTS.md` → detección por
    manifiesto → preguntar), luego `/code-review`, más `/security-review` cuando el diff toca
    autenticación, secretos, parsing de entrada o I/O externo. Nunca avanza en rojo. Los gates que tu repo no
    define se reportan como saltados, no se cuentan en verde en silencio.
11. **Abrir el PR** — uno solo para todo el ticket, listando cada subissue y los comandos de
    verificación realmente ejecutados. **Si algo de la lista de trabajo no se implementó —
    bloqueado, escalado, abandonado — no hay PR:** reporta qué falta y por qué, y deja la rama
    subida para que nada de lo construido se pierda.
12. **Cuidar el PR hasta el verde** — vigilar CI, reintentar una vez un job flaky, arreglar en la
    fuente los fallos reales, y luego atender comentarios de revisión en bucle hasta que el PR esté
    verde y limpio. Se detiene tras tres intentos fallidos sobre el mismo job.
13. **Cerrar** — publicar el resumen en el ticket padre y moverlo a su estado de revisión, donde
    se queda hasta que alguien mergee el PR; preguntar qué hacer con el archivo de plan (borrarlo,
    dejarlo, o moverlo a tu documentación); y reportar qué subissues se construyeron y cuáles
    quedaron fuera de la ejecución.

Durante toda la ejecución se narra a sí mismo en lenguaje sencillo: una línea al abrir y otra al
cerrar cada paso, y cada cambio de estado anunciado cuando ocurre — la rama, cada estado escrito en
el tracker y cuál eligió, cada commit y push, la URL del PR, y la corrida de CI que está
esperando.

## Prerrequisitos

- `linear-plan-build`: el [servidor MCP de Linear](https://linear.app/docs/mcp), más `gh`
  instalado y autenticado contra un `origin` de GitHub. Linear es solo un tracker — no aloja
  código, ni pull requests, ni CI — así que la mitad de código de este skill la pone GitHub. Ambos
  se verifican **antes** de empezar el trabajo, porque un `gh` sin autenticar descubierto a la hora
  del push cuesta una implementación entera averiguarlo.
- `ado-plan-build`: el servidor MCP de Azure DevOps **o** el CLI `az` con la extensión
  `azure-devops`. Detecta cuál tienes y te lo dice.

## Qué están pre-aprobados a hacer

Para que decidas si es demasiado: leer y escribir archivos (incluida la libreta de plan bajo
`.claude/plans/`), correr los comandos de build/test de tu repo, escribir en *el único ticket que
están trabajando* y en los subissues que seleccionaste, hacer push de su rama y abrir un PR para
ella.

Nunca hacen merge ni completan un PR, nunca se saltan una política de rama, nunca despliegan, y
nunca escriben nada más en tu tracker. Quita `skip-checkpoint` y detente en la parada de aprobación
si quieres la correa más corta.

A diferencia del skill de contexto, estos escriben código, no docs — así que no tienen ledger de
afirmaciones; la correctitud se prueba con la revisión adversarial y con el gate real. Esos gates
son exactamente lo que instala
[`instrument-project-dotnet`](./instrument-project-dotnet-es.md).
