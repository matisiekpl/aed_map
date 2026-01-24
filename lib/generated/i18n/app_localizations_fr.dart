// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get heading => 'Informations';

  @override
  String subheading(int count) {
    return '$count DAE disponibles';
  }

  @override
  String get access => 'Accès';

  @override
  String get closestAED => 'DAE le plus proche';

  @override
  String get closerAEDAvailable => 'DAE plus proche disponible (appuyez)';

  @override
  String get location => 'Emplacement';

  @override
  String get operator => 'Opérateur';

  @override
  String get openingHours => 'Heures d\'ouverture';

  @override
  String get insideBuilding => 'À l\'intérieur d\'un bâtiment';

  @override
  String get contact => 'Contact';

  @override
  String get noData => 'Pas de données';

  @override
  String get navigate => 'Naviguer';

  @override
  String get chooseMapApp => 'Choisir l\'application de cartes';

  @override
  String get about => 'À propos de l\'application';

  @override
  String get defibrillator => 'Défibrillateur';

  @override
  String runDistance(int minutes, int meters) {
    return 'Environ $minutes minute(s) de course (${meters}m)';
  }

  @override
  String distance(int kilometers) {
    return 'à environ ${kilometers}km d\'ici';
  }

  @override
  String get noNetwork => 'Pas de connexion réseau !';

  @override
  String get checkNetwork => 'Vérifier la connexion réseau';

  @override
  String get retry => 'Réessayer';

  @override
  String get yes => 'oui';

  @override
  String get no => 'non';

  @override
  String get accessYes => 'accessible au public';

  @override
  String get accessCustomers => 'pendant les heures de travail';

  @override
  String get accessPrivate => 'avec autorisation du propriétaire';

  @override
  String get accessPermissive => 'jusqu\'à nouvel ordre';

  @override
  String get accessNo => 'non disponible';

  @override
  String get accessUnknown => 'accès inconnu';

  @override
  String get chooseLocation =>
      'Sélectionnez l\'emplacement du DAE que vous souhaitez ajouter';

  @override
  String get cancel => 'Annuler';

  @override
  String get next => 'Suivant';

  @override
  String get edit => 'Modifier';

  @override
  String get imageOfDefibrillator => 'Image du défibrillateur';

  @override
  String get save => 'Enregistrer';

  @override
  String get editDefibrillator => 'Modifier le défibrillateur';

  @override
  String get information => 'Information';

  @override
  String get enterDescription => 'Saisir une description';

  @override
  String get enterOperator => 'Saisir l\'opérateur';

  @override
  String get enterPhone => 'Saisir le numéro de téléphone';

  @override
  String get longitude => 'Longitude';

  @override
  String get latitude => 'Latitude';

  @override
  String get chooseAccess => 'Choisir l\'accès';

  @override
  String get calculatingRoute => 'Calcul de l\'itinéraire...';

  @override
  String get stop => 'Arrêter';

  @override
  String get minutes => 'minutes';

  @override
  String get seconds => 'secondes';

  @override
  String get meters => 'mètres';

  @override
  String get datasetHeading => 'Base de données des points';

  @override
  String get datasetDescription =>
      'La base de données des points AED provient du projet openaedmap.org';

  @override
  String get defibrillatorsInDataset =>
      'Défibrillateurs dans la base de données';

  @override
  String get defibrillatorsWithin5km => 'Défibrillateurs dans un rayon de 5 km';

  @override
  String get defibrillatorsWithImages => 'Points avec des images';

  @override
  String get version => 'Version';

  @override
  String get website => 'Site web du projet';

  @override
  String get author => 'Auteur';

  @override
  String get understand => 'Je comprends';

  @override
  String get dataSource => 'Source de données';

  @override
  String get dataSourceDescription =>
      'Les données sur l\'emplacement des défibrillateurs proviennent d\'OpenStreetMap. Leur qualité peut varier. L\'auteur n\'est pas responsable de l\'exactitude des données. Nous vous encourageons à co-créer la base de données sur openaedmap.org';

  @override
  String get lastUpdate => 'Dernière mise à jour';

  @override
  String get refreshing => 'Actualisation en cours';

  @override
  String get refresh => 'Actualiser maintenant';

  @override
  String get onboardingTitle0 =>
      'Bienvenue dans l\'application Carte des DAE !';

  @override
  String get onboardingBody0 =>
      'Application conçue pour trouver des défibrillateurs dans votre région';

  @override
  String get onboardingTitle1 => 'Voir les défibrillateurs à proximité';

  @override
  String get onboardingBody1 =>
      'Trouvez le défibrillateur le plus proche de votre emplacement';

  @override
  String get onboardingTitle2 =>
      'Itinéraire vers le défibrillateur le plus proche';

  @override
  String get onboardingBody2 =>
      'Obtenez des directions vers le défibrillateur le plus proche';

  @override
  String get onboardingTitle3 =>
      'Nous utilisons la base de données OpenStreetMap';

  @override
  String get onboardingBody3 =>
      'Gardez à l\'esprit que les données peuvent ne pas être à jour à 100%';

  @override
  String get openStreetMapAccount => 'Cuenta de OpenStreetMap';

  @override
  String get signedInAs => 'Conectado como';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get viewOpenStreetMapNode => 'Voir le nœud OpenStreetMap';

  @override
  String get delete => 'Supprimer';

  @override
  String get accountNumber => 'Numéro de compte';

  @override
  String get add => 'Ajouter';

  @override
  String get contactAuthorDescription =>
      'Si vous avez des questions ou des retours, n\'hésitez pas à me contacter sur l\'une de ces plateformes.';
}
