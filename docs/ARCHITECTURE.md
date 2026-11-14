# Arquitectura y reglas

`MissionState` y `MissionRules` son RefCounted del dominio, sin archivos, red o UI.
`GameData` valida y lee JSON en infraestructura. La aplicación coordina reglas/proveedores
y emite señales; la presentación no modifica directamente los recursos.

## Orden de resolución (F2-01)

1. Validar fase, identificador de sol esperado, acción y recursos; rechazo sin mutación.
2. Calcular presupuesto conocido sin mutar estado ni RNG. Sumar asignaciones de soporte vital y ciencia;
   comprobar que la batería actual cubre el trabajo antes de cualquier recarga.
3. Entrar en resolución; cobrar acción, aplicar oxígeno/ciencia.
4. Consumir oxígeno y comida del sol; recargar batería limitada. Registrar producción solar almacenada
   y excedente que no cabe. Recursos agotados se limitan a cero.
5. Comprobar escasez antes de victoria; registrar diferencias y presupuesto desglosado, terminar o avanzar sol.

La vista previa y la resolución comparten el presupuesto del dominio. La vista previa no consume
turnos ni cambia semilla, RNG o historial. En F2-01 todos los efectos son conocidos; cuando se añadan
eventos inciertos no deberán anticiparse tiradas ni mostrarse resultados futuros como certezas.

Cada acción JSON define `allocation.life_support` y `allocation.science`; su suma es el costo,
sin un segundo campo duplicado. Planes discretos para evitar sobrecargar a niños con deslizadores:
aire 4/0, ciencia 0/3, ambos 3/3, reserva 0/0. El plan combinado consume seis y solo recupera cuatro,
de modo que repetirlo reduce la batería. Reservar no produce oxígeno ni ciencia, consume reservas
y ocupa el sol. Siempre está disponible durante decisión, incluso con batería vacía.
El adaptador valida enteros, límites, sistemas requeridos, producción con asignación positiva
y recuperación gratuita sin producción. Costos y rendimientos son unidades educativas de balance.

Los números son unidades de juego. Semilla y estado RNG se conservan como cadenas decimales
en snapshots para evitar pérdida de precisión de enteros de 64 bits al serializar JSON.
El identificador de turno evita aplicar dos veces una orden retrasada.
