import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'i18n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('pl')
  ];

  /// No description provided for @heading.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get heading;

  /// No description provided for @subheading.
  ///
  /// In en, this message translates to:
  /// **'{count} AEDs available'**
  String subheading(int count);

  /// No description provided for @access.
  ///
  /// In en, this message translates to:
  /// **'Access'**
  String get access;

  /// No description provided for @closestAED.
  ///
  /// In en, this message translates to:
  /// **'Closest AED'**
  String get closestAED;

  /// No description provided for @closerAEDAvailable.
  ///
  /// In en, this message translates to:
  /// **'Closer AED is available (tap)'**
  String get closerAEDAvailable;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @operator.
  ///
  /// In en, this message translates to:
  /// **'Operator'**
  String get operator;

  /// No description provided for @openingHours.
  ///
  /// In en, this message translates to:
  /// **'Opening hours'**
  String get openingHours;

  /// No description provided for @insideBuilding.
  ///
  /// In en, this message translates to:
  /// **'Inside building'**
  String get insideBuilding;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @navigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get navigate;

  /// No description provided for @chooseMapApp.
  ///
  /// In en, this message translates to:
  /// **'Choose maps application'**
  String get chooseMapApp;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About the application'**
  String get about;

  /// No description provided for @defibrillator.
  ///
  /// In en, this message translates to:
  /// **'Defibrillator'**
  String get defibrillator;

  /// No description provided for @runDistance.
  ///
  /// In en, this message translates to:
  /// **'~{minutes} minute(s) of running ({meters}m)'**
  String runDistance(int minutes, int meters);

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'about {kilometers}km from here'**
  String distance(int kilometers);

  /// No description provided for @noNetwork.
  ///
  /// In en, this message translates to:
  /// **'No network connection!'**
  String get noNetwork;

  /// No description provided for @checkNetwork.
  ///
  /// In en, this message translates to:
  /// **'Check network connection'**
  String get checkNetwork;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'no'**
  String get no;

  /// No description provided for @accessYes.
  ///
  /// In en, this message translates to:
  /// **'publicly accessible'**
  String get accessYes;

  /// No description provided for @accessCustomers.
  ///
  /// In en, this message translates to:
  /// **'during work hours'**
  String get accessCustomers;

  /// No description provided for @accessPrivate.
  ///
  /// In en, this message translates to:
  /// **'with owner\'s permit'**
  String get accessPrivate;

  /// No description provided for @accessPermissive.
  ///
  /// In en, this message translates to:
  /// **'until further notice'**
  String get accessPermissive;

  /// No description provided for @accessNo.
  ///
  /// In en, this message translates to:
  /// **'unavailable'**
  String get accessNo;

  /// No description provided for @accessUnknown.
  ///
  /// In en, this message translates to:
  /// **'unknown access'**
  String get accessUnknown;

  /// No description provided for @chooseLocation.
  ///
  /// In en, this message translates to:
  /// **'Select the location of the AED you want to add'**
  String get chooseLocation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @imageOfDefibrillator.
  ///
  /// In en, this message translates to:
  /// **'Image of defibrillator'**
  String get imageOfDefibrillator;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @editDefibrillator.
  ///
  /// In en, this message translates to:
  /// **'Edit defibrillator'**
  String get editDefibrillator;

  /// No description provided for @information.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// No description provided for @enterDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter description'**
  String get enterDescription;

  /// No description provided for @enterOperator.
  ///
  /// In en, this message translates to:
  /// **'Enter operator'**
  String get enterOperator;

  /// No description provided for @enterPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhone;

  /// No description provided for @longitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// No description provided for @latitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// No description provided for @chooseAccess.
  ///
  /// In en, this message translates to:
  /// **'Choose access'**
  String get chooseAccess;

  /// No description provided for @calculatingRoute.
  ///
  /// In en, this message translates to:
  /// **'Calculating route...'**
  String get calculatingRoute;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'stop'**
  String get stop;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get seconds;

  /// No description provided for @meters.
  ///
  /// In en, this message translates to:
  /// **'meters'**
  String get meters;

  /// No description provided for @datasetHeading.
  ///
  /// In en, this message translates to:
  /// **'Points Database'**
  String get datasetHeading;

  /// No description provided for @datasetDescription.
  ///
  /// In en, this message translates to:
  /// **'The AED points database comes from the openaedmap.org project.'**
  String get datasetDescription;

  /// No description provided for @defibrillatorsInDataset.
  ///
  /// In en, this message translates to:
  /// **'Defibrillators in the database'**
  String get defibrillatorsInDataset;

  /// No description provided for @defibrillatorsWithin5km.
  ///
  /// In en, this message translates to:
  /// **'Defibrillators within 5km radius'**
  String get defibrillatorsWithin5km;

  /// No description provided for @defibrillatorsWithImages.
  ///
  /// In en, this message translates to:
  /// **'Points with images'**
  String get defibrillatorsWithImages;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Project website'**
  String get website;

  /// No description provided for @author.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get author;

  /// No description provided for @understand.
  ///
  /// In en, this message translates to:
  /// **'I understand'**
  String get understand;

  /// No description provided for @dataSource.
  ///
  /// In en, this message translates to:
  /// **'Data source'**
  String get dataSource;

  /// No description provided for @dataSourceDescription.
  ///
  /// In en, this message translates to:
  /// **'The data about the location of defibrillators comes from OpenStreetMap. Their quality may vary. The author is not responsible for the correctness of the data. We encourage you to co-create the database on openaedmap.org'**
  String get dataSourceDescription;

  /// No description provided for @lastUpdate.
  ///
  /// In en, this message translates to:
  /// **'Last update'**
  String get lastUpdate;

  /// No description provided for @refreshing.
  ///
  /// In en, this message translates to:
  /// **'Refreshing'**
  String get refreshing;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh now'**
  String get refresh;

  /// No description provided for @onboardingTitle0.
  ///
  /// In en, this message translates to:
  /// **'Welcome to AED Map app!'**
  String get onboardingTitle0;

  /// No description provided for @onboardingBody0.
  ///
  /// In en, this message translates to:
  /// **'App made for finding defibrillators in your area'**
  String get onboardingBody0;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'View nearby defibrillators'**
  String get onboardingTitle1;

  /// No description provided for @onboardingBody1.
  ///
  /// In en, this message translates to:
  /// **'Find the closest defibrillator to your location'**
  String get onboardingBody1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Route to the nearest defibrillator'**
  String get onboardingTitle2;

  /// No description provided for @onboardingBody2.
  ///
  /// In en, this message translates to:
  /// **'Get directions to the nearest defibrillator'**
  String get onboardingBody2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'We are using OpenStreetMap database'**
  String get onboardingTitle3;

  /// No description provided for @onboardingBody3.
  ///
  /// In en, this message translates to:
  /// **'Keep in mind that the data may not be up 100% up to date'**
  String get onboardingBody3;

  /// No description provided for @openStreetMapAccount.
  ///
  /// In en, this message translates to:
  /// **'OpenStreetMap account'**
  String get openStreetMapAccount;

  /// No description provided for @signedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as'**
  String get signedInAs;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @viewOpenStreetMapNode.
  ///
  /// In en, this message translates to:
  /// **'View OpenStreetMap node'**
  String get viewOpenStreetMapNode;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @accountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account number'**
  String get accountNumber;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'de',
        'en',
        'es',
        'fr',
        'it',
        'pl'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
