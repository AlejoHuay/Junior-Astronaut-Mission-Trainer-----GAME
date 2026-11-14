# Junior Astronaut Mission Trainer

Juego educativo 2D para edades 7–12: administra una base en Marte durante 7 soles simulados.
Energía, oxígeno y alimentos hacen visibles las renuncias de una misión. Duración objetivo: 5–10 minutos.

## Estado actual

Fase 1 en curso. Última iteración: **F1-02**. Próxima: **F1-03: nucleo de simulacion**.
Estado de esta iteración: Proyecto Compatibility, tareas VS Code y exportacion web sin hilos. Verificación: Importacion y exportacion release correctas con Godot 4.7.2.
Rama `feat/mission-trainer`; main, origin y commit inicial conservados. Sin push ni merge.

## Entorno y ejecución

Godot **4.7.2.stable.official.ed1daf0bf**, instalación existente indicada por el usuario; versión comprobada
con `--headless --version`. VS Code para edición, Git y Python 3.13 para utilidades.
Proyecto Compatibility creado. Plantilla web release 4.7.2 instalada en `.tools/templates` (ignorada).
Los archivos compartidos usan `GODOT_BIN` o `godot` en PATH. En la terminal de VS Code define
`$env:GODOT_BIN` con la ruta de tu ejecutable instalado, preferiblemente la variante `_console.exe`.

Comandos comprobados desde la raíz:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/godot.ps1 import
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/godot.ps1 export
```

También disponibles como tareas de VS Code. La política Bypass se aplica solo a ese proceso.
Para otra máquina: descargar las plantillas **4.7.2** desde el archivo oficial Godot y ejecutar
`python scripts/install_templates.py ruta/al/archivo.tpz`. El preset usa las dos plantillas locales.

## Arquitectura y funcionalidades

Dominio independiente → aplicación → adaptadores de archivos y presentación Godot.
Completado: inspección, rama y documentación. Pendiente: simulación, interfaz, ciencia archivada,
guardado, pruebas y paquete web. [Plan completo](docs/PLAN.md) · [Desafío](docs/CHALLENGE.md).

## Verificación y problemas conocidos

Comprobados: árbol inicial limpio, main siguiendo origin/main, remoto esperado, `26d25ed first commit`,
Godot 4.7.2 ejecutable. No se ejecutaron pruebas de juego ni navegador.
Una búsqueda inicial no encontró Godot en PATH; el usuario proporcionó después la instalación correcta.
Un intento anterior de descarga falló y no instaló otro motor. Se obtuvo la plantilla web mediante
rangos HTTP del paquete oficial; descarga completa detenida. Importación y exportación release pasan.
En el entorno restringido, Godot necesitó acceso a sus cachés normales; con ese acceso no hubo errores.

## Datos científicos

[DONKI](https://ccmc.gsfc.nasa.gov/tools/DONKI/),
[OSDR](https://osdr.nasa.gov/bio/repo/search?q=&data_source=cgene,alsda,esa&data_type=study),
[RadLab](https://visualization.osdr.nasa.gov/radlab/gui/data-api/).
Aún no se incorporaron registros científicos. No hay respaldo NASA. Los valores del juego serán
abstracciones educativas, nunca dosis clínicas ni observaciones de una base marciana real.

## Registro de iteraciones

| ID | Cambios | Verificación | Siguiente |
|---|---|---|---|
| F1-01 | Rama, README, AGENTS, PLAN y CHALLENGE | Git y versión de Godot comprobados; documentos revisados | F1-02: entorno y exportación |
| F1-02 | Proyecto Compatibility, tareas VS Code y exportacion web sin hilos | Importacion y exportacion release correctas con Godot 4.7.2 | F1-03: nucleo de simulacion |
