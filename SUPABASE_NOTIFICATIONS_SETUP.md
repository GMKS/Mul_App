# Supabase + FCM Hybrid Notification Setup

## 🎯 Architecture Overview

Your app uses **Supabase for backend** and **Firebase Cloud Messaging (FCM) for push notifications only**. This is the recommended approach because:

✅ Supabase handles: Auth, Database, Storage, Edge Functions  
✅ Firebase handles: Push notifications (FCM is industry standard)  
✅ Supabase triggers notifications via Edge Functions

---

## 📋 Current Setup Status

### ✅ Already Configured

- Supabase initialized in `main.dart`
- Firebase Core initialized
- Firebase Messaging configured
- Notification services created

### 🔧 What We'll Add

- Supabase Edge Functions to trigger notifications
- Database table to store notification history
- Supabase Realtime for instant in-app updates
- Topic management via Supabase

---

## 🗄️ STEP 1: Create Notifications Table in Supabase

### SQL Schema

Go to **Supabase Dashboard → SQL Editor** and run:

```sql
-- Notifications table
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('alert', 'event', 'devotional', 'general')),
  category TEXT,
  area TEXT,
  locality TEXT,
  image_url TEXT,
  action_url TEXT,
  metadata JSONB DEFAULT '{}'::jsonb,
  is_read BOOLEAN DEFAULT false,
  sent_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_type ON notifications(type);
CREATE INDEX idx_notifications_sent_at ON notifications(sent_at DESC);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);

-- Enable Row Level Security
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own notifications
CREATE POLICY "Users can view own notifications" ON notifications
  FOR SELECT USING (auth.uid() = user_id);

-- Policy: Service role can insert notifications
CREATE POLICY "Service can insert notifications" ON notifications
  FOR INSERT WITH CHECK (true);

-- Policy: Users can update their own notifications (mark as read)
CREATE POLICY "Users can update own notifications" ON notifications
  FOR UPDATE USING (auth.uid() = user_id);

-- Enable Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
```

### User Notification Preferences Table

```sql
-- User notification preferences
CREATE TABLE user_notification_preferences (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  alerts_enabled BOOLEAN DEFAULT true,
  events_enabled BOOLEAN DEFAULT true,
  devotional_enabled BOOLEAN DEFAULT true,
  fcm_token TEXT,
  topics TEXT[] DEFAULT ARRAY[]::TEXT[],
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE user_notification_preferences ENABLE ROW LEVEL SECURITY;

-- Policy: Users can manage their own preferences
CREATE POLICY "Users can view own preferences" ON user_notification_preferences
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own preferences" ON user_notification_preferences
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own preferences" ON user_notification_preferences
  FOR UPDATE USING (auth.uid() = user_id);
```

---

## ⚙️ STEP 2: Create Supabase Edge Function for FCM

### Install Supabase CLI

```bash
npm install -g supabase
supabase login
supabase link --project-ref vwazacymtdhvynuglzph
```

### Create Edge Function

```bash
supabase functions new send-notification
```

### Function Code: `supabase/functions/send-notification/index.ts`

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

interface NotificationPayload {
  title: string;
  body: string;
  type: "alert" | "event" | "devotional" | "general";
  topic?: string;
  userIds?: string[];
  data?: Record<string, any>;
  imageUrl?: string;
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const payload: NotificationPayload = await req.json();

    // Get Firebase Server Key from environment
    const FCM_SERVER_KEY = Deno.env.get("FCM_SERVER_KEY");
    if (!FCM_SERVER_KEY) {
      throw new Error("FCM_SERVER_KEY not configured");
    }

    // Initialize Supabase client
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Prepare FCM message
    let fcmPayload: any = {
      notification: {
        title: payload.title,
        body: payload.body,
      },
      data: {
        type: payload.type,
        ...payload.data,
      },
      android: {
        priority: "high",
        notification: {
          sound: "default",
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
    };

    // Add image if provided
    if (payload.imageUrl) {
      fcmPayload.notification.image = payload.imageUrl;
    }

    // Send to topic or specific users
    if (payload.topic) {
      fcmPayload.to = `/topics/${payload.topic}`;
    } else if (payload.userIds && payload.userIds.length > 0) {
      // Get FCM tokens for specific users
      const { data: preferences } = await supabase
        .from("user_notification_preferences")
        .select("fcm_token")
        .in("user_id", payload.userIds)
        .not("fcm_token", "is", null);

      const tokens = preferences?.map((p) => p.fcm_token).filter(Boolean) || [];

      if (tokens.length === 0) {
        throw new Error("No FCM tokens found for specified users");
      }

      fcmPayload.registration_ids = tokens;
    } else {
      throw new Error("Either topic or userIds must be provided");
    }

    // Send via FCM
    const fcmResponse = await fetch("https://fcm.googleapis.com/fcm/send", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `key=${FCM_SERVER_KEY}`,
      },
      body: JSON.stringify(fcmPayload),
    });

    const fcmResult = await fcmResponse.json();

    // Store notification in database (for history)
    if (payload.userIds) {
      const notifications = payload.userIds.map((userId) => ({
        user_id: userId,
        title: payload.title,
        body: payload.body,
        type: payload.type,
        image_url: payload.imageUrl,
        metadata: payload.data || {},
      }));

      await supabase.from("notifications").insert(notifications);
    }

    return new Response(
      JSON.stringify({
        success: true,
        fcmResult,
        message: "Notification sent successfully",
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200,
      }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({
        success: false,
        error: error.message,
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 400,
      }
    );
  }
});
```

### Deploy Edge Function

```bash
# Set FCM Server Key as secret
supabase secrets set FCM_SERVER_KEY=YOUR_FIREBASE_SERVER_KEY

# Deploy function
supabase functions deploy send-notification
```

---

## 📱 STEP 3: Update Flutter App to Use Supabase

### Update Notification Service to Save to Supabase

Create: `lib/services/supabase_notification_service.dart`

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_item_model.dart';

class SupabaseNotificationService {
  static final SupabaseNotificationService _instance = SupabaseNotificationService._internal();
  factory SupabaseNotificationService() => _instance;
  SupabaseNotificationService._internal();

  final _supabase = Supabase.instance.client;

  /// Save FCM token to Supabase
  Future<void> saveFCMToken(String token) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase
          .from('user_notification_preferences')
          .upsert({
            'user_id': userId,
            'fcm_token': token,
            'updated_at': DateTime.now().toIso8601String(),
          });

      print('✅ FCM token saved to Supabase');
    } catch (e) {
      print('❌ Failed to save FCM token: $e');
    }
  }

  /// Update notification preferences
  Future<void> updatePreferences({
    required bool alertsEnabled,
    required bool eventsEnabled,
    required bool devotionalEnabled,
    required List<String> topics,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase
          .from('user_notification_preferences')
          .upsert({
            'user_id': userId,
            'alerts_enabled': alertsEnabled,
            'events_enabled': eventsEnabled,
            'devotional_enabled': devotionalEnabled,
            'topics': topics,
            'updated_at': DateTime.now().toIso8601String(),
          });

      print('✅ Preferences saved to Supabase');
    } catch (e) {
      print('❌ Failed to save preferences: $e');
    }
  }

  /// Fetch notifications from Supabase
  Future<List<NotificationItem>> fetchNotifications({
    NotificationType? filter,
    int limit = 100,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      var query = _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('sent_at', ascending: false)
          .limit(limit);

      if (filter != null) {
        query = query.eq('type', filter.toString().split('.').last);
      }

      final response = await query;

      return (response as List).map((json) {
        return NotificationItem(
          id: json['id'],
          title: json['title'],
          body: json['body'],
          type: NotificationType.values.firstWhere(
            (e) => e.toString().split('.').last == json['type'],
            orElse: () => NotificationType.general,
          ),
          timestamp: DateTime.parse(json['sent_at']),
          isRead: json['is_read'] ?? false,
          metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
          imageUrl: json['image_url'],
          actionUrl: json['action_url'],
        );
      }).toList();
    } catch (e) {
      print('❌ Failed to fetch notifications: $e');
      return [];
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      print('❌ Failed to mark as read: $e');
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('id', notificationId);
    } catch (e) {
      print('❌ Failed to delete notification: $e');
    }
  }

  /// Subscribe to real-time notifications
  RealtimeChannel subscribeToNotifications(
    void Function(NotificationItem) onNotification,
  ) {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final channel = _supabase
        .channel('notifications:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            final json = payload.newRecord;
            final notification = NotificationItem(
              id: json['id'],
              title: json['title'],
              body: json['body'],
              type: NotificationType.values.firstWhere(
                (e) => e.toString().split('.').last == json['type'],
                orElse: () => NotificationType.general,
              ),
              timestamp: DateTime.parse(json['sent_at']),
              isRead: json['is_read'] ?? false,
              metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
              imageUrl: json['image_url'],
              actionUrl: json['action_url'],
            );
            onNotification(notification);
          },
        )
        .subscribe();

    return channel;
  }

  /// Send notification via Edge Function
  Future<bool> sendNotification({
    required String title,
    required String body,
    required NotificationType type,
    String? topic,
    List<String>? userIds,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'send-notification',
        body: {
          'title': title,
          'body': body,
          'type': type.toString().split('.').last,
          if (topic != null) 'topic': topic,
          if (userIds != null) 'userIds': userIds,
          if (data != null) 'data': data,
          if (imageUrl != null) 'imageUrl': imageUrl,
        },
      );

      return response.status == 200;
    } catch (e) {
      print('❌ Failed to send notification: $e');
      return false;
    }
  }
}
```

---

## 🔄 STEP 4: Update Notification Triggers Service

Modify `lib/services/notification_triggers_service.dart` to integrate Supabase:

```dart
// Add at the top
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_notification_service.dart';

// In the class, add:
final _supabaseNotificationService = SupabaseNotificationService();

// In init() method, add FCM token saving:
Future<void> init() async {
  await _loadPreferences();
  await _loadStoredNotifications();
  await _subscribeToTopics();

  // Save FCM token to Supabase
  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) {
    await _supabaseNotificationService.saveFCMToken(token);
  }

  // Listen to token refresh
  FirebaseMessaging.instance.onTokenRefresh.listen((token) {
    _supabaseNotificationService.saveFCMToken(token);
  });
}

// Update setAlertsEnabled, setEventsEnabled, setDevotionalEnabled to save to Supabase:
Future<void> setAlertsEnabled(bool enabled) async {
  _alertsEnabled = enabled;
  await _prefs.setBool('alerts_enabled', enabled);

  // Update Supabase
  await _supabaseNotificationService.updatePreferences(
    alertsEnabled: enabled,
    eventsEnabled: _eventsEnabled,
    devotionalEnabled: _devotionalEnabled,
    topics: _getActiveTopics(),
  );

  if (enabled) {
    await FirebaseMessaging.instance.subscribeToTopic('alerts');
  } else {
    await FirebaseMessaging.instance.unsubscribeFromTopic('alerts');
  }
  notifyListeners();
}

// Helper to get active topics
List<String> _getActiveTopics() {
  final topics = <String>[];
  if (_alertsEnabled) topics.add('alerts');
  if (_eventsEnabled) topics.add('events');
  if (_devotionalEnabled) topics.add('devotional');
  return topics;
}
```

---

## 🚀 STEP 5: Trigger Notifications from Backend

### Example 1: Send Alert to Topic (from anywhere)

```dart
// From your Flutter app or backend
await SupabaseNotificationService().sendNotification(
  title: '🚨 Emergency Alert',
  body: 'Heavy rain expected in your area',
  type: NotificationType.alert,
  topic: 'alerts',
  data: {
    'category': 'weather',
    'area': 'Downtown',
  },
);
```

### Example 2: Using SQL Trigger

Create a database trigger to auto-send notifications when alerts are created:

```sql
-- Function to send notification when alert is created
CREATE OR REPLACE FUNCTION notify_new_alert()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM net.http_post(
    url := 'https://vwazacymtdhvynuglzph.supabase.co/functions/v1/send-notification',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || current_setting('app.service_role_key')
    ),
    body := jsonb_build_object(
      'title', '🚨 New Alert: ' || NEW.title,
      'body', NEW.description,
      'type', 'alert',
      'topic', 'alerts',
      'data', jsonb_build_object(
        'alertId', NEW.id,
        'category', NEW.category,
        'area', NEW.area
      )
    )
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
CREATE TRIGGER on_alert_created
  AFTER INSERT ON alerts
  FOR EACH ROW
  EXECUTE FUNCTION notify_new_alert();
```

### Example 3: From Node.js Backend

```javascript
const { createClient } = require("@supabase/supabase-js");

const supabase = createClient(
  "https://vwazacymtdhvynuglzph.supabase.co",
  "YOUR_SERVICE_ROLE_KEY"
);

// Send notification
const { data, error } = await supabase.functions.invoke("send-notification", {
  body: {
    title: "📅 New Event: Summer Festival",
    body: "Join us this weekend",
    type: "event",
    topic: "events",
    data: {
      eventId: "123",
      category: "festival",
    },
  },
});
```

---

## 📊 STEP 6: Test the Complete Flow

### Test 1: User Registers FCM Token

```dart
// This happens automatically in init()
// Check Supabase Dashboard → Table: user_notification_preferences
// Should see your user_id with fcm_token populated
```

### Test 2: Send Via Edge Function

```bash
curl -X POST 'https://vwazacymtdhvynuglzph.supabase.co/functions/v1/send-notification' \
  -H 'Authorization: Bearer YOUR_ANON_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "title": "🧪 Test from Supabase",
    "body": "This notification was sent via Supabase Edge Function",
    "type": "alert",
    "topic": "alerts"
  }'
```

### Test 3: Verify in App

1. Open app
2. Should receive notification
3. Check Notifications screen
4. Open Supabase Dashboard → Notifications table
5. Should see the notification record

---

## 🔐 Security Setup

### Environment Variables

In Supabase Dashboard → Project Settings → Edge Functions:

```
FCM_SERVER_KEY=YOUR_FIREBASE_SERVER_KEY
```

### RLS Policies Already Created ✅

The SQL above includes proper Row Level Security policies.

---

## 🎯 Summary

**What You Have Now:**

1. ✅ **Firebase FCM**: Handles push notification delivery
2. ✅ **Supabase Database**: Stores notification history
3. ✅ **Supabase Edge Functions**: Sends notifications to FCM
4. ✅ **Supabase Realtime**: Live notification updates in-app
5. ✅ **Topic Management**: Via Supabase preferences table
6. ✅ **FCM Token Storage**: In Supabase for targeting users

**Benefits:**

- 🎯 Single source of truth (Supabase)
- 🔄 Real-time updates in app
- 📊 Notification history and analytics
- 🔐 Proper security with RLS
- 🚀 Scalable architecture
- 💰 Cost-effective (Supabase is free tier friendly)

**Next Steps:**

1. Run the SQL in Supabase Dashboard
2. Create and deploy the Edge Function
3. Update Flutter code to integrate Supabase service
4. Test sending notifications via Edge Function
5. Enjoy unified notification system! 🎉
