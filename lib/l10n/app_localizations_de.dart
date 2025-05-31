// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Lachen Erkennung';

  @override
  String get welcome => 'Willkommen';

  @override
  String get login => 'Anmelden';

  @override
  String get logout => 'Abmelden';

  @override
  String get settings => 'Einstellungen';

  @override
  String get shop => 'Shop';

  @override
  String get home => 'Startseite';

  @override
  String get profile => 'Profil';

  @override
  String get language => 'Sprache';

  @override
  String get english => 'Englisch';

  @override
  String get german => 'Deutsch';

  @override
  String get persian => 'Persisch';

  @override
  String get stars => 'Sterne';

  @override
  String get money => 'Geld';

  @override
  String get coins => 'Münzen';

  @override
  String get purchaseStars => 'Sterne kaufen';

  @override
  String get starPackages => 'Sterne-Pakete';

  @override
  String get smallPackage => 'Kleines Paket';

  @override
  String get mediumPackage => 'Mittleres Paket';

  @override
  String get largePackage => 'Großes Paket';

  @override
  String get megaPackage => 'Mega-Paket';

  @override
  String get purchaseConfirmation => 'Kaufbestätigung';

  @override
  String purchaseConfirmationMessage(int stars, int coins) {
    return 'Sind Sie sicher, dass Sie $stars Sterne für $coins Münzen kaufen möchten?';
  }

  @override
  String get confirm => 'Bestätigen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get purchaseSuccess => 'Kauf erfolgreich!';

  @override
  String purchaseSuccessMessage(int stars) {
    return 'Sie haben erfolgreich $stars Sterne gekauft!';
  }

  @override
  String get purchaseError => 'Kauffehler';

  @override
  String purchaseErrorMessage(String error) {
    return 'Kauf fehlgeschlagen: $error';
  }

  @override
  String get insufficientFunds => 'Nicht genügend Guthaben';

  @override
  String get ok => 'OK';

  @override
  String get games => 'Spiele';

  @override
  String get play => 'Spielen';

  @override
  String get score => 'Punktzahl';

  @override
  String get highScore => 'Bestpunktzahl';

  @override
  String get level => 'Level';

  @override
  String get achievements => 'Erfolge';

  @override
  String get statistics => 'Statistiken';

  @override
  String get totalGamesPlayed => 'Gespielte Spiele insgesamt';

  @override
  String get totalStarsEarned => 'Verdiente Sterne insgesamt';

  @override
  String get averageScore => 'Durchschnittliche Punktzahl';

  @override
  String get laughDetectionGame => 'Lachen-Erkennungsspiel';

  @override
  String get startGame => 'Spiel starten';

  @override
  String get gameInstructions =>
      'Bring dich zum Lachen, um Punkte zu verdienen!';

  @override
  String get gameComplete => 'Spiel beendet!';

  @override
  String get gameResults => 'Spielergebnisse';

  @override
  String get playAgain => 'Nochmal spielen';

  @override
  String get backToHome => 'Zurück zur Startseite';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get about => 'Über';

  @override
  String get gameSettings => 'Spieleinstellungen';

  @override
  String get soundEffects => 'Soundeffekte';

  @override
  String get enableGameSounds => 'Spielsounds aktivieren';

  @override
  String get vibration => 'Vibration';

  @override
  String get enableHapticFeedback => 'Haptisches Feedback aktivieren';

  @override
  String get laughSensitivity => 'Lach-Empfindlichkeit';

  @override
  String get adjustDetectionSensitivity => 'Erkennungsempfindlichkeit anpassen';

  @override
  String get pushNotifications => 'Push-Benachrichtigungen';

  @override
  String get getGameUpdates => 'Spiel-Updates erhalten';

  @override
  String get appVersion => 'App-Version';

  @override
  String get testLocationDetection => 'Standorterkennung testen';

  @override
  String get debugCountryFlagDetection => 'Länderflaggen-Erkennung debuggen';

  @override
  String get privacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get viewOurPrivacyPolicy => 'Unsere Datenschutzrichtlinie anzeigen';

  @override
  String get changeProfileEmoji => 'Profil-Emoji ändern';

  @override
  String get updateYourProfileEmoji => 'Profil-Emoji aktualisieren';

  @override
  String get editUsername => 'Benutzername bearbeiten';

  @override
  String get changeYourDisplayName => 'Anzeigename ändern';

  @override
  String get termsOfService => 'Nutzungsbedingungen';

  @override
  String get viewTermsAndConditions =>
      'Allgemeine Geschäftsbedingungen anzeigen';

  @override
  String get preparingLaughDetector => 'Lachen-Detektor wird vorbereitet...';

  @override
  String get cameraError => 'Kamera-Fehler';

  @override
  String get retry => 'Wiederholen';

  @override
  String timeForThreeStars(int seconds) {
    return 'Zeit für 3 Sterne: ${seconds}s';
  }
}
