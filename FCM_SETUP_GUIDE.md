# Firebase Cloud Messaging (FCM) Setup Guide

## 🔥 Complete Firebase Setup for Push Notifications

### Prerequisites

- ✅ Firebase project created
- ✅ App registered in Firebase Console
- ✅ `google-services.json` in `android/app/` folder
- ✅ Firebase dependencies in `pubspec.yaml`

---

## 📱 STEP 1: Verify Firebase Configuration

### Check Files Exist

**Android**: `android/app/google-services.json`

```json
{
  "project_info": {
    "project_number": "YOUR_PROJECT_NUMBER",
    "project_id": "YOUR_PROJECT_ID",
    ...
  }
}
```

**Check pubspec.yaml has:**

```yaml
dependencies:
  firebase_core: ^latest
  firebase_messaging: ^latest
  flutter_local_notifications: ^latest
```

---

## 📡 STEP 2: Get Your FCM Token

### Method 1: From App Settings Screen

1. **Run the app**
2. **Go to Settings screen** (Gear icon in home screen)
3. **Scroll down** to "FCM Token" section
4. **Copy the token** - Long string starting with something like:
   ```
   cXXXXXXX:APA91bFXXXXXXXXXXXXXXXX...
   ```
5. **Save this token** - You'll need it for testing

### Method 2: From Console Logs

When app starts, check console for:

```
📱 FCM Token: [YOUR_TOKEN_HERE]
👆 Copy this token to test notifications from Firebase Console
✅ FCM Token saved to storage
```

---

## 🎯 STEP 3: Test FCM with Single Device Token

### Using Firebase Console

1. **Go to Firebase Console**: https://console.firebase.google.com
2. **Select your project**
3. **Navigate**: Engage → Cloud Messaging
4. **Click**: "Send your first message" or "New campaign"

### Configure Test Notification

**Notification Details:**

```
Title: Test Notification
Body: This is a test message
```

**Target:**

- Select: "Send test message"
- Enter: Your FCM token (from STEP 2)
- Click: "Test"

**Expected Result:**

- ✅ Notification appears on device
- ✅ System tray shows notification
- ✅ App receives notification data

---

## 📢 STEP 4: Set Up FCM Topics

### What Are Topics?

Topics allow you to send notifications to **groups of users** who subscribe to specific categories:

- `alerts` - For local alerts
- `events` - For events and festivals
- `devotional` - For devotional content

### Topics Are Already Configured! ✅

Your app **automatically subscribes** users to topics based on their preferences in Settings.

### Verify Topics in Console

When app initializes, you should see logs:

```
✅ Subscribed to topic: alerts
✅ Subscribed to topic: events
✅ Subscribed to topic: devotional
```

---

## 🚀 STEP 5: Send Notification to Topic (Firebase Console)

### Method A: Using Firebase Console UI

#### Option 1: Using Messaging (Recommended for Campaigns)

1. **Go to**: Firebase Console → **Left sidebar** → **Engage** section
2. **Click**: **"Messaging"** (or "Cloud Messaging")
3. **Click**: "New campaign" button or "Create your first campaign"
4. **Select**: "Firebase Notification messages"

**Note**: If you don't see "Messaging" in the left sidebar:

- Make sure you're on the correct Firebase project
- Some older projects may need to enable this feature first

#### Option 2: Using Notifications Composer (Direct Method)

1. **Go to**: Firebase Console
2. **Left sidebar** → **Engage** → **Messaging**
3. **Click**: "Send your first message" (if first time)
4. **OR Click**: "New notification"

#### **Tab 1: Notification**

```
Title: Emergency Alert
Body: Heavy rain expected in your area
Image URL: (optional) https://example.com/image.jpg
```

#### **Tab 2: Target**

- Select: "Topic"
- Enter topic name: `alerts`
- Click "Next"

#### **Tab 3: Additional Options**

Click "Advanced options" → "Custom data"

Add key-value pairs:

```
Key: type          | Value: alert
Key: category      | Value: weather
Key: area          | Value: Downtown
Key: locality      | Value: Main Street
```

#### **Tab 4: Review and Send**

- Click "Review"
- Click "Publish"

**Expected Result:**

- ✅ All users subscribed to `alerts` topic receive notification
- ✅ Notification appears in system tray
- ✅ App stores notification in history
- ✅ Visible in Notifications screen

---

## 🔧 STEP 6: Send Notification Using REST API

### Get Server Key

1. **Go to**: Firebase Console → Project Settings
2. **Select**: Cloud Messaging tab
3. **Find**: "Server key" or "Cloud Messaging API (Legacy)"
4. **Copy**: Server key (starts with `AAAA...`)

**⚠️ Note**: For new projects, use Firebase Admin SDK instead

---

## 📨 STEP 7: Send Notifications via API (Backend)

### Option 1: Using Legacy HTTP API

#### Endpoint

```
POST https://fcm.googleapis.com/fcm/send
```

#### Headers

```
Content-Type: application/json
Authorization: key=YOUR_SERVER_KEY
```

#### Example 1: Alert Notification to Topic

```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Content-Type: application/json" \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -d '{
    "to": "/topics/alerts",
    "notification": {
      "title": "🚨 Emergency Alert",
      "body": "Heavy rain expected in your area"
    },
    "data": {
      "type": "alert",
      "alertId": "alert_123",
      "category": "weather",
      "area": "Downtown",
      "locality": "Main Street",
      "customKey": "అన్ని మందులపై 20% తగ్గింపు"
    }
  }'
```

#### Example 2: Event Notification to Topic

```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Content-Type: application/json" \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -d '{
    "to": "/topics/events",
    "notification": {
      "title": "📅 New Event: Summer Festival",
      "body": "Join us this weekend for celebration"
    },
    "data": {
      "type": "event",
      "eventId": "event_456",
      "category": "festival",
      "isReminder": "false"
    }
  }'
```

#### Example 3: Devotional Notification to Topic

```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Content-Type: application/json" \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -d '{
    "to": "/topics/devotional",
    "notification": {
      "title": "🙏 Morning Prayer",
      "body": "Start your day with divine blessings"
    },
    "data": {
      "type": "devotional",
      "subtype": "prayer_time",
      "prayerName": "Morning Aarti"
    }
  }'
```

---

### Option 2: Using Firebase Admin SDK (Node.js)

#### Install

```bash
npm install firebase-admin
```

#### Initialize

```javascript
const admin = require("firebase-admin");
const serviceAccount = require("./path/to/serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});
```

#### Send to Topic

```javascript
// Alert Notification
const message = {
  notification: {
    title: "🚨 Emergency Alert",
    body: "Heavy rain expected in your area",
  },
  data: {
    type: "alert",
    alertId: "alert_123",
    category: "weather",
    area: "Downtown",
    locality: "Main Street",
  },
  topic: "alerts",
};

admin
  .messaging()
  .send(message)
  .then((response) => {
    console.log("Successfully sent message:", response);
  })
  .catch((error) => {
    console.log("Error sending message:", error);
  });
```

```javascript
// Event Notification
const eventMessage = {
  notification: {
    title: "📅 New Event: Summer Festival",
    body: "Join us this weekend",
  },
  data: {
    type: "event",
    eventId: "event_456",
    category: "festival",
  },
  topic: "events",
};

admin.messaging().send(eventMessage);
```

```javascript
// Devotional Notification
const devotionalMessage = {
  notification: {
    title: "🙏 Morning Prayer",
    body: "Start your day with blessings",
  },
  data: {
    type: "devotional",
    prayerName: "Morning Aarti",
  },
  topic: "devotional",
};

admin.messaging().send(devotionalMessage);
```

---

### Option 3: Using Python with Firebase Admin SDK

#### Install

```bash
pip install firebase-admin
```

#### Code

```python
import firebase_admin
from firebase_admin import credentials
from firebase_admin import messaging

# Initialize
cred = credentials.Certificate("path/to/serviceAccountKey.json")
firebase_admin.initialize_app(cred)

# Send Alert to Topic
message = messaging.Message(
    notification=messaging.Notification(
        title='🚨 Emergency Alert',
        body='Heavy rain expected in your area',
    ),
    data={
        'type': 'alert',
        'category': 'weather',
        'area': 'Downtown',
    },
    topic='alerts',
)

response = messaging.send(message)
print('Successfully sent message:', response)
```

---

## 🧪 STEP 8: Test All Three Topics

### Test Script (Node.js)

```javascript
const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

async function testAllTopics() {
  // 1. Test Alerts Topic
  console.log("Sending to alerts topic...");
  await admin.messaging().send({
    notification: {
      title: "🚨 Test Alert",
      body: "This is a test alert notification",
    },
    data: { type: "alert", category: "test" },
    topic: "alerts",
  });

  // 2. Test Events Topic
  console.log("Sending to events topic...");
  await admin.messaging().send({
    notification: {
      title: "📅 Test Event",
      body: "This is a test event notification",
    },
    data: { type: "event", category: "test" },
    topic: "events",
  });

  // 3. Test Devotional Topic
  console.log("Sending to devotional topic...");
  await admin.messaging().send({
    notification: {
      title: "🙏 Test Devotional",
      body: "This is a test devotional notification",
    },
    data: { type: "devotional" },
    topic: "devotional",
  });

  console.log("All test notifications sent!");
}

testAllTopics().catch(console.error);
```

---

## 🔍 STEP 9: Verify Notifications in App

### Check Notifications Screen

1. **Open app**
2. **Tap bell icon** in home screen
3. **Verify** you see 3 notifications:
   - 🚨 Test Alert (Red theme)
   - 📅 Test Event (Purple theme)
   - 🙏 Test Devotional (Violet theme)

### Use Filters

1. **Tap "Alerts"** - See only alert
2. **Tap "Events"** - See only event
3. **Tap "Devotional"** - See only devotional
4. **Tap "All"** - See all 3

---

## 🎛️ STEP 10: Test User Preferences

### Disable a Topic

1. **Go to Settings**
2. **Toggle OFF** "Alert Notifications"
3. **Check logs**: Should see `Unsubscribed from topic: alerts`
4. **Send notification** to alerts topic
5. **Verify**: Notification NOT received

### Re-enable Topic

1. **Toggle ON** "Alert Notifications"
2. **Check logs**: Should see `Subscribed to topic: alerts`
3. **Send notification** to alerts topic
4. **Verify**: Notification received

---

## 📊 STEP 11: Monitor Delivery (Firebase Console)

### View Statistics

1. **Go to**: Firebase Console → Cloud Messaging
2. **Click**: Campaign name
3. **View**:
   - Notifications sent
   - Notifications opened
   - Delivery rate
   - Error rate

### Debug Failed Deliveries

Common issues:

- ❌ **Invalid token** - User uninstalled app
- ❌ **Topic not subscribed** - User disabled in settings
- ❌ **Network error** - Device offline
- ❌ **Invalid server key** - Wrong credentials

---

## 🔔 STEP 12: Advanced: Scheduled Notifications

### Using Firebase Cloud Functions

#### Install Firebase CLI

```bash
npm install -g firebase-tools
firebase login
firebase init functions
```

#### Create Scheduled Function

```javascript
// functions/index.js
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// Daily morning devotional (6 AM IST)
exports.sendMorningDevotion = functions.pubsub
  .schedule("0 6 * * *")
  .timeZone("Asia/Kolkata")
  .onRun(async (context) => {
    const message = {
      notification: {
        title: "🙏 Morning Prayer",
        body: "Start your day with divine blessings",
      },
      data: {
        type: "devotional",
        subtype: "daily_prayer",
      },
      topic: "devotional",
    };

    await admin.messaging().send(message);
    console.log("Morning devotional sent");
    return null;
  });

// Event reminders (check 1 day before)
exports.sendEventReminders = functions.pubsub
  .schedule("0 9 * * *")
  .timeZone("Asia/Kolkata")
  .onRun(async (context) => {
    // Query events happening tomorrow
    // Send notifications
    console.log("Event reminders sent");
    return null;
  });
```

#### Deploy

```bash
firebase deploy --only functions
```

---

## 🚨 Troubleshooting

### Notifications Not Received?

**Check 1: App Logs**

```
✅ NotificationService initialized successfully
✅ Subscribed to topic: alerts
📱 FCM Token: [YOUR_TOKEN]
```

**Check 2: Settings**

- Ensure notification type is enabled
- Check system notification permissions

**Check 3: Firebase Console**

- Verify message sent successfully
- Check delivery reports

**Check 4: Device**

- Ensure internet connection
- Disable battery optimization for app
- Check Do Not Disturb settings

### Token Not Showing in Settings?

Check logs for:

```
❌ Failed to get FCM token: [ERROR]
```

Common causes:

- Firebase not initialized
- `google-services.json` missing
- Wrong package name in Firebase

---

## 📱 Platform-Specific Setup

### Android

#### Minimum SDK Version

```gradle
// android/app/build.gradle
android {
    defaultConfig {
        minSdkVersion 21  // FCM requires min 21
    }
}
```

#### Notification Icon

Place notification icon in:

```
android/app/src/main/res/
  └── mipmap-*/ic_launcher.png
```

### iOS

#### Add Capabilities

1. Open Xcode project
2. Select target → Capabilities
3. Enable "Push Notifications"
4. Enable "Background Modes" → Check "Remote notifications"

#### APNs Certificate

1. Generate APNs certificate in Apple Developer Portal
2. Upload to Firebase Console → Project Settings → Cloud Messaging

---

## ✅ Quick Verification Checklist

- [ ] Firebase project created
- [ ] `google-services.json` in place
- [ ] App runs successfully
- [ ] FCM token visible in Settings
- [ ] Can send test notification to token
- [ ] Topics appear in logs (alerts, events, devotional)
- [ ] Can send to topic from Firebase Console
- [ ] All 3 topic types work (alerts, events, devotional)
- [ ] Notifications appear in app Notifications screen
- [ ] Badge updates on home screen
- [ ] Can disable/enable topics in Settings
- [ ] Preferences persist after app restart

---

## 📞 Need Help?

**Firebase Documentation**: https://firebase.google.com/docs/cloud-messaging

**Test Your Setup**:

1. Get FCM token from Settings
2. Send test from Firebase Console
3. Check Notifications screen in app

**Still Not Working?**

- Check console logs carefully
- Verify `google-services.json` matches package name
- Ensure Firebase services are enabled in console
- Try sending to individual token first, then topics
