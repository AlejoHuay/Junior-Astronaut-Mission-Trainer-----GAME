# Balance de Fase 2

Valores educativos ficticios. No se han medido diversión, duración de partida ni comprensión con niños.
La variedad de estrategias comprobada no demuestra equilibrio óptimo ni cubre todas las combinaciones.

## Escenarios

- **Entrenamiento tranquilo:** sin eventos adversos.
- **Misión Aurora:** polvo sol 3, alerta solar sol 4, avería sol 6. Semilla de demo: 214.
- **Desafío de exploración:** sol 3 despejado/polvo y sol 6 polvo/avería según RNG; alerta fija sol 4.

El sol previo avisa de alerta. Los eventos inciertos se revelan al iniciar el sol, nunca al previsualizar.
`tests/strategies.json` conserva cuatro secuencias; la suite ejecuta cada una en los tres escenarios
con semillas 1, 77, 214 y 999: **48 partidas completas y exitosas**.

## Comparación reproducible: Aurora, semilla 214

| Estrategia | Acciones de los soles 1–7 | Energía | Oxígeno | Comida | Ciencia | Materiales |
|---|---|---:|---:|---:|---:|---:|
| Cautelosa | cultivo, cultivo, oxígeno, refugio, oxígeno, investigar, oxígeno | 9 | 7 | 2 | 2 | 2 |
| Científica | cultivo, cultivo, oxígeno, refugio, ambos, exterior, oxígeno | 8 | 4 | 2 | 5 | 2 |
| Reforzada | reforzar, cultivo, cultivo, oxígeno, ambos, investigar, oxígeno | 6 | 6 | 2 | 4 | 0 |
| Radio | cultivo, cultivo, oxígeno, refugio, radio, oxígeno, oxígeno | 8 | 9 | 2 | 0 | 2 |

La científica obtiene ambos objetivos opcionales (4 hallazgos y una muestra exterior), con menos oxígeno.
La reforzada trabaja dentro durante la alerta y conserva más oxígeno, pero agota los materiales.
La radio sacrifica ciencia para recibir consejo al inicio del sol 7 y mejorar una producción local.
Todas completan la misión aunque no logren objetivos opcionales.

## Costos y renuncias

- Oxígeno: energía y renuncia a otras tareas. Investigar: energía y consumo de reservas sin reponer aire.
- Ambos: seis de energía frente a cuatro solares nominales; no puede repetirse indefinidamente.
- Cultivo: energía, dos trabajos consecutivos y riesgo de interrupción; sin producción de aire.
- Reservar: sol consumido, comida/oxígeno gastados, sin ciencia ni cosecha.
- Refugio: turno, interrupción de cultivo y un oxígeno extra del equipo para traslado (abstracción).
  Ese costo diferencia refugio de reservar en un sol tranquilo. El blindaje no gasta electricidad.
- Reforzar: dos materiales y un turno, antes de la alerta. Nunca protege al explorador fuera de la base.
- Exterior: energía y un oxígeno extra; tres hallazgos y muestra, pero inseguro durante alerta.
- Radio: dos de energía y un turno; el consejo tarda dos soles y solo mejora una producción local.
- Reparar: energía, un material y turno; recupera producción futura, pero puede no convenir cerca del final.

No hay un plan que satisfaga todas las necesidades: repetir solo ciencia o solo cultivo agota oxígeno;
repetir solo soporte vital termina sin comida; quedarse siempre en refugio también consume reservas.
La inversión anticipada y las reservas iniciales determinan el momento adecuado de cada acción.

## Verificación

679 aserciones aprobadas en `tests/run_tests.gd`, incluyendo restricciones, orden de cosecha/consumo,
costos exactos, límites, rechazos atómicos, turnos duplicados, interrupciones, seguridad, radio diferida,
uso único del consejo, eventos reproducibles, variedad por semilla y finales específicos.
`tests/smoke_scene.gd` recorre el selector real, vista previa y botón de ejecución de la estrategia
científica en Aurora; exige victoria con 5 hallazgos, abre fuentes y vuelve al menú.
Importación, escenas y exportación Web sin memoria compartida pasan. La revisión visual final de Fase 2
quedó bloqueada por Computer Use al no poder determinar la URL de Edge; no equivale a fallo del juego.

## Protocolo manual final pendiente

1. Recargar `http://127.0.0.1:8060/`. Elegir Misión Aurora y semilla 214.
2. Seleccionar cada plan de la estrategia científica y pulsar **Ejecutar plan y terminar sol**.
3. En sol 3 comprobar polvo y aviso de alerta para sol 4; usar refugio en sol 4.
4. En sol 6 comprobar avería y salida científica. Verificar final: energía 8, oxígeno 4, comida 2,
   ciencia 5 y una muestra. Revisar bitácora y reiniciar.
5. Probar estrategia Radio: consulta sol 5, pendiente en sol 6, recibida/aplicada sol 7. No llegan materiales.
6. Para fracaso por seguridad, usar una tarea interior sin refuerzo en sol 4; debe explicar la parada.
7. Entrenamiento tranquilo permite repetir las pruebas anteriores de cultivo sin alertas. No confundir
   las cifras previas de Fase 1 con las reservas actuales (5 alimentos).
