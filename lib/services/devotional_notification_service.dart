/// Devotional Notification Service
/// Handles daily quote notifications and festival-specific alerts

import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/quote_model.dart';
import '../models/festival_model.dart';
import '../models/devotional_video_model.dart';
import 'religion_service.dart';

class DevotionalNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _quotesEnabledKey = 'devotional_quotes_notifications';
  static const String _festivalsEnabledKey =
      'devotional_festivals_notifications';
  static const String _lastQuoteNotificationKey =
      'last_quote_notification_date';

  // Notification channel IDs
  static const String _quoteChannelId = 'devotional_quotes';
  static const String _festivalChannelId = 'devotional_festivals';

  // Notification IDs
  static const int _dailyQuoteNotificationId = 1001;
  static const int _festivalNotificationBaseId = 2000;

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

    // Create notification channels for Android
    await _createNotificationChannels();
  }

  static Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel quoteChannel = AndroidNotificationChannel(
      _quoteChannelId,
      'Daily Quotes',
      description: 'Daily spiritual quotes and wisdom',
      importance: Importance.high,
    );

    const AndroidNotificationChannel festivalChannel =
        AndroidNotificationChannel(
      _festivalChannelId,
      'Festival Alerts',
      description: 'Notifications for upcoming festivals and special days',
      importance: Importance.high,
    );

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(quoteChannel);
    await androidPlugin?.createNotificationChannel(festivalChannel);
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - navigate to devotional screen
    print('Notification tapped: ${response.payload}');
  }

  /// Request notification permissions
  static Future<bool> requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }

    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  /// Enable/disable quote notifications
  static Future<void> setQuoteNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_quotesEnabledKey, enabled);

    if (enabled) {
      await scheduleDailyQuoteNotification();
    } else {
      await _notifications.cancel(_dailyQuoteNotificationId);
    }
  }

  /// Check if quote notifications are enabled
  static Future<bool> isQuoteNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_quotesEnabledKey) ?? false;
  }

  /// Enable/disable festival notifications
  static Future<void> setFestivalNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_festivalsEnabledKey, enabled);

    if (enabled) {
      await scheduleUpcomingFestivalNotifications();
    } else {
      // Cancel all festival notifications
      for (int i = 0; i < 10; i++) {
        await _notifications.cancel(_festivalNotificationBaseId + i);
      }
    }
  }

  /// Check if festival notifications are enabled
  static Future<bool> isFestivalNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_festivalsEnabledKey) ?? false;
  }

  /// Schedule daily quote notification at 7 AM
  static Future<void> scheduleDailyQuoteNotification() async {
    // Get user's religion preference
    final religion = await ReligionService.getReligionString();

    // Get a quote for the religion
    final quotes = DevotionalQuote.getPredefinedQuotes(religion ?? 'hinduism');

    if (quotes.isEmpty) return;

    final randomQuote = quotes[Random().nextInt(quotes.length)];

    // Schedule for 7 AM tomorrow
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, 7, 0);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _quoteChannelId,
      'Daily Quotes',
      channelDescription: 'Daily spiritual quotes and wisdom',
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
      _dailyQuoteNotificationId,
      '🙏 Quote of the Day',
      '"${randomQuote.text}" - ${randomQuote.author}',
      tzScheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_quote',
    );

    print(
        'Scheduled daily quote notification for ${tzScheduledDate.toString()}');
  }

  /// Show immediate quote notification
  static Future<void> showQuoteNotification(DevotionalQuote quote) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _quoteChannelId,
      'Daily Quotes',
      channelDescription: 'Daily spiritual quotes and wisdom',
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

    await _notifications.show(
      _dailyQuoteNotificationId,
      '🙏 Spiritual Wisdom',
      '"${quote.text}" - ${quote.author}',
      notificationDetails,
      payload: 'quote_${quote.id}',
    );
  }

  /// Schedule notifications for upcoming festivals
  static Future<void> scheduleUpcomingFestivalNotifications() async {
    // Get user's religion preference
    final religion = await ReligionService.getReligionString();

    // Get upcoming festivals
    final now = DateTime.now();
    final festivals = Festival.getPredefinedFestivals(now.year)
        .where((f) {
          final isUpcoming = f.startDate.isAfter(now) &&
              f.startDate.isBefore(now.add(const Duration(days: 30)));
          final matchesReligion = religion == null || f.religion == religion;
          return isUpcoming && matchesReligion;
        })
        .take(5)
        .toList();

    // Cancel existing festival notifications
    for (int i = 0; i < 10; i++) {
      await _notifications.cancel(_festivalNotificationBaseId + i);
    }

    // Schedule new festival notifications
    for (int i = 0; i < festivals.length; i++) {
      final festival = festivals[i];
      await _scheduleFestivalNotification(
          festival, _festivalNotificationBaseId + i);
    }
  }

  static Future<void> _scheduleFestivalNotification(
    Festival festival,
    int notificationId,
  ) async {
    // Schedule notification for the morning of the festival (6 AM)
    final scheduledDate = DateTime(
      festival.startDate.year,
      festival.startDate.month,
      festival.startDate.day,
      6,
      0,
    );

    // Don't schedule if date is in the past
    if (scheduledDate.isBefore(DateTime.now())) return;

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    final religionEmoji = _getReligionEmoji(festival.religion);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _festivalChannelId,
      'Festival Alerts',
      channelDescription:
          'Notifications for upcoming festivals and special days',
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
      notificationId,
      '$religionEmoji ${festival.name}',
      festival.description,
      tzScheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'festival_${festival.id}',
    );

    print(
        'Scheduled festival notification for ${festival.name} on ${tzScheduledDate.toString()}');
  }

  /// Show immediate festival notification
  static Future<void> showFestivalNotification(Festival festival) async {
    final religionEmoji = _getReligionEmoji(festival.religion);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _festivalChannelId,
      'Festival Alerts',
      channelDescription:
          'Notifications for upcoming festivals and special days',
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

    await _notifications.show(
      _festivalNotificationBaseId + 99,
      '$religionEmoji ${festival.name}',
      festival.description,
      notificationDetails,
      payload: 'festival_${festival.id}',
    );
  }

  static String _getReligionEmoji(String? religion) {
    switch (religion?.toLowerCase()) {
      case 'hinduism':
        return '🕉️';
      case 'islam':
        return '☪️';
      case 'christianity':
        return '✝️';
      case 'sikhism':
        return '🙏';
      case 'buddhism':
        return '☸️';
      default:
        return '🙏';
    }
  }

  /// Get pending notifications count
  static Future<int> getPendingNotificationsCount() async {
    final pendingNotifications =
        await _notifications.pendingNotificationRequests();
    return pendingNotifications.length;
  }

  /// Cancel all devotional notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
