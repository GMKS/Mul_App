# Test Cases for Notification Triggers

## 📋 Test Suite Overview

### Test Environment

- **App Version**: Latest
- **Flutter Version**: 3.x
- **Firebase**: Enabled
- **Device**: Android/iOS

---

## 🧪 TEST CASES

### **TC-01: Notification Service Initialization**

**Objective**: Verify notification service initializes correctly

**Prerequisites**:

- App freshly installed
- Firebase configured

**Steps**:

1. Launch the app
2. Check logs for initialization messages

**Expected Results**:

```
✅ NotificationService initialized successfully
✅ NotificationTriggersService initialized
📋 Notification preferences: Alerts=true, Events=true, Devotional=true
✅ Subscribed to topic: alerts
✅ Subscribed to topic: events
✅ Subscribed to topic: devotional
```

**Status**: [ ] Pass [ ] Fail

---

### **TC-02: Home Screen - Notification Icon Visible**

**Objective**: Verify notification bell icon appears in home screen

**Steps**:

1. Launch app and navigate to Home screen
2. Look at the AppBar (top right area)

**Expected Results**:

- ✅ Bell icon (🔔) visible in AppBar
- ✅ Icon color: Blue (#4A90E2)
- ✅ Icon position: Second from right (after Settings)
- ❌ No badge initially (no unread notifications)

**Location**: Top right corner of screen

```
[Settings Icon] [Bell Icon] [More Icon] [Logout Icon]
```

**Status**: [ ] Pass [ ] Fail

---

### **TC-03: Open Notifications Screen**

**Objective**: Verify notifications screen opens when bell icon tapped

**Steps**:

1. From Home screen
2. Tap the bell icon in AppBar
3. Observe screen transition

**Expected Results**:

- ✅ Notifications screen opens
- ✅ Title shows "Notifications"
- ✅ Filter chips visible: All, Alerts, Events, Devotional
- ✅ Empty state shows:
  - Icon: 🔔
  - Text: "No notifications yet"
  - Subtext: "Stay tuned for updates"

**Status**: [ ] Pass [ ] Fail

---

### **TC-04: Settings - Notification Preferences**

**Objective**: Verify notification settings section appears in Settings

**Steps**:

1. From Home screen
2. Tap Settings icon (gear icon)
3. Scroll to top of settings screen

**Expected Results**:

- ✅ "Notification Preferences" card visible at TOP
- ✅ Card shows 3 toggle switches:
  - 🚨 Alert Notifications - ON (default)
  - 📅 Event Notifications - ON (default)
  - 🙏 Devotional Notifications - ON (default)
- ✅ Each has icon, title, subtitle
- ✅ All toggles are active (blue color)

**Status**: [ ] Pass [ ] Fail

---

### **TC-05: Disable Alert Notifications**

**Objective**: Verify alert notifications can be disabled

**Steps**:

1. Go to Settings → Notification Preferences
2. Toggle OFF "Alert Notifications"
3. Check snackbar message
4. Check logs

**Expected Results**:

- ✅ Toggle turns gray/off
- ✅ Snackbar: "Alert notifications disabled"
- ✅ Logs show: `✅ Unsubscribed from topic: alerts`

**Status**: [ ] Pass [ ] Fail

---

### **TC-06: Re-enable Alert Notifications**

**Objective**: Verify alert notifications can be re-enabled

**Steps**:

1. From previous test state (alerts disabled)
2. Toggle ON "Alert Notifications"
3. Check snackbar and logs

**Expected Results**:

- ✅ Toggle turns blue/on
- ✅ Snackbar: "Alert notifications enabled"
- ✅ Logs show: `✅ Subscribed to topic: alerts`

**Status**: [ ] Pass [ ] Fail

---

### **TC-07: Trigger Test Alert Notification**

**Objective**: Verify alert notification can be triggered manually

**Steps**:

1. Navigate to Local Alerts screen (Home → Regional → Local Alerts)
2. Tap the bell icon (🔔) in the AppBar (top right)
3. Check for snackbar and notification

**Expected Results**:

- ✅ Snackbar: "Test alert added!"
- ✅ Local notification appears on device
- ✅ Notification title: "🚨 Test Alert"
- ✅ Notification body contains test message

**Alternative Method**:

- Check the "Add Alert" debug button in Local Alerts screen AppBar

**Status**: [ ] Pass [ ] Fail

---

### **TC-08: View Alert in Notifications Screen**

**Objective**: Verify triggered alert appears in notifications list

**Steps**:

1. After TC-07, go to Home screen
2. Check bell icon - should now have badge
3. Tap bell icon
4. View notifications list

**Expected Results**:

- ✅ Bell icon has red badge with "1"
- ✅ Notifications screen shows 1 alert
- ✅ Alert has:
  - Red icon/background tint
  - 🚨 emoji
  - Unread indicator (red dot)
  - "Just now" timestamp
- ✅ Filter chip "Alerts" shows badge "1"

**Status**: [ ] Pass [ ] Fail

---

### **TC-09: Mark Notification as Read**

**Objective**: Verify notification can be marked as read

**Steps**:

1. From notifications screen with unread notification
2. Tap the notification card

**Expected Results**:

- ✅ Red dot (unread indicator) disappears
- ✅ Background changes from tinted to white
- ✅ Bell badge updates (decrements count or disappears)
- ✅ Filter chip badge updates

**Status**: [ ] Pass [ ] Fail

---

### **TC-10: Delete Notification (Swipe)**

**Objective**: Verify notification can be deleted by swiping

**Steps**:

1. From notifications screen
2. Swipe notification card LEFT (endToStart)
3. Observe deletion

**Expected Results**:

- ✅ Red background with trash icon appears during swipe
- ✅ Notification card is removed
- ✅ Snackbar: "Notification deleted"
- ✅ If list empty, empty state appears

**Status**: [ ] Pass [ ] Fail

---

### **TC-11: Filter Notifications by Type**

**Objective**: Verify filtering works correctly

**Steps**:

1. Create notifications of different types (alert, event, devotional)
2. Open notifications screen
3. Tap different filter chips

**Expected Results**:

- ✅ "All" shows all notifications
- ✅ "Alerts" shows only alert notifications
- ✅ "Events" shows only event notifications
- ✅ "Devotional" shows only devotional notifications
- ✅ Selected chip is highlighted blue with white text
- ✅ Badge counts update correctly

**Status**: [ ] Pass [ ] Fail

---

### **TC-12: Mark All as Read**

**Objective**: Verify mark all as read functionality

**Steps**:

1. Have multiple unread notifications
2. Open notifications screen
3. Tap "Mark all read" button in AppBar

**Expected Results**:

- ✅ All red dots disappear
- ✅ All cards change to white background
- ✅ Bell badge disappears from home screen
- ✅ "Mark all read" button disappears (no unread)

**Status**: [ ] Pass [ ] Fail

---

### **TC-13: Clear All Notifications**

**Objective**: Verify clear all functionality

**Steps**:

1. Have multiple notifications in list
2. Open notifications screen
3. Tap menu icon (⋮) → Clear All
4. Confirm in dialog

**Expected Results**:

- ✅ Confirmation dialog appears
- ✅ Dialog title: "Clear Notifications"
- ✅ Dialog message based on filter
- ✅ On confirm: All notifications removed
- ✅ Snackbar: "Notifications cleared"
- ✅ Empty state appears

**Status**: [ ] Pass [ ] Fail

---

### **TC-14: Pull to Refresh**

**Objective**: Verify pull to refresh works

**Steps**:

1. Open notifications screen
2. Pull down from top of list

**Expected Results**:

- ✅ Refresh indicator appears
- ✅ List refreshes
- ✅ Indicator disappears

**Status**: [ ] Pass [ ] Fail

---

### **TC-15: FCM - Send Alert from Firebase Console**

**Objective**: Verify FCM alert notification works

**Prerequisites**:

- Firebase Console access
- FCM token copied from Settings

**Steps**:

1. Go to Firebase Console → Cloud Messaging
2. Send to topic: `alerts`
3. Add notification:
   ```
   Title: Emergency Alert
   Body: Heavy rain expected
   ```
4. Add data payload:
   ```json
   {
     "type": "alert",
     "category": "weather",
     "area": "Downtown"
   }
   ```
5. Send notification

**Expected Results**:

- ✅ Device receives notification
- ✅ Notification appears in system tray
- ✅ App stores notification in history
- ✅ Visible in notifications screen
- ✅ Badge updates on home screen

**Status**: [ ] Pass [ ] Fail

---

### **TC-16: FCM - Send Event Notification**

**Objective**: Verify FCM event notification works

**Steps**:

1. Send to topic: `events`
2. Notification:
   ```
   Title: New Event: Summer Festival
   Body: Join us this weekend
   ```
3. Data:
   ```json
   {
     "type": "event",
     "eventId": "123",
     "category": "festival"
   }
   ```

**Expected Results**:

- ✅ Notification received
- ✅ Purple icon/theme (events)
- ✅ Appears in Events filter
- ✅ 📅 emoji shown

**Status**: [ ] Pass [ ] Fail

---

### **TC-17: FCM - Send Devotional Notification**

**Objective**: Verify FCM devotional notification works

**Steps**:

1. Send to topic: `devotional`
2. Notification:
   ```
   Title: Morning Prayer
   Body: Start your day with blessings
   ```
3. Data:
   ```json
   {
     "type": "devotional"
   }
   ```

**Expected Results**:

- ✅ Notification received
- ✅ Violet icon/theme (devotional)
- ✅ Appears in Devotional filter
- ✅ 🙏 emoji shown

**Status**: [ ] Pass [ ] Fail

---

### **TC-18: Preferences Persistence**

**Objective**: Verify preferences survive app restart

**Steps**:

1. Disable alert notifications in Settings
2. Close app completely (kill process)
3. Reopen app
4. Go to Settings → Notification Preferences

**Expected Results**:

- ✅ Alert notifications still OFF
- ✅ Not subscribed to alerts topic (check logs)
- ✅ Other preferences unchanged

**Status**: [ ] Pass [ ] Fail

---

### **TC-19: Notification History Persistence**

**Objective**: Verify notifications persist across app restarts

**Steps**:

1. Receive 3-5 notifications
2. Close app completely
3. Reopen app
4. Check notifications screen

**Expected Results**:

- ✅ All notifications still visible
- ✅ Read/unread status preserved
- ✅ Timestamps correct
- ✅ Badge count correct

**Status**: [ ] Pass [ ] Fail

---

### **TC-20: Maximum Storage (100 Notifications)**

**Objective**: Verify only last 100 notifications are stored

**Steps**:

1. Generate 105 test notifications
2. Check notifications screen
3. Scroll to bottom

**Expected Results**:

- ✅ Only 100 notifications visible
- ✅ Oldest 5 removed automatically
- ✅ Most recent 100 retained

**Status**: [ ] Pass [ ] Fail

---

### **TC-21: Event Creation Triggers Notification**

**Objective**: Verify creating approved event triggers notification

**Steps**:

1. Go to Events section
2. Create new event
3. Mark as approved (if admin)
4. Check notifications

**Expected Results**:

- ✅ Notification appears immediately
- ✅ Title: "📅 New Event: [Event Name]"
- ✅ Body contains event details
- ✅ Event image included (if provided)

**Status**: [ ] Pass [ ] Fail

---

### **TC-22: Devotional Helper - Daily Devotion**

**Objective**: Verify devotional notification helper works

**Steps**:

1. Add code to trigger daily devotion:
   ```dart
   await DevotionalNotificationsHelper.triggerDailyDevotion(
     title: 'Morning Prayer',
     body: 'Start your day with blessings',
   );
   ```
2. Check notifications

**Expected Results**:

- ✅ Notification appears
- ✅ Title: "🙏 Morning Prayer"
- ✅ Violet theme
- ✅ In Devotional filter

**Status**: [ ] Pass [ ] Fail

---

## 🎯 Summary Metrics

### Expected Pass Rate: 100%

**Critical Tests** (Must Pass):

- TC-02: Icon Visible
- TC-03: Open Screen
- TC-04: Settings Section
- TC-07: Trigger Alert
- TC-08: View in List
- TC-15: FCM Alert
- TC-18: Persistence

**High Priority**:

- All other TCs

---

## 📊 Test Results Template

```
Test Date: ___________
Tester: ___________
Device: ___________
App Version: ___________

Total Tests: 22
Passed: ___
Failed: ___
Skipped: ___

Pass Rate: ___%

Critical Issues Found:
1.
2.

Notes:

```

---

## 🔍 Debugging Tips

### Can't Find Notification Icon?

- **Check**: Home screen AppBar, top right
- **Look for**: Bell icon (🔔) in blue color
- **Position**: Between Settings and More icons

### Notifications Not Appearing?

1. Check logs for initialization errors
2. Verify Settings → Notifications enabled
3. Check FCM token in Settings screen
4. Verify topic subscription in logs

### Badge Not Updating?

1. Trigger test notification
2. Go to different screen and back
3. Check if `_updateUnreadCount()` is called

### Empty Notifications Screen?

- This is correct if no notifications yet
- Trigger test alert to add first notification

---

## 📞 Support

If tests fail, check:

1. `NOTIFICATION_TRIGGERS_GUIDE.md` - Full documentation
2. Console logs for error messages
3. Firebase Console for FCM delivery status
4. Settings screen for FCM token
