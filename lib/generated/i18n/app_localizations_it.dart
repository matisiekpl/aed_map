// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get heading => 'Informazioni';

  @override
  String subheading(int count) {
    return '$count DAE disponibili';
  }

  @override
  String get access => 'Accesso';

  @override
  String get closestAED => 'DAE più vicino';

  @override
  String get closerAEDAvailable => 'È disponibile un DAE più vicino';

  @override
  String get location => 'Posizione';

  @override
  String get operator => 'Operatore';

  @override
  String get openingHours => 'Orario di apertura';

  @override
  String get insideBuilding => 'All\'interno del edificio';

  @override
  String get contact => 'Contatto';

  @override
  String get noData => 'Nessun dato';

  @override
  String get navigate => 'Naviga';

  @override
  String get chooseMapApp => 'Scegli l\'applicazione di mappe';

  @override
  String get about => 'Informazioni sull\'applicazione';

  @override
  String get defibrillator => 'Defibrillatore';

  @override
  String runDistance(int minutes, int meters) {
    return 'Circa $minutes minuti di corsa (${meters}m)';
  }

  @override
  String distance(int kilometers) {
    return 'circa ${kilometers}km da qui';
  }

  @override
  String get noNetwork => 'Connessione di rete assente!';

  @override
  String get checkNetwork => 'Verifica la connessione di rete';

  @override
  String get retry => 'Riprova';

  @override
  String get yes => 'sì';

  @override
  String get no => 'no';

  @override
  String get accessYes => 'accessibile al pubblico';

  @override
  String get accessCustomers => 'durante l\'orario di lavoro';

  @override
  String get accessPrivate => 'con permesso del proprietario';

  @override
  String get accessPermissive => 'fino a nuovo avviso';

  @override
  String get accessNo => 'non disponibile';

  @override
  String get accessUnknown => 'accesso sconosciuto';

  @override
  String get chooseLocation =>
      'Seleziona la posizione del DAE che desideri aggiungere';

  @override
  String get cancel => 'Annulla';

  @override
  String get next => 'Avanti';

  @override
  String get edit => 'Modifica';

  @override
  String get imageOfDefibrillator => 'Immagine del defibrillatore';

  @override
  String get save => 'Salva';

  @override
  String get editDefibrillator => 'Modifica defibrillatore';

  @override
  String get information => 'Informazioni';

  @override
  String get enterDescription => 'Inserisci una descrizione';

  @override
  String get enterOperator => 'Inserisci l\'operatore';

  @override
  String get enterPhone => 'Inserisci il numero di telefono';

  @override
  String get longitude => 'Longitudine';

  @override
  String get latitude => 'Latitudine';

  @override
  String get chooseAccess => 'Scegli l\'accesso';

  @override
  String get calculatingRoute => 'Calcolo del percorso in corso...';

  @override
  String get stop => 'stop';

  @override
  String get minutes => 'minuti';

  @override
  String get seconds => 'secondi';

  @override
  String get meters => 'metri';

  @override
  String get datasetHeading => 'Database dei punti';

  @override
  String get datasetDescription =>
      'Il database dei punti AED proviene dal progetto openaedmap.org';

  @override
  String get defibrillatorsInDataset => 'Defibrillatori nel database';

  @override
  String get defibrillatorsWithin5km => 'Defibrillatori entro 5 km';

  @override
  String get defibrillatorsWithImages => 'Punti con immagini';

  @override
  String get version => 'Versione';

  @override
  String get website => 'Sito web del progetto';

  @override
  String get author => 'Autore';

  @override
  String get understand => 'Capisco';

  @override
  String get dataSource => 'Fonte dei dati';

  @override
  String get dataSourceDescription =>
      'I dati sulla posizione dei defibrillatori provengono da OpenStreetMap. La loro qualità può variare. L\'autore non è responsabile per la correttezza dei dati. Ti incoraggiamo a co-creare il database su openaedmap.org';

  @override
  String get lastUpdate => 'Ultimo aggiornamento';

  @override
  String get refreshing => 'Aggiornamento in corso';

  @override
  String get refresh => 'Aggiorna ora';

  @override
  String get onboardingTitle0 => 'Benvenuto nell\'app AED Map!';

  @override
  String get onboardingBody0 =>
      'App creata per trovare defibrillatori nella tua zona';

  @override
  String get onboardingTitle1 => 'Visualizza i defibrillatori nelle vicinanze';

  @override
  String get onboardingBody1 =>
      'Trova il defibrillatore più vicino alla tua posizione';

  @override
  String get onboardingTitle2 => 'Percorso verso il defibrillatore più vicino';

  @override
  String get onboardingBody2 =>
      'Ottieni indicazioni per il defibrillatore più vicino';

  @override
  String get onboardingTitle3 =>
      'Stiamo utilizzando il database di OpenStreetMap';

  @override
  String get onboardingBody3 =>
      'Tieni presente che i dati potrebbero non essere aggiornati al 100%';

  @override
  String get openStreetMapAccount => 'Account OpenStreetMap';

  @override
  String get signedInAs => 'Connesso come';

  @override
  String get logout => 'Disconnetti';

  @override
  String get viewOpenStreetMapNode => 'Visualizza nodo OpenStreetMap';

  @override
  String get delete => 'Elimina';

  @override
  String get accountNumber => 'Numero di account';

  @override
  String get add => 'Aggiungi';
}
