# Arquitectura y reglas

`MissionState` y `MissionRules` son RefCounted del dominio, sin archivos, red o UI.
`GameData` valida y lee JSON en infraestructura. La aplicación coordina reglas/proveedores
y emite señales; la presentación no modifica directamente los recursos.

## Orden de resolución (F1-03)

1. Validar fase, identificador de sol esperado, acción y recursos; rechazo sin mutación.
2. Entrar en resolución; cobrar acción, aplicar oxígeno/ciencia.
3. Consumir oxígeno y comida del sol; recargar batería limitada.
4. Comprobar escasez antes de victoria; registrar diferencias y terminar o avanzar sol.

Los números son unidades de juego. Semilla y estado RNG se conservan como cadenas decimales
en snapshots para evitar pérdida de precisión de enteros de 64 bits al serializar JSON.
El identificador de turno evita aplicar dos veces una orden retrasada.
