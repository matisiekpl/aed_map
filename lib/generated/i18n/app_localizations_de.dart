// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get heading => 'AED-Karte';

  @override
  String subheading(int count) {
    return '$count verfügbare AEDs';
  }

  @override
  String get access => 'Zugang';

  @override
  String get closestAED => 'Nächster AED';

  @override
  String get closerAEDAvailable => 'Näherer AED ist verfügbar';

  @override
  String get location => 'Standort';

  @override
  String get operator => 'Betreiber';

  @override
  String get openingHours => 'Öffnungszeiten';

  @override
  String get insideBuilding => 'Im Gebäude';

  @override
  String get contact => 'Kontakt';

  @override
  String get noData => 'Keine Daten';

  @override
  String get navigate => 'Navigieren';

  @override
  String get chooseMapApp => 'Wähle Kartenanwendung';

  @override
  String get about => 'Über die Anwendung';

  @override
  String get defibrillator => 'Defibrillator';

  @override
  String runDistance(int minutes, int meters) {
    return '~$minutes Minute(n) Laufen (${meters}m)';
  }

  @override
  String distance(int kilometers) {
    return 'ungefähr ${kilometers}km von hier entfernt';
  }

  @override
  String get noNetwork => 'Keine Netzwerkverbindung!';

  @override
  String get checkNetwork => 'Netzwerkverbindung überprüfen';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get yes => 'ja';

  @override
  String get no => 'nein';

  @override
  String get accessYes => 'öffentlich zugänglich';

  @override
  String get accessCustomers => 'während der Arbeitszeiten';

  @override
  String get accessPrivate => 'mit Genehmigung des Eigentümers';

  @override
  String get accessPermissive => 'bis auf weiteres';

  @override
  String get accessNo => 'nicht verfügbar';

  @override
  String get accessUnknown => 'unbekannter Zugang';

  @override
  String get chooseLocation =>
      'Wähle den Standort des AED, den du hinzufügen möchtest';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get next => 'Weiter';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get imageOfDefibrillator => 'Bild des Defibrillators';

  @override
  String get save => 'Speichern';

  @override
  String get editDefibrillator => 'Defibrillator bearbeiten';

  @override
  String get information => 'Informationen';

  @override
  String get enterDescription => 'Beschreibung eingeben';

  @override
  String get enterOperator => 'Betreiber eingeben';

  @override
  String get enterPhone => 'Telefonnummer eingeben';

  @override
  String get longitude => 'Längengrad';

  @override
  String get latitude => 'Breitengrad';

  @override
  String get chooseAccess => 'Zugang wählen';

  @override
  String get calculatingRoute => 'Route wird berechnet...';

  @override
  String get stop => 'stoppen';

  @override
  String get minutes => 'Minuten';

  @override
  String get seconds => 'Sekunden';

  @override
  String get meters => 'Meter';

  @override
  String get datasetHeading => 'Punktedatenbank';

  @override
  String get datasetDescription =>
      'Die AED-Punktedatenbank stammt aus dem Projekt openaedmap.org';

  @override
  String get defibrillatorsInDataset => 'Defibrillatoren in der Datenbank';

  @override
  String get defibrillatorsWithin5km => 'Defibrillatoren im Umkreis von 5 km';

  @override
  String get defibrillatorsWithImages => 'Punkte mit Bildern';

  @override
  String get version => 'Version';

  @override
  String get website => 'Projektwebsite';

  @override
  String get author => 'Autor';

  @override
  String get understand => 'Ich verstehe';

  @override
  String get dataSource => 'Datenquelle';

  @override
  String get dataSourceDescription =>
      'Die Daten über die Standorte von Defibrillatoren stammen von OpenStreetMap. Ihre Qualität kann variieren. Der Autor übernimmt keine Verantwortung für die Richtigkeit der Daten. Wir ermutigen Sie, die Datenbank auf openaedmap.org mitzugestalten';

  @override
  String get lastUpdate => 'Letzte Aktualisierung';

  @override
  String get refreshing => 'Aktualisieren';

  @override
  String get refresh => 'Jetzt aktualisieren';

  @override
  String get onboardingTitle0 => 'Willkommen bei der AED-Karten-App!';

  @override
  String get onboardingBody0 =>
      'App zum Auffinden von Defibrillatoren in Ihrer Umgebung';

  @override
  String get onboardingTitle1 => 'Nahegelegene Defibrillatoren anzeigen';

  @override
  String get onboardingBody1 =>
      'Finden Sie den nächstgelegenen Defibrillator zu Ihrem Standort';

  @override
  String get onboardingTitle2 => 'Route zum nächstgelegenen Defibrillator';

  @override
  String get onboardingBody2 =>
      'Erhalten Sie Wegbeschreibungen zum nächstgelegenen Defibrillator';

  @override
  String get onboardingTitle3 => 'Wir verwenden die OpenStreetMap-Datenbank';

  @override
  String get onboardingBody3 =>
      'Beachten Sie, dass die Daten möglicherweise nicht zu 100% aktuell sind';

  @override
  String get openStreetMapAccount => 'OpenStreetMap-Konto';

  @override
  String get signedInAs => 'Angemeldet als';

  @override
  String get logout => 'Abmelden';

  @override
  String get viewOpenStreetMapNode => 'OpenStreetMap-Knoten anzeigen';

  @override
  String get delete => 'Löschen';

  @override
  String get accountNumber => 'Kontonummer';

  @override
  String get add => 'Hinzufügen';

  @override
  String get contactAuthorDescription =>
      'Bei Fragen oder Feedback zögere nicht, mich auf einer dieser Plattformen zu kontaktieren.';
}
