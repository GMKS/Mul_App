// STEP 1: Language Selection Service
// Save selection locally and in backend user profile.

import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class LanguageService {
  static const String _primaryLanguageKey = 'primary_language';
  static const String _secondaryLanguageKey = 'secondary_language';
  static const String _languageSelectedKey = 'language_selected';

  // Get primary language
  static Future<String> getPrimaryLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_primaryLanguageKey) ?? 'en';
  }

  // Get secondary language
  static Future<String?> getSecondaryLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_secondaryLanguageKey);
  }

  // Save language preferences locally
  static Future<void> saveLanguagePreferences({
    required String primaryLanguage,
    String? secondaryLanguage,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_primaryLanguageKey, primaryLanguage);
    if (secondaryLanguage != null && secondaryLanguage.isNotEmpty) {
      await prefs.setString(_secondaryLanguageKey, secondaryLanguage);
    }
    await prefs.setBool(_languageSelectedKey, true);
  }

  // Check if language has been selected
  static Future<bool> hasSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_languageSelectedKey) ?? false;
  }

  // Get both languages for feed filtering
  static Future<List<String>> getPreferredLanguages() async {
    final primary = await getPrimaryLanguage();
    final secondary = await getSecondaryLanguage();

    final languages = [primary];
    if (secondary != null && secondary.isNotEmpty && secondary != primary) {
      languages.add(secondary);
    }
    return languages;
  }

  // Get language display info
  static AppLanguage? getLanguageInfo(String code) {
    return AppLanguage.getByCode(code);
  }

  // Save to backend (mock implementation)
  static Future<void> syncToBackend(
      String userId, String primaryLang, String? secondaryLang) async {
    // TODO: Implement actual backend sync
    // Example API call:
    // await api.updateUserProfile(userId, {
    //   'primaryLanguage': primaryLang,
    //   'secondaryLanguage': secondaryLang,
    // });
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
