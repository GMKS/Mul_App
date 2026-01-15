import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/local_alerts_controller.dart';
import '../main.dart';

/// Top-level function to handle background messages
/// Must be top-level or static to work with Firebase
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📩 Background message received: ${message.messageId}');
  debugPrint('Title: ${message.notification?.title}');
  debugPrint('Body: ${message.notification?.body}');
  debugPrint('Payload: ${message.data}');
}

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize the notification service
  /// Call this once in main.dart after Firebase initialization
  Future<void> init() async {
    if (_initialized) {
      debugPrint('⚠️ NotificationService already initialized');
      return;
    }

    try {
      // Request notification permissions
      await _requestPermission();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Get and log FCM token
      await _getFCMToken();

      // Listen to token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        debugPrint('🔄 FCM Token refreshed: $newToken');
        // TODO: Send new token to your backend
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification taps when app is in background/terminated
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Check if app was opened from a notification
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      _initialized = true;
      debugPrint('✅ NotificationService initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize NotificationService: $e');
    }
  }

  /// Request notification permission
  Future<void> _requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('✅ Notification permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('⚠️ User granted provisional permission');
    } else {
      debugPrint('❌ User declined or has not accepted permission');
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    debugPrint('✅ Local notifications initialized');
  }

  String? fcmToken;

  /// Get FCM token
  Future<void> _getFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      fcmToken = token;
      debugPrint('📱 FCM Token: $token');
      debugPrint(
          '👆 Copy this token to test notifications from Firebase Console');

      // Save token to shared preferences
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', token);
        debugPrint('✅ FCM Token saved to storage');
      }
      // TODO: Send token to your backend
    } catch (e) {
      debugPrint('❌ Failed to get FCM token: $e');
    }
  }

  /// Handle foreground messages
  /// Shows local notification when app is open
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('📩 Foreground message received: ${message.messageId}');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    debugPrint('Payload: ${message.data}');

    // Show local notification
    if (message.notification != null) {
      await _showLocalNotification(
        title: message.notification!.title ?? 'New Alert',
        body: message.notification!.body ?? '',
        payload: message.data.toString(),
      );
    }

    // Store as local alert (if context is available)
    _addAlertToLocalAlerts(message);
  }

  // Helper to add alert to LocalAlertsController using Provider
  void _addAlertToLocalAlerts(RemoteMessage message) {
    // Try to get a context from the navigator key
    final context = navigatorKey.currentContext;
    if (context != null) {
      try {
        final controller =
            Provider.of<LocalAlertsController>(context, listen: false);
        controller.addAlertFromNotification({
          'title': message.notification?.title,
          'body': message.notification?.body,
          ...message.data,
        });
        debugPrint('✅ Alert added to LocalAlertsController');
      } catch (e) {
        debugPrint('⚠️ Could not add alert to LocalAlertsController: $e');
      }
    } else {
      debugPrint(
          '⚠️ No context available to add alert to LocalAlertsController');
    }
  }

  /// Handle notification tap
  Future<void> _handleNotificationTap(RemoteMessage message) async {
    debugPrint('🔔 Notification tapped: ${message.messageId}');
    debugPrint('Payload: ${message.data}');

    // TODO: Navigate based on notification type
    // Example:
    // final type = message.data['type'];
    // if (type == 'local_alert') {
    //   navigatorKey.currentState?.pushNamed('/local-alerts');
    // } else if (type == 'business') {
    //   navigatorKey.currentState?.pushNamed('/business', arguments: message.data['id']);
    // }
  }

  /// Handle local notification tap
  void _onNotificationTap(NotificationResponse response) {
    debugPrint('🔔 Local notification tapped: ${response.payload}');
    // TODO: Add navigation logic here
  }

  /// Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel', // channelId
      'Default Notifications', // channelName
      channelDescription: 'Default notification channel for the app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond, // notification id
      title,
      body,
      notificationDetails,
      payload: payload,
    );

    debugPrint('✅ Local notification shown: $title');
  }

  /// Show test notification (for development)
  Future<void> showTestNotification() async {
    await _showLocalNotification(
      title: 'Test Alert',
      body: 'Notifications are working! 🎉',
      payload: '{"type": "test"}',
    );
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('✅ Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('❌ Failed to subscribe to topic $topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('❌ Failed to unsubscribe from topic $topic: $e');
    }
  }
}
