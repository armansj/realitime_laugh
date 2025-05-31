// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Laugh Detection';

  @override
  String get welcome => 'Welcome';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get settings => 'Settings';

  @override
  String get shop => 'Shop';

  @override
  String get home => 'Home';

  @override
  String get profile => 'Profile';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get german => 'German';

  @override
  String get persian => 'Persian';

  @override
  String get stars => 'Stars';

  @override
  String get money => 'Money';

  @override
  String get coins => 'Coins';

  @override
  String get purchaseStars => 'Purchase Stars';

  @override
  String get starPackages => 'Star Packages';

  @override
  String get smallPackage => 'Small Package';

  @override
  String get mediumPackage => 'Medium Package';

  @override
  String get largePackage => 'Large Package';

  @override
  String get megaPackage => 'Mega Package';

  @override
  String get purchaseConfirmation => 'Purchase Confirmation';

  @override
  String purchaseConfirmationMessage(int stars, int coins) {
    return 'Are you sure you want to purchase $stars stars for $coins coins?';
  }

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get purchaseSuccess => 'Purchase Successful!';

  @override
  String purchaseSuccessMessage(int stars) {
    return 'You have successfully purchased $stars stars!';
  }

  @override
  String get purchaseError => 'Purchase Error';

  @override
  String purchaseErrorMessage(String error) {
    return 'Purchase failed: $error';
  }

  @override
  String get insufficientFunds => 'Insufficient funds';

  @override
  String get ok => 'OK';

  @override
  String get games => 'Games';

  @override
  String get play => 'Play';

  @override
  String get score => 'Score';

  @override
  String get highScore => 'High Score';

  @override
  String get level => 'Level';

  @override
  String get achievements => 'Achievements';

  @override
  String get statistics => 'Statistics';

  @override
  String get totalGamesPlayed => 'Total Games Played';

  @override
  String get totalStarsEarned => 'Total Stars Earned';

  @override
  String get averageScore => 'Average Score';

  @override
  String get laughDetectionGame => 'Laugh Detection Game';

  @override
  String get startGame => 'Start Game';

  @override
  String get gameInstructions => 'Make yourself laugh to earn points!';

  @override
  String get gameComplete => 'Game Complete!';

  @override
  String get gameResults => 'Game Results';

  @override
  String get playAgain => 'Play Again';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get notifications => 'Notifications';

  @override
  String get about => 'About';

  @override
  String get gameSettings => 'Game Settings';

  @override
  String get soundEffects => 'Sound Effects';

  @override
  String get enableGameSounds => 'Enable game sounds';

  @override
  String get vibration => 'Vibration';

  @override
  String get enableHapticFeedback => 'Enable haptic feedback';

  @override
  String get laughSensitivity => 'Laugh Sensitivity';

  @override
  String get adjustDetectionSensitivity => 'Adjust detection sensitivity';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get getGameUpdates => 'Get game updates';

  @override
  String get appVersion => 'App Version';

  @override
  String get testLocationDetection => 'Test Location Detection';

  @override
  String get debugCountryFlagDetection => 'Debug country flag detection';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get viewOurPrivacyPolicy => 'View our privacy policy';

  @override
  String get changeProfileEmoji => 'Change Profile Emoji';

  @override
  String get updateYourProfileEmoji => 'Update your profile emoji';

  @override
  String get editUsername => 'Edit Username';

  @override
  String get changeYourDisplayName => 'Change your display name';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get viewTermsAndConditions => 'View terms and conditions';

  @override
  String get preparingLaughDetector => 'Preparing Laugh Detector...';

  @override
  String get cameraError => 'Camera Error';

  @override
  String get retry => 'Retry';

  @override
  String timeForThreeStars(int seconds) {
    return 'Time for 3 Stars: ${seconds}s';
  }
}
