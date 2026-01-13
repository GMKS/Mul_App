# Supabase Database Schema Setup

## Authentication Setup

The app uses **Supabase Auth** with the following methods:

- **Anonymous Authentication**: Auto sign-in for browsing
- **Phone Authentication**: OTP-based verification for personalized features

## Database Collections (Tables)

### 1. profiles

User profile information

```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT,
  email TEXT,
  phone TEXT,
  primary_language TEXT DEFAULT 'en',
  secondary_language TEXT,
  region TEXT,
  state TEXT,
  city TEXT,
  is_first_login BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view and update their own profile
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);
```

### 2. videos

Video content for Regional, Business, Devotional categories

```sql
CREATE TABLE videos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  video_url TEXT NOT NULL,
  thumbnail_url TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  language TEXT NOT NULL,
  category TEXT NOT NULL CHECK (category IN ('Regional', 'Business', 'Devotional')),
  region TEXT,
  state TEXT,
  city TEXT,
  creator_id UUID REFERENCES profiles(id),
  creator_name TEXT,
  creator_avatar TEXT,
  likes INTEGER DEFAULT 0,
  comments INTEGER DEFAULT 0,
  shares INTEGER DEFAULT 0,
  views INTEGER DEFAULT 0,
  watch_time FLOAT DEFAULT 0,
  replays INTEGER DEFAULT 0,
  hashtags TEXT[],
  is_festival_content BOOLEAN DEFAULT false,
  is_boosted BOOLEAN DEFAULT false,
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'removed')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE videos ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can view active videos
CREATE POLICY "Anyone can view active videos" ON videos
  FOR SELECT USING (status = 'active');

-- Policy: Creators can insert their own videos
CREATE POLICY "Creators can insert videos" ON videos
  FOR INSERT WITH CHECK (auth.uid() = creator_id);
```

### 3. local_alerts

Approved local alerts for regional information

```sql
CREATE TABLE local_alerts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  category TEXT NOT NULL CHECK (category IN ('offer', 'event', 'emergency', 'news', 'announcement')),
  area TEXT,
  locality TEXT,
  region TEXT,
  state TEXT,
  city TEXT,
  start_time TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  end_time TIMESTAMP WITH TIME ZONE,
  status TEXT DEFAULT 'approved' CHECK (status IN ('pending', 'approved', 'rejected')),
  submitted_by UUID REFERENCES profiles(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE local_alerts ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can view approved alerts
CREATE POLICY "Anyone can view approved alerts" ON local_alerts
  FOR SELECT USING (status = 'approved');
```

### 4. alert_submissions

Customer-submitted alerts pending admin approval

```sql
CREATE TABLE alert_submissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  category TEXT NOT NULL,
  area TEXT,
  locality TEXT,
  submitted_by UUID REFERENCES profiles(id),
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE alert_submissions ENABLE ROW LEVEL SECURITY;

-- Policy: Users can submit alerts
CREATE POLICY "Users can submit alerts" ON alert_submissions
  FOR INSERT WITH CHECK (auth.uid() = submitted_by);

-- Policy: Users can view their own submissions
CREATE POLICY "Users can view own submissions" ON alert_submissions
  FOR SELECT USING (auth.uid() = submitted_by);
```

### 5. cab_services

Cab service listings by region

```sql
CREATE TABLE cab_services (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  whatsapp TEXT,
  city TEXT NOT NULL,
  state TEXT,
  region TEXT,
  service_type TEXT CHECK (service_type IN ('local', 'outstation', 'both')),
  rating FLOAT DEFAULT 0,
  is_verified BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE cab_services ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can view cab services
CREATE POLICY "Anyone can view cab services" ON cab_services
  FOR SELECT USING (true);
```

### 6. video_interactions

Track user interactions with videos

```sql
CREATE TABLE video_interactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id),
  video_id UUID REFERENCES videos(id) ON DELETE CASCADE,
  interaction_type TEXT NOT NULL CHECK (interaction_type IN ('like', 'comment', 'share', 'view', 'watch_time')),
  value INTEGER DEFAULT 1,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, video_id, interaction_type)
);

-- Enable RLS
ALTER TABLE video_interactions ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view and create their own interactions
CREATE POLICY "Users can manage own interactions" ON video_interactions
  FOR ALL USING (auth.uid() = user_id);
```

### 7. comments

Video comments

```sql
CREATE TABLE comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  video_id UUID REFERENCES videos(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id),
  user_name TEXT,
  user_avatar TEXT,
  comment_text TEXT NOT NULL,
  voice_url TEXT,
  likes INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can view comments
CREATE POLICY "Anyone can view comments" ON comments
  FOR SELECT USING (true);

-- Policy: Users can create comments
CREATE POLICY "Users can create comments" ON comments
  FOR INSERT WITH CHECK (auth.uid() = user_id);
```

## Setup Instructions

### 1. Create Tables in Supabase

1. Go to your Supabase dashboard: https://app.supabase.com
2. Select your project
3. Go to **SQL Editor**
4. Copy and paste each table schema above
5. Run each SQL statement

### 2. Enable Authentication

1. Go to **Authentication** > **Providers**
2. Enable **Phone** provider (for SMS OTP)
3. Configure SMS provider (Twilio or MessageBird)
4. **Anonymous** auth is enabled by default

### 3. Storage Buckets (Optional - for video uploads)

```sql
-- Create storage bucket for videos
INSERT INTO storage.buckets (id, name, public)
VALUES ('videos', 'videos', true);

-- Create storage bucket for thumbnails
INSERT INTO storage.buckets (id, name, public)
VALUES ('thumbnails', 'thumbnails', true);

-- Policy: Allow authenticated users to upload videos
CREATE POLICY "Authenticated users can upload videos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'videos');
```

### 4. Environment Variables

Make sure your Supabase credentials are set in `lib/main.dart`:

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_PROJECT_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

## Testing Authentication

Use the AuthService in your app:

```dart
// Auto sign in anonymously
await AuthService.ensureUserSignedIn();

// Sign in with phone
await AuthService.signInWithPhone('+1234567890');

// Verify OTP
await AuthService.verifyOTP(phone: '+1234567890', token: '123456');
```
