# Junior Astronaut Mission Trainer

Juego educativo 2D para edades 7–12: administra una base en Marte durante 7 soles simulados.
Energía, oxígeno y alimentos hacen visibles las renuncias de una misión. Duración objetivo: 5–10 minutos.

## Estado actual

Fase 1 en curso. Última iteración: **F1-04a**, corrección de plantillas web. Próxima: **Validar recorrido web F1-04; después F2-01**.
Exportación regenerada con plantilla `web_nothreads_release.zip`. Importación, 14 aserciones,
inicio de escena headless y comprobación de memoria WebAssembly pasan. **Arranque visual confirmado en Edge**:
tras recargar se muestra el menú «Tu primera base. Un gran reto en Marte.», semilla 214 y botón Comenzar misión.
Pendiente comprobar el recorrido completo de siete soles en navegador.
Rama `feat/mission-trainer`; main, origin y commit inicial conservados. Sin push ni merge.

## Entorno y ejecución

Godot **4.7.2.stable.official.ed1daf0bf**, instalación existente indicada por el usuario; versión comprobada
con `--headless --version`. VS Code para edición, Git y Python 3.13 para utilidades.
Proyecto Compatibility creado. Plantilla web sin hilos 4.7.2 instalada en `.tools/templates` (ignorada).
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
Deben ser `web_nothreads_debug.zip` y `web_nothreads_release.zip`: las variantes `web_debug.zip`
y `web_release.zip` llevan hilos. La exportación comprueba ahora la memoria del binario WebAssembly
con `python scripts/check_web_export.py build/web`; falla si requiere memoria compartida.

## Arquitectura y funcionalidades

Dominio independiente → aplicación → adaptadores de archivos y presentación Godot.
Completado: inspección, rama, documentación, proyecto Compatibility, núcleo determinista, inicio,
misión con dos acciones, resultado, reinicio y exportación web. Parcial: recorrido mínimo sin revisión
visual en navegador. Pendiente: sistemas Fase 2, ciencia archivada, presentación Fase 3 y guardado Fase 4.
[Plan completo](docs/PLAN.md) · [Desafío](docs/CHALLENGE.md) · [Arquitectura](docs/ARCHITECTURE.md).

## Verificación y problemas conocidos

Comprobados: árbol inicial limpio, main siguiendo origin/main, remoto esperado, `26d25ed first commit`,
Godot 4.7.2 ejecutable. Ejecutadas 14 aserciones headless: todas pasan, incluyendo siete soles,
determinismo, rechazo atómico y órdenes duplicadas. Importación y exportación release posteriores
a la interfaz también pasan. No se completó una partida visual en navegador.
Una búsqueda inicial no encontró Godot en PATH; el usuario proporcionó después la instalación correcta.
Un intento anterior de descarga falló y no instaló otro motor. Se obtuvo la plantilla web mediante
rangos HTTP del paquete oficial; descarga completa detenida. Importación y exportación release pasan.
En el entorno restringido, Godot necesitó acceso a sus cachés normales; con ese acceso no hubo errores.
Ambas plantillas web release/debug se descargaron y comprobaron como ZIP íntegros.
El host de automatización de navegador no está disponible; el intento alternativo de usar Edge
fue detenido por Computer Use al no poder determinar con confianza su URL.
Después, la captura del usuario confirmó un bloqueo real: `DataCloneError`, transferencia de
`SharedArrayBuffer` sin `crossOriginIsolated`. Causa: se habían seleccionado plantillas explícitas
con hilos, aunque el preset desactivaba hilos. Corregido en F1-04a usando las variantes `web_nothreads`.
La comprobación nueva rechazó el binario anterior y aceptó el regenerado; HTTP 200 sirve exactamente
el WASM corregido. No se cambiaron cabeceras ni protecciones del navegador.
Referencia técnica: [exportador oficial Godot 4.7.2](https://raw.githubusercontent.com/godotengine/godot/4.7.2-stable/platform/web/export/export_plugin.cpp).
**Fase 1 pendiente de aceptación visual**, y Fases 2–4 aún no implementadas.

### Comprobación manual pendiente

1. En VS Code, define `$env:GODOT_BIN` con tu ejecutable Godot 4.7.2 instalado.
2. Ejecuta `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/godot.ps1 verify`.
3. Ejecuta `python -m http.server 8060 --bind 127.0.0.1 --directory build/web` si no está ya activo.
4. Abre `http://127.0.0.1:8060` en Edge y recarga con **Ctrl+Shift+R** para descartar archivos antiguos.
   Inicia con semilla 214 y alterna renovar oxígeno / investigar
   durante siete soles, comenzando y terminando con oxígeno. Comprueba resultado, reinicio y fuentes.
5. Revisa Tab/Enter, textos y controles. Registrar el resultado antes de cerrar Fase 1.

El paquete actual está en `build/web`, excluido de Git. No se publicó en internet.

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
| F1-03 | Dominio tipado, acciones atomicas y balance validado | 14 aserciones headless pasan; determinismo, siete soles y rechazo sin cambios | F1-04: recorrido jugable |
| F1-04 | Inicio, decisiones, bitacora, final y reinicio; revision visual bloqueada | Importacion, 14 aserciones y exportacion correctas; Computer Use no pudo verificar URL de Edge | Validar recorrido web F1-04; despues F2-01 |
| F1-04a | Plantillas web sin hilos; instalador corregido y control automático del WASM | Binario anterior rechazado; regenerado aceptado; 14 aserciones, importación, inicio headless y HTTP pasan | Confirmar arranque y recorrido en Edge; después F2-01 |
| F1-04b | Verificación visual posterior a la corrección | Edge sale de la carga y muestra el menú inicial; observado mediante Computer Use | Recorrido completo de siete soles en navegador; después F2-01 |
