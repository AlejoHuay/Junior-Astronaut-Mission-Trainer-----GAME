# Revisión del equipo — candidata F4

Estado: **pendiente de revisión manual**. No marcar aprobado sin ejecutar el caso.
El usuario verificará persistencia en Edge; los compañeros revisarán la entrega extraída del ZIP.
Las fases 3 y 4 siguen pendientes de aceptación hasta recibir resultados y resolver fallos críticos.

## Preparación

Seguir LEEME.md del ZIP. Usar Edge o Chrome de escritorio y anotar versión, sistema, resolución
y SHA-256 del ZIP recibido. Mantener el mismo navegador, perfil y dirección durante las pruebas
de guardado: `http://127.0.0.1:8060/`. No mezclar `localhost` con `127.0.0.1` ni cambiar puerto.
No abrir el HTML mediante doble clic. No se necesita Godot para jugar; sí Python 3 para el servidor.
Comenzar una misión reemplaza la anterior. Preferencias de sonido/movimiento/consejos son de sesión.

## Casos manuales (todos pendientes)

| ID | Responsable | Pasos | Resultado esperado |
|---|---|---|---|
| M01 | Compañeros | Extraer ZIP, iniciar servidor y abrir URL | Menú jugable, sin bloqueo en logo ni errores en consola |
| M02 | Compañeros | Aurora, semilla 214. Cultivo dos veces | Alimentos 5 → 4 → 7; cultivo progresa y luego se cosecha; causas visibles |
| M03 | Compañeros | Seguir con oxígeno, refugio, ambos, exterior, oxígeno | Victoria al terminar sol 7: energía 8, oxígeno 4, alimentos 2, hallazgos 5, muestra 1 |
| M04 | Compañeros | Nueva Aurora/214: cultivo, cultivo, oxígeno; ejecutar oxígeno durante alerta sol 4 | Vista previa advierte peligro; final por seguridad; se puede volver a comenzar |
| M05 | Usuario/Edge | Nueva Aurora/214, cultivar una vez. Anotar sol 2, E9/O5/F4 y cultivo 1; esperar unos segundos, recargar y Continuar | Mismos recursos, semilla, escenario, historial y cultivo. Cuidar cultivo otra vez da sol 3, E10/O3/F7 |
| M06 | Usuario/Edge | Aurora/214: cultivo, cultivo, oxígeno, refugio, radio. En sol 6, cerrar pestaña y reabrir la misma URL; Continuar; ejecutar oxígeno | Consejo sigue pendiente en sol 6 y llega al inicio del 7. Ejecutar oxígeno en sol 7 usa el consejo una vez |
| M07 | Usuario/Edge | Recargar tras victoria y Continuar; después Comenzar nueva misión y recargar | Resultado final conservado; nueva misión reemplaza la anterior y comienza en sol 1 |
| M08 | Compañeros | Recorrer controles con Tab, flechas y Enter/Espacio; seleccionar sin ejecutar | Foco visible; cambiar selección no consume recursos; ejecutar avanza solo un sol |
| M09 | Compañeros | Desactivar/activar sonido; ejecutar acciones. Activar Reducir movimiento | Sonido opcional sin distorsiones; sin animación al reducir movimiento; estados siguen escritos |
| M10 | Compañeros | Abrir ayuda y fuentes durante partida y volver | Estado intacto; tres registros históricos, contexto, límites y créditos legibles |
| M11 | Compañeros | Revisar a 1280×800 y ventana pequeña; jugar varios turnos | Texto y botones accesibles mediante scroll, sin cortes que impidan jugar; flechas sin cuadrados |
| M12 | Compañeros | Revisar consola y jugar de principio a fin | Sin errores de scripts ni bloqueos. Anotar tiempo de carga, duración y pausas perceptibles |

Para M06 la secuencia completa termina con E8/O9/F2; no llegan materiales desde la Tierra.
El objetivo de duración 5–10 minutos y la comprensión/diversión con niños no están validados.
Una prueba en ventana pequeña no certifica soporte móvil ni accesibilidad con lectores de pantalla.
Prueba adicional deseable: repetir con almacenamiento restringido/perfil temporal y documentar
si el juego informa del problema. No se garantiza persistencia en navegación privada o al borrar datos.

## Resultados automatizados

- Dominio: 684 aserciones; 48 partidas con cuatro estrategias, tres escenarios y cuatro semillas.
- Persistencia: 631 comprobaciones, comparación de snapshots completos antes/después de cargar,
  continuidad determinista, pendientes, finales, órdenes duplicadas, corrupción y fallo de escritura.
- Escenas: recorrido científico usando controles, preferencias, ayuda, fuentes y resumen.
- Ciencia: hashes y observaciones de tres registros archivados.
- Exportación: WASM sin memoria compartida; no requiere aislamiento para SharedArrayBuffer.

Último registro de la suite: `build/verify-f401-final.txt`. Una nueva ejecución de entrega se registra
en README. Estas pruebas no sustituyen M01–M12 ni acreditan rendimiento en otros equipos.

## Plantilla para devolver resultados

Copiar y completar en un mensaje o archivo; no hace falta modificar el repositorio:

```text
Probador / fecha:
SHA-256 del ZIP:
Sistema / navegador y versión / resolución / zoom:
Caso M__ : APROBADO / FALLÓ / NO EJECUTADO
Escenario y semilla:
Acciones en orden:
Esperado:
Observado (sol, energía, oxígeno, alimentos):
Captura y mensaje de consola, si hay error:
Tiempo de carga / duración / dificultad para entender:
```

Un fallo de arranque, pérdida de misión tras recarga, acción duplicada o imposibilidad de terminar
impide aceptar la entrega. Registrar y corregir antes del cierre de fase; no ocultar pendientes.
