// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'تشخیص خنده';

  @override
  String get welcome => 'خوش آمدید';

  @override
  String get login => 'ورود';

  @override
  String get logout => 'خروج';

  @override
  String get settings => 'تنظیمات';

  @override
  String get shop => 'فروشگاه';

  @override
  String get home => 'خانه';

  @override
  String get profile => 'پروفایل';

  @override
  String get language => 'زبان';

  @override
  String get english => 'انگلیسی';

  @override
  String get german => 'آلمانی';

  @override
  String get persian => 'فارسی';

  @override
  String get stars => 'ستاره';

  @override
  String get money => 'پول';

  @override
  String get coins => 'سکه';

  @override
  String get purchaseStars => 'خرید ستاره';

  @override
  String get starPackages => 'بسته‌های ستاره';

  @override
  String get smallPackage => 'بسته کوچک';

  @override
  String get mediumPackage => 'بسته متوسط';

  @override
  String get largePackage => 'بسته بزرگ';

  @override
  String get megaPackage => 'بسته فوق العاده';

  @override
  String get purchaseConfirmation => 'تایید خرید';

  @override
  String purchaseConfirmationMessage(int stars, int coins) {
    return 'آیا مطمئن هستید که می‌خواهید $stars ستاره به قیمت $coins سکه خریداری کنید؟';
  }

  @override
  String get confirm => 'تایید';

  @override
  String get cancel => 'لغو';

  @override
  String get purchaseSuccess => 'خرید موفق!';

  @override
  String purchaseSuccessMessage(int stars) {
    return 'شما با موفقیت $stars ستاره خریداری کردید!';
  }

  @override
  String get purchaseError => 'خطای خرید';

  @override
  String purchaseErrorMessage(String error) {
    return 'خرید ناموفق بود: $error';
  }

  @override
  String get insufficientFunds => 'موجودی کافی نیست';

  @override
  String get ok => 'تایید';

  @override
  String get games => 'بازی‌ها';

  @override
  String get play => 'بازی';

  @override
  String get score => 'امتیاز';

  @override
  String get highScore => 'بالاترین امتیاز';

  @override
  String get level => 'سطح';

  @override
  String get achievements => 'دستاوردها';

  @override
  String get statistics => 'آمار';

  @override
  String get totalGamesPlayed => 'کل بازی‌های انجام شده';

  @override
  String get totalStarsEarned => 'کل ستاره‌های کسب شده';

  @override
  String get averageScore => 'میانگین امتیاز';

  @override
  String get laughDetectionGame => 'بازی تشخیص خنده';

  @override
  String get startGame => 'شروع بازی';

  @override
  String get findingPlayers => 'جستجوی بازیکنان';

  @override
  String get gameInstructions =>
      'خودتان را به خنده بیاندازید تا امتیاز کسب کنید!';

  @override
  String get gameComplete => 'بازی تمام شد!';

  @override
  String get gameResults => 'نتایج بازی';

  @override
  String get playAgain => 'بازی مجدد';

  @override
  String get backToHome => 'بازگشت به خانه';

  @override
  String get notifications => 'اعلانات';

  @override
  String get about => 'درباره';

  @override
  String get gameSettings => 'تنظیمات بازی';

  @override
  String get soundEffects => 'جلوه‌های صوتی';

  @override
  String get enableGameSounds => 'فعال‌سازی صداهای بازی';

  @override
  String get vibration => 'لرزش';

  @override
  String get enableHapticFeedback => 'فعال‌سازی بازخورد لمسی';

  @override
  String get laughSensitivity => 'حساسیت خنده';

  @override
  String get adjustDetectionSensitivity => 'تنظیم حساسیت تشخیص';

  @override
  String get pushNotifications => 'اعلانات فوری';

  @override
  String get getGameUpdates => 'دریافت به‌روزرسانی‌های بازی';

  @override
  String get appVersion => 'نسخه برنامه';

  @override
  String get testLocationDetection => 'تست تشخیص موقعیت';

  @override
  String get debugCountryFlagDetection => 'عیب‌یابی تشخیص پرچم کشور';

  @override
  String get privacyPolicy => 'سیاست حفظ حریم خصوصی';

  @override
  String get viewOurPrivacyPolicy => 'مشاهده سیاست حفظ حریم خصوصی ما';

  @override
  String get changeProfileEmoji => 'تغییر ایموجی پروفایل';

  @override
  String get updateYourProfileEmoji => 'به‌روزرسانی ایموجی پروفایل';

  @override
  String get editUsername => 'ویرایش نام کاربری';

  @override
  String get changeYourDisplayName => 'تغییر نام نمایشی';

  @override
  String get termsOfService => 'شرایط خدمات';

  @override
  String get viewTermsAndConditions => 'مشاهده شرایط و ضوابط';

  @override
  String get preparingLaughDetector => 'آماده‌سازی تشخیص‌گر خنده...';

  @override
  String get cameraError => 'خطای دوربین';

  @override
  String get retry => 'تلاش مجدد';

  @override
  String timeForThreeStars(int seconds) {
    return 'زمان برای ۳ ستاره: $seconds ثانیه';
  }

  @override
  String get challenges => 'Challenges';

  @override
  String get selectChallenge => 'Select a Challenge';

  @override
  String get challengeDescription =>
      'Test your self-control with these fun challenges!';

  @override
  String get dontLaughChallenge => 'Don\'t Laugh Challenge';

  @override
  String get dontLaughDescription =>
      'Try not to laugh while watching funny content';

  @override
  String get comingSoon => 'Coming Soon!';

  @override
  String get stayTuned => 'Stay tuned for more exciting challenges';

  @override
  String get moreChallengesToCome =>
      'More exciting challenges are being developed. Stay tuned!';
}
