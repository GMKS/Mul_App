# Notification Triggers Feature - Implementation Guide

## Overview

This document explains the **Notification Triggers** feature that has been integrated into your app for **Alerts**, **Events**, and **Devotional** content.

## Features Implemented

### 1. **Notification Data Model**

- `NotificationItem` model with type-specific metadata
- `NotificationType` enum: `alert`, `event`, `devotional`, `general`
- Fields: id, title, body, type, timestamp, isRead, metadata, imageUrl, actionUrl

### 2. **Notification Triggers Service**

- **Location**: `lib/services/notification_triggers_service.dart`
- Manages notification preferences, storage, and FCM topic subscriptions
- Provides methods to trigger notifications for each type
- Stores notification history (last 100 notifications)
- Handles unread count and filtering

### 3. **User Interface**

#### Notifications Screen

- **Location**: `lib/screens/notifications_screen.dart`
- **Features**:
  - View all notifications
  - Filter by type (All, Alerts, Events, Devotional)
  - Unread badges on filter chips
  - Mark as read / Mark all as read
  - Swipe to delete
  - Pull to refresh
  - Clear all notifications

#### Home Screen Integration

- **Notifications icon with badge** in AppBar
- Shows unread count (9+ for 10 or more)
- Opens notifications screen on tap
- Updates badge count when notifications screen is closed

#### Settings Screen

- **Notification Preferences Widget**
- Toggle notifications for each type:
  - ✅ Alert Notifications
  - ✅ Event Notifications
  - ✅ Devotional Notifications
- Auto-subscribes/unsubscribes from FCM topics

### 4. **Automatic Triggers**

#### Alert Notifications

- **Triggered when**: New local alert is added from FCM or locally
- **Location**: `lib/controllers/local_alerts_controller.dart`
- **Code**:

```dart
NotificationTriggersService().triggerAlertNotification(alert);
```

#### Event Notifications

- **Triggered when**: New event is created and approved
- **Location**: `lib/screens/events/create_event_screen.dart`
- **Code**:

```dart
await NotificationTriggersService().triggerEventNotification(event);
await NotificationTriggersService().scheduleEventReminder(event);
```

#### Devotional Notifications

- **Helper class**: `lib/utils/devotional_notifications_helper.dart`
- **Methods**:
  - `triggerDailyDevotion()` - Daily devotional content
  - `triggerFestivalReminder()` - Festival reminders
  - `triggerNewVideo()` - New devotional videos
  - `triggerPrayerTime()` - Prayer time notifications
  - `triggerTempleEvent()` - Temple special events
  - `scheduleDailyMorningPrayer()` - Schedule 6 AM prayer
  - `scheduleDailyEveningAarti()` - Schedule 7 PM aarti

## How to Use

### Triggering Alert Notifications

When a local alert is created or received via FCM:

```dart
import '../services/notification_triggers_service.dart';
import '../models/local_alert_model.dart';

// Create alert
final alert = LocalAlert(
  id: 'alert_123',
  title: 'Emergency Alert',
  message: 'Heavy rain expected in your area',
  area: 'Downtown',
  locality: 'Main Street',
  distanceKm: 2.5,
  startTime: DateTime.now(),
  category: 'announcement',
);

// Trigger notification
await NotificationTriggersService().triggerAlertNotification(alert);
```

### Triggering Event Notifications

When a new event is approved:

```dart
import '../services/notification_triggers_service.dart';
import '../models/event_model.dart';

// After event is approved
if (event.isApproved) {
  // Immediate notification
  await NotificationTriggersService().triggerEventNotification(event);

  // Schedule reminder for 1 day before event
  await NotificationTriggersService().scheduleEventReminder(event);
}
```

### Triggering Devotional Notifications

Using the helper class:

```dart
import '../utils/devotional_notifications_helper.dart';

// Daily devotional
await DevotionalNotificationsHelper.triggerDailyDevotion(
  title: 'Morning Prayer',
  body: 'Start your day with this beautiful prayer',
  imageUrl: 'https://example.com/prayer.jpg',
);

// Festival reminder
await DevotionalNotificationsHelper.triggerFestivalReminder(
  festivalName: 'Diwali',
  date: DateTime(2026, 10, 24),
  imageUrl: 'https://example.com/diwali.jpg',
);

// New video notification
await DevotionalNotificationsHelper.triggerNewVideo(
  creatorName: 'Temple Live',
  videoTitle: 'Morning Aarti from Golden Temple',
  thumbnailUrl: 'https://example.com/thumb.jpg',
);

// Prayer time
await DevotionalNotificationsHelper.triggerPrayerTime(
  prayerName: 'Evening Aarti',
  time: '7:00 PM',
);

// Temple event
await DevotionalNotificationsHelper.triggerTempleEvent(
  templeName: 'Sri Venkateswara Temple',
  eventName: 'Special Abhishekam',
  description: 'Join us for the monthly special abhishekam',
  imageUrl: 'https://example.com/temple.jpg',
);

// Schedule daily notifications
await DevotionalNotificationsHelper.scheduleDailyMorningPrayer(); // 6 AM
await DevotionalNotificationsHelper.scheduleDailyEveningAarti();  // 7 PM
```

### Managing Notification Preferences

```dart
import '../services/notification_triggers_service.dart';

final service = NotificationTriggersService();

// Get current preferences
bool alertsEnabled = service.alertsEnabled;
bool eventsEnabled = service.eventsEnabled;
bool devotionalEnabled = service.devotionalEnabled;

// Update preferences
await service.setAlertsEnabled(true);
await service.setEventsEnabled(false);
await service.setDevotionalEnabled(true);
```

### Accessing Notifications

```dart
import '../services/notification_triggers_service.dart';

final service = NotificationTriggersService();

// Get all notifications
List<NotificationItem> all = service.getNotifications();

// Get filtered notifications
List<NotificationItem> alerts = service.getNotifications(
  filter: NotificationType.alert,
);

// Get unread count
int unreadCount = service.getUnreadCount();
int unreadAlerts = service.getUnreadCount(filter: NotificationType.alert);

// Mark as read
await service.markAsRead('notification_id');
await service.markAllAsRead(filter: NotificationType.event);

// Delete notification
await service.deleteNotification('notification_id');

// Clear all
await service.clearAll();
await service.clearAll(filter: NotificationType.alert);
```

## Firebase Cloud Messaging (FCM) Integration

### Topics

The app automatically subscribes to FCM topics based on user preferences:

- `alerts` - For alert notifications
- `events` - For event notifications
- `devotional` - For devotional notifications

### Sending Test Notifications

From Firebase Console or your backend, send notifications with these data fields:

**Alert Notification:**

```json
{
  "topic": "alerts",
  "notification": {
    "title": "Emergency Alert",
    "body": "Heavy rain expected"
  },
  "data": {
    "type": "alert",
    "alertId": "123",
    "category": "weather",
    "area": "Downtown",
    "locality": "Main Street"
  }
}
```

**Event Notification:**

```json
{
  "topic": "events",
  "notification": {
    "title": "New Event: Summer Festival",
    "body": "Join us for the summer festival this weekend"
  },
  "data": {
    "type": "event",
    "eventId": "456",
    "category": "festival",
    "isReminder": "false"
  }
}
```

**Devotional Notification:**

```json
{
  "topic": "devotional",
  "notification": {
    "title": "Morning Prayer",
    "body": "Start your day with blessings"
  },
  "data": {
    "type": "devotional",
    "subtype": "prayer_time"
  }
}
```

## File Structure

```
lib/
├── models/
│   └── notification_item_model.dart       # Notification data model
├── services/
│   ├── notification_service.dart          # Base FCM & local notifications
│   └── notification_triggers_service.dart # Triggers & management
├── screens/
│   └── notifications_screen.dart          # Notifications UI
├── widgets/
│   └── notification_settings_widget.dart  # Settings UI
└── utils/
    └── devotional_notifications_helper.dart # Devotional helpers
```

## Testing

### Test Alert Notification

```dart
// In Local Alerts Screen, tap the "Add Alert" button to test
```

### Test Manual Trigger

```dart
// In HomeScreen or any screen
await NotificationTriggersService().triggerAlertNotification(
  LocalAlert(
    id: 'test',
    title: 'Test Alert',
    message: 'This is a test',
    area: 'Test Area',
    locality: 'Test',
    distanceKm: 1,
    startTime: DateTime.now(),
    category: 'announcement',
  ),
);
```

## Next Steps

1. **Schedule Notifications**: Implement actual scheduling using `flutter_local_notifications` scheduled notifications
2. **Deep Links**: Add navigation to specific screens when notification is tapped
3. **Rich Notifications**: Add images, actions, and custom layouts
4. **Analytics**: Track notification open rates and engagement
5. **Backend Integration**: Connect to your backend to send targeted notifications

## Notes

- All notifications are stored locally (last 100)
- Preferences are persisted across app restarts
- FCM topics are auto-managed based on preferences
- Existing functionality is NOT disturbed
- All features work alongside existing notification system

## Support

For issues or questions, check:

- `lib/services/notification_triggers_service.dart` for core logic
- `lib/screens/notifications_screen.dart` for UI
- `lib/utils/devotional_notifications_helper.dart` for devotional examples
