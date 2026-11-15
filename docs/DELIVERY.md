# Junior Astronaut — paquete de revisión F4

Esta es una **candidata para pruebas**, no una entrega aceptada. El guardado pasó pruebas
automatizadas; su persistencia en Edge y la revisión visual final siguen pendientes.
Compartir el ZIP completo y el archivo `.zip.sha256`. No se publicó en ningún alojamiento.

## Jugar sin instalar Godot

1. Extrae **todo** el ZIP a una carpeta. No abras el HTML dentro del ZIP.
2. Necesitas Python 3 instalado. Abre una terminal en la carpeta que contiene este LEEME.md.
3. Ejecuta:

   ```text
   python -m http.server 8060 --bind 127.0.0.1 --directory web
   ```

   En Windows, si `python` no está disponible pero tienes Python instalado, prueba `py -3` en su lugar.
4. Abre Edge o Chrome y escribe **http://127.0.0.1:8060/**. Mantén la terminal abierta.
5. Para detener el servidor, pulsa Ctrl+C en esa terminal.

No abrir `index.html` con doble clic: el juego necesita HTTP. Si el puerto está ocupado,
detén tu servidor anterior o elige otro puerto (por ejemplo 8061) en el comando y la URL.
No cambies host/puerto mientras verificas un guardado: el navegador separa el almacenamiento por origen.
Si ya tienes el servidor del repositorio en 8060, asegúrate de detenerlo antes de probar el ZIP;
de otro modo podrías estar viendo una exportación distinta.

Una vez extraído, el juego no necesita APIs ni internet. Abrir enlaces externos de Fuentes sí necesita red.
Para jugar no necesitas el repositorio, Godot, plantillas de exportación ni una cuenta.

## Qué revisar y cómo reportar

Usa [docs/TESTING.md](docs/TESTING.md). Incluye casos, resultados esperados y plantilla de reporte.
Demo reproducible: Aurora, semilla **214**, planes **cultivo, cultivo, oxígeno, refugio, ambos,
exterior, oxígeno**. Final esperado E8/O4/F2, cinco hallazgos y una muestra.
El pitch y su secuencia de presentación se encuentran en `docs/DEMO.md` en el paquete final.

Tras un turno, espera unos segundos antes de recargar, elige **Continuar misión guardada** y compara
los recursos, el sol y el historial. No pulses Comenzar: reemplaza la misión anterior.
Repite cerrando y reabriendo la pestaña. Preferencias no se guardan entre recargas.
No hay guardado en la nube ni sincronización; borrar datos del sitio puede borrar la misión.
La persistencia web aún necesita tu comprobación; no uses esta candidata para conservar partidas valiosas.

## Contenido y procedencia

- `web/`: exportación Godot 4.7.2 Compatibility sin hilos, con ciencia archivada incluida en el PCK.
- `docs/`: protocolo, ciencia, arquitectura, balance, créditos y pitch.
- `README-PROYECTO.md`: estado del proyecto; sus comandos de desarrollo requieren el repositorio.
- `GODOT-LICENSES.txt`: licencia del motor y avisos de terceros extraídos de la instalación usada.
- `MANIFEST.json`: commit fuente, estado del árbol y SHA-256 de cada archivo; aceptación manual pendiente.

NASA no avala el juego. DONKI aporta contexto solar histórico; OSD-267 y RadLab proceden de la ISS,
no de una base marciana. Los números y tiempos de juego son balance educativo ficticio.
Consulta `docs/SCIENCE.md` y `docs/ASSETS.md`. No se concede una licencia nueva al código original
del proyecto en este paquete; su elección queda a cargo del equipo propietario.

## Reproducir la entrega desde el repositorio

Configura `GODOT_BIN` con tu instalación existente Godot **4.7.2** y las plantillas exactas
sin hilos descritas en README. Desde la raíz:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/godot.ps1 package
```

Ejecuta importación, pruebas, exportación, extracción de licencias y empaquetado. El resultado queda
en `build/Junior-Astronaut-Mission-Trainer-F4.zip` y su `.zip.sha256`, ambos fuera de Git.
`python scripts/package_web.py` permite reempaquetar documentación tras los commits sin repetir
Godot, siempre que la exportación verificada no haya cambiado. No equivale a volver a probar código.

## Alojamiento futuro

Publicar solo con destino autorizado. Servir **todo** `web/` en la misma ruta, por HTTPS (o localhost
para desarrollo), con MIME `application/wasm` para `.wasm` y JavaScript para `.js`; evitar que una
regla de aplicación devuelva HTML en lugar del WASM/PCK. Mantener rutas relativas y actualizar
archivos juntos para evitar caché mezclada. Esta exportación no usa hilos ni requiere COOP/COEP.
Verificar WebGL 2 y almacenamiento del navegador en el destino real antes de anunciar compatibilidad.
