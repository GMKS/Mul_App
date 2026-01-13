// BUSINESS FEATURE 7: Interaction Tracking Service
// Track views, call clicks and WhatsApp clicks for business videos

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/business_video_model.dart';

class BusinessInteractionService {
  static const String _interactionsKey = 'business_interactions';
  static const String _dailyStatsKey = 'business_daily_stats';

  /// Track a view for a business video
  static Future<void> trackView(String videoId) async {
    await _incrementCounter(videoId, 'views');
    await _updateDailyStats(videoId, 'views');
  }

  /// Track a call click for a business video
  static Future<void> trackCallClick(String videoId) async {
    await _incrementCounter(videoId, 'callClicks');
    await _updateDailyStats(videoId, 'calls');
  }

  /// Track a WhatsApp click for a business video
  static Future<void> trackWhatsappClick(String videoId) async {
    await _incrementCounter(videoId, 'whatsappClicks');
    await _updateDailyStats(videoId, 'whatsapp');
  }

  /// Get interaction stats for a video
  static Future<Map<String, int>> getVideoStats(String videoId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_interactionsKey);

    if (data == null) {
      return {'views': 0, 'callClicks': 0, 'whatsappClicks': 0};
    }

    final interactions = json.decode(data) as Map<String, dynamic>;
    final videoData = interactions[videoId] as Map<String, dynamic>?;

    if (videoData == null) {
      return {'views': 0, 'callClicks': 0, 'whatsappClicks': 0};
    }

    return {
      'views': videoData['views'] ?? 0,
      'callClicks': videoData['callClicks'] ?? 0,
      'whatsappClicks': videoData['whatsappClicks'] ?? 0,
    };
  }

  /// Get total stats for all videos of a business owner
  static Future<Map<String, int>> getOwnerTotalStats(
      String ownerId, List<BusinessVideo> videos) async {
    int totalViews = 0;
    int totalCalls = 0;
    int totalWhatsapp = 0;

    for (final video in videos.where((v) => v.ownerId == ownerId)) {
      final stats = await getVideoStats(video.id);
      totalViews += stats['views'] ?? 0;
      totalCalls += stats['callClicks'] ?? 0;
      totalWhatsapp += stats['whatsappClicks'] ?? 0;
    }

    return {
      'totalViews': totalViews,
      'totalCalls': totalCalls,
      'totalWhatsapp': totalWhatsapp,
    };
  }

  /// Get daily stats for a specific date
  static Future<Map<String, Map<String, int>>> getDailyStats(
      String ownerId, DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey = _formatDate(date);
    final data = prefs.getString('${_dailyStatsKey}_$dateKey');

    if (data == null) {
      return {};
    }

    final stats = json.decode(data) as Map<String, dynamic>;
    final result = <String, Map<String, int>>{};

    stats.forEach((videoId, videoStats) {
      result[videoId] = Map<String, int>.from(videoStats as Map);
    });

    return result;
  }

  /// Get weekly stats aggregated
  static Future<List<DailyStat>> getWeeklyStats(
      String ownerId, List<BusinessVideo> videos) async {
    final stats = <DailyStat>[];
    final ownerVideos = videos.where((v) => v.ownerId == ownerId).toList();

    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dailyData = await getDailyStats(ownerId, date);

      int dayViews = 0;
      int dayCalls = 0;
      int dayWhatsapp = 0;

      for (final video in ownerVideos) {
        final videoStats = dailyData[video.id];
        if (videoStats != null) {
          dayViews += videoStats['views'] ?? 0;
          dayCalls += videoStats['calls'] ?? 0;
          dayWhatsapp += videoStats['whatsapp'] ?? 0;
        }
      }

      stats.add(DailyStat(
        date: date,
        views: dayViews,
        calls: dayCalls,
        whatsappClicks: dayWhatsapp,
      ));
    }

    return stats;
  }

  /// Private helper to increment a counter
  static Future<void> _incrementCounter(
      String videoId, String counterType) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_interactionsKey);

    Map<String, dynamic> interactions = {};
    if (data != null) {
      interactions = json.decode(data) as Map<String, dynamic>;
    }

    if (!interactions.containsKey(videoId)) {
      interactions[videoId] = {
        'views': 0,
        'callClicks': 0,
        'whatsappClicks': 0,
      };
    }

    interactions[videoId][counterType] =
        (interactions[videoId][counterType] ?? 0) + 1;

    await prefs.setString(_interactionsKey, json.encode(interactions));
  }

  /// Private helper to update daily stats
  static Future<void> _updateDailyStats(String videoId, String statType) async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey = _formatDate(DateTime.now());
    final key = '${_dailyStatsKey}_$dateKey';
    final data = prefs.getString(key);

    Map<String, dynamic> stats = {};
    if (data != null) {
      stats = json.decode(data) as Map<String, dynamic>;
    }

    if (!stats.containsKey(videoId)) {
      stats[videoId] = {
        'views': 0,
        'calls': 0,
        'whatsapp': 0,
      };
    }

    stats[videoId][statType] = (stats[videoId][statType] ?? 0) + 1;

    await prefs.setString(key, json.encode(stats));
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Daily statistics data class
class DailyStat {
  final DateTime date;
  final int views;
  final int calls;
  final int whatsappClicks;

  DailyStat({
    required this.date,
    required this.views,
    required this.calls,
    required this.whatsappClicks,
  });

  int get totalEngagement => views + calls * 10 + whatsappClicks * 5;

  String get dayName {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}
