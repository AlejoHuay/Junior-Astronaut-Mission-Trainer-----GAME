# Junior Astronaut Mission Trainer

Juego educativo 2D para edades 7–12: administra una base en Marte durante 7 soles simulados.
Energía, oxígeno y alimentos hacen visibles las renuncias de una misión. Duración objetivo: 5–10 minutos.

## Estado actual

Fase 1 en curso. Última iteración: **F1-01**, inspección y documentación. Próxima: **F1-02**, proyecto y entorno.
Rama `feat/mission-trainer`; main, origin y commit inicial conservados. Sin push ni merge.

## Entorno y ejecución

Godot **4.7.2.stable.official.ed1daf0bf**, instalación existente indicada por el usuario; versión comprobada
con `--headless --version`. VS Code para edición, Git y Python 3.13 para utilidades.
Aún no existe proyecto ejecutable. Plantillas de exportación pendientes de localizar/configurar.
No descargar otro motor. Los archivos compartidos usarán `GODOT_BIN` o un ejecutable en PATH.

## Arquitectura y funcionalidades

Dominio independiente → aplicación → adaptadores de archivos y presentación Godot.
Completado: inspección, rama y documentación. Pendiente: simulación, interfaz, ciencia archivada,
guardado, pruebas y paquete web. [Plan completo](docs/PLAN.md) · [Desafío](docs/CHALLENGE.md).

## Verificación y problemas conocidos

Comprobados: árbol inicial limpio, main siguiendo origin/main, remoto esperado, `26d25ed first commit`,
Godot 4.7.2 ejecutable. No se ejecutaron pruebas de juego ni navegador.
Una búsqueda inicial no encontró Godot en PATH; el usuario proporcionó después la instalación correcta.
Un intento anterior de descarga falló y no instaló otro motor. Plantillas pendientes de comprobación.

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
