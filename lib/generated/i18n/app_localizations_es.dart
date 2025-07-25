// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get heading => 'Información';

  @override
  String subheading(int count) {
    return '$count DEA disponibles';
  }

  @override
  String get access => 'Acceso';

  @override
  String get closestAED => 'DEA más cercano';

  @override
  String get closerAEDAvailable => 'DEA más cercano disponible';

  @override
  String get location => 'Ubicación';

  @override
  String get operator => 'Operador';

  @override
  String get openingHours => 'Horario de apertura';

  @override
  String get insideBuilding => 'Dentro del edificio';

  @override
  String get contact => 'Contacto';

  @override
  String get noData => 'Sin datos';

  @override
  String get navigate => 'Navegar';

  @override
  String get chooseMapApp => 'Elegir aplicación de mapas';

  @override
  String get about => 'Acerca de la aplicación';

  @override
  String get defibrillator => 'Desfibrilador';

  @override
  String runDistance(int minutes, int meters) {
    return 'Aproximadamente $minutes minuto(s) corriendo (${meters}m)';
  }

  @override
  String distance(int kilometers) {
    return 'a unos ${kilometers}km de aquí';
  }

  @override
  String get noNetwork => '¡Sin conexión de red!';

  @override
  String get checkNetwork => 'Verificar conexión de red';

  @override
  String get retry => 'Reintentar';

  @override
  String get yes => 'sí';

  @override
  String get no => 'no';

  @override
  String get accessYes => 'accesible al público';

  @override
  String get accessCustomers => 'durante horas de trabajo';

  @override
  String get accessPrivate => 'con permiso del propietario';

  @override
  String get accessPermissive => 'hasta nuevo aviso';

  @override
  String get accessNo => 'no disponible';

  @override
  String get accessUnknown => 'acceso desconocido';

  @override
  String get chooseLocation =>
      'Selecciona la ubicación del DEA que deseas agregar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get next => 'Siguiente';

  @override
  String get edit => 'Editar';

  @override
  String get imageOfDefibrillator => 'Imagen del desfibrilador';

  @override
  String get save => 'Guardar';

  @override
  String get editDefibrillator => 'Editar desfibrilador';

  @override
  String get information => 'Información';

  @override
  String get enterDescription => 'Ingrese una descripción';

  @override
  String get enterOperator => 'Ingrese el operador';

  @override
  String get enterPhone => 'Ingrese el número de teléfono';

  @override
  String get longitude => 'Longitud';

  @override
  String get latitude => 'Latitud';

  @override
  String get chooseAccess => 'Elegir acceso';

  @override
  String get calculatingRoute => 'Calculando ruta...';

  @override
  String get stop => 'detener';

  @override
  String get minutes => 'minutos';

  @override
  String get seconds => 'segundos';

  @override
  String get meters => 'metros';

  @override
  String get datasetHeading => 'Base de datos de puntos';

  @override
  String get datasetDescription =>
      'La base de datos de puntos AED proviene del proyecto openaedmap.org';

  @override
  String get defibrillatorsInDataset => 'Desfibriladores en la base de datos';

  @override
  String get defibrillatorsWithin5km => 'Desfibriladores en un radio de 5 km';

  @override
  String get defibrillatorsWithImages => 'Puntos con imágenes';

  @override
  String get version => 'Versión';

  @override
  String get website => 'Sitio web del proyecto';

  @override
  String get author => 'Autor';

  @override
  String get understand => 'Entiendo';

  @override
  String get dataSource => 'Fuente de datos';

  @override
  String get dataSourceDescription =>
      'Los datos sobre la ubicación de los desfibriladores provienen de OpenStreetMap. Su calidad puede variar. El autor no es responsable de la exactitud de los datos. Te animamos a co-crear la base de datos en openaedmap.org';

  @override
  String get lastUpdate => 'Última actualización';

  @override
  String get refreshing => 'Actualizando';

  @override
  String get refresh => 'Actualizar ahora';

  @override
  String get onboardingTitle0 => '¡Bienvenido a la aplicación Mapa de DEA!';

  @override
  String get onboardingBody0 =>
      'Aplicación hecha para encontrar desfibriladores en tu área';

  @override
  String get onboardingTitle1 => 'Ver desfibriladores cercanos';

  @override
  String get onboardingBody1 =>
      'Encuentra el desfibrilador más cercano a tu ubicación';

  @override
  String get onboardingTitle2 => 'Ruta al desfibrilador más cercano';

  @override
  String get onboardingBody2 =>
      'Obtén direcciones al desfibrilador más cercano';

  @override
  String get onboardingTitle3 =>
      'Estamos usando la base de datos de OpenStreetMap';

  @override
  String get onboardingBody3 =>
      'Ten en cuenta que los datos pueden no estar 100% actualizados';

  @override
  String get openStreetMapAccount => 'Cuenta de OpenStreetMap';

  @override
  String get signedInAs => 'Conectado como';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get viewOpenStreetMapNode => 'Ver nodo de OpenStreetMap';

  @override
  String get delete => 'Eliminar';

  @override
  String get accountNumber => 'Número de cuenta';

  @override
  String get add => 'Añadir';
}
