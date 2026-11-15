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

## OSDR — F3-02

[OSD-267](https://osdr.nasa.gov/bio/repo/data/studies/OSD-267),
[metadatos originales](https://osdr.nasa.gov/osdr/data/osd/meta/267),
publicación asociada DOI `10.3389/fpls.2020.00199` (Khodadad y colaboradores).
Se leyeron descripción, protocolo de crecimiento y recolección de la ficha; no se reanalizaron
secuencias ni se verificaron independientemente los resultados del artículo.
Organismo: lechuga roja Lactuca sativa Outredgeous y microbiota de hojas/raíces.
VEG-01A: ISS, 8 mayo–10 junio 2014, cosecha a 33 días; controles terrestres con 24 h de desfase.
Veggie emplea sustrato, fertilizante, agua y LED con ciclo de 16 h luz/8 h oscuridad.
Archivo completo `raw/osdr-267-metadata.json`; curado conserva título, enlace y DOI.
Interpretación: producir comida exige condiciones y planificación. Dos cuidados y cuatro unidades
de alimento son ficción; el estudio no prueba rendimientos marcianos ni seguridad universal.

## RadLab — F3-02

Archivo `raw/radlab-dostel-2022-04-01.json`: respuesta completa de 16 filas entre 23:00 inclusive
y 23:10 exclusive del 01-04-2022. Consulta exacta y hash en el catálogo curado.
Primera fila: DosTel2, Columbus, ISS, Earth, LEO, timestamp `2022-04-01T23:00:00`, tasa absorbida
`10.2160856666667 µGy/h`. Se conservan timestamps de API sin añadir zona horaria no indicada.
Las unidades provienen de la documentación API. No se convierte a dosis equivalente ni a riesgo.
Se selecciona una fila sin promediar, extrapolar o inferir eficacia del refugio.
La ubicación orbital y el detector son parte esencial de la lectura; no es una medición de Marte
ni de la tripulación. El juego no cambia balance a partir del valor.

[Buscador OSDR](https://osdr.nasa.gov/bio/repo/search?q=&data_source=cgene,alsda,esa&data_type=study)
y [API RadLab](https://visualization.osdr.nasa.gov/radlab/gui/data-api/).
Créditos: NASA OSDR y equipos contribuyentes de los estudios y de RadLab/DosTel.
No se incluyen logos NASA ni se afirma patrocinio. Los enlaces externos requieren conexión;
las fichas educativas y los datos archivados no. Verificación reproducible: `python scripts/check_science.py`.
