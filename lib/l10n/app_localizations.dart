import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';

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
    Locale('fa'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Laugh Detection'**
  String get appTitle;

  /// Welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Logout button text
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Settings page title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Shop page title
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shop;

  /// Home page title
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Profile page title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// German language option
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// Persian language option
  ///
  /// In en, this message translates to:
  /// **'Persian'**
  String get persian;

  /// Stars currency label
  ///
  /// In en, this message translates to:
  /// **'Stars'**
  String get stars;

  /// Money currency label
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get money;

  /// Coins currency label
  ///
  /// In en, this message translates to:
  /// **'Coins'**
  String get coins;

  /// Purchase stars section title
  ///
  /// In en, this message translates to:
  /// **'Purchase Stars'**
  String get purchaseStars;

  /// Star packages section title
  ///
  /// In en, this message translates to:
  /// **'Star Packages'**
  String get starPackages;

  /// Small star package name
  ///
  /// In en, this message translates to:
  /// **'Small Package'**
  String get smallPackage;

  /// Medium star package name
  ///
  /// In en, this message translates to:
  /// **'Medium Package'**
  String get mediumPackage;

  /// Large star package name
  ///
  /// In en, this message translates to:
  /// **'Large Package'**
  String get largePackage;

  /// Mega star package name
  ///
  /// In en, this message translates to:
  /// **'Mega Package'**
  String get megaPackage;

  /// Purchase confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Purchase Confirmation'**
  String get purchaseConfirmation;

  /// Purchase confirmation dialog message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to purchase {stars} stars for {coins} coins?'**
  String purchaseConfirmationMessage(int stars, int coins);

  /// Confirm button text
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Purchase success message
  ///
  /// In en, this message translates to:
  /// **'Purchase Successful!'**
  String get purchaseSuccess;

  /// Purchase success detailed message
  ///
  /// In en, this message translates to:
  /// **'You have successfully purchased {stars} stars!'**
  String purchaseSuccessMessage(int stars);

  /// Purchase error dialog title
  ///
  /// In en, this message translates to:
  /// **'Purchase Error'**
  String get purchaseError;

  /// Purchase error message
  ///
  /// In en, this message translates to:
  /// **'Purchase failed: {error}'**
  String purchaseErrorMessage(String error);

  /// Insufficient funds error message
  ///
  /// In en, this message translates to:
  /// **'Insufficient funds'**
  String get insufficientFunds;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Games section title
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get games;

  /// Play button text
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// Score label
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// High score label
  ///
  /// In en, this message translates to:
  /// **'High Score'**
  String get highScore;

  /// Level label
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// Achievements section title
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// Statistics section title
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// Total games played statistic
  ///
  /// In en, this message translates to:
  /// **'Total Games Played'**
  String get totalGamesPlayed;

  /// Total stars earned statistic
  ///
  /// In en, this message translates to:
  /// **'Total Stars Earned'**
  String get totalStarsEarned;

  /// Average score statistic
  ///
  /// In en, this message translates to:
  /// **'Average Score'**
  String get averageScore;

  /// Laugh detection game title
  ///
  /// In en, this message translates to:
  /// **'Laugh Detection Game'**
  String get laughDetectionGame;

  /// Start game button text
  ///
  /// In en, this message translates to:
  /// **'Start Game'**
  String get startGame;

  /// Game instructions text
  ///
  /// In en, this message translates to:
  /// **'Make yourself laugh to earn points!'**
  String get gameInstructions;

  /// Game complete message
  ///
  /// In en, this message translates to:
  /// **'Game Complete!'**
  String get gameComplete;

  /// Game results title
  ///
  /// In en, this message translates to:
  /// **'Game Results'**
  String get gameResults;

  /// Play again button text
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get playAgain;

  /// Back to home button text
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// Notifications section title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// About section title
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Game settings section title
  ///
  /// In en, this message translates to:
  /// **'Game Settings'**
  String get gameSettings;

  /// Sound effects setting
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get soundEffects;

  /// Sound effects description
  ///
  /// In en, this message translates to:
  /// **'Enable game sounds'**
  String get enableGameSounds;

  /// Vibration setting
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// Vibration setting description
  ///
  /// In en, this message translates to:
  /// **'Enable haptic feedback'**
  String get enableHapticFeedback;

  /// Laugh sensitivity setting
  ///
  /// In en, this message translates to:
  /// **'Laugh Sensitivity'**
  String get laughSensitivity;

  /// Laugh sensitivity description
  ///
  /// In en, this message translates to:
  /// **'Adjust detection sensitivity'**
  String get adjustDetectionSensitivity;

  /// Push notifications setting
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// Push notifications description
  ///
  /// In en, this message translates to:
  /// **'Get game updates'**
  String get getGameUpdates;

  /// App version label
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// Test location detection option
  ///
  /// In en, this message translates to:
  /// **'Test Location Detection'**
  String get testLocationDetection;

  /// Test location detection description
  ///
  /// In en, this message translates to:
  /// **'Debug country flag detection'**
  String get debugCountryFlagDetection;

  /// Privacy policy option
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Privacy policy description
  ///
  /// In en, this message translates to:
  /// **'View our privacy policy'**
  String get viewOurPrivacyPolicy;

  /// Change profile emoji option
  ///
  /// In en, this message translates to:
  /// **'Change Profile Emoji'**
  String get changeProfileEmoji;

  /// Change profile emoji description
  ///
  /// In en, this message translates to:
  /// **'Update your profile emoji'**
  String get updateYourProfileEmoji;

  /// Edit username option
  ///
  /// In en, this message translates to:
  /// **'Edit Username'**
  String get editUsername;

  /// Edit username description
  ///
  /// In en, this message translates to:
  /// **'Change your display name'**
  String get changeYourDisplayName;

  /// Terms of service option
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// Terms of service description
  ///
  /// In en, this message translates to:
  /// **'View terms and conditions'**
  String get viewTermsAndConditions;

  /// Loading message for laugh detector
  ///
  /// In en, this message translates to:
  /// **'Preparing Laugh Detector...'**
  String get preparingLaughDetector;

  /// Camera error title
  ///
  /// In en, this message translates to:
  /// **'Camera Error'**
  String get cameraError;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Countdown timer for 3 stars
  ///
  /// In en, this message translates to:
  /// **'Time for 3 Stars: {seconds}s'**
  String timeForThreeStars(int seconds);
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
      <String>['de', 'en', 'fa'].contains(locale.languageCode);

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
    case 'fa':
      return AppLocalizationsFa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
