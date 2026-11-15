# Ciencia y límites

Consulta y archivo: 15-11-2026. Sin llamadas a APIs durante la partida. NASA no avala este juego.
Los recursos, tiempos, cosechas, alertas y resultados son balance educativo, no predicciones.

## DONKI — F3-01

[Documentación CCMC](https://ccmc.gsfc.nasa.gov/tools/DONKI/),
[API vigente](https://ccmc.gsfc.nasa.gov/DONKI/api/),
[OpenAPI consultado](https://ccmc.gsfc.nasa.gov/DONKI/api/openapi/).
El esquema publicado indica servidor `https://ccmc.gsfc.nasa.gov/DONKI-API` y ruta `/get/FLR`.
Se descargó la respuesta completa para startDate=endDate=2024-05-10, sin modificar bytes,
en `data/nasa/raw/donki-flr-2024-05-10.json`. Catálogo curado: `data/nasa/curated/catalog.json`.
Conserva consulta, fecha de recuperación, SHA-256, registro seleccionado completo y unidades.

Registro `2024-05-10T06:27:00-FLR-001`, versión 2, M2M_CATALOG:
clase X3.9, GOES-P EXIS 1.0-8.0, inicio 06:27Z, máximo 06:54Z, fin 07:06Z.
[Ficha original](https://ccmc.gsfc.nasa.gov/DONKI/view/FLR/30666/-1).
Clase y tiempos se copian; no se calcula dosis. Las relaciones con CME/SEP se conservan como
relaciones del catálogo, sin deducir exposición en Marte.

Transformación: `demo.science_id` apunta al registro. La alerta del cuarto sol de Aurora es una
decisión narrativa para practicar protección frente a trabajo; ni fecha ni intensidad ni
seguridad del escenario se calculan a partir de X3.9. No recreamos una misión histórica.
Crédito: NASA CCMC y Moon to Mars Space Weather Analysis Office. Datos de investigación
proporcionados sin garantía; consultar [condiciones DONKI](https://ccmc.gsfc.nasa.gov/tools/DONKI/#disclaimer).

## OSDR y RadLab — siguiente iteración

[Buscador OSDR](https://osdr.nasa.gov/bio/repo/search?q=&data_source=cgene,alsda,esa&data_type=study)
y [API RadLab](https://visualization.osdr.nasa.gov/radlab/gui/data-api/).
Todavía no se usan como evidencia del juego. Una lectura orbital no representa una base marciana.
