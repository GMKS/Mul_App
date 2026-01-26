-- Bhajan Feature Database Schema
-- Daily Bhajan 2026+ Features: Smart Audio/Video, AI Playlists, Live Rooms, Offline Sync

-- ============================================
-- ENUMS
-- ============================================

-- Bhajan Type (Audio/Video)
CREATE TYPE bhajan_type AS ENUM ('audio', 'video');

-- Bhajan Category
CREATE TYPE bhajan_category AS ENUM (
  'morning', 'evening', 'aarti', 'chalisa', 'mantra',
  'kirtan', 'stotram', 'bhakti', 'meditation', 'festival'
);

-- Bhajan Mood
CREATE TYPE bhajan_mood AS ENUM (
  'peaceful', 'energetic', 'devotional', 'meditative',
  'celebratory', 'soulful', 'uplifting'
);

-- Streaming Quality
CREATE TYPE streaming_quality AS ENUM (
  'auto', 'low', 'medium', 'hd', 'full_hd', 'ultra_hd', 'spatial_audio'
);

-- Upload Status
CREATE TYPE upload_status AS ENUM (
  'pending', 'processing', 'ai_review', 'human_review',
  'approved', 'rejected', 'published'
);

-- Room Status
CREATE TYPE room_status AS ENUM ('active', 'ended', 'scheduled');

-- ============================================
-- MAIN TABLES
-- ============================================

-- Bhajans Table
CREATE TABLE IF NOT EXISTS bhajans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(255) NOT NULL,
  description TEXT,
  media_url VARCHAR(500) NOT NULL,
  type bhajan_type NOT NULL DEFAULT 'audio',
  language VARCHAR(50) NOT NULL DEFAULT 'hindi',
  
  -- Categorization
  category bhajan_category NOT NULL DEFAULT 'bhakti',
  tags TEXT[] DEFAULT '{}',
  mood bhajan_mood,
  deity VARCHAR(100),
  religion VARCHAR(100),
  festival VARCHAR(100),
  
  -- Media Info
  lyrics_url VARCHAR(500),
  subtitles_url VARCHAR(500),
  cover_image_url VARCHAR(500),
  duration_seconds INTEGER NOT NULL DEFAULT 0,
  
  -- Uploader Info
  uploaded_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  uploader_name VARCHAR(255),
  uploader_avatar_url VARCHAR(500),
  
  -- Flags
  is_trending BOOLEAN DEFAULT FALSE,
  is_featured BOOLEAN DEFAULT FALSE,
  is_verified BOOLEAN DEFAULT FALSE,
  is_premium BOOLEAN DEFAULT FALSE,
  has_lyrics BOOLEAN DEFAULT FALSE,
  has_subtitles BOOLEAN DEFAULT FALSE,
  ai_generated BOOLEAN DEFAULT FALSE,
  ai_upscaled BOOLEAN DEFAULT FALSE,
  
  -- Quality & Languages
  available_quality streaming_quality DEFAULT 'auto',
  available_languages TEXT[] DEFAULT '{"hindi"}',
  
  -- Stats (denormalized for performance)
  play_count INTEGER DEFAULT 0,
  like_count INTEGER DEFAULT 0,
  favorite_count INTEGER DEFAULT 0,
  share_count INTEGER DEFAULT 0,
  download_count INTEGER DEFAULT 0,
  
  -- Ratings
  avg_rating DECIMAL(2,1) DEFAULT 0.0,
  rating_count INTEGER DEFAULT 0,
  
  -- Approval Status
  status upload_status DEFAULT 'pending',
  approved BOOLEAN DEFAULT FALSE,
  approved_at TIMESTAMP WITH TIME ZONE,
  approved_by UUID REFERENCES auth.users(id),
  rejection_reason TEXT,
  
  -- AI Moderation
  ai_moderation_score DECIMAL(3,2),
  ai_moderation_flags TEXT[],
  ai_moderation_at TIMESTAMP WITH TIME ZONE,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  published_at TIMESTAMP WITH TIME ZONE
);

-- Bhajan Playlists Table
CREATE TABLE IF NOT EXISTS bhajan_playlists (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  description TEXT,
  cover_image_url VARCHAR(500),
  
  -- Playlist Type
  is_ai_curated BOOLEAN DEFAULT FALSE,
  is_official BOOLEAN DEFAULT FALSE,
  is_public BOOLEAN DEFAULT TRUE,
  
  -- For AI Playlists
  mood bhajan_mood,
  time_of_day VARCHAR(50), -- 'morning', 'afternoon', 'evening', 'night'
  deity VARCHAR(100),
  
  -- Owner
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  creator_name VARCHAR(255),
  
  -- Stats
  bhajan_count INTEGER DEFAULT 0,
  total_duration_seconds INTEGER DEFAULT 0,
  play_count INTEGER DEFAULT 0,
  follower_count INTEGER DEFAULT 0,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Playlist Bhajans Junction Table
CREATE TABLE IF NOT EXISTS playlist_bhajans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  playlist_id UUID NOT NULL REFERENCES bhajan_playlists(id) ON DELETE CASCADE,
  bhajan_id UUID NOT NULL REFERENCES bhajans(id) ON DELETE CASCADE,
  position INTEGER NOT NULL DEFAULT 0,
  added_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  UNIQUE(playlist_id, bhajan_id)
);

-- Bhajan Favorites Table
CREATE TABLE IF NOT EXISTS bhajan_favorites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  bhajan_id UUID NOT NULL REFERENCES bhajans(id) ON DELETE CASCADE,
  
  -- Offline Sync
  is_downloaded BOOLEAN DEFAULT FALSE,
  downloaded_at TIMESTAMP WITH TIME ZONE,
  download_quality streaming_quality DEFAULT 'medium',
  local_path VARCHAR(500),
  
  -- Sync Status
  last_synced_at TIMESTAMP WITH TIME ZONE,
  sync_version INTEGER DEFAULT 1,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  UNIQUE(user_id, bhajan_id)
);

-- Bhajan Rooms (Live Listening) Table
CREATE TABLE IF NOT EXISTS bhajan_rooms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  description TEXT,
  cover_image_url VARCHAR(500),
  
  -- Host
  host_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  host_name VARCHAR(255) NOT NULL,
  host_avatar_url VARCHAR(500),
  
  -- Current Playing
  current_bhajan_id UUID REFERENCES bhajans(id),
  current_position_seconds INTEGER DEFAULT 0,
  
  -- Room Settings
  is_public BOOLEAN DEFAULT TRUE,
  is_recording BOOLEAN DEFAULT FALSE,
  max_participants INTEGER DEFAULT 100,
  status room_status DEFAULT 'active',
  
  -- Schedule (for scheduled rooms)
  scheduled_at TIMESTAMP WITH TIME ZONE,
  
  -- Stats
  participant_count INTEGER DEFAULT 0,
  peak_participants INTEGER DEFAULT 0,
  total_reactions INTEGER DEFAULT 0,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  ended_at TIMESTAMP WITH TIME ZONE
);

-- Room Participants Table
CREATE TABLE IF NOT EXISTS room_participants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id UUID NOT NULL REFERENCES bhajan_rooms(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  
  is_muted BOOLEAN DEFAULT FALSE,
  is_host BOOLEAN DEFAULT FALSE,
  is_co_host BOOLEAN DEFAULT FALSE,
  
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  left_at TIMESTAMP WITH TIME ZONE,
  
  UNIQUE(room_id, user_id)
);

-- Room Messages (Chat) Table
CREATE TABLE IF NOT EXISTS room_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id UUID NOT NULL REFERENCES bhajan_rooms(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  user_name VARCHAR(255) NOT NULL,
  user_avatar_url VARCHAR(500),
  
  message TEXT NOT NULL,
  message_type VARCHAR(20) DEFAULT 'text', -- 'text', 'reaction', 'system', 'request'
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Bhajan Comments Table
CREATE TABLE IF NOT EXISTS bhajan_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  bhajan_id UUID NOT NULL REFERENCES bhajans(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  user_name VARCHAR(255) NOT NULL,
  user_avatar_url VARCHAR(500),
  
  content TEXT NOT NULL,
  parent_id UUID REFERENCES bhajan_comments(id) ON DELETE CASCADE, -- For replies
  
  like_count INTEGER DEFAULT 0,
  reply_count INTEGER DEFAULT 0,
  
  is_pinned BOOLEAN DEFAULT FALSE,
  is_hidden BOOLEAN DEFAULT FALSE,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Bhajan Listening History Table
CREATE TABLE IF NOT EXISTS bhajan_listening_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  bhajan_id UUID NOT NULL REFERENCES bhajans(id) ON DELETE CASCADE,
  
  -- Progress Tracking
  progress_seconds INTEGER DEFAULT 0,
  completed BOOLEAN DEFAULT FALSE,
  play_count INTEGER DEFAULT 1,
  
  -- Context
  source VARCHAR(50), -- 'search', 'playlist', 'recommendation', 'room'
  playlist_id UUID REFERENCES bhajan_playlists(id),
  room_id UUID REFERENCES bhajan_rooms(id),
  
  -- Timestamps
  first_listened_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_listened_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  UNIQUE(user_id, bhajan_id)
);

-- Bhajan Ratings Table
CREATE TABLE IF NOT EXISTS bhajan_ratings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  bhajan_id UUID NOT NULL REFERENCES bhajans(id) ON DELETE CASCADE,
  
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  UNIQUE(user_id, bhajan_id)
);

-- User Bhajan Preferences (For AI Recommendations) Table
CREATE TABLE IF NOT EXISTS user_bhajan_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Preferences
  favorite_deities TEXT[] DEFAULT '{}',
  favorite_categories bhajan_category[] DEFAULT '{}',
  favorite_moods bhajan_mood[] DEFAULT '{}',
  preferred_languages TEXT[] DEFAULT '{"hindi"}',
  
  -- AI Learning
  morning_time TIME DEFAULT '06:00',
  evening_time TIME DEFAULT '18:00',
  preferred_quality streaming_quality DEFAULT 'auto',
  
  -- Notification Settings
  notify_new_by_favorite_artist BOOLEAN DEFAULT TRUE,
  notify_trending BOOLEAN DEFAULT TRUE,
  notify_festival_specials BOOLEAN DEFAULT TRUE,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  UNIQUE(user_id)
);

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================

-- Bhajans Indexes
CREATE INDEX IF NOT EXISTS idx_bhajans_category ON bhajans(category);
CREATE INDEX IF NOT EXISTS idx_bhajans_mood ON bhajans(mood);
CREATE INDEX IF NOT EXISTS idx_bhajans_deity ON bhajans(deity);
CREATE INDEX IF NOT EXISTS idx_bhajans_language ON bhajans(language);
CREATE INDEX IF NOT EXISTS idx_bhajans_trending ON bhajans(is_trending) WHERE is_trending = TRUE;
CREATE INDEX IF NOT EXISTS idx_bhajans_featured ON bhajans(is_featured) WHERE is_featured = TRUE;
CREATE INDEX IF NOT EXISTS idx_bhajans_approved ON bhajans(approved, status);
CREATE INDEX IF NOT EXISTS idx_bhajans_play_count ON bhajans(play_count DESC);
CREATE INDEX IF NOT EXISTS idx_bhajans_created ON bhajans(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_bhajans_search ON bhajans USING gin(to_tsvector('english', title || ' ' || COALESCE(description, '')));

-- Favorites Indexes
CREATE INDEX IF NOT EXISTS idx_favorites_user ON bhajan_favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_favorites_bhajan ON bhajan_favorites(bhajan_id);
CREATE INDEX IF NOT EXISTS idx_favorites_downloaded ON bhajan_favorites(user_id, is_downloaded) WHERE is_downloaded = TRUE;

-- Playlists Indexes
CREATE INDEX IF NOT EXISTS idx_playlists_creator ON bhajan_playlists(created_by);
CREATE INDEX IF NOT EXISTS idx_playlists_ai ON bhajan_playlists(is_ai_curated, mood, time_of_day);
CREATE INDEX IF NOT EXISTS idx_playlist_bhajans_playlist ON playlist_bhajans(playlist_id);
CREATE INDEX IF NOT EXISTS idx_playlist_bhajans_position ON playlist_bhajans(playlist_id, position);

-- Rooms Indexes
CREATE INDEX IF NOT EXISTS idx_rooms_status ON bhajan_rooms(status);
CREATE INDEX IF NOT EXISTS idx_rooms_public ON bhajan_rooms(is_public, status);
CREATE INDEX IF NOT EXISTS idx_rooms_host ON bhajan_rooms(host_id);
CREATE INDEX IF NOT EXISTS idx_room_participants_room ON room_participants(room_id);
CREATE INDEX IF NOT EXISTS idx_room_messages_room ON room_messages(room_id, created_at DESC);

-- History Indexes
CREATE INDEX IF NOT EXISTS idx_history_user ON bhajan_listening_history(user_id, last_listened_at DESC);
CREATE INDEX IF NOT EXISTS idx_history_bhajan ON bhajan_listening_history(bhajan_id);

-- Comments Indexes
CREATE INDEX IF NOT EXISTS idx_comments_bhajan ON bhajan_comments(bhajan_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_comments_user ON bhajan_comments(user_id);

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

-- Enable RLS
ALTER TABLE bhajans ENABLE ROW LEVEL SECURITY;
ALTER TABLE bhajan_playlists ENABLE ROW LEVEL SECURITY;
ALTER TABLE playlist_bhajans ENABLE ROW LEVEL SECURITY;
ALTER TABLE bhajan_favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE bhajan_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE room_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE room_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE bhajan_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE bhajan_listening_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE bhajan_ratings ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_bhajan_preferences ENABLE ROW LEVEL SECURITY;

-- Bhajans: Public read for approved, owner can manage own
CREATE POLICY "Approved bhajans are viewable by everyone" ON bhajans
  FOR SELECT USING (approved = TRUE AND status = 'published');

CREATE POLICY "Users can view their own pending bhajans" ON bhajans
  FOR SELECT USING (uploaded_by = auth.uid());

CREATE POLICY "Users can insert their own bhajans" ON bhajans
  FOR INSERT WITH CHECK (uploaded_by = auth.uid());

CREATE POLICY "Users can update their own pending bhajans" ON bhajans
  FOR UPDATE USING (uploaded_by = auth.uid() AND approved = FALSE);

-- Favorites: Users manage their own
CREATE POLICY "Users can view their own favorites" ON bhajan_favorites
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can add to favorites" ON bhajan_favorites
  FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can remove from favorites" ON bhajan_favorites
  FOR DELETE USING (user_id = auth.uid());

CREATE POLICY "Users can update their favorites" ON bhajan_favorites
  FOR UPDATE USING (user_id = auth.uid());

-- Playlists: Public read, owner manage
CREATE POLICY "Public playlists are viewable by everyone" ON bhajan_playlists
  FOR SELECT USING (is_public = TRUE);

CREATE POLICY "Users can view their own playlists" ON bhajan_playlists
  FOR SELECT USING (created_by = auth.uid());

CREATE POLICY "Users can create playlists" ON bhajan_playlists
  FOR INSERT WITH CHECK (created_by = auth.uid());

CREATE POLICY "Users can update their own playlists" ON bhajan_playlists
  FOR UPDATE USING (created_by = auth.uid());

CREATE POLICY "Users can delete their own playlists" ON bhajan_playlists
  FOR DELETE USING (created_by = auth.uid());

-- Rooms: Public read for active
CREATE POLICY "Active public rooms are viewable by everyone" ON bhajan_rooms
  FOR SELECT USING (is_public = TRUE AND status = 'active');

CREATE POLICY "Users can create rooms" ON bhajan_rooms
  FOR INSERT WITH CHECK (host_id = auth.uid());

CREATE POLICY "Hosts can update their rooms" ON bhajan_rooms
  FOR UPDATE USING (host_id = auth.uid());

-- Room Participants
CREATE POLICY "Room participants viewable by room members" ON room_participants
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM room_participants rp WHERE rp.room_id = room_participants.room_id AND rp.user_id = auth.uid())
  );

CREATE POLICY "Users can join rooms" ON room_participants
  FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can leave rooms" ON room_participants
  FOR DELETE USING (user_id = auth.uid());

-- Room Messages
CREATE POLICY "Messages viewable by room members" ON room_messages
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM room_participants rp WHERE rp.room_id = room_messages.room_id AND rp.user_id = auth.uid())
  );

CREATE POLICY "Room members can send messages" ON room_messages
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM room_participants rp WHERE rp.room_id = room_messages.room_id AND rp.user_id = auth.uid())
  );

-- Comments: Public read
CREATE POLICY "Comments are viewable by everyone" ON bhajan_comments
  FOR SELECT USING (is_hidden = FALSE);

CREATE POLICY "Users can add comments" ON bhajan_comments
  FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update their own comments" ON bhajan_comments
  FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "Users can delete their own comments" ON bhajan_comments
  FOR DELETE USING (user_id = auth.uid());

-- Listening History: Private
CREATE POLICY "Users can view their own history" ON bhajan_listening_history
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can add to history" ON bhajan_listening_history
  FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update their history" ON bhajan_listening_history
  FOR UPDATE USING (user_id = auth.uid());

-- Ratings
CREATE POLICY "Ratings are viewable by everyone" ON bhajan_ratings
  FOR SELECT USING (TRUE);

CREATE POLICY "Users can add ratings" ON bhajan_ratings
  FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update their own ratings" ON bhajan_ratings
  FOR UPDATE USING (user_id = auth.uid());

-- User Preferences: Private
CREATE POLICY "Users can view their own preferences" ON user_bhajan_preferences
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can create their preferences" ON user_bhajan_preferences
  FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update their own preferences" ON user_bhajan_preferences
  FOR UPDATE USING (user_id = auth.uid());

-- ============================================
-- FUNCTIONS & TRIGGERS
-- ============================================

-- Function to update bhajan stats
CREATE OR REPLACE FUNCTION update_bhajan_stats()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_TABLE_NAME = 'bhajan_favorites' THEN
    IF TG_OP = 'INSERT' THEN
      UPDATE bhajans SET favorite_count = favorite_count + 1 WHERE id = NEW.bhajan_id;
    ELSIF TG_OP = 'DELETE' THEN
      UPDATE bhajans SET favorite_count = favorite_count - 1 WHERE id = OLD.bhajan_id;
    END IF;
  ELSIF TG_TABLE_NAME = 'bhajan_ratings' THEN
    UPDATE bhajans 
    SET 
      avg_rating = (SELECT AVG(rating)::DECIMAL(2,1) FROM bhajan_ratings WHERE bhajan_id = COALESCE(NEW.bhajan_id, OLD.bhajan_id)),
      rating_count = (SELECT COUNT(*) FROM bhajan_ratings WHERE bhajan_id = COALESCE(NEW.bhajan_id, OLD.bhajan_id))
    WHERE id = COALESCE(NEW.bhajan_id, OLD.bhajan_id);
  ELSIF TG_TABLE_NAME = 'bhajan_comments' THEN
    IF TG_OP = 'INSERT' AND NEW.parent_id IS NOT NULL THEN
      UPDATE bhajan_comments SET reply_count = reply_count + 1 WHERE id = NEW.parent_id;
    ELSIF TG_OP = 'DELETE' AND OLD.parent_id IS NOT NULL THEN
      UPDATE bhajan_comments SET reply_count = reply_count - 1 WHERE id = OLD.parent_id;
    END IF;
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Triggers for stats
CREATE TRIGGER trigger_favorite_stats
  AFTER INSERT OR DELETE ON bhajan_favorites
  FOR EACH ROW EXECUTE FUNCTION update_bhajan_stats();

CREATE TRIGGER trigger_rating_stats
  AFTER INSERT OR UPDATE OR DELETE ON bhajan_ratings
  FOR EACH ROW EXECUTE FUNCTION update_bhajan_stats();

CREATE TRIGGER trigger_comment_reply_stats
  AFTER INSERT OR DELETE ON bhajan_comments
  FOR EACH ROW EXECUTE FUNCTION update_bhajan_stats();

-- Function to update room participant count
CREATE OR REPLACE FUNCTION update_room_participant_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE bhajan_rooms 
    SET 
      participant_count = participant_count + 1,
      peak_participants = GREATEST(peak_participants, participant_count + 1)
    WHERE id = NEW.room_id;
  ELSIF TG_OP = 'DELETE' OR (TG_OP = 'UPDATE' AND NEW.left_at IS NOT NULL AND OLD.left_at IS NULL) THEN
    UPDATE bhajan_rooms SET participant_count = participant_count - 1 WHERE id = COALESCE(NEW.room_id, OLD.room_id);
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_room_participant_count
  AFTER INSERT OR UPDATE OR DELETE ON room_participants
  FOR EACH ROW EXECUTE FUNCTION update_room_participant_count();

-- Function to update playlist stats
CREATE OR REPLACE FUNCTION update_playlist_stats()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE bhajan_playlists 
    SET 
      bhajan_count = bhajan_count + 1,
      total_duration_seconds = total_duration_seconds + (SELECT duration_seconds FROM bhajans WHERE id = NEW.bhajan_id)
    WHERE id = NEW.playlist_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE bhajan_playlists 
    SET 
      bhajan_count = bhajan_count - 1,
      total_duration_seconds = total_duration_seconds - COALESCE((SELECT duration_seconds FROM bhajans WHERE id = OLD.bhajan_id), 0)
    WHERE id = OLD.playlist_id;
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_playlist_stats
  AFTER INSERT OR DELETE ON playlist_bhajans
  FOR EACH ROW EXECUTE FUNCTION update_playlist_stats();

-- Updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at triggers
CREATE TRIGGER update_bhajans_updated_at BEFORE UPDATE ON bhajans
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_playlists_updated_at BEFORE UPDATE ON bhajan_playlists
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_rooms_updated_at BEFORE UPDATE ON bhajan_rooms
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_comments_updated_at BEFORE UPDATE ON bhajan_comments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_preferences_updated_at BEFORE UPDATE ON user_bhajan_preferences
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- SEED DATA: AI-CURATED PLAYLISTS
-- ============================================

-- Insert AI-curated playlists
INSERT INTO bhajan_playlists (id, name, description, is_ai_curated, is_official, mood, time_of_day, cover_image_url) VALUES
  (gen_random_uuid(), 'Morning Divine', 'AI-curated peaceful bhajans for your morning rituals', TRUE, TRUE, 'peaceful', 'morning', 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400'),
  (gen_random_uuid(), 'Evening Aarti', 'Soulful evening bhajans to end your day', TRUE, TRUE, 'soulful', 'evening', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400'),
  (gen_random_uuid(), 'Meditation Flow', 'Deep meditative chants for inner peace', TRUE, TRUE, 'meditative', NULL, 'https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?w=400'),
  (gen_random_uuid(), 'Festival Beats', 'Energetic bhajans for celebrations', TRUE, TRUE, 'celebratory', NULL, 'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?w=400'),
  (gen_random_uuid(), 'Krishna Leela', 'Beautiful Krishna bhajans', TRUE, TRUE, 'devotional', NULL, 'https://images.unsplash.com/photo-1545389336-cf090694435e?w=400'),
  (gen_random_uuid(), 'Shiva Tandav', 'Powerful Shiva bhajans and mantras', TRUE, TRUE, 'energetic', NULL, 'https://images.unsplash.com/photo-1548013146-72479768bada?w=400')
ON CONFLICT DO NOTHING;

-- ============================================
-- USEFUL VIEWS
-- ============================================

-- View for trending bhajans
CREATE OR REPLACE VIEW trending_bhajans AS
SELECT 
  b.*,
  (b.play_count * 1.0 + b.favorite_count * 2.0 + b.share_count * 3.0) / 
  (EXTRACT(EPOCH FROM (NOW() - b.published_at)) / 86400 + 1) AS trending_score
FROM bhajans b
WHERE b.approved = TRUE AND b.status = 'published'
ORDER BY trending_score DESC;

-- View for personalized recommendations (requires user context)
CREATE OR REPLACE VIEW active_live_rooms AS
SELECT 
  r.*,
  b.title as current_bhajan_title,
  b.cover_image_url as current_bhajan_cover
FROM bhajan_rooms r
LEFT JOIN bhajans b ON r.current_bhajan_id = b.id
WHERE r.status = 'active' AND r.is_public = TRUE
ORDER BY r.participant_count DESC;
