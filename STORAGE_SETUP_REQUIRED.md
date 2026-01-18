# ⚠️ CRITICAL: Supabase Storage Setup Required

## Error: "Bucket not found" (404)

This error occurs because the Supabase storage bucket hasn't been created yet.

---

## 🔧 Quick Fix (5 minutes)

### **Step 1: Create Storage Bucket**

1. Go to your Supabase Dashboard: https://supabase.com/dashboard
2. Select your project: **MyLocalApp**
3. Navigate to **Storage** (left sidebar)
4. Click **"New Bucket"**
5. Create bucket with these settings:
   - **Name:** `devotional-content`
   - **Public:** ✅ **Yes** (Check this box)
   - **File size limit:** 100 MB
   - **Allowed MIME types:** Leave empty (allow all)
6. Click **"Create Bucket"**

### **Step 2: Create Folder Structure**

After creating the bucket, create these folders inside it:

```
devotional-content/
  ├── devotional/
  │   ├── videos/
  │   └── thumbnails/
```

**How to create folders:**

1. Click on `devotional-content` bucket
2. Click **"Create Folder"**
3. Name it `devotional`
4. Open `devotional` folder
5. Create `videos` folder
6. Create `thumbnails` folder

---

## 🔐 Storage Security (Optional but Recommended)

### Set Up Row Level Security (RLS)

Go to **Storage** → **Policies** → **devotional-content** → **New Policy**:

**Policy 1: Allow Public Read**

```sql
CREATE POLICY "Allow public read"
ON storage.objects FOR SELECT
USING (bucket_id = 'devotional-content');
```

**Policy 2: Allow Authenticated Users to Upload**

```sql
CREATE POLICY "Allow authenticated uploads"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'devotional-content'
  AND auth.role() = 'authenticated'
);
```

---

## ✅ Verification

After setup, test by uploading a video in the app:

1. Open app → Devotional section
2. Tap **"Upload Video"** button
3. Select video and thumbnail
4. Fill form and upload
5. Should upload successfully!

---

## 📊 Storage Limits

**Free Tier (Supabase):**

- Storage: 1 GB
- Bandwidth: 2 GB/month
- File size limit: 50 MB (can increase)

**Upgrade if needed:**

- Pro Plan: $25/month (100 GB storage)

---

## 🐛 Still Getting Errors?

**Check these:**

1. Bucket name is exactly `devotional-content` (case-sensitive)
2. Bucket is set to **Public**
3. Folders are created inside the bucket
4. Your Supabase project is active (not paused)

**Check Connection:**

```dart
// In main.dart, verify these match your project:
url: 'https://vwazacymtdhvynuglzph.supabase.co'
anonKey: 'your-anon-key...'
```

---

## 📝 Alternative: Use Mock Data (Testing Only)

If you're still testing and don't want to set up storage yet:

**In `devotional_repository.dart`:**

```dart
static const bool useMockData = true;  // Use local mock data
```

This bypasses Supabase completely for testing.

---

**Once you create the bucket, the upload feature will work perfectly!** 🎉
