// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get heading => 'Information';

  @override
  String subheading(int count) {
    return '$count AEDs available';
  }

  @override
  String get access => 'Access';

  @override
  String get closestAED => 'Closest AED';

  @override
  String get closerAEDAvailable => 'Closer AED is available (tap)';

  @override
  String get location => 'Location';

  @override
  String get operator => 'Operator';

  @override
  String get openingHours => 'Opening hours';

  @override
  String get insideBuilding => 'Inside building';

  @override
  String get contact => 'Contact';

  @override
  String get noData => 'No data';

  @override
  String get navigate => 'Navigate';

  @override
  String get chooseMapApp => 'Choose maps application';

  @override
  String get about => 'About the application';

  @override
  String get defibrillator => 'Defibrillator';

  @override
  String runDistance(int minutes, int meters) {
    return '~$minutes minute(s) of running (${meters}m)';
  }

  @override
  String distance(int kilometers) {
    return 'about ${kilometers}km from here';
  }

  @override
  String get noNetwork => 'No network connection!';

  @override
  String get checkNetwork => 'Check network connection';

  @override
  String get retry => 'Retry';

  @override
  String get yes => 'yes';

  @override
  String get no => 'no';

  @override
  String get accessYes => 'publicly accessible';

  @override
  String get accessCustomers => 'during work hours';

  @override
  String get accessPrivate => 'with owner\'s permit';

  @override
  String get accessPermissive => 'until further notice';

  @override
  String get accessNo => 'unavailable';

  @override
  String get accessUnknown => 'unknown access';

  @override
  String get chooseLocation => 'Select the location of the AED you want to add';

  @override
  String get cancel => 'Cancel';

  @override
  String get next => 'Next';

  @override
  String get edit => 'Edit';

  @override
  String get imageOfDefibrillator => 'Image of defibrillator';

  @override
  String get save => 'Save';

  @override
  String get editDefibrillator => 'Edit defibrillator';

  @override
  String get information => 'Information';

  @override
  String get enterDescription => 'Enter description';

  @override
  String get enterOperator => 'Enter operator';

  @override
  String get enterPhone => 'Enter phone number';

  @override
  String get longitude => 'Longitude';

  @override
  String get latitude => 'Latitude';

  @override
  String get chooseAccess => 'Choose access';

  @override
  String get calculatingRoute => 'Calculating route...';

  @override
  String get stop => 'stop';

  @override
  String get minutes => 'minutes';

  @override
  String get seconds => 'seconds';

  @override
  String get meters => 'meters';

  @override
  String get datasetHeading => 'Points Database';

  @override
  String get datasetDescription =>
      'The AED points database comes from the openaedmap.org project.';

  @override
  String get defibrillatorsInDataset => 'Defibrillators in the database';

  @override
  String get defibrillatorsWithin5km => 'Defibrillators within 5km radius';

  @override
  String get defibrillatorsWithImages => 'Points with images';

  @override
  String get version => 'Version';

  @override
  String get website => 'Project website';

  @override
  String get author => 'Author';

  @override
  String get understand => 'I understand';

  @override
  String get dataSource => 'Data source';

  @override
  String get dataSourceDescription =>
      'The data about the location of defibrillators comes from OpenStreetMap. Their quality may vary. The author is not responsible for the correctness of the data. We encourage you to co-create the database on openaedmap.org';

  @override
  String get lastUpdate => 'Last update';

  @override
  String get refreshing => 'Refreshing';

  @override
  String get refresh => 'Refresh now';

  @override
  String get onboardingTitle0 => 'Welcome to AED Map app!';

  @override
  String get onboardingBody0 =>
      'App made for finding defibrillators in your area';

  @override
  String get onboardingTitle1 => 'View nearby defibrillators';

  @override
  String get onboardingBody1 =>
      'Find the closest defibrillator to your location';

  @override
  String get onboardingTitle2 => 'Route to the nearest defibrillator';

  @override
  String get onboardingBody2 => 'Get directions to the nearest defibrillator';

  @override
  String get onboardingTitle3 => 'We are using OpenStreetMap database';

  @override
  String get onboardingBody3 =>
      'Keep in mind that the data may not be up 100% up to date';

  @override
  String get openStreetMapAccount => 'OpenStreetMap account';

  @override
  String get signedInAs => 'Signed in as';

  @override
  String get logout => 'Logout';

  @override
  String get viewOpenStreetMapNode => 'View OpenStreetMap node';

  @override
  String get delete => 'Delete';

  @override
  String get accountNumber => 'Account number';

  @override
  String get add => 'Add';

  @override
  String get contactAuthorDescription =>
      'If you\'ve any questions or feedback don\'t hesitate to message me on any of these platforms.';
}
