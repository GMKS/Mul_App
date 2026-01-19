# Notification Triggers - Quick Start Guide

## 🚀 Getting Started in 5 Minutes

### 1. View Notifications

```dart
// Tap the bell icon 🔔 in home screen AppBar
// Badge shows unread count
```

### 2. Enable/Disable Notification Types

```dart
// Go to Settings → Notification Preferences
// Toggle switches for:
// - 🚨 Alerts
// - 📅 Events
// - 🙏 Devotional
```

### 3. Trigger Alert Notification (Already Integrated)

When a new local alert arrives via FCM or is created locally, a notification is automatically triggered.

**Location**: Already implemented in `LocalAlertsController`

### 4. Trigger Event Notification (Already Integrated)

When a new event is created and approved, notifications are automatically sent.

**Location**: Already implemented in `CreateEventScreen`

### 5. Trigger Devotional Notification (Use Helper)

```dart
import 'package:your_app/utils/devotional_notifications_helper.dart';

// Daily devotion
await DevotionalNotificationsHelper.triggerDailyDevotion(
  title: 'Morning Prayer',
  body: 'Start your day with blessings',
);

// Festival reminder
await DevotionalNotificationsHelper.triggerFestivalReminder(
  festivalName: 'Diwali',
  date: DateTime(2026, 10, 24),
);
```

---

## 📱 User Features

### Notifications Screen

- **Filter** by type (All/Alerts/Events/Devotional)
- **Mark as read** - Tap notification
- **Mark all as read** - Tap button in AppBar
- **Delete** - Swipe left on notification
- **Clear all** - Menu → Clear All
- **Refresh** - Pull down

### Home Screen

- **Badge** on bell icon shows unread count
- **Tap bell** to open notifications

### Settings

- **Toggle** notification types on/off
- **Instant** FCM topic subscription update

---

## 🔧 Developer Quick Reference

### Import

```dart
import 'package:your_app/services/notification_triggers_service.dart';
import 'package:your_app/models/notification_item_model.dart';
```

### Get Service Instance

```dart
final service = NotificationTriggersService();
```

### Trigger Notifications

```dart
// Alert
await service.triggerAlertNotification(alert);

// Event
await service.triggerEventNotification(event);

// Devotional
await service.triggerDevotionalNotification(
  title: 'Title',
  body: 'Body',
);
```

### Get Notifications

```dart
// All
List<NotificationItem> all = service.getNotifications();

// By type
List<NotificationItem> alerts = service.getNotifications(
  filter: NotificationType.alert,
);

// Unread count
int unread = service.getUnreadCount();
```

### Manage

```dart
// Mark as read
await service.markAsRead('id');

// Delete
await service.deleteNotification('id');

// Clear all
await service.clearAll();
```

### Preferences

```dart
// Get
bool enabled = service.alertsEnabled;

// Set
await service.setAlertsEnabled(true);
await service.setEventsEnabled(false);
await service.setDevotionalEnabled(true);
```

---

## 🧪 Quick Test

### Test Alert

1. Open Local Alerts Screen
2. Tap "Add Alert" button (bell icon in AppBar)
3. Check notification appears
4. Open Notifications screen from home

### Test Preferences

1. Go to Settings
2. Disable "Alert Notifications"
3. Try adding alert - no notification
4. Enable again - notifications work

### Test UI

1. Open Notifications screen
2. Filter by type
3. Swipe to delete
4. Mark all as read
5. Clear all

---

## 🎯 Common Use Cases

### 1. Send Daily Devotional

```dart
// Add to your scheduler or call manually
await DevotionalNotificationsHelper.triggerDailyDevotion(
  title: 'Morning Prayer',
  body: 'Om Shanti 🙏',
);
```

### 2. Alert Users of Nearby Event

```dart
// When event is approved
if (event.isApproved) {
  await NotificationTriggersService().triggerEventNotification(event);
}
```

### 3. Emergency Alert

```dart
await NotificationTriggersService().triggerAlertNotification(
  LocalAlert(
    id: 'emergency_1',
    title: 'Emergency Alert',
    message: 'Please stay indoors',
    area: 'City Center',
    locality: 'Downtown',
    distanceKm: 0,
    startTime: DateTime.now(),
    category: 'emergency',
  ),
);
```

### 4. Festival Countdown

```dart
await DevotionalNotificationsHelper.triggerFestivalReminder(
  festivalName: 'Holi',
  date: DateTime(2026, 3, 14),
  imageUrl: 'https://example.com/holi.jpg',
);
```

---

## 📚 More Information

- **Full Guide**: `NOTIFICATION_TRIGGERS_GUIDE.md`
- **Summary**: `NOTIFICATION_TRIGGERS_SUMMARY.md`
- **Code**: Check inline documentation in service files

---

## ✅ Checklist

- [x] Feature implemented
- [x] Alert triggers working
- [x] Event triggers working
- [x] Devotional helpers ready
- [x] UI/UX complete
- [x] Settings integrated
- [x] Badge working
- [x] Preferences saving
- [x] FCM topics managed
- [x] No breaking changes

**Status**: ✅ Ready to use!
