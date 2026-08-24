# `instrument-project-dotnet`

**[← README](../../README-es.md)** · **[English version →](./instrument-project-dotnet.md)**

Donde [`agent-context-dotnet`](./agent-context-dotnet-es.md) le dice al agente qué *es* el repo,
este decide qué se le *permite entregar*. Instala los controles contra los que el agente choca
solo, antes de que un humano lea el diff.

```
/arkandia:instrument-project-dotnet
```

## Los ocho controles

| # | Control | Artefacto | Qué impide |
|---|---------|-----------|------------|
| 1 | Entradas reproducibles | `global.json`, `Directory.Packages.props`, lock files | Que dos máquinas resuelvan distinto SDK o distinto árbol de dependencias |
| 2 | Build estricto | `Directory.Build.props` | Que un warning llegue a `main` |
| 3 | Estilo | `.editorconfig` | Ruido de formato en cada diff |
| 4 | Punto de entrada | `Makefile` | Que nadie sepa cómo se verifica el repo |
| 5 | Shift-left | `lefthook.yml` | Que el error aparezca en el review |
| 6 | Secretos | `gitleaks` | Que una credencial llegue a la historia |
| 7 | Pruebas de arquitectura | Proyecto de arch-tests (ArchUnitNET) | Que se rompa la regla de dependencias en silencio |
| 8 | CI | GitHub Actions o Azure DevOps | Que se salten los gates locales |

## El recorrido

1. **Reconocer** — la solución y el grafo de proyectos, los target frameworks, el framework y el
   runner de tests, la gestión de paquetes, qué controles ya existen, la plataforma de CI, la
   documentación de contexto, y la **arquitectura real**, leída del grafo de `<ProjectReference>` y
   no asumida.
2. **Verificar prerrequisitos** — por sistema operativo, reportando el comando de instalación.
   Nunca instala por ti.
3. **Preguntar solo lo que no pudo inferir** — plataforma de CI, escaneo de secretos, deuda de
   warnings, y las migraciones que tocan todos los `.csproj`.
4. **Aplicar** — adaptando cada plantilla a este repositorio, en orden de dependencia.
5. **Verificar rompiendo** — introducir cada violación, comprobar que el control la atrapa,
   restaurar.
6. **Actualizar la documentación que la instalación invalidó** y reportar.

## Las reglas de arquitectura salen del repo, no de una plantilla

Se derivan de lo que el repositorio ya hace, sea cual sea su forma: por capas, slices verticales,
monolito modular, n-capas o plano. Cada regla candidata se evalúa contra el código actual **antes**
de escribirse:

| Resultado | Qué pasa |
|---|---|
| Pasa | Se vuelve un test |
| Falla en uno o dos tipos | Te pregunta: ¿arreglar el código o saltar la regla? |
| Falla ampliamente | Se vuelve un **hallazgo**, no un test |

Una suite que sale roja al instalar es una propuesta de refactor, no un sensor.

## Lo que no hace

- **Inventar versiones.** El pin del SDK se deriva de lo instalado — la banda de features más baja
  del `major.minor` presente, para que un compañero una banda atrás siga compilando. Los paquetes
  los resuelve NuGet, y las versiones resueltas se te reportan.
- **Sobrescribir un archivo de configuración que no haya leído y fusionado.** Un `global.json`
  existente conserva sus bloques `test` y `msbuild-sdks`.
- **Tocar un `.csproj`** para algo que pueda vivir en `Directory.Build.props`. Las migraciones que
  sí lo exigen — central package management, lock files, centralizar el target framework — se
  ofrecen explícitamente, con el conteo de archivos, nunca como efecto secundario.
- **Reportar éxito con un control en rojo.**
- **Hacer commit.** Los cambios quedan para que los revises.

## Documentación

Instalar ocho controles deja partes de la documentación del repo en falso: una sección de setup sin
`make hooks`, una tabla de prerrequisitos sin `make`, una tabla de controles de calidad que dice
"falta" para algo que acabas de instalar. El skill actualiza lo que existe y reporta lo que falta —
no crea el paquete de documentación, eso es trabajo de `agent-context-dotnet`.

Una sola regla gobierna las ediciones: **cada dato vive en un documento y los demás enlazan.**
Copiar los pasos del CI en tres archivos significa que dos van a estar desactualizados en un mes, y
que un agente que lea la copia vieja va a actuar sobre ella.

## Prerrequisitos

Los verifica y los reporta; nunca los instala:

| Herramienta | macOS | Windows | Linux |
|---|---|---|---|
| [Lefthook](https://lefthook.dev) | `brew install lefthook` | `winget install evilmartians.lefthook` | `go install github.com/evilmartians/lefthook@latest` |
| `make` | viene con Xcode CLT | `winget install ezwinports.make` | viene con la distro |
| [gitleaks](https://gitleaks.io) (si se activa) | `brew install gitleaks` | `winget install gitleaks` | `apt install gitleaks` en Debian trixie+ / Ubuntu 25.04+; si no, el binario del release |

`make` no viene con Windows. El skill expone el comando de `winget` como prerrequisito documentado
en vez de cambiar en silencio a otro task runner — `make check` es la convención en todo el
material de Arkandia.
