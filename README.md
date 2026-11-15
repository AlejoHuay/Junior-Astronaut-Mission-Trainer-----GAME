# Junior Astronaut Mission Trainer

Juego educativo 2D individual para edades 7–12: administra una base en Marte durante 7 soles simulados.
Energía, oxígeno y alimentos hacen visibles las renuncias de una misión. Duración objetivo: 5–10 minutos,
pendiente de medir con jugadores. Interfaz en español, sin cuentas ni APIs durante la partida.

## Estado actual

**F4-01 implementada: guardado automático y continuación. Aceptación web pendiente.**
Siguiente tarea: F4-02 a F4-04, revisión automatizada final, paquete ZIP y pitch.
El usuario comprobará persistencia en Edge; sus compañeros harán la revisión final con el ZIP.
Fases 3 y 4 no se declaran aceptadas hasta registrar esos resultados manuales.
El usuario confirmó la revisión solicitada de Fase 2 el 15-11-2026. Es validación manual del
usuario, separada de nuestras pruebas automatizadas. Fases 1 y 2 aceptadas.
Aurora vincula su alerta ficticia con una llamarada histórica DONKI; fuentes disponibles sin red.

Rama `feat/mission-trainer`; main, origin y commit inicial conservados. Sin push ni merge.

## Entorno y ejecución

Godot **4.7.2.stable.official.ed1daf0bf**, instalación existente del usuario, sin descargar otro motor.
VS Code, Git y Python 3.13. Renderer Compatibility; exportación web sin hilos.
Define `$env:GODOT_BIN` en la terminal con tu ejecutable Godot instalado (preferiblemente `_console.exe`).
No hay rutas personales en las tareas compartidas.

Comandos comprobados desde la raíz:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/godot.ps1 import
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/godot.ps1 test
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/godot.ps1 export
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/godot.ps1 verify
python -m http.server 8060 --bind 127.0.0.1 --directory build/web
```

También disponibles en tareas de VS Code. Bypass se aplica solo al proceso de PowerShell.
Abre **http://127.0.0.1:8060/** y recarga con Ctrl+Shift+R. Si el servidor ya está activo, no inicies otro.
Elige escenario y semilla; en cada sol selecciona un plan, revisa sus consecuencias y pulsa ejecutar.
La bitácora se despliega con su botón. Con teclado: Tab, flechas para seleccionar y Enter para activar.

Plantillas locales ignoradas: `.tools/templates/web_nothreads_debug.zip` y `web_nothreads_release.zip`.
En otra máquina descarga las plantillas oficiales **4.7.2** y ejecuta
`python scripts/install_templates.py ruta/al/archivo.tpz`. No usar `web_debug.zip`/`web_release.zip`,
que llevan hilos. Cada exportación ejecuta `python scripts/check_web_export.py build/web` y rechaza
un WASM con memoria compartida. Paquete generado: `build/web`, fuera de Git; no publicado.

## Arquitectura y funcionalidades

Dominio RefCounted sin UI, archivos ni red; aplicación coordina acciones y señales; infraestructura
valida JSON; presentación ofrece controles y explicaciones. Semilla y RNG propios por misión,
órdenes protegidas por sol esperado y guardado versionado validado por reproducción de decisiones.
[Arquitectura](docs/ARCHITECTURE.md) · [Plan](docs/PLAN.md) · [Desafío](docs/CHALLENGE.md).

- Energía: asignaciones, batería limitada, producción solar, excedente y vista previa sin mutaciones.
- Oxígeno: producción y consumo; salidas y traslado al refugio consumen una unidad extra del equipo.
- Comida: reservas iniciales 5, cultivo por dos cuidados consecutivos de 3 energía cada uno,
  cosecha +4 antes del consumo. Interrupción pierde progreso sin reembolso; tiempo ficticio acelerado.
- Protección: refugio ocupa turno; refuerzo gasta 2 materiales y trabajo previo. Blindaje sin gasto eléctrico.
- Radio: consulta cuesta energía y turno; consejo dos soles después, mejora una producción local de oxígeno.
  Sin suministros instantáneos, sin llamadas a internet durante partida.
- Entorno: polvo reduce solar; avería resta producción hasta reparar; alerta solar anunciada un sol antes.
- Misión: tres escenarios, objetivos opcionales de ciencia y muestra exterior, finales específicos,
  resumen basado en historial, reinicio y bitácora. La ciencia opcional no es condición de supervivencia.

- Ciencia: DONKI, OSD-267 y RadLab archivados y comprobados; fuentes dentro del juego.
- Presentación: base 2D original, estados escritos, foco visible, sonido opcional y movimiento reducido.
- Aprendizaje: consejos contextuales, glosario, causas de cambios y resumen ligado a tus decisiones.

Guardado automático al comenzar y tras cada turno válido; el menú ofrece Continuar misión guardada.
Comenzar reemplaza la misión anterior. Se conservan historial, recursos, pendientes y RNG.
Archivos inválidos no bloquean una nueva misión; errores de escritura muestran un aviso.
Pendientes: aceptación visual final y persistencia web real. Preferencias solo durante la sesión.

## Verificación y balance

**684 aserciones aprobadas**, prueba de escenas y controles aprobada, importación y exportación web
sin hilos correctas. La suite cubre restricciones, recursos, cosechas, interrupciones, seguridad,
radio diferida/uso único, determinismo, semilla variable, órdenes duplicadas y prioridad de finales.
La prueba de escena completa la estrategia científica usando selector y botón de ejecución,
comprueba victoria con 5 hallazgos, preferencias, ayuda, fuentes y resumen coherente con el historial.
`python scripts/check_science.py` verifica hashes y correspondencia de los tres archivos científicos.
Persistencia: **631 comprobaciones aprobadas**, continuidad tras cada turno en tres escenarios,
tres semillas y tres secuencias, finales guardados, archivos inválidos y almacenamiento no disponible.
Las pruebas headless no demuestran persistencia del almacenamiento de Edge.
Última verificación: `build/verify-f401-final.txt` (archivo local ignorado).

**48 partidas automatizadas completas:** 4 estrategias × 3 escenarios × 4 semillas.
Resultados de Aurora con semilla 214:

| Estrategia | Energía | Oxígeno | Alimentos | Ciencia | Materiales |
|---|---:|---:|---:|---:|---:|
| Cautelosa | 9 | 7 | 2 | 2 | 2 |
| Científica | 8 | 4 | 2 | 5 | 2 |
| Reforzada | 6 | 6 | 2 | 4 | 0 |
| Radio | 8 | 9 | 2 | 0 | 2 |

Secuencias, costos y límites de estas conclusiones: [BALANCE.md](docs/BALANCE.md).
Más ciencia sacrifica reservas; reforzar gasta materiales; esperar consejo sacrifica ciencia.
Estas pruebas no demuestran diversión, equilibrio óptimo ni duración de 5–10 minutos con niños.

## Revisión manual y problemas conocidos

Confirmados en versiones anteriores: menú en Edge por el agente; ambos finales de Fase 1 y cosecha
5 → 4 → 7 por el usuario; restricciones energéticas F2-01 por el agente. La revisión visual final
de Fase 2 fue confirmada por el usuario el 15-11-2026, tras el bloqueo previo de Computer Use.
Revisión parcial del agente en Edge: módulos, cosecha 5 → 4 → 7, alerta/refugio, foco Tab/Enter,
ayuda y controles de preferencias observados. No constituye aceptación completa de Fase 3.
La comprobación de recarga de F4-01 se detuvo por Escape; persistencia web aún no comprobada.
Se sustituyeron flechas que aparecían como cuadrados; falta confirmación visual de la corrección.
[Pasos de aceptación de Fase 3](docs/PHASE3_REVIEW.md).

Prueba rápida de Aurora/214: **cultivo, cultivo, oxígeno, refugio, ambos, exterior, oxígeno**.
Final esperado: energía 8, oxígeno 4, alimentos 2, ciencia 5 y una muestra exterior.
La estrategia antigua sin cultivar o sin refugio no completa este escenario. Entrenamiento tranquilo
sirve para probar cultivo sin alertas. Radio: consultar en sol 5, observar espera en 6 y consejo en 7.

En ventanas pequeñas puede ser necesario desplazarse; diseño móvil y lectores de pantalla no validados.
No se detectaron errores de scripts en las pruebas actuales. No se hizo auditoría de rendimiento integral.
El bloqueo anterior `SharedArrayBuffer` se corrigió con plantillas sin hilos y se controla automáticamente.
El entorno restringido requiere acceso a cachés normales de Godot para importar sin errores de permisos.

## Datos científicos

[DONKI](https://ccmc.gsfc.nasa.gov/tools/DONKI/),
[OSDR](https://osdr.nasa.gov/bio/repo/search?q=&data_source=cgene,alsda,esa&data_type=study),
[RadLab](https://visualization.osdr.nasa.gov/radlab/gui/data-api/).
DONKI histórico archivado: llamarada X3.9 del 10-05-2024 vinculada con Aurora.
OSD-267: ficha y protocolos de cultivo de lechuga en la ISS; RadLab: DosTel con ubicación y unidades.
[Procedencia y límites](docs/SCIENCE.md). Los efectos del escenario siguen siendo ficticios.
El juego no está avalado por NASA. El balance no representa dosis ni observaciones de Marte.
Cultivo acelerado, oxígeno de traslado y dos soles de radio son abstracciones educativas, no mediciones.

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
| F2-03 | Refugio, refuerzo con 2 materiales y trabajo, salidas con oxígeno extra y parada de seguridad | Suite, escenas y exportación sin hilos pasan; cultivo 5 → 4 → 7 validado por usuario | F2-04: eventos y comunicaciones |
| F2-04 | Catálogo validado de eventos, polvo, avería/reparación, aviso solar y radio con consejo diferido | 284 aserciones; escenas; exportación sin hilos; determinismo y entrega única comprobados | F2-05: objetivos, finales y balance |
| F2-05 | Objetivos opcionales, finales específicos, selector de escenarios/planes y comparación de estrategias | 679 aserciones, 48 partidas y controles/escenas pasan; exportación sin hilos; revisión visual final bloqueada por URL de Edge | Verificación visual pendiente; F3-01: DONKI histórico |
| F3-01 | Archivo DONKI original/curado, adaptador validado, Aurora trazable y fuentes | 684 aserciones, procedencia, escenas y exportación sin hilos pasan | F3-02 |
| F3-02 | Ficha OSD-267 y muestra RadLab DosTel archivadas con contexto, límites y unidades | Tres archivos comprobados, 684 aserciones, escenas y exportación sin hilos pasan | F3-03 |
| F3-03 | Base 2D original, módulos con estados escritos, animación breve, foco, sonido opcional y reducción de movimiento | 684 aserciones, escena y exportación sin hilos pasan; revisión visual pendiente | F3-04 |
| F3-04 | Guía contextual, glosario, causas de recursos y aprendizaje según historial | 684 aserciones, procedencia, escenas, exportación sin hilos y HTTP 200; revisión visual pendiente | Aceptación visual; F4-01 |
| F4-01 | Guardado versionado por turno, continuar, validación por replay y avisos de error; texto sin flechas problemáticas | 684 aserciones de dominio, 631 de persistencia, escenas y exportación; revisión Edge pendiente a cargo del usuario | F4-02: revisión integral y protocolo manual |
