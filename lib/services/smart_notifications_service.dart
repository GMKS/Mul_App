/// Smart Notifications Service
/// Priority-based notification system with grouping and quiet hours

import 'dart:async';
import 'package:flutter/material.dart';

enum NotificationPriority {
  critical, // Immediate delivery
  high, // Within 5 minutes
  normal, // Can be grouped
  low, // Can wait for quiet hours
}

enum NotificationType {
  reportStatus,
  moderatorFeedback,
  warning,
  communityUpdate,
  contentRemoved,
  appealResponse,
  trustLevelUp,
}

class SmartNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationPriority priority;
  final DateTime createdAt;
  final Map<String, dynamic>? data;
  final String? actionUrl;
  final bool isRead;

  SmartNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.priority,
    required this.createdAt,
    this.data,
    this.actionUrl,
    this.isRead = false,
  });

  IconData get icon {
    switch (type) {
      case NotificationType.reportStatus:
        return Icons.report_problem;
      case NotificationType.moderatorFeedback:
        return Icons.message;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.communityUpdate:
        return Icons.people;
      case NotificationType.contentRemoved:
        return Icons.delete;
      case NotificationType.appealResponse:
        return Icons.gavel;
      case NotificationType.trustLevelUp:
        return Icons.emoji_events;
    }
  }

  Color get iconColor {
    switch (priority) {
      case NotificationPriority.critical:
        return Colors.red;
      case NotificationPriority.high:
        return Colors.orange;
      case NotificationPriority.normal:
        return Colors.blue;
      case NotificationPriority.low:
        return Colors.grey;
    }
  }
}

class SmartNotificationsService {
  static final SmartNotificationsService _instance =
      SmartNotificationsService._internal();
  factory SmartNotificationsService() => _instance;
  SmartNotificationsService._internal();

  final StreamController<List<SmartNotification>> _notificationsController =
      StreamController<List<SmartNotification>>.broadcast();

  Stream<List<SmartNotification>> get notificationsStream =>
      _notificationsController.stream;

  List<SmartNotification> _notifications = [];
  List<SmartNotification> _pendingBatch = [];
  Timer? _batchTimer;

  // User preferences
  TimeOfDay quietHoursStart = TimeOfDay(hour: 22, minute: 0); // 10 PM
  TimeOfDay quietHoursEnd = TimeOfDay(hour: 7, minute: 0); // 7 AM
  bool enableQuietHours = true;
  bool enableGrouping = true;
  int batchingDelayMinutes = 15;

  /// Send notification with smart delivery
  Future<void> sendNotification(SmartNotification notification) async {
    _notifications.add(notification);

    if (notification.priority == NotificationPriority.critical) {
      // Send immediately, even during quiet hours
      await _deliverImmediately(notification);
    } else if (notification.priority == NotificationPriority.high) {
      // Send within 5 minutes
      await _scheduleHighPriority(notification);
    } else {
      // Add to batch for grouping
      _addToBatch(notification);
    }
  }

  Future<void> _deliverImmediately(SmartNotification notification) async {
    // Send push notification immediately
    print('🔴 CRITICAL: ${notification.title}');
    _notificationsController.add(_notifications);
  }

  Future<void> _scheduleHighPriority(SmartNotification notification) async {
    if (_isQuietHours() && enableQuietHours) {
      // Queue for end of quiet hours
      print('⏰ Scheduled for after quiet hours: ${notification.title}');
    } else {
      // Send within 5 minutes
      await Future.delayed(Duration(minutes: 2));
      print('🟠 HIGH PRIORITY: ${notification.title}');
      _notificationsController.add(_notifications);
    }
  }

  void _addToBatch(SmartNotification notification) {
    _pendingBatch.add(notification);

    // Cancel existing timer
    _batchTimer?.cancel();

    // Schedule batch delivery
    _batchTimer = Timer(
      Duration(minutes: batchingDelayMinutes),
      _deliverBatch,
    );
  }

  Future<void> _deliverBatch() async {
    if (_pendingBatch.isEmpty) return;

    if (_isQuietHours() && enableQuietHours) {
      // Wait until quiet hours end
      _scheduleForEndOfQuietHours();
      return;
    }

    if (enableGrouping && _pendingBatch.length > 1) {
      // Group similar notifications
      final grouped = _groupNotifications(_pendingBatch);
      for (var group in grouped) {
        await _deliverGroupedNotification(group);
      }
    } else {
      // Send individually
      for (var notif in _pendingBatch) {
        await _deliverImmediately(notif);
      }
    }

    _pendingBatch.clear();
  }

  List<List<SmartNotification>> _groupNotifications(
    List<SmartNotification> notifications,
  ) {
    final Map<NotificationType, List<SmartNotification>> grouped = {};

    for (var notif in notifications) {
      grouped.putIfAbsent(notif.type, () => []).add(notif);
    }

    return grouped.values.toList();
  }

  Future<void> _deliverGroupedNotification(
    List<SmartNotification> group,
  ) async {
    if (group.isEmpty) return;

    final type = group.first.type;
    final count = group.length;

    String groupTitle = '';
    String groupBody = '';

    switch (type) {
      case NotificationType.reportStatus:
        groupTitle = '$count Report Updates';
        groupBody = 'You have $count reports with status updates';
        break;
      case NotificationType.moderatorFeedback:
        groupTitle = '$count New Messages';
        groupBody = 'Moderators have responded to your reports';
        break;
      case NotificationType.communityUpdate:
        groupTitle = '$count Community Updates';
        groupBody = 'New updates from the moderation team';
        break;
      default:
        groupTitle = '$count Updates';
        groupBody = 'You have $count new notifications';
    }

    print('📦 GROUPED: $groupTitle - $groupBody');
    _notificationsController.add(_notifications);
  }

  bool _isQuietHours() {
    final now = TimeOfDay.now();
    final currentMinutes = now.hour * 60 + now.minute;
    final startMinutes = quietHoursStart.hour * 60 + quietHoursStart.minute;
    final endMinutes = quietHoursEnd.hour * 60 + quietHoursEnd.minute;

    if (startMinutes < endMinutes) {
      // Normal case: 10 PM - 7 AM
      return currentMinutes >= startMinutes && currentMinutes < endMinutes;
    } else {
      // Crosses midnight
      return currentMinutes >= startMinutes || currentMinutes < endMinutes;
    }
  }

  void _scheduleForEndOfQuietHours() {
    final now = DateTime.now();
    final endOfQuietHours = DateTime(
      now.year,
      now.month,
      now.day,
      quietHoursEnd.hour,
      quietHoursEnd.minute,
    );

    var deliveryTime = endOfQuietHours;
    if (deliveryTime.isBefore(now)) {
      deliveryTime = deliveryTime.add(Duration(days: 1));
    }

    final delay = deliveryTime.difference(now);
    Timer(delay, _deliverBatch);

    print('🌙 Notifications scheduled for ${deliveryTime.toString()}');
  }

  /// Get notifications for user
  Future<List<SmartNotification>> getNotifications({
    String? userId,
    bool unreadOnly = false,
  }) async {
    // Mock data
    return [
      SmartNotification(
        id: 'notif_001',
        title: 'Report Resolved',
        body: 'Your report about "Controversial Video" has been resolved',
        type: NotificationType.reportStatus,
        priority: NotificationPriority.normal,
        createdAt: DateTime.now().subtract(Duration(hours: 2)),
        data: {'reportId': 'rep_123'},
      ),
      SmartNotification(
        id: 'notif_002',
        title: 'Moderator Feedback',
        body:
            'Thank you for your report. The content has been reviewed and appropriate action taken.',
        type: NotificationType.moderatorFeedback,
        priority: NotificationPriority.high,
        createdAt: DateTime.now().subtract(Duration(hours: 1)),
      ),
      SmartNotification(
        id: 'notif_003',
        title: 'Trust Level Upgraded! 🎉',
        body: 'Congratulations! You\'ve been promoted to Trusted Reporter',
        type: NotificationType.trustLevelUp,
        priority: NotificationPriority.high,
        createdAt: DateTime.now().subtract(Duration(minutes: 30)),
      ),
    ];
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      // In production, update in database
      print('✓ Marked as read: $notificationId');
    }
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    // In production, update all in database
    print('✓ Marked all notifications as read');
  }

  /// Update quiet hours settings
  void setQuietHours({
    required TimeOfDay start,
    required TimeOfDay end,
    required bool enabled,
  }) {
    quietHoursStart = start;
    quietHoursEnd = end;
    enableQuietHours = enabled;
    print('🌙 Quiet hours updated: $start - $end (${enabled ? 'ON' : 'OFF'})');
  }

  /// Update grouping settings
  void setGroupingEnabled(bool enabled) {
    enableGrouping = enabled;
    print('📦 Notification grouping: ${enabled ? 'ON' : 'OFF'}');
  }

  /// Update batching delay
  void setBatchingDelay(int minutes) {
    batchingDelayMinutes = minutes;
    print('⏱️ Batching delay updated: $minutes minutes');
  }

  /// Get notification statistics
  Future<Map<String, dynamic>> getStats() async {
    return {
      'total': _notifications.length,
      'unread': _notifications.where((n) => !n.isRead).length,
      'pending_batch': _pendingBatch.length,
      'quiet_hours_active': _isQuietHours(),
    };
  }

  void dispose() {
    _batchTimer?.cancel();
    _notificationsController.close();
  }
}
