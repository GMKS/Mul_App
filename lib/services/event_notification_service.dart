/// Event Notification Service
/// Handles push notifications for events and festivals

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/event_model.dart';
import '../repositories/event_repository.dart';

class EventNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _eventsNotificationsEnabledKey =
      'events_notifications_enabled';
  static const String _eventsTodayNotificationTimeKey =
      'events_today_notification_time'; // Default 8 AM
  static const String _eventsTomorrowNotificationTimeKey =
      'events_tomorrow_notification_time'; // Default 7 PM

  // Notification channel IDs
  static const String _eventChannelId = 'events_channel';
  static const String _liveEventChannelId = 'live_events_channel';

  // Notification IDs
  static const int _todayEventsNotificationId = 3001;
  static const int _tomorrowEventsNotificationId = 3002;
  static const int _liveEventNotificationBaseId = 3100;

  /// Initialize the notification service
  static Future<void> initialize() async {
    tz_data.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _createNotificationChannels();
  }

  static Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel eventChannel = AndroidNotificationChannel(
      _eventChannelId,
      'Event Notifications',
      description: 'Notifications for upcoming events and festivals',
      importance: Importance.high,
    );

    const AndroidNotificationChannel liveChannel = AndroidNotificationChannel(
      _liveEventChannelId,
      'Live Event Alerts',
      description: 'Alerts for events happening right now',
      importance: Importance.max,
    );

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(eventChannel);
    await androidPlugin?.createNotificationChannel(liveChannel);
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - navigate to events screen
    print('Event notification tapped: ${response.payload}');
  }

  /// Enable/disable event notifications
  static Future<void> setEventsNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_eventsNotificationsEnabledKey, enabled);

    if (enabled) {
      await scheduleTodayEventsNotification();
      await scheduleTomorrowEventsNotification();
    } else {
      await _notifications.cancel(_todayEventsNotificationId);
      await _notifications.cancel(_tomorrowEventsNotificationId);
    }
  }

  /// Check if event notifications are enabled
  static Future<bool> isEventsNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_eventsNotificationsEnabledKey) ?? true;
  }

  /// Schedule notification for today's events at 8 AM
  static Future<void> scheduleTodayEventsNotification() async {
    final repository = EventRepository();
    final events = await repository.fetchTodayEvents();

    if (events.isEmpty) return;

    // Schedule for 8 AM today
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, 8, 0);

    // If 8 AM has passed, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    final eventCount = events.length;
    final firstEvent = events.first;
    final title = eventCount == 1
        ? '📅 Event Today: ${firstEvent.title}'
        : '📅 $eventCount Events Today!';
    final body = eventCount == 1
        ? '${firstEvent.categoryIcon} ${firstEvent.formattedTime} at ${firstEvent.locationName}'
        : 'Check out the events happening near you today';

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _eventChannelId,
      'Event Notifications',
      channelDescription: 'Notifications for upcoming events and festivals',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(''),
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      _todayEventsNotificationId,
      title,
      body,
      tzScheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'today_events',
    );

    print(
        'Scheduled today events notification for ${tzScheduledDate.toString()}');
  }

  /// Schedule notification for tomorrow's events at 7 PM
  static Future<void> scheduleTomorrowEventsNotification() async {
    final repository = EventRepository();
    final events = await repository.fetchTomorrowEvents();

    if (events.isEmpty) return;

    // Schedule for 7 PM today (for tomorrow's events)
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, 19, 0);

    // If 7 PM has passed, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    final eventCount = events.length;
    final firstEvent = events.first;
    final title = eventCount == 1
        ? '🗓️ Tomorrow: ${firstEvent.title}'
        : '🗓️ $eventCount Events Tomorrow!';
    final body = eventCount == 1
        ? '${firstEvent.categoryIcon} ${firstEvent.formattedTime} at ${firstEvent.locationName}'
        : 'Plan your day with these upcoming events';

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _eventChannelId,
      'Event Notifications',
      channelDescription: 'Notifications for upcoming events and festivals',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(''),
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      _tomorrowEventsNotificationId,
      title,
      body,
      tzScheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'tomorrow_events',
    );

    print(
        'Scheduled tomorrow events notification for ${tzScheduledDate.toString()}');
  }

  /// Show immediate notification for a live event
  static Future<void> showLiveEventNotification(EventModel event) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _liveEventChannelId,
      'Live Event Alerts',
      channelDescription: 'Alerts for events happening right now',
      importance: Importance.max,
      priority: Priority.max,
      styleInformation: BigTextStyleInformation(''),
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFE91E63),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      _liveEventNotificationBaseId + event.id.hashCode % 100,
      '🔴 LIVE: ${event.title}',
      '${event.categoryIcon} Happening now at ${event.locationName}',
      notificationDetails,
      payload: 'live_event_${event.id}',
    );
  }

  /// Show notification for upcoming event (user subscribed)
  static Future<void> showEventReminderNotification(EventModel event) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _eventChannelId,
      'Event Notifications',
      channelDescription: 'Notifications for upcoming events and festivals',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(''),
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final timeUntil = event.timeUntilStart;
    String timeText;
    if (timeUntil.inMinutes < 60) {
      timeText = '${timeUntil.inMinutes} minutes';
    } else if (timeUntil.inHours < 24) {
      timeText = '${timeUntil.inHours} hours';
    } else {
      timeText = '${timeUntil.inDays} days';
    }

    await _notifications.show(
      event.id.hashCode,
      '⏰ Event Starting Soon!',
      '${event.categoryIcon} ${event.title} starts in $timeText',
      notificationDetails,
      payload: 'event_reminder_${event.id}',
    );
  }

  /// Cancel all event notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancel(_todayEventsNotificationId);
    await _notifications.cancel(_tomorrowEventsNotificationId);
  }

  /// Refresh notifications based on user preferences
  static Future<void> refreshNotifications({
    String? distanceCategory,
  }) async {
    final enabled = await isEventsNotificationsEnabled();
    if (!enabled) return;

    await cancelAllNotifications();
    await scheduleTodayEventsNotification();
    await scheduleTomorrowEventsNotification();
  }
}

/// Color class for notification (Android)
class Color {
  final int value;
  const Color(this.value);
}
