import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
  ];

  /// The title of the application
  ///
  /// In de, this message translates to:
  /// **'MyFriends'**
  String get appTitle;

  /// Welcome message on home screen
  ///
  /// In de, this message translates to:
  /// **'Willkommen bei MyFriends'**
  String get welcomeTitle;

  /// Subtitle on home screen
  ///
  /// In de, this message translates to:
  /// **'Behalte alle besonderen Menschen im Blick'**
  String get welcomeSubtitle;

  /// Add friend button text
  ///
  /// In de, this message translates to:
  /// **'Neuen Freund hinzufügen'**
  String get addFriend;

  /// My friends button/title
  ///
  /// In de, this message translates to:
  /// **'Meine Freunde'**
  String get myFriends;

  /// Quick add tooltip
  ///
  /// In de, this message translates to:
  /// **'Freund hinzufügen'**
  String get quickAdd;

  /// Coming soon message
  ///
  /// In de, this message translates to:
  /// **'Demnächst verfügbar'**
  String get comingSoon;

  /// Name field label
  ///
  /// In de, this message translates to:
  /// **'Name'**
  String get name;

  /// Nickname field label
  ///
  /// In de, this message translates to:
  /// **'Spitzname'**
  String get nickname;

  /// Location field label
  ///
  /// In de, this message translates to:
  /// **'Ort'**
  String get location;

  /// First met label
  ///
  /// In de, this message translates to:
  /// **'Erstes Treffen'**
  String get firstMet;

  /// Birthday field label
  ///
  /// In de, this message translates to:
  /// **'Geburtstag'**
  String get birthday;

  /// Phone field label
  ///
  /// In de, this message translates to:
  /// **'Telefon'**
  String get phone;

  /// Email field label
  ///
  /// In de, this message translates to:
  /// **'E-Mail'**
  String get email;

  /// Notes field label
  ///
  /// In de, this message translates to:
  /// **'Notizen'**
  String get notes;

  /// Save button text
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get save;

  /// Cancel button text
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get cancel;

  /// Delete button text
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get delete;

  /// Edit button text
  ///
  /// In de, this message translates to:
  /// **'Bearbeiten'**
  String get edit;

  /// Search placeholder
  ///
  /// In de, this message translates to:
  /// **'Suchen...'**
  String get search;

  /// Empty state message
  ///
  /// In de, this message translates to:
  /// **'Noch keine Freunde hinzugefügt'**
  String get noFriendsYet;

  /// Empty state call to action
  ///
  /// In de, this message translates to:
  /// **'Füge deinen ersten Freund hinzu!'**
  String get addYourFirstFriend;

  /// Take photo button
  ///
  /// In de, this message translates to:
  /// **'Foto aufnehmen'**
  String get takePhoto;

  /// Choose from gallery button
  ///
  /// In de, this message translates to:
  /// **'Aus Galerie wählen'**
  String get chooseFromGallery;

  /// Current location button
  ///
  /// In de, this message translates to:
  /// **'Aktueller Standort'**
  String get currentLocation;

  /// Enter location manually
  ///
  /// In de, this message translates to:
  /// **'Manuell eingeben'**
  String get enterManually;

  /// Required field validation message
  ///
  /// In de, this message translates to:
  /// **'Dieses Feld ist erforderlich'**
  String get requiredField;

  /// Invalid email validation message
  ///
  /// In de, this message translates to:
  /// **'Ungültige E-Mail-Adresse'**
  String get invalidEmail;

  /// Invalid phone validation message
  ///
  /// In de, this message translates to:
  /// **'Ungültige Telefonnummer'**
  String get invalidPhone;

  /// Friend saved success message
  ///
  /// In de, this message translates to:
  /// **'Freund erfolgreich gespeichert'**
  String get friendSaved;

  /// Friend deleted message
  ///
  /// In de, this message translates to:
  /// **'Freund wurde gelöscht'**
  String get friendDeleted;

  /// Error saving friend
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Speichern des Freundes'**
  String get errorSavingFriend;

  /// Confirm delete dialog title
  ///
  /// In de, this message translates to:
  /// **'Löschen bestätigen'**
  String get confirmDelete;

  /// Confirm delete dialog message
  ///
  /// In de, this message translates to:
  /// **'Möchtest du diesen Freund wirklich löschen?'**
  String get confirmDeleteMessage;

  /// Yes button
  ///
  /// In de, this message translates to:
  /// **'Ja'**
  String get yes;

  /// No button
  ///
  /// In de, this message translates to:
  /// **'Nein'**
  String get no;

  /// Settings title
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settings;

  /// Language setting
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get language;

  /// Dark mode setting
  ///
  /// In de, this message translates to:
  /// **'Dunkler Modus'**
  String get darkMode;

  /// About section
  ///
  /// In de, this message translates to:
  /// **'Über'**
  String get about;

  /// Version label
  ///
  /// In de, this message translates to:
  /// **'Version'**
  String get version;

  /// Privacy policy link
  ///
  /// In de, this message translates to:
  /// **'Datenschutzrichtlinie'**
  String get privacyPolicy;

  /// Terms of service link
  ///
  /// In de, this message translates to:
  /// **'Nutzungsbedingungen'**
  String get termsOfService;

  /// Friend books/groups
  ///
  /// In de, this message translates to:
  /// **'Freundesbücher'**
  String get friendBooks;

  /// Create friend book button
  ///
  /// In de, this message translates to:
  /// **'Neues Freundesbuch'**
  String get createFriendBook;

  /// Friend book name field
  ///
  /// In de, this message translates to:
  /// **'Name des Freundesbuchs'**
  String get friendBookName;

  /// I like field label
  ///
  /// In de, this message translates to:
  /// **'Ich mag'**
  String get iLike;

  /// I don't like field label
  ///
  /// In de, this message translates to:
  /// **'Ich mag nicht'**
  String get iDontLike;

  /// Hobbies field label
  ///
  /// In de, this message translates to:
  /// **'Hobbys'**
  String get hobbies;

  /// Favorite color field
  ///
  /// In de, this message translates to:
  /// **'Lieblingsfarbe'**
  String get favoriteColor;

  /// Home location field
  ///
  /// In de, this message translates to:
  /// **'Wohnort'**
  String get homeLocation;

  /// Work/occupation field
  ///
  /// In de, this message translates to:
  /// **'Beruf'**
  String get work;

  /// Social media field
  ///
  /// In de, this message translates to:
  /// **'Social Media'**
  String get socialMedia;

  /// Classic template name
  ///
  /// In de, this message translates to:
  /// **'Klassisch'**
  String get classicTemplate;

  /// Modern template name
  ///
  /// In de, this message translates to:
  /// **'Modern'**
  String get modernTemplate;

  /// Custom template name
  ///
  /// In de, this message translates to:
  /// **'Benutzerdefiniert'**
  String get customTemplate;

  /// Select template prompt
  ///
  /// In de, this message translates to:
  /// **'Vorlage auswählen'**
  String get selectTemplate;

  /// Location captured success message
  ///
  /// In de, this message translates to:
  /// **'Standort erfasst'**
  String get locationCaptured;

  /// Location error title
  ///
  /// In de, this message translates to:
  /// **'Standort-Fehler'**
  String get locationError;

  /// Permission denied title
  ///
  /// In de, this message translates to:
  /// **'Berechtigung verweigert'**
  String get permissionDenied;

  /// Location disabled title
  ///
  /// In de, this message translates to:
  /// **'Standort deaktiviert'**
  String get locationDisabled;

  /// Open settings button
  ///
  /// In de, this message translates to:
  /// **'Einstellungen öffnen'**
  String get openSettings;

  /// OK button
  ///
  /// In de, this message translates to:
  /// **'OK'**
  String get ok;

  /// Photo captured success message
  ///
  /// In de, this message translates to:
  /// **'Foto aufgenommen'**
  String get photoCaptured;

  /// Photo selected from gallery message
  ///
  /// In de, this message translates to:
  /// **'Foto ausgewählt'**
  String get photoSelected;

  /// Photo error title
  ///
  /// In de, this message translates to:
  /// **'Foto-Fehler'**
  String get photoError;

  /// Camera permission denied message
  ///
  /// In de, this message translates to:
  /// **'Kamera-Berechtigung wurde verweigert. Bitte erlaube den Zugriff in den Einstellungen.'**
  String get cameraPermissionDenied;

  /// Gallery permission denied message
  ///
  /// In de, this message translates to:
  /// **'Galerie-Berechtigung wurde verweigert. Bitte erlaube den Zugriff in den Einstellungen.'**
  String get galleryPermissionDenied;

  /// No camera found error
  ///
  /// In de, this message translates to:
  /// **'Keine Kamera auf diesem Gerät gefunden.'**
  String get cameraNotFound;

  /// Photo file too large error
  ///
  /// In de, this message translates to:
  /// **'Das Foto ist zu groß. Maximale Dateigröße: 10MB.'**
  String get photoTooLarge;

  /// Unsupported photo format error
  ///
  /// In de, this message translates to:
  /// **'Nicht unterstütztes Fotoformat. Bitte verwende JPG, PNG oder HEIC.'**
  String get unsupportedPhotoFormat;

  /// Photo source selection dialog title
  ///
  /// In de, this message translates to:
  /// **'Foto hinzufügen'**
  String get photoSourceDialog;

  /// Remove photo option
  ///
  /// In de, this message translates to:
  /// **'Foto entfernen'**
  String get removePhoto;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

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
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
