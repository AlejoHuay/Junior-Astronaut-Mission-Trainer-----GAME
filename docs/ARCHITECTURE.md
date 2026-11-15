# Arquitectura y reglas

## Persistencia (F4-01)

`MissionStore`, inyectado en `MissionSession`, escribe `user://mission.save` como JSON versión 1.
Escribe primero un temporal, comprueba escritura y lo renombra. Un error se muestra sin detener
la simulación. Guarda al iniciar y tras cada acción válida; no guarda selecciones ni órdenes rechazadas.
El snapshot incluye pendientes, cultivo, historial, final y cadenas decimales de semilla/RNG de 64 bits.
Al cargar, la aplicación reproduce hasta siete acciones con las reglas actuales y compara todo el
snapshot normalizado como JSON; solo entonces sustituye la misión. Rechaza esquemas incompatibles,
estados alterados y archivos mayores de 256 KiB. Cambiar el balance puede invalidar guardados antiguos.
No es un sistema de autenticación; evita estados inválidos. Las pruebas usan un archivo separado.

En web la persistencia depende del almacenamiento del navegador para ese origen. Sigue pendiente
verificar recarga y cierre/reapertura en Edge; escribir al filesystem de Godot no demuestra por sí
solo persistencia durable en el navegador. No cambiar host/puerto durante la prueba. Las preferencias
son de sesión. No hay sincronización entre dispositivos, exportación de guardados ni migraciones.

`MissionState` y `MissionRules` son RefCounted del dominio, sin archivos, red o UI.
`GameData` valida y lee JSON en infraestructura. La aplicación coordina reglas/proveedores
y emite señales; la presentación no modifica directamente los recursos.

## Orden de resolución (F2-02)

1. Validar fase, identificador de sol esperado, acción y recursos; rechazo sin mutación.
2. Calcular presupuesto conocido sin mutar estado ni RNG. Sumar asignaciones de soporte vital, ciencia e invernadero;
   comprobar que la batería actual cubre el trabajo antes de cualquier recarga.
3. Entrar en resolución; cobrar acción, aplicar oxígeno/ciencia.
4. Avanzar cultivo con energía al invernadero; sin ella, perder el progreso. Al completar el ciclo,
   sumar cosecha y reiniciar progreso. Después consumir oxígeno y comida; recargar batería limitada.
   Registrar producción solar almacenada
   y excedente que no cabe. Recursos agotados se limitan a cero.
5. Comprobar escasez antes de victoria; registrar diferencias y presupuesto desglosado, terminar o avanzar sol.

La vista previa y la resolución comparten el presupuesto del dominio. La vista previa no consume
turnos ni cambia semilla, RNG o historial. En F2-01 todos los efectos son conocidos; cuando se añadan
eventos inciertos no deberán anticiparse tiradas ni mostrarse resultados futuros como certezas.

Cada acción JSON define `allocation.life_support`, `allocation.science` y `allocation.greenhouse`; su suma es el costo,
sin un segundo campo duplicado. Planes discretos para evitar sobrecargar a niños con deslizadores:
aire 4/0, ciencia 0/3, ambos 3/3, reserva 0/0. El plan combinado consume seis y solo recupera cuatro,
de modo que repetirlo reduce la batería. Reservar no produce oxígeno ni ciencia, consume reservas
y ocupa el sol. Siempre está disponible durante decisión, incluso con batería vacía.
El adaptador valida enteros, límites, sistemas requeridos, producción con asignación positiva
y recuperación gratuita sin producción. Costos y rendimientos son unidades educativas de balance.

Los números son unidades de juego. Semilla y estado RNG se conservan como cadenas decimales
en snapshots para evitar pérdida de precisión de enteros de 64 bits al serializar JSON.
El identificador de turno evita aplicar dos veces una orden retrasada.

## Cultivos y abstracción educativa

F2-02 empieza con 5 alimentos: siete soles consumen 7, por lo que hace falta al menos una cosecha.
`crop_turns=2` y `harvest_food=4` son balance ficticio. Cuidar consume 3 de energía y un sol de trabajo,
sin oxígeno ni ciencia producidos. Dos cuidados consecutivos entregan 4 alimentos antes del consumo
del segundo sol. El primer cuidado no entrega comida. Después se puede iniciar un nuevo ciclo.
Otra acción durante un cultivo pierde el progreso, sin reembolso de energía; una acción rechazada
no avanza el tiempo ni destruye el cultivo. La previsión de cosecha incluye sol y condición de continuar.
Un cultivo iniciado el sol 7 anuncia cosecha en el sol 8, fuera de la misión; no se acelera al terminar.

`crop_progress` forma parte del snapshot; el presupuesto e historial guardan cosecha, interrupción,
progreso siguiente y fecha condicionada. La persistencia conserva y valida ese progreso.
Esta compresión no representa tiempos agrícolas reales ni implica que cualquier interrupción real
mate plantas: simplifica la necesidad de mantener condiciones y dedicar trabajo continuado.

## Protección (F2-03)

Cada acción tiene ubicación interior, exterior o refugio. El refugio protege durante el sol a cambio
del turno, consumo de reservas y posible interrupción del cultivo; su blindaje no consume electricidad.
Reforzar gasta dos materiales y un turno; la protección interior se evalúa antes de instalar la mejora,
por lo que debe prepararse antes de una alerta. Nunca protege una salida exterior.
En F2-05, trasladarse al refugio cuesta un oxígeno extra del equipo (balance ficticio), diferenciándolo
de reservar energía en calma. Este gasto no se atribuye al blindaje pasivo.
Explorar gasta un oxígeno extra del traje y dos de energía para tres hallazgos. Una decisión sin
protección durante alerta detiene la misión por protocolo educativo, sin dosis ni consecuencias clínicas.
F2-04 conecta las alertas con los eventos de misión.

## Eventos y radio (F2-04)

Infraestructura lee y valida `data/events/scenarios.json`, luego inyecta catálogo y escenarios al dominio.
Al iniciar cada sol, primero se selecciona su evento (solo entonces se consume RNG si hay alternativas),
se actualizan alerta/producción/avería y se entregan efectos cuyo `due_sol` llegó. La vista previa no tira
dados. Antes de cada selección se restaura el estado RNG propio de la misión; después se conserva.
Los escenarios no permiten alertas solares aleatorias sin aviso: una alerta fija se anuncia el sol anterior.
Polvo afecta solo producción del sol; avería persiste y resta dos hasta reparación. Reparar cobra trabajo,
energía y material local y restaura producción antes de recargar, sin eliminar el polvo presente.

La radio cobra energía y turno, agenda consejo al inicio del sol actual + 2 y rechaza consultas duplicadas.
El consejo no modifica reservas al llegar: mejora en dos una futura producción local de oxígeno y se consume.
Los pendientes permanecen registrados si vencen después del final; nunca se adelantan para premiar al jugador.
Estos tiempos, rendimientos y eventos son balance ficticio, no latencias reales ni datos NASA.
`pending`, `radio_sent`, `advice_ready`, avería, evento actual, escenario y RNG pertenecen al snapshot.

## Finales, objetivos y presentación (F2-05)

`outcome_code` separa éxito, parada de seguridad, oxígeno agotado, alimentos agotados y ambos agotados.
Seguridad y escasez se comprueban antes de victoria en el séptimo sol; mensajes en JSON de balance.
Objetivos opcionales: `science_goal` hallazgos y una muestra exterior segura. No bloquean la victoria.
El resumen calcula cosechas, interrupciones y refugios desde el historial; no inventa consecuencias.

La presentación ofrece selector de escenario/semilla y un selector de planes. Seleccionar no consume
el turno: muestra costos y restricciones, y el botón de ejecución envía el sol esperado al dominio.
Los planes imposibles pueden seleccionarse para leer el motivo, pero no ejecutarse. La bitácora es
desplegable. Datos ambientales, cultivo, radio y protección son estados contextuales; se mantienen
solo tres reservas principales. Los efectos pendientes no se adelantan al terminar la misión.

## Ciencia y aprendizaje (Fase 3)

`ScienceData` valida el catálogo archivado y ofrece búsquedas por identificador. `demo.science_id`
vincula Aurora con DONKI; la presentación explica su uso narrativo, sin introducir datos científicos
en cálculos de riesgo. `check_science.py` contrasta hashes y observaciones contra archivos originales.
`GameData.load_learning` valida las explicaciones españolas en JSON. Los consejos dependen del
estado actual; el resumen usa únicamente historial y agregados del dominio. No cambia reglas.

`BaseView` dibuja módulos y estados. Animaciones y audio pertenecen a presentación y no bloquean
turnos; audio se libera al salir. Preferencias de sesión aún no persistentes. Ayuda/fuentes no
reinician misión. Recursos originales y créditos en [ASSETS.md](ASSETS.md).
