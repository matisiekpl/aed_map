---
title: Política de privacidad
updatedAt: '2026-10-15'
---

# Política de privacidad

Esta política se aplica a la aplicación móvil Mapa de DEA para iOS y Android y al sitio web aedmapa.pl.

## Responsable del tratamiento

El responsable del tratamiento de los datos es Mateusz Woźniak. Contacto para cuestiones relacionadas con datos personales: [mateusz@aedmapa.pl](mailto:mateusz@aedmapa.pl).

## Datos tratados por la aplicación

### Ubicación

Una vez concedido el permiso de acceso a la ubicación, la aplicación la utiliza para mostrar los desfibriladores más cercanos y la distancia hasta ellos. Las coordenadas aproximadas también se registran en los eventos analíticos de Mixpanel (descritos más abajo).

Al calcular una ruta a pie, las coordenadas del punto de partida y del DEA seleccionado se envían al servidor de cálculo de rutas Valhalla (sa.tt.com.pl). El servidor devuelve la ruta y no recibe ningún otro dato sobre el usuario.

### Mapa

Las teselas del mapa se descargan de los servidores de la OpenStreetMap Foundation (tile.openstreetmap.org). En cada descarga el servidor recibe la dirección IP del dispositivo, conforme a la [política de privacidad de la OSMF](https://osmfoundation.org/wiki/Privacy_Policy).

### Cuenta de OpenStreetMap

Para añadir y editar desfibriladores es necesario iniciar sesión con una cuenta de OpenStreetMap (OAuth 2.0). La aplicación guarda el token de acceso únicamente en el dispositivo y obtiene de OpenStreetMap el identificador, el nombre de usuario y el avatar.

Cada cambio guardado en OpenStreetMap es público y va firmado con el nombre de usuario. El historial de cambios de OpenStreetMap se rige por las normas de la OpenStreetMap Foundation y la aplicación no puede eliminarlo.

### Fotos

Antes del envío, la foto del desfibrilador se analiza en el dispositivo mediante un modelo que detecta contenido inapropiado. La foto se envía al servidor del proyecto OpenAEDMap (back.openaedmap.org), se publica con licencia CC0 y es visible para todos los usuarios de OpenAEDMap. La denuncia de una foto transmite a OpenAEDMap su identificador.

### Analítica y diagnóstico

La aplicación utiliza los siguientes servicios:

- **Mixpanel** (Mixpanel, Inc., servidores en la UE): eventos de uso de la aplicación, como la selección de un desfibrilador, el inicio de la navegación, una llamada telefónica o el guardado de una edición, junto con el modelo del dispositivo, la versión del sistema y de la aplicación y las coordenadas de ubicación. Tras iniciar sesión con una cuenta de OpenStreetMap, los eventos se vinculan al identificador, el nombre y el avatar del usuario de OpenStreetMap.
- **Sentry** (Functional Software, Inc.): informes de errores y datos de rendimiento, con el modelo del dispositivo y la versión del sistema. Tras iniciar sesión, el informe incluye el identificador y el nombre de usuario de OpenStreetMap. Los comentarios enviados desde la pantalla de ajustes llegan a Sentry junto con una captura de pantalla y el texto introducido por el usuario.
- **Firebase Analytics y Firebase Remote Config** (Google Ireland Ltd.): estadísticas de uso de la aplicación vinculadas al identificador de instalación y descarga de la configuración de la aplicación.
- **Plausible** (instancia alojada por el responsable): estadísticas agregadas de visitas sin cookies y sin identificadores de usuario.

## Datos tratados por el sitio web

El sitio web aedmapa.pl utiliza Plausible alojado por el responsable. Plausible no instala cookies ni almacena direcciones IP. El sitio web guarda la cookie `i18n_redirected` con el idioma seleccionado.

## Finalidad y base jurídica

- Funcionamiento de las funciones de la aplicación (ubicación, ruta, edición, fotos): prestación del servicio solicitado por el usuario (art. 6.1.b del RGPD) y consentimiento de acceso a la ubicación y a las fotos otorgado en el sistema.
- Analítica y diagnóstico de errores: interés legítimo del responsable consistente en el mantenimiento y desarrollo de la aplicación (art. 6.1.f del RGPD).

## Transferencias de datos fuera del EEE

Sentry, Google y Mixpanel pueden tratar datos en los Estados Unidos sobre la base de cláusulas contractuales tipo o del Marco de Privacidad de Datos UE-EE. UU. (EU-U.S. Data Privacy Framework).

## Plazo de conservación

- Datos en Mixpanel: hasta 5 años.
- Informes de Sentry: 90 días.
- Datos de Firebase Analytics: 14 meses.
- Datos guardados en el dispositivo (base de datos de desfibriladores, token de OpenStreetMap, ajustes): hasta el cierre de sesión o la desinstalación de la aplicación.

## Derechos del usuario

El usuario tiene derecho de acceso a sus datos, de rectificación, supresión, limitación del tratamiento y portabilidad, así como derecho de oposición al tratamiento basado en el interés legítimo. Las solicitudes se atienden en la dirección [mateusz@aedmapa.pl](mailto:mateusz@aedmapa.pl). También tiene derecho a presentar una reclamación ante el Presidente de la Oficina de Protección de Datos Personales de Polonia (UODO) o la autoridad de control del país de residencia.

## Menores

La aplicación no está dirigida a menores de 13 años y no recoge conscientemente sus datos.

## Cambios

Las nuevas versiones de la política se publican en esta página con la fecha de la última actualización.
