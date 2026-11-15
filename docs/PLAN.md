# Planning final — Junior Astronaut Mission Trainer

Plan proporcionado por el usuario, normalizado a Markdown. Fecha de inicio: 2026-11-14.

## Repositorio y entorno

Repositorio existente: https://github.com/AlejoHuay/Junior-Astronaut-Mission-Trainer-----GAME.git.
Estado inicial comprobado: main sigue origin/main, único README, commit `26d25ed first commit`, árbol limpio.
Conservar main, remoto e historial. Trabajar en `feat/mission-trainer`, sin push ni merge.
Desarrollo desde VS Code, Godot 4 y GDScript. Instalación indicada posteriormente por el usuario:
`C:\Tools\Godot_v4.7.2-stable_win64.exe`, versión comprobada `4.7.2.stable.official.ed1daf0bf`.
No descargar otro motor. Comprobar plantillas y exportación desde terminal.

## Producto y límites

Juego 2D individual por turnos en Marte, para edades 7–12. Una base, una misión de 7 soles,
duración objetivo 5–10 minutos (requiere prueba con jugadores). Sin cuentas, multijugador,
backend obligatorio, IA en ejecución, consultas API durante partida ni simulación médica.
Mostrar energía, oxígeno y alimentos; refugio, radio y objetivos como estados contextuales.
Cada decisión relevante tendrá costo, riesgo o renuncia y consecuencias inmediatas o diferidas.
Los rendimientos y tiempos acelerados son abstracciones educativas, nunca mediciones reales.

## Arquitectura

Dominio: estado, recursos, reglas y turnos con RefCounted, tipos y enumeraciones.
Aplicación: inicio, acciones, avance, guardado y final; inyección de proveedores.
Infraestructura: JSON, ciencia y almacenamiento. Presentación: escenas, controles, sonido y mensajes.
Dependencias hacia el dominio; dominio sin UI, red o archivos. Señales Observer, máquina de estados
preparación/decisión/resolución/final, adaptadores, DI y configuración JSON validada.
No frameworks innecesarios ni clase por botón. Funciones pequeñas, nombres en inglés, UI en español,
semilla y RNG conservados, orden de resolución explícito, sin dependencias circulares.

Estructura: project.godot, export_presets.cfg, README, AGENTS, .gitignore, .gitattributes,
.editorconfig, .vscode, src/{domain,application,infrastructure,presentation}, scenes/{menus,mission,components},
assets/{graphics,audio,fonts}, data/{balance,events,nasa/{raw,curated}}, tests, scripts,
docs/{PLAN,CHALLENGE,ARCHITECTURE,SCIENCE,DEMO}. Crear solo directorios con contenido útil.

## Ciencia

- DONKI principal: https://ccmc.gsfc.nasa.gov/tools/DONKI/ . Consultar documentación vigente antes de endpoints.
- OSDR: https://osdr.nasa.gov/bio/repo/search?q=&data_source=cgene,alsda,esa&data_type=study . Leer estudio concreto.
- RadLab: https://visualization.osdr.nasa.gov/radlab/gui/data-api/ . Conservar instrumento, cuerpo, trayectoria y nave.
- Archivar original y curado con URL, ID, fechas, unidades, contexto y transformaciones.
- Identificar datos históricos, interpretación educativa y valores de balance.
- No convertir llamaradas en dosis marcianas ni usar mediciones de otro entorno como datos de la base.
- Registrar bloqueos cuando no se pueda verificar; no inventar resultados ni respaldo NASA.

## Ciclo obligatorio de iteración

1. Revisar cambios y definir tarea acotada.
2. Implementar y ejecutar verificaciones pertinentes.
3. Actualizar README y documentación afectada incluso si existe bloqueo.
4. Revisar diff, agregar solo archivos relacionados y crear commit semántico local.
5. Informar resultado, hash y siguiente tarea. No poner en README el hash aún no creado.

README debe cubrir resumen, estado actual/última/próxima tarea, versión exacta y herramientas,
comandos comprobados, arquitectura, funciones completas/parciales/pendientes, verificaciones reales,
ciencia y límites, problemas conocidos y registro por identificador de iteración.
Normalizar finales de línea sin Git global; excluir .godot, herramientas, exportaciones, guardados,
secretos y rutas personales. Versionar escenas, scripts y exportación sin credenciales.

## Fase 1 — Preparación y primera misión jugable

- **F1-01:** inspección, rama, README, AGENTS, PLAN y CHALLENGE con requisitos y fuentes.
- **F1-02:** detectar/fijar Godot; Compatibility, tareas VS Code importar/ejecutar/probar/exportar,
  estilo y exclusiones, web sin hilos, sin rutas personales compartidas; documentar plantillas faltantes.
- **F1-03:** estado, recursos, configuración, acciones y resultados estructurados, orden de turnos,
  semilla reproducible y dominio independiente.
- **F1-04:** inicio/misión/resultado, elección soporte vital o investigación, costos y consecuencias,
  final/reinicio, exportar y probar por HTTP local.

Aceptación: sin errores de scripts, decisión modifica dominio, determinismo, web ejecutable,
README y commits por iteración.

## Fase 2 — Sistemas completos y balance

- **F2-01:** solar/batería limitada, asignación, producción/consumo O2, rechazo explicado,
  vista previa conocida sin revelar incertidumbre.
- **F2-02:** reservas, invernadero con energía y cosecha diferida, interrupción y compresión temporal.
- **F2-03:** refugio/actividad exterior, renuncia a trabajo, mejoras con materiales/trabajo limitados,
  blindaje pasivo sin electricidad propia, sin cálculos clínicos.
- **F2-04:** polvo/avería/alerta solar, solicitudes y consejos diferidos, sin suministros instantáneos,
  efectos pendientes y momento de aplicación.
- **F2-05:** ciencia opcional, finales claros, historial, evitar opción dominante,
  escenarios reproducibles y comparación de estrategias.

Aceptación: cinco sistemas, costo en decisiones, consecuencias inmediatas/diferidas, varias estrategias,
pruebas de recursos, restricciones y orden.

## Fase 3 — Ciencia y presentación educativa

- **F3-01:** documentación DONKI vigente, evento histórico verificable, original/curado,
  adaptador validado, escenario vinculado y transformación documentada.
- **F3-02:** leer OSDR (organismo, condiciones, límites); muestra RadLab (instrumento, ubicación,
  unidades, periodo); explicaciones contextualizadas; pendientes explícitos si no verificable.
- **F3-03:** base 2D con módulos, estados de paneles/refugio/cultivo, animaciones, texto+icono+color,
  controles grandes, foco/teclado, sonido opcional y reducción de movimiento.
- **F3-04:** tutorial por decisiones, términos en contexto, causas de cambios,
  resumen de partida, fuentes y créditos accesibles.

Aceptación: escenario trazable, ciencia/simulación diferenciadas, OSDR/RadLab verificables o pendientes,
información no solo por color, ciclo comprensible sin manual.

## Fase 4 — Persistencia, calidad y entrega

- **F4-01:** guardado por turno versionado con pendientes/RNG, continuar/reiniciar,
  archivos inválidos o almacenamiento indisponible sin bloquear; comprobar persistencia web.
- **F4-02:** pruebas, partidas de semillas conocidas, victoria/fracaso/escasez/diferidos,
  no aplicación doble, continuidad guardado/carga, distribución/teclado/audio/rendimiento.
- **F4-03:** automatizar importación/pruebas/exportación, paquete no versionado, HTTP,
  requisitos de alojamiento, publicar solo con destino autorizado, semilla demo estable.
- **F4-04:** README/arquitectura, procedencia/licencias, guion de 2–3 minutos con costo/consecuencia,
  limitaciones/mejoras y continuidad para otro agente.

Aceptación: ciclo completo en navegador, ciencia archivada sin APIs, persistencia fiel, verificaciones
documentadas, paquete reproducible, errores críticos conocidos registrados.

## Verificación y decisiones de alcance

Automatizar importación, scripts/escenas, pruebas headless, JSON/ciencia, exportación y Git.
Headless no prueba legibilidad ni diversión. Registrar aparte revisión visual y partidas reales en navegador.
Si falta herramienta, registrar y continuar tareas independientes; no declarar fase cerrada.
Propuesta opcional del usuario: introducción narrativa, mapa superior, recursos inferiores y radio.
Se adoptan base/mapa y radio. Se posponen confianza entre países, política y materiales enviados desde
Tierra porque amplían el alcance y pueden distorsionar el retraso de comunicaciones/transporte.
Se conserva Marte como único destino. El texto del desafío y transcripción aportados son contexto
del usuario, no prueba independiente de publicación o corrección científica.
