// STEP 8: Festival Service
// Detect festival dates.
// Change UI theme and highlight festival videos.
// Create festival-specific feed filter.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/festival_model.dart';

class FestivalService {
  static const String _festivalModeKey = 'festival_mode_enabled';
  static const String _lastFestivalCheckKey = 'last_festival_check';

  // Get current active festival
  static Festival? getCurrentFestival({String? userRegion}) {
    final currentYear = DateTime.now().year;
    final festivals = Festival.getPredefinedFestivals(currentYear);

    for (final festival in festivals) {
      if (festival.isActive) {
        // Check if festival is relevant to user's region
        if (festival.regions.contains('all') ||
            (userRegion != null && festival.regions.contains(userRegion))) {
          return festival;
        }
      }
    }

    return null;
  }

  // Get upcoming festivals
  static List<Festival> getUpcomingFestivals(
      {String? userRegion, int limit = 5}) {
    final currentYear = DateTime.now().year;
    final festivals = Festival.getPredefinedFestivals(currentYear);
    final now = DateTime.now();

    final upcoming = festivals.where((f) {
      if (f.startDate.isBefore(now)) return false;
      if (userRegion != null &&
          !f.regions.contains('all') &&
          !f.regions.contains(userRegion)) {
        return false;
      }
      return true;
    }).toList();

    upcoming.sort((a, b) => a.startDate.compareTo(b.startDate));

    return upcoming.take(limit).toList();
  }

  // Get festival theme
  static ThemeData getFestivalTheme(Festival festival, ThemeData baseTheme) {
    return baseTheme.copyWith(
      primaryColor: festival.color,
      colorScheme: ColorScheme.fromSeed(
        seedColor: festival.color,
        brightness: baseTheme.brightness,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: festival.color,
        foregroundColor: Colors.white,
      ),
    );
  }

  // Check if festival mode is enabled
  static Future<bool> isFestivalModeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_festivalModeKey) ?? true;
  }

  // Toggle festival mode
  static Future<void> setFestivalModeEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_festivalModeKey, enabled);
  }

  // Get festival-related hashtags
  static List<String> getFestivalHashtags(Festival festival) {
    return festival.relatedHashtags;
  }

  // Get days until festival
  static int getDaysUntilFestival(Festival festival) {
    final now = DateTime.now();
    if (festival.isActive) return 0;
    return festival.startDate.difference(now).inDays;
  }

  // Get festival greeting message
  static String getFestivalGreeting(Festival festival) {
    switch (festival.id.split('_').first) {
      case 'diwali':
        return 'Happy Diwali! 🪔✨';
      case 'holi':
        return 'Happy Holi! 🎨🌈';
      case 'pongal':
        return 'Happy Pongal! 🌾🎉';
      case 'onam':
        return 'Happy Onam! 🛶🌸';
      case 'durga':
        return 'Shubho Bijoya! 🙏✨';
      case 'ganesh':
        return 'Ganpati Bappa Morya! 🐘🎉';
      case 'navratri':
        return 'Happy Navratri! 💃🎶';
      case 'eid':
        return 'Eid Mubarak! 🌙✨';
      case 'christmas':
        return 'Merry Christmas! 🎄🎅';
      case 'new':
        return 'Happy New Year! 🎆🎉';
      default:
        return 'Happy ${festival.name}! ${festival.iconEmoji}';
    }
  }

  // Check if video is festival-relevant
  static bool isVideoFestivalRelevant(
      List<String> videoHashtags, Festival festival) {
    final festivalTags =
        festival.relatedHashtags.map((t) => t.toLowerCase()).toSet();
    return videoHashtags.any((t) => festivalTags.contains(t.toLowerCase()));
  }
}
