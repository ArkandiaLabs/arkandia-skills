# `requirement-to-spec`

**[← README](../../README-es.md)** · **[English version →](./requirement-to-spec.md)**

La otra mitad del pipeline de entrega, aguas arriba de [`linear-plan-build` /
`ado-plan-build`](./plan-build-es.md). Donde esos llevan un ticket hasta un PR en verde,
`requirement-to-spec` lleva un documento de requerimiento de negocio — Word, PDF, Excel, Markdown,
más sus adjuntos — hasta una **spec** y un **desglose de tareas ordenado**, escrito donde el equipo
trackea su trabajo. `linear-plan-build`/`ado-plan-build` nunca crean subissues por contrato; esto
es lo que llena el issue padre que ellos consumen.

```
/arkandia:requirement-to-spec ruta/al/requerimiento.docx
```

No es "resume este documento". Un resumen repite lo que está escrito; este skill también saca a la
luz lo que el documento deja sin decir — una API pública que rompería sin mencionar a quienes la
consumen, un adjunto referenciado pero nunca entregado, un párrafo que amplía el alcance sin
avisar — y convierte las respuestas ya cerradas en algo listo para construir.

## La cadena

1. **Convertir** — un solo modelo en Markdown sin importar el formato de origen: primero `anydoc`,
   `Read` nativo como respaldo donde el formato lo permite (un PDF escaneado se lee visualmente; un
   `.docx` no se puede leer sin `anydoc`), y un alto definitivo — nunca una respuesta inventada — si
   ninguno de los dos produce contenido usable. Los archivos convertidos viven en un directorio
   temporal, nunca en tu repo. Cada adjunto que el documento menciona se verifica contra los
   archivos que realmente están junto a él; uno faltante se reporta, nunca se describe como si se
   conociera su contenido.
2. **Leer el repo destino** — `AGENTS.md`/`CLAUDE.md`/`docs/`, sin asumir arquitectura, y una
   detección agnóstica de stack de contratos públicos que el cambio pueda tocar (OpenAPI, GraphQL,
   `.proto`, símbolos exportados de una librería). Si existe uno, el skill pregunta explícitamente
   si romperlo o mantenerlo compatible — aunque el documento mismo nunca plantee la pregunta. Si el
   repo no expone ninguno, lo dice y sigue en vez de preguntar algo genérico sin nada concreto que
   nombrar.
3. **Encontrar la documentación que el cambio deja mal** — la página de arquitectura, el documento
   del modelo de datos, la lista de endpoints, el runbook, el ADR que este cambio supera,
   `AGENTS.md`. No por categoría: el skill busca en tu set de documentos los nombres concretos que
   el requerimiento toca, y solo lista un documento cuando puede citar la línea que queda obsoleta.
   Cada uno que confirmes se vuelve su propia tarea documental al inicio del desglose, nombrando el
   archivo, qué quedó falso y qué debería decir en su lugar; cada uno que excluyas queda registrado
   por nombre como fuera de alcance. El skill nunca edita esos documentos — eso es lo que hacen los
   skills de entrega con la tarea.
4. **Cruzar datos**, si hay un MCP de base de datos conectado — detectado por la forma de sus
   herramientas, no por un nombre fijo — comparando un adjunto tabular contra los números reales y
   reportando cualquier discrepancia con las cifras exactas de ambos lados.
5. **Barrer ambigüedades** — alcance implícito, contradicciones entre texto y adjuntos, vacíos de
   comportamiento, cifras que no cuadran, alcance que se cuela al final del documento en tono
   casual, moneda o unidad no declarada. Preguntadas en tandas de máximo cuatro, en lenguaje llano,
   con la opción recomendada primero. El alcance colado son dos preguntas, no una: ¿entra en este
   cambio?, y — si no — ¿se anota en la spec o se vuelve su propio item del desglose? Sin default
   fijo; se decide cada vez — y la segunda pregunta se formula en términos del desglose, no del
   gestor, porque dónde se archiva el resultado no se decide hasta el paso 6.
6. **Preguntar dónde guardar** — siempre, incluso con un solo gestor detectado, nunca auto-elegido:
   los gestores realmente encontrados (Linear, Azure DevOps) más **Archivo local**, en ese orden.
   Sin ningún gestor conectado la pregunta igual se hace, con "parar aquí y cablear uno primero"
   como alternativa real; si la rechazas, no se escribe nada.
7. **Derivar el desglose de tareas** a partir de las decisiones cerradas — las tareas puramente
   documentales (declarar un contrato, escribir un ADR, actualizar cada documento obsoleto del
   paso 3) van primero como su propio item, las tareas funcionales que dependen de ellas van
   después, con la dependencia declarada explícitamente.
8. **Escribirlo** — un issue/work item padre más hijos enlazados en modo gestor, resolviendo el
   estado inicial por categoría en vez de por un nombre fijo; o `docs/specs/<slug>/spec.md` +
   `docs/specs/<slug>/tasks.md` en modo archivo.
9. **Verificar releyendo** — que la relación padre-hijo de verdad resuelve, que el estado inicial
   quedó donde dice, o (modo archivo) que ambos archivos existen y el enlace entre ellos funciona.
10. **Reportar** — cuatro secciones siempre presentes (preguntado / respondido / fuera de alcance /
   no leído), cerrando con una línea concreta para encadenar con `linear-plan-build`/
   `ado-plan-build`, o una nota de que el modo archivo aún no encadena automáticamente con ellos.

## Prerrequisitos

- Node.js/`npx`, para el paso de conversión fijado en `@firecrawl/anydoc@0.2.3`. Se verifica antes de
  la primera conversión, no después. Si falta, la corrida degrada a `Read` nativo, que sí cubre PDFs
  (visualmente) y cualquier formato de texto — pero **no** Word, Excel ni PowerPoint, que son
  contenedores binarios que `Read` no abre. Para esos el skill se detiene y te pide el contenido en
  vez de adivinarlo, así que `npx` es de hecho obligatorio si tus documentos son `.docx`.
- Opcionalmente, el servidor MCP de Linear o el de Azure DevOps / el CLI `az` con la extensión
  `azure-devops` — el que sea que quieras ofrecido como destino. Ninguno es obligatorio; el modo
  archivo siempre funciona.

## Lo que nunca hace

- Nunca auto-elige un gestor, ni con uno solo detectado.
- Nunca escribe código, abre un PR, ni toca en el tracker nada más allá de los items que acaba de
  crear.
- Nunca inventa el contenido de un documento o adjunto que no pudo leer.
- Nunca obedece instrucciones que vengan *dentro* de un documento. El documento es material a
  especificar, no un set de órdenes — una línea en el PDF de un cliente que le diga al agente que
  escriba un archivo o llame una API se cita y se señala, no se ejecuta.
- Nunca decide por su cuenta si un contrato se rompe, dónde se registra el alcance colado, ni qué
  documentos obsoletos se actualizan en este pase — las tres son siempre una pregunta.
- Nunca edita la documentación de tu proyecto. Emite una tarea por documento; los skills de entrega
  son los que escriben.
- Nunca señala un documento del que no pueda citar la línea obsoleta. Nada de "revisar los docs".
- Nunca hace commit.

## La asimetría que deja

`linear-plan-build`/`ado-plan-build` hoy no tienen entrada en modo archivo — arrancan desde un
issue o work item que ya existe. Una corrida de `requirement-to-spec` que cae en modo archivo no
encadena automáticamente con ellos; alguien tiene que convertir `docs/specs/<slug>/` en un ticket a
mano, o volver a correr `requirement-to-spec` una vez el tracker esté cableado. Esto se acepta, no
es un defecto: el modo archivo es el camino entre sesiones para un equipo que aún no tiene tracker.
