import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  
  Locale _locale = const Locale('en');
  
  Locale get locale => _locale;
  
  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('de'), // German
    Locale('fa'), // Persian
  ];
  
  static const Map<String, String> languageNames = {
    'en': 'English',
    'de': 'Deutsch',
    'fa': 'فارسی',
  };
  
  static const Map<String, String> languageNamesInEnglish = {
    'en': 'English',
    'de': 'German',
    'fa': 'Persian',
  };
  
  LanguageService() {
    _loadLanguage();
  }
  
  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey);
      if (languageCode != null) {
        _locale = Locale(languageCode);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading language preference: $e');
    }
  }
  
  Future<void> setLanguage(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, locale.languageCode);
      _locale = locale;
      notifyListeners();
    } catch (e) {
      print('Error saving language preference: $e');
    }
  }
  
  String getLanguageName(String languageCode) {
    return languageNames[languageCode] ?? languageCode;
  }
  
  String getLanguageNameInEnglish(String languageCode) {
    return languageNamesInEnglish[languageCode] ?? languageCode;
  }
  
  bool isRTL() {
    return _locale.languageCode == 'fa'; // Persian is RTL
  }
}
