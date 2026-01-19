/// Devotional Notifications Helper
/// Utility functions to trigger devotional notifications

import '../services/notification_triggers_service.dart';
import '../models/devotional_video_model.dart';

class DevotionalNotificationsHelper {
  static final NotificationTriggersService _service =
      NotificationTriggersService();

  /// Trigger notification for daily devotional content
  static Future<void> triggerDailyDevotion({
    required String title,
    required String body,
    String? imageUrl,
  }) async {
    await _service.triggerDevotionalNotification(
      title: title,
      body: body,
      imageUrl: imageUrl,
      metadata: {
        'type': 'daily_devotion',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Trigger notification for festival reminder
  static Future<void> triggerFestivalReminder({
    required String festivalName,
    required DateTime date,
    String? imageUrl,
  }) async {
    final daysUntil = date.difference(DateTime.now()).inDays;
    final body = daysUntil == 0
        ? '$festivalName is today! 🎉'
        : daysUntil == 1
            ? '$festivalName is tomorrow! 🎉'
            : '$festivalName is in $daysUntil days';

    await _service.triggerDevotionalNotification(
      title: 'Festival Reminder',
      body: body,
      imageUrl: imageUrl,
      metadata: {
        'type': 'festival_reminder',
        'festivalName': festivalName,
        'date': date.toIso8601String(),
      },
    );
  }

  /// Trigger notification for new devotional video
  static Future<void> triggerNewVideo({
    required String creatorName,
    required String videoTitle,
    String? thumbnailUrl,
  }) async {
    await _service.triggerDevotionalNotification(
      title: 'New Devotional Content',
      body: '$creatorName uploaded: $videoTitle',
      imageUrl: thumbnailUrl,
      metadata: {
        'type': 'new_video',
        'creator': creatorName,
      },
    );
  }

  /// Trigger notification for prayer time
  static Future<void> triggerPrayerTime({
    required String prayerName,
    required String time,
  }) async {
    await _service.triggerDevotionalNotification(
      title: 'Prayer Time',
      body: '$prayerName at $time',
      metadata: {
        'type': 'prayer_time',
        'prayerName': prayerName,
        'time': time,
      },
    );
  }

  /// Trigger notification for temple special event
  static Future<void> triggerTempleEvent({
    required String templeName,
    required String eventName,
    required String description,
    String? imageUrl,
  }) async {
    await _service.triggerDevotionalNotification(
      title: '🛕 $templeName',
      body: '$eventName\n$description',
      imageUrl: imageUrl,
      metadata: {
        'type': 'temple_event',
        'templeName': templeName,
        'eventName': eventName,
      },
    );
  }

  /// Schedule daily devotional notification (e.g., morning prayer at 6 AM)
  static Future<void> scheduleDailyMorningPrayer() async {
    await _service.scheduleDailyDevotional(hour: 6, minute: 0);
  }

  /// Schedule daily devotional notification (e.g., evening aarti at 7 PM)
  static Future<void> scheduleDailyEveningAarti() async {
    await _service.scheduleDailyDevotional(hour: 19, minute: 0);
  }
}
