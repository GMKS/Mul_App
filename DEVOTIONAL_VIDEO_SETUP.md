# Real-Time Devotional Video Upload & Streaming Setup Guide

## 📋 Overview

This system allows users to upload devotional videos that are instantly visible to all app users in real-time.

---

## 🗄️ Supabase Setup

### 1. Create Storage Bucket

In Supabase Dashboard → Storage:

1. Create a **new bucket** named: `devotional-content`
2. Set it to **Public** (so videos/thumbnails are accessible)
3. Create folders:
   - `devotional/videos/`
   - `devotional/thumbnails/`

### 2. Update devotional_videos Table

Add this column to track uploader:

```sql
ALTER TABLE devotional_videos
ADD COLUMN uploaded_by UUID REFERENCES auth.users(id);
```

### 3. Enable Row Level Security (RLS)

```sql
-- Allow anyone to read verified videos
CREATE POLICY "Allow public read verified videos"
ON devotional_videos FOR SELECT
USING (is_verified = true);

-- Allow authenticated users to insert videos
CREATE POLICY "Allow users to upload videos"
ON devotional_videos FOR INSERT
WITH CHECK (auth.uid() = uploaded_by);

-- Allow users to view their own unverified videos
CREATE POLICY "Allow users to view their videos"
ON devotional_videos FOR SELECT
USING (auth.uid() = uploaded_by);
```

### 4. Enable Realtime

In Supabase Dashboard → Database → Replication:

- Enable **Realtime** for `devotional_videos` table
- This allows instant updates when new videos are added

---

## 🎯 How It Works

### **Upload Flow:**

1. User opens the app
2. Navigates to Devotional → Upload button (➕)
3. Fills form:
   - Video file (from gallery or camera)
   - Thumbnail image
   - Title, deity, temple name
   - Language, festival tags
4. Clicks "Upload"
5. Video uploads to Supabase Storage
6. Metadata saved to `devotional_videos` table
7. Status: `is_verified = false` (pending admin approval)

### **Real-Time Viewing:**

1. Admin verifies video (sets `is_verified = true`)
2. **ALL users instantly see the new video** (no refresh needed)
3. Video appears in feed based on filters (deity/language/location)

---

## 💻 Code Integration

### **1. Navigation to Upload Screen**

Add this button to your devotional feed:

```dart
FloatingActionButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UploadDevotionalVideoScreen(),
      ),
    );
  },
  child: const Icon(Icons.add),
)
```

### **2. Use Real-Time Streaming**

In your devotional feed screen:

```dart
import 'package:provider/provider.dart';
import '../controllers/devotional_controller.dart';

class DevotionalFeedScreen extends StatefulWidget {
  // ...
}

class _DevotionalFeedScreenState extends State<DevotionalFeedScreen> {
  @override
  void initState() {
    super.initState();

    // Start real-time streaming
    context.read<DevotionalController>().startRealtimeStream(
      deity: 'Lord Rama',  // Optional filter
      language: 'telugu',  // Optional filter
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DevotionalController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.error != null) {
          return Center(child: Text('Error: ${controller.error}'));
        }

        // Display videos in real-time
        return ListView.builder(
          itemCount: controller.videos.length,
          itemBuilder: (context, index) {
            final video = controller.videos[index];
            return VideoCard(video: video);
          },
        );
      },
    );
  }

  @override
  void dispose() {
    // Stop streaming when leaving screen
    context.read<DevotionalController>().stopRealtimeStream();
    super.dispose();
  }
}
```

### **3. Filter Videos**

```dart
// Filter by deity
ElevatedButton(
  onPressed: () {
    context.read<DevotionalController>().filterByDeity('Lord Rama');
  },
  child: Text('Show Rama Videos'),
)

// Filter by language
ElevatedButton(
  onPressed: () {
    context.read<DevotionalController>().filterByLanguage('telugu');
  },
  child: Text('Telugu Only'),
)

// Clear all filters
ElevatedButton(
  onPressed: () {
    context.read<DevotionalController>().clearFilters();
  },
  child: Text('Show All'),
)
```

---

## 🔄 Testing Flow

### **Test with Mock Data:**

```dart
// In devotional_repository.dart
static const bool useMockData = true;
```

### **Test with Real Supabase:**

```dart
// In devotional_repository.dart
static const bool useMockData = false;
```

### **Test Real-Time Updates:**

1. Open app on **Device A**
2. Open app on **Device B**
3. Upload video from **Device A**
4. Admin verifies video in Supabase
5. **Device B automatically shows the new video** (no refresh!)

---

## 🚀 Production Checklist

Before publishing to Play Store:

- [ ] Set `useMockData = false`
- [ ] Verify Supabase RLS policies are active
- [ ] Test video upload with different file sizes
- [ ] Test real-time streaming on multiple devices
- [ ] Add admin panel for video verification
- [ ] Set up content moderation rules
- [ ] Add video compression (optional, for faster uploads)
- [ ] Test on slow network (3G/4G)
- [ ] Add analytics for video views

---

## 📱 User Flow Summary

**Upload:**

```
User → Upload Button → Select/Record Video → Fill Form → Upload
→ Video Saved (pending verification) → Admin Approves → Video Live!
```

**View:**

```
User Opens App → Real-Time Stream Active → New Video Added
→ Automatically Appears → No Refresh Needed!
```

---

## 🛠️ Files Created

1. **lib/services/devotional_upload_service.dart** - Handles video uploads
2. **lib/screens/devotional/upload_devotional_video_screen.dart** - Upload UI
3. **lib/controllers/devotional_controller.dart** - Real-time stream management
4. **lib/repositories/devotional_repository.dart** - Updated with streaming

---

## 🔍 Troubleshooting

**Videos not appearing in real-time?**

- Check if Realtime is enabled in Supabase
- Verify `is_verified = true` for test videos
- Check console logs for stream errors

**Upload fails?**

- Verify storage bucket is public
- Check file size limits (max 100MB recommended)
- Ensure authenticated user

**Stream disconnects?**

- Check network connection
- Verify Supabase URL and keys are correct
- Monitor console for error messages

---

## 📊 Admin Panel (Optional)

Create an admin screen to approve videos:

```dart
// Approve a video
await Supabase.instance.client
  .from('devotional_videos')
  .update({'is_verified': true})
  .eq('id', videoId);

// The video instantly appears to all users!
```

---

**You're all set!** 🎉  
Users can now upload videos that are visible to everyone in real-time.
