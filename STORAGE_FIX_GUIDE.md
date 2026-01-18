# CRITICAL: Supabase Storage Bucket Setup - SIMPLE METHOD

## Step 1: Make Bucket Public (EASIEST FIX)

### Go to Supabase Dashboard:

1. **Storage** → Click on `devotional-content` bucket
2. Look for **"Configuration"** or **"Settings"** tab
3. Find **"Public bucket"** toggle switch
4. **Turn it ON** (enable public access)
5. **Save/Apply** changes

This makes all files readable by anyone - perfect for video streaming!

---

## Step 2: Create Upload Policy via SQL Editor

### Go to SQL Editor:

1. Click **"SQL Editor"** in left sidebar
2. Click **"New Query"**
3. **Copy and paste this ENTIRE block:**

```sql
-- Delete any existing policies (clean slate)
DROP POLICY IF EXISTS "Public can view devotional content" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload" ON storage.objects;
DROP POLICY IF EXISTS "Public Access" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Upload" ON storage.objects;

-- Create simple public read policy
CREATE POLICY "Anyone can read devotional videos"
ON storage.objects FOR SELECT
USING (bucket_id = 'devotional-content');

-- Create simple authenticated upload policy
CREATE POLICY "Logged in users can upload devotional videos"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'devotional-content' AND auth.role() = 'authenticated');

-- Allow authenticated users to update their uploads
CREATE POLICY "Users can update devotional videos"
ON storage.objects FOR UPDATE
USING (bucket_id = 'devotional-content' AND auth.role() = 'authenticated');
```

4. Click **"Run"** or press **Ctrl+Enter**
5. You should see: **"Success. No rows returned"**

---

## Step 3: Verify Policies Created

### Go back to Storage:

1. **Storage** → `devotional-content` bucket
2. Click **"Policies"** tab
3. You should see 3 policies:
   - Anyone can read devotional videos (SELECT)
   - Logged in users can upload devotional videos (INSERT)
   - Users can update devotional videos (UPDATE)

---

## Step 4: Enable Anonymous Auth in Supabase

### Go to Authentication Settings:

1. **Authentication** → **"Providers"** (in left sidebar)
2. Find **"Anonymous Sign-ins"**
3. **Enable it** (toggle ON)
4. **Save** changes

This allows your app to authenticate users anonymously for uploads.

---

## Step 5: Test Upload

1. Restart your Flutter app
2. Navigate to Devotional → Upload Video
3. Select video + thumbnail
4. Fill in details
5. Click Upload
6. Watch console for:
   - `🔐 No user logged in, signing in anonymously...`
   - `✅ Anonymous sign-in successful`

---

## Troubleshooting

**Still getting "StorageException"?**

- Verify bucket is **Public** (Step 1)
- Run SQL again (Step 2)
- Check **Anonymous Sign-ins** enabled (Step 4)
- Restart app completely (not just hot reload)

**Getting "Auth error"?**

- Enable Anonymous Sign-ins in Authentication → Providers

**Getting "Policy error"?**

- Run the DROP POLICY commands first to clean up
- Then run CREATE POLICY commands

---

## Quick Verification Checklist

✅ Bucket `devotional-content` exists
✅ Bucket marked as **Public**
✅ 3 policies visible in Policies tab
✅ Anonymous Sign-ins enabled
✅ App restarted (not hot reloaded)

Once all checkboxes are checked, upload should work! 🎥
