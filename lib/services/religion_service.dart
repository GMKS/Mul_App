/// Religion Service
/// Manages user's religion preference with local storage

import 'package:shared_preferences/shared_preferences.dart';
import '../models/devotional_video_model.dart';

class ReligionService {
  static const String _religionKey = 'user_religion';
  static const String _religionSetKey = 'religion_is_set';

  /// Get user's selected religion
  static Future<Religion?> getSelectedReligion() async {
    final prefs = await SharedPreferences.getInstance();
    final religionStr = prefs.getString(_religionKey);
    return Religion.fromString(religionStr);
  }

  /// Save user's selected religion
  static Future<void> saveReligion(Religion religion) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_religionKey, religion.displayName.toLowerCase());
    await prefs.setBool(_religionSetKey, true);
  }

  /// Check if religion has been set
  static Future<bool> isReligionSet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_religionSetKey) ?? false;
  }

  /// Clear religion selection
  static Future<void> clearReligion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_religionKey);
    await prefs.setBool(_religionSetKey, false);
  }

  /// Get religion as string
  static Future<String?> getReligionString() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_religionKey);
  }
}
