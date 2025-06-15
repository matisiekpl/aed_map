// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get heading => 'Informacje';

  @override
  String subheading(int count) {
    return '$count AED dostępnych';
  }

  @override
  String get access => 'Dostęp';

  @override
  String get closestAED => 'Najbliższy AED';

  @override
  String get closerAEDAvailable => 'Bliższy AED jest dostępny (kliknij)';

  @override
  String get location => 'Lokalizacja';

  @override
  String get operator => 'Operator';

  @override
  String get openingHours => 'Godziny otwarcia';

  @override
  String get insideBuilding => 'Wewnątrz budynku';

  @override
  String get contact => 'Kontakt';

  @override
  String get noData => 'Brak danych';

  @override
  String get navigate => 'Nawiguj';

  @override
  String get chooseMapApp => 'Wybierz aplikację do map';

  @override
  String get about => 'O aplikacji';

  @override
  String get defibrillator => 'Defibrylator AED';

  @override
  String runDistance(int minutes, int meters) {
    return '~$minutes minut biegiem (${meters}m)';
  }

  @override
  String distance(int kilometers) {
    return 'około ${kilometers}km stąd';
  }

  @override
  String get noNetwork => 'Brak połączenia sieciowego!';

  @override
  String get checkNetwork => 'Sprawdź połączenie sieciowe';

  @override
  String get retry => 'Ponów';

  @override
  String get yes => 'tak';

  @override
  String get no => 'nie';

  @override
  String get accessYes => 'publicznie dostępny';

  @override
  String get accessCustomers => 'tylko w godzinach pracy';

  @override
  String get accessPrivate => 'za zgodą właściciela';

  @override
  String get accessPermissive => 'publicznie do odwołania';

  @override
  String get accessNo => 'niedostępny';

  @override
  String get accessUnknown => 'nieznany';

  @override
  String get chooseLocation => 'Wybierz lokalizację AED, który chcesz dodać';

  @override
  String get cancel => 'Anuluj';

  @override
  String get next => 'Dalej';

  @override
  String get edit => 'Edytuj';

  @override
  String get imageOfDefibrillator => 'Zdjęcie defibrylatora';

  @override
  String get save => 'Zapisz';

  @override
  String get editDefibrillator => 'Edytuj defibrylator';

  @override
  String get information => 'Informacje';

  @override
  String get enterDescription => 'Wpisz opis lokalizacji';

  @override
  String get enterOperator => 'Wpisz operatora';

  @override
  String get enterPhone => 'Wpisz numer telefonu';

  @override
  String get longitude => 'Długość geograficzna';

  @override
  String get latitude => 'Szerokość geograficzna';

  @override
  String get chooseAccess => 'Wybierz dostępność';

  @override
  String get calculatingRoute => 'Liczenie trasy...';

  @override
  String get stop => 'Zakończ';

  @override
  String get minutes => 'minut';

  @override
  String get seconds => 'sekund';

  @override
  String get meters => 'metrów';

  @override
  String get datasetHeading => 'Baza punktów';

  @override
  String get datasetDescription =>
      'Baza punktów AED pochodzi z projektu openaedmap.org';

  @override
  String get defibrillatorsInDataset => 'Defibrylatory w bazie';

  @override
  String get defibrillatorsWithin5km => 'Defibrylatory w promieniu 5km';

  @override
  String get defibrillatorsWithImages => 'Punkty ze zdjęciami';

  @override
  String get version => 'Wersja';

  @override
  String get website => 'Strona projektu';

  @override
  String get author => 'Autor';

  @override
  String get understand => 'Rozumiem';

  @override
  String get dataSource => 'Pochodzenie danych';

  @override
  String get dataSourceDescription =>
      'Dane o lokalizacji defibrylatorów pochodzą z OpenStreetMap. Ich jakość może się różnić. Autor nie ponosi odpowiedzialności za poprawność danych. Zachęcamy do współtworzenia bazy na openaedmap.org';

  @override
  String get lastUpdate => 'Ostatnia aktualizacja';

  @override
  String get refreshing => 'Odświeżanie';

  @override
  String get refresh => 'Odśwież teraz';

  @override
  String get onboardingTitle0 => 'Witamy w aplikacji AED Map!';

  @override
  String get onboardingBody0 =>
      'Aplikacja stworzona do znajdowania defibrylatorów w Twojej okolicy';

  @override
  String get onboardingTitle1 => 'Zobacz pobliskie defibrylatory';

  @override
  String get onboardingBody1 =>
      'Znajdź najbliższy defibrylator w Twojej lokalizacji';

  @override
  String get onboardingTitle2 => 'Trasa do najbliższego defibrylatora';

  @override
  String get onboardingBody2 =>
      'Uzyskaj wskazówki do najbliższego defibrylatora';

  @override
  String get onboardingTitle3 => 'Używamy bazy danych OpenStreetMap';

  @override
  String get onboardingBody3 =>
      'Pamiętaj, że dane mogą nie być w 100% aktualne';

  @override
  String get openStreetMapAccount => 'Konto OpenStreetMap';

  @override
  String get signedInAs => 'Zalogowany jako';

  @override
  String get logout => 'Wyloguj się';

  @override
  String get viewOpenStreetMapNode => 'Zobacz węzeł OpenStreetMap';

  @override
  String get delete => 'Usuń';

  @override
  String get accountNumber => 'Numer konta';
}
