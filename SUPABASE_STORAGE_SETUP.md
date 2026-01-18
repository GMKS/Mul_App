# Supabase Storage Setup for Devotional Videos

## ⚠️ Required: Create Storage Bucket

The "Storage not configured" error occurs because the Supabase Storage bucket doesn't exist yet.

### Step-by-Step Instructions:

#### 1. Open Supabase Dashboard

- Go to: https://supabase.com/dashboard
- Sign in to your account
- Select your project: **regional_shorts_app** (or your project name)

#### 2. Navigate to Storage

- Click **"Storage"** in the left sidebar
- You'll see a list of existing buckets (probably empty)

#### 3. Create New Bucket

- Click the **"New bucket"** button (top right)
- Fill in the details:

  - **Name**: `devotional-content` (exact name - don't change)
  - **Public bucket**: ✅ **Enable** (check this box)
  - **File size limit**: 100 MB (optional, recommended for video files)
  - **Allowed MIME types**: Leave empty or add: `video/*,image/*`

- Click **"Create bucket"**

#### 4. Verify Bucket Created

- You should now see `devotional-content` in your buckets list
- Click on it to open

#### 5. Set Storage Policies (Important!)

The bucket needs policies to allow uploads from authenticated users:

**Option A: Using Supabase Dashboard UI**

1. Click on `devotional-content` bucket
2. Go to **"Policies"** tab
3. Click **"New Policy"**
4. Create two policies:

**Policy 1: Allow Public Read**

```sql
-- Name: Public Read Access
-- Policy:
CREATE POLICY "Public can view devotional content"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'devotional-content');
```

**Policy 2: Allow Authenticated Upload**

```sql
-- Name: Authenticated users can upload
-- Policy:
CREATE POLICY "Authenticated users can upload devotional content"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'devotional-content');
```

**Option B: Quick Setup (All Authenticated Users)**

1. In bucket policies, click **"New Policy"**
2. Choose template: **"Allow authenticated uploads"**
3. Choose template: **"Allow public downloads"**
4. Apply both policies

#### 6. Test Upload

- Go back to your app
- Try uploading a video again
- It should work now! ✅

---

## Folder Structure (Automatic)

When videos are uploaded, they're automatically organized:

```
devotional-content/
├── devotional/
│   ├── videos/
│   │   ├── user123_timestamp.mp4
│   │   ├── user456_timestamp.mp4
│   │   └── ...
│   └── thumbnails/
│       ├── user123_timestamp.jpg
│       ├── user456_timestamp.jpg
│       └── ...
```

---

## Storage Pricing (Supabase)

- **Free Tier**: 1 GB storage + 2 GB bandwidth/month
- **Pro Plan**: 100 GB storage + 200 GB bandwidth ($25/month)
- **Pay-as-you-go**: $0.021/GB for storage, $0.09/GB for bandwidth

### Estimate for Your App:

- Average video: 5 MB
- Average thumbnail: 200 KB
- **Free tier**: ~180 videos
- **Pro plan**: ~18,000 videos

---

## Verify Cloud Storage is Working

After creating the bucket, uploaded videos will:
✅ Store in Supabase Cloud (not on user's device)
✅ Stream to all users from cloud
✅ Not increase app size
✅ Be accessible via public URL
✅ Automatically deleted from device after upload

Your app **already** handles this correctly - just needs the bucket created!

---

## Troubleshooting

**Still getting "Storage not configured"?**

1. Check bucket name is exactly: `devotional-content`
2. Verify bucket is marked as **Public**
3. Check storage policies are enabled
4. Restart your app (hot reload)

**Upload works but videos don't play?**

1. Check "Public bucket" is enabled
2. Verify public read policy exists
3. Test public URL in browser

**Need to change bucket name?**
Edit: `lib/services/devotional_upload_service.dart`

```dart
static const String _bucketName = 'your-new-bucket-name';
```
