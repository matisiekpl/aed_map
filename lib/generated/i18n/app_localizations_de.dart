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
  String get noLocationPermission => 'Standortzugriff nicht erteilt';

  @override
  String get openSettings => 'Einstellungen öffnen';

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
  String get editOpeningHours => 'Öffnungszeiten bearbeiten';

  @override
  String get openingHoursNotSet => 'Keine';

  @override
  String get openingHoursView => 'Anzeigen';

  @override
  String get openingHoursAlwaysOpen => 'Immer geöffnet (24/7)';

  @override
  String get openingHoursWorkingHours => 'Während der Arbeitszeiten';

  @override
  String get openingHoursCustomSchedule => 'Benutzerdefinierter Zeitplan';

  @override
  String get openingHoursAdvanced => 'Erweitert (OSM-Format)';

  @override
  String get openingHoursAdvancedHint =>
      'z.B. Mo-Fr 08:00-18:00; Sa 09:00-12:00';

  @override
  String get openingHoursClosed => 'Geschlossen';

  @override
  String get openingHoursAddRange => 'Zeitraum hinzufügen';

  @override
  String get openingHoursClear => 'Löschen';

  @override
  String get openingHoursInvalidFormat =>
      'Bestehender Wert konnte nicht verarbeitet werden; erweiterter Modus aktiviert.';

  @override
  String get dayMonday => 'Montag';

  @override
  String get dayTuesday => 'Dienstag';

  @override
  String get dayWednesday => 'Mittwoch';

  @override
  String get dayThursday => 'Donnerstag';

  @override
  String get dayFriday => 'Freitag';

  @override
  String get daySaturday => 'Samstag';

  @override
  String get daySunday => 'Sonntag';

  @override
  String get dayMondayShort => 'Mo';

  @override
  String get dayTuesdayShort => 'Di';

  @override
  String get dayWednesdayShort => 'Mi';

  @override
  String get dayThursdayShort => 'Do';

  @override
  String get dayFridayShort => 'Fr';

  @override
  String get daySaturdayShort => 'Sa';

  @override
  String get daySundayShort => 'So';

  @override
  String get backToDaysList => 'Zurück zur Tagesliste';

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

  @override
  String pendingChangesBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ausstehende Änderungen',
      one: '1 ausstehende Änderung',
    );
    return '$_temp0';
  }

  @override
  String get pendingChangesTitle => 'Ausstehende Änderungen';

  @override
  String get pendingAedBannerText =>
      'Dieser AED wird von OpenStreetMap verarbeitet';

  @override
  String get pendingChangeTypeAdd => 'Hinzugefügt';

  @override
  String get pendingChangeTypeEdit => 'Bearbeitet';

  @override
  String get pendingChangeTypeDelete => 'Gelöscht';

  @override
  String get pendingChangesProcessingInfo =>
      'Änderungen werden verarbeitet und erscheinen in der App innerhalb von etwa 3 Stunden.';

  @override
  String get osmErrorUnauthorized =>
      'Bitte melde dich erneut bei OpenStreetMap an';

  @override
  String get osmErrorNotFound =>
      'Dieser AED existiert nicht mehr auf OpenStreetMap';

  @override
  String get osmErrorConflict =>
      'Dieser AED wurde bereits von jemand anderem geändert. Bitte aktualisieren und erneut versuchen.';

  @override
  String osmErrorGeneric(int code) {
    return 'Änderungen konnten nicht gespeichert werden (HTTP $code)';
  }
}
