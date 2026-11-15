# Aceptación visual de Fase 3

Estado: pendiente. Las pruebas headless no demuestran legibilidad ni sonido correcto.
El usuario confirmó Fase 2; esta lista corresponde a la presentación nueva.

1. Abrir http://127.0.0.1:8060/ y recargar con Ctrl+Shift+R. Si hay dos pestañas del juego,
   usar la recién recargada. Deben aparecer Ayuda, fuentes y preferencias nuevas.
2. Entrar en Aurora, semilla 214. Comprobar cuatro módulos dibujados con nombre y estado:
   paneles, hábitat, invernadero y refugio; tres reservas, consejo y selector legibles al desplazarse.
3. Ejecutar Cuidar el cultivo dos veces. La guía debe hablar de continuidad tras el primer
   cuidado; alimentos 5 → 4 → 7. La explicación muestra cosecha y consumo por separado.
4. Seguir oxígeno → refugio → ambos → exterior → oxígeno, usando los planes del selector.
   El sol 3 avisa; el 4 muestra alerta y guía de protección.
   Final: energía 8, oxígeno 4, alimentos 2, ciencia 5, una muestra. El resumen menciona cosecha,
   refugio e investigación; no dice que enviaste radio si no lo hiciste.
5. Con Tab comprobar borde de foco; flechas cambian plan, Enter/espacio activan controles.
   Seleccionar no consume turno. Ayuda y Fuentes deben permitir volver a la misión.
6. Activar Sonido: se espera un tono breve al ejecutar. Desactivarlo: silencio.
   Activar Reducir movimiento: sin desplazamientos ni resaltado animado en el siguiente turno.
   Desactivar Mostrar consejo: desaparece la guía, conservando reservas y reglas visibles.
7. Fuentes: tres fichas históricas, límites y créditos; DONKI solar, OSDR de cultivo,
   RadLab de ISS, sin presentarlos como mediciones de Marte. Comprobar texto sin cortes.

No es necesario repetir las 48 estrategias automáticas. Registrar problemas con pantalla, acción,
sol y tamaño de ventana. Ensayo con niños y duración real de partida siguen pendientes.
# Actualización de revisión final

La revisión parcial del agente observó módulos, cultivo, alerta/refugio, teclado, ayuda y
controles de preferencias; no cerró la aceptación completa. El equipo realizará ahora la
revisión con el ZIP según [TESTING.md](TESTING.md). Los casos finales siguen pendientes.
