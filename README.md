# Junior Astronaut Mission Trainer

Juego educativo 2D para edades 7–12: administra una base en Marte durante 7 soles simulados.
Energía, oxígeno y alimentos hacen visibles las renuncias de una misión. Duración objetivo: 5–10 minutos.

## Estado actual

**Fase 1 completada; Fase 2 en curso.** Última iteración: **F2-02**, alimentos e invernadero.
Implementación y verificación automatizada completas; **revisión visual de F2-02 pendiente**.
Próxima tarea: comprobar el cultivo en navegador; siguiente implementación: **F2-03: protección y actividad exterior**.
Cinco planes de asignación. Cuidar el cultivo cuesta 3 de energía por sol; dos cuidados consecutivos
entregan 4 alimentos antes del consumo del segundo sol. Otra tarea pierde el progreso sin reembolso.
Reservas iniciales: energía 8, oxígeno 7 y alimentos 5. Al menos una cosecha es necesaria para siete soles.
Importación, **154 aserciones**, prueba de escenas headless, exportación y control del WASM sin hilos pasan.
Estas pruebas se ejecutaron antes de la pausa; al retomar se revisaron los cambios y el registro de escenas,
sin repetir pruebas de código para el cierre documental. La validación manual anterior corresponde
a Fase 1 y F2-01, no a una partida completa de esta nueva versión.
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
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/godot.ps1 verify
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
misión, resultado, reinicio y exportación web; energía y soporte vital de F2-01 e invernadero de F2-02.
Cinco planes definidos en JSON asignan energía a aire, ciencia y cultivo; la bitácora desglosa gasto,
recarga, excedente solar, oxígeno, cosecha, consumo de comida e interrupciones.
Reservar cuesta un sol y reservas aunque no gasta energía. El plan combinado agota la batería si se repite.
Pendiente: revisión visual de F2-02, F2-03 a F2-05, ciencia archivada, presentación Fase 3 y guardado Fase 4.
[Plan completo](docs/PLAN.md) · [Desafío](docs/CHALLENGE.md) · [Arquitectura](docs/ARCHITECTURE.md).

## Verificación y problemas conocidos

Comprobados: árbol inicial limpio, main siguiendo origin/main, remoto esperado, `26d25ed first commit`,
Godot 4.7.2 ejecutable. Ejecutadas 14 aserciones headless: todas pasan, incluyendo siete soles,
determinismo, rechazo atómico y órdenes duplicadas. Importación y exportación release posteriores
a la interfaz también pasan. El usuario completó ambos finales en Edge y confirmó el resultado satisfactorio
del protocolo manual. No se atribuye esta prueba manual al agente ni se afirma una prueba de usabilidad
con niños o una duración de partida medida. En F2-01 se amplió y ejecutó la suite a 112 aserciones:
límites 0–12 de batería, excedente solar, recuperación, producción antes de consumo, escasez,
asignaciones inválidas, vista previa sin mutaciones y coincidencia con resolución. Todas pasan.
La revisión visual F2-01 cubre inicio y tres decisiones en Edge; no se ha validado diseño móvil,
lectores de pantalla, diversión ni balance final. En ventanas pequeñas, bitácora y navegación requieren
desplazamiento vertical; la presentación definitiva sigue prevista en F3-03.
F2-02 amplía la suite a 154 aserciones: cosecha diferida, interrupción sin reembolso, reinicio del ciclo,
rechazo sin mutación, cosecha antes de consumo, escasez y prevención de cosechas duplicadas.
La prueba `tests/smoke_scene.gd`, integrada en la tarea `test`, recorrió menú, cultivo, cosecha,
interrupción, resultado y fuentes sin errores de scripts. Headless no demuestra legibilidad.
El intento de revisión visual F2-02 quedó bloqueado al seleccionar la pestaña de Edge:
Computer Use devolvió `coordinate input geometry is unavailable`. No se registró como prueba aprobada.
Una búsqueda inicial no encontró Godot en PATH; el usuario proporcionó después la instalación correcta.
Un intento anterior de descarga falló y no instaló otro motor. Se obtuvo la plantilla web mediante
rangos HTTP del paquete oficial; descarga completa detenida. Importación y exportación release pasan.
En el entorno restringido, Godot necesitó acceso a sus cachés normales; con ese acceso no hubo errores.
Ambas plantillas web release/debug se descargaron y comprobaron como ZIP íntegros.
El host de automatización de navegador estuvo inicialmente indisponible; el primer intento alternativo
de usar Edge fue detenido por Computer Use al no poder determinar con confianza su URL. Posteriormente
el agente pudo observar el menú inicial en Edge tras corregir la exportación.
Después, la captura del usuario confirmó un bloqueo real: `DataCloneError`, transferencia de
`SharedArrayBuffer` sin `crossOriginIsolated`. Causa: se habían seleccionado plantillas explícitas
con hilos, aunque el preset desactivaba hilos. Corregido en F1-04a usando las variantes `web_nothreads`.
La comprobación nueva rechazó el binario anterior y aceptó el regenerado; HTTP 200 sirve exactamente
el WASM corregido. No se cambiaron cabeceras ni protecciones del navegador.
Referencia técnica: [exportador oficial Godot 4.7.2](https://raw.githubusercontent.com/godotengine/godot/4.7.2-stable/platform/web/export/export_plugin.cpp).
**Fase 1 aceptada con la confirmación manual del usuario. F2-01 verificada; F2-02 verificada en headless.**
Fase 2 sigue abierta: faltan revisión visual de cultivos, protección, eventos, comunicaciones y balance integral.

### Protocolo manual para futuras regresiones

1. En VS Code, define `$env:GODOT_BIN` con tu ejecutable Godot 4.7.2 instalado.
2. Ejecuta `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/godot.ps1 verify`.
3. Ejecuta `python -m http.server 8060 --bind 127.0.0.1 --directory build/web` si no está ya activo.
4. Abre `http://127.0.0.1:8060` en Edge y recarga con **Ctrl+Shift+R** para descartar archivos antiguos.
   Inicia con semilla 214. Para completar la misión con el balance F2-02, elige:
   **cultivo, cultivo, oxígeno, investigar, oxígeno, investigar, oxígeno**.
   Debes terminar con energía 12, oxígeno 8, alimentos 2 y 4 hallazgos. Comprueba resultado, reinicio y fuentes.
5. Reinicia y elige investigar cuatro veces para comprobar el final por agotamiento de oxígeno.
6. Revisa fuentes, regreso al juego, Tab/Enter, textos y controles. Registrar cualquier regresión.
7. Para F2-01, inicia una partida y elige **Repartir entre ambos** dos veces: al sol 3 debes tener
   energía 4, oxígeno 9 y alimentos 3; el plan combinado queda deshabilitado con déficit 2.
8. Elige **Reservar energía**: al sol 4 debes tener energía 8, oxígeno 7, alimentos 2 y 4 hallazgos.
   Compara la vista previa y la bitácora. El flujo energético se comprobó en Edge en F2-01;
   los valores de alimentos de este protocolo corresponden al nuevo balance F2-02.
9. Para comprobar la cosecha, reinicia: el primer cuidado deja alimentos 4 y progreso 1/2;
   el segundo deja alimentos 7 y progreso 0/2. La cosecha suma 4 y el consumo resta 1.
10. Para comprobar interrupción, reinicia y elige cultivo seguido de oxígeno. Antes de cambiar
    debe verse la advertencia; después el progreso debe ser 0/2, alimentos 3 y energía 9.
    Estos casos están probados en headless; su comprobación visual sigue pendiente.

El paquete actual está en `build/web`, excluido de Git. No se publicó en internet.

## Datos científicos

[DONKI](https://ccmc.gsfc.nasa.gov/tools/DONKI/),
[OSDR](https://osdr.nasa.gov/bio/repo/search?q=&data_source=cgene,alsda,esa&data_type=study),
[RadLab](https://visualization.osdr.nasa.gov/radlab/gui/data-api/).
Aún no se incorporaron registros científicos. No hay respaldo NASA. Los valores del juego serán
abstracciones educativas, nunca dosis clínicas ni observaciones de una base marciana real.
Los dos soles de cultivo y la pérdida total de progreso son simplificaciones de juego: no son tiempos
agrícolas observados ni implican que cualquier interrupción real destruya plantas. Véase arquitectura.

## Registro de iteraciones

| ID | Cambios | Verificación | Siguiente |
|---|---|---|---|
| F1-01 | Rama, README, AGENTS, PLAN y CHALLENGE | Git y versión de Godot comprobados; documentos revisados | F1-02: entorno y exportación |
| F1-02 | Proyecto Compatibility, tareas VS Code y exportacion web sin hilos | Importacion y exportacion release correctas con Godot 4.7.2 | F1-03: nucleo de simulacion |
| F1-03 | Dominio tipado, acciones atomicas y balance validado | 14 aserciones headless pasan; determinismo, siete soles y rechazo sin cambios | F1-04: recorrido jugable |
| F1-04 | Inicio, decisiones, bitacora, final y reinicio; revision visual bloqueada | Importacion, 14 aserciones y exportacion correctas; Computer Use no pudo verificar URL de Edge | Validar recorrido web F1-04; despues F2-01 |
| F1-04a | Plantillas web sin hilos; instalador corregido y control automático del WASM | Binario anterior rechazado; regenerado aceptado; 14 aserciones, importación, inicio headless y HTTP pasan | Confirmar arranque y recorrido en Edge; después F2-01 |
| F1-04b | Verificación visual posterior a la corrección | Edge sale de la carga y muestra el menú inicial; observado mediante Computer Use | Recorrido completo de siete soles en navegador; después F2-01 |
| F1-04c | Cierre documental de Fase 1 | Usuario confirma ambos finales en Edge y protocolo satisfactorio; sin nuevas pruebas de código | F2-01: energía y soporte vital |
| F2-01 | Asignaciones aire/ciencia, plan combinado y reserva, presupuesto previo, excedente solar y bitácora desglosada | 112 aserciones; importación/exportación sin hilos; tres decisiones verificadas en Edge con escasez y recuperación | F2-02: alimentos e invernadero |
| F2-02 | Cultivo con costo, cosecha diferida, interrupción, reservas iniciales 5 y compresión temporal documentada | 154 aserciones y prueba de escenas pasan; importación/exportación sin hilos; revisión visual bloqueada por geometría de Computer Use | Revisar cultivo en navegador; F2-03: protección y actividad exterior |
