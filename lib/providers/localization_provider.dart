import 'package:flutter/material.dart';
import '../services/language_service.dart';

class LocalizationProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LocalizationProvider() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final savedLanguage = await LanguageService.getPrimaryLanguage();
    _locale = Locale(savedLanguage);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;

    // Save to language service
    await LanguageService.saveLanguagePreferences(
      primaryLanguage: locale.languageCode,
    );

    notifyListeners();
  }

  void clearLocale() {
    _locale = const Locale('en');
    notifyListeners();
  }

  // Get language name for display
  String getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'te':
        return 'తెలుగు (Telugu)';
      case 'hi':
        return 'हिंदी (Hindi)';
      case 'ta':
        return 'தமிழ் (Tamil)';
      case 'kn':
        return 'ಕನ್ನಡ (Kannada)';
      case 'ml':
        return 'മലയാളം (Malayalam)';
      case 'bn':
        return 'বাংলা (Bengali)';
      case 'mr':
        return 'मराठी (Marathi)';
      case 'gu':
        return 'ગુજરાતી (Gujarati)';
      case 'pa':
        return 'ਪੰਜਾਬੀ (Punjabi)';
      default:
        return 'English';
    }
  }
}
