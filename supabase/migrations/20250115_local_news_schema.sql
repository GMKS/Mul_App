-- Local News Feature Database Schema
-- Hyperlocal news with AI verification, community validation, and social features
-- Run this migration in Supabase SQL Editor

-- ================================
-- 1. LOCAL NEWS TABLE
-- ================================
CREATE TABLE local_news (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    tldr TEXT, -- Short summary
    
    -- Media
    image_urls TEXT[] DEFAULT '{}',
    video_urls TEXT[] DEFAULT '{}',
    audio_url TEXT,
    
    -- Location (Hyperlocal)
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    location_name VARCHAR(200),
    radius_km DECIMAL(6, 2) DEFAULT 5.0, -- Relevant radius
    
    -- Categorization
    category VARCHAR(50) NOT NULL,
    tags TEXT[] DEFAULT '{}',
    priority VARCHAR(20) DEFAULT 'medium', -- low, medium, high, urgent, critical
    
    -- Verification & Trust
    status VARCHAR(30) DEFAULT 'pending', -- pending, ai_review, community_verified, admin_verified, published, rejected
    ai_verified BOOLEAN DEFAULT false,
    community_verified BOOLEAN DEFAULT false,
    admin_verified BOOLEAN DEFAULT false,
    credibility_score INTEGER DEFAULT 0, -- 0-100
    
    -- Reporter
    reporter_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    reporter_name VARCHAR(100) NOT NULL,
    reporter_avatar TEXT,
    is_verified_reporter BOOLEAN DEFAULT false,
    is_anonymous BOOLEAN DEFAULT false,
    
    -- Engagement
    upvotes INTEGER DEFAULT 0,
    downvotes INTEGER DEFAULT 0,
    view_count INTEGER DEFAULT 0,
    shares_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,
    
    -- Social Features
    reactions JSONB DEFAULT '{}', -- {"like": 10, "love": 5, "sad": 2}
    
    -- Flags
    is_breaking BOOLEAN DEFAULT false,
    is_trending BOOLEAN DEFAULT false,
    is_pinned BOOLEAN DEFAULT false,
    is_featured BOOLEAN DEFAULT false,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    published_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    
    -- Moderation
    flag_count INTEGER DEFAULT 0,
    moderator_notes TEXT,
    
    -- Indexing
    CONSTRAINT check_coordinates CHECK (
        latitude BETWEEN -90 AND 90 AND
        longitude BETWEEN -180 AND 180
    )
);

-- Indexes for performance
CREATE INDEX idx_news_location ON local_news USING GIST (
    ll_to_earth(latitude, longitude)
);
CREATE INDEX idx_news_status ON local_news(status);
CREATE INDEX idx_news_category ON local_news(category);
CREATE INDEX idx_news_created_at ON local_news(created_at DESC);
CREATE INDEX idx_news_trending ON local_news(is_trending, created_at DESC) WHERE is_trending = true;
CREATE INDEX idx_news_breaking ON local_news(is_breaking, created_at DESC) WHERE is_breaking = true;
CREATE INDEX idx_news_reporter ON local_news(reporter_id);

-- Full-text search
CREATE INDEX idx_news_search ON local_news USING GIN (
    to_tsvector('english', title || ' ' || content)
);

-- ================================
-- 2. NEWS COMMENTS TABLE
-- ================================
CREATE TABLE news_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    news_id UUID NOT NULL REFERENCES local_news(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    parent_comment_id UUID REFERENCES news_comments(id) ON DELETE CASCADE,
    
    content TEXT NOT NULL,
    
    -- Media
    image_urls TEXT[] DEFAULT '{}',
    audio_url TEXT, -- Voice comment
    
    -- User Info
    user_name VARCHAR(100) NOT NULL,
    user_avatar TEXT,
    
    -- Engagement
    upvotes INTEGER DEFAULT 0,
    downvotes INTEGER DEFAULT 0,
    
    -- Flags
    is_pinned BOOLEAN DEFAULT false,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Moderation
    flag_count INTEGER DEFAULT 0
);

CREATE INDEX idx_comments_news ON news_comments(news_id, created_at);
CREATE INDEX idx_comments_parent ON news_comments(parent_comment_id);
CREATE INDEX idx_comments_user ON news_comments(user_id);

-- ================================
-- 3. NEWS REACTIONS TABLE
-- ================================
CREATE TABLE news_reactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    news_id UUID NOT NULL REFERENCES local_news(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    reaction_type VARCHAR(20) NOT NULL, -- like, love, sad, angry, wow, support, pray
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(news_id, user_id)
);

CREATE INDEX idx_reactions_news ON news_reactions(news_id);
CREATE INDEX idx_reactions_user ON news_reactions(user_id);

-- ================================
-- 4. NEWS VALIDATIONS TABLE
-- ================================
CREATE TABLE news_validations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    news_id UUID NOT NULL REFERENCES local_news(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    validation_type VARCHAR(20) NOT NULL, -- upvote, downvote, flag
    reason TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(news_id, user_id, validation_type)
);

CREATE INDEX idx_validations_news ON news_validations(news_id);
CREATE INDEX idx_validations_user ON news_validations(user_id);

-- ================================
-- 5. NEWS POLLS TABLE
-- ================================
CREATE TABLE news_polls (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    news_id UUID NOT NULL REFERENCES local_news(id) ON DELETE CASCADE,
    question TEXT NOT NULL,
    options JSONB NOT NULL, -- [{"id": "1", "text": "Yes", "votes": 0}, ...]
    total_votes INTEGER DEFAULT 0,
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_polls_news ON news_polls(news_id);

-- ================================
-- 6. REPORTER PROFILES TABLE
-- ================================
CREATE TABLE reporter_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Profile
    name VARCHAR(100) NOT NULL,
    avatar TEXT,
    bio TEXT,
    location VARCHAR(200),
    
    -- Stats
    reports_count INTEGER DEFAULT 0,
    verified_reports INTEGER DEFAULT 0,
    rejected_reports INTEGER DEFAULT 0,
    total_upvotes INTEGER DEFAULT 0,
    total_views INTEGER DEFAULT 0,
    
    -- Trust Score
    trust_score INTEGER DEFAULT 0, -- 0-100
    credibility_rating DECIMAL(3, 2) DEFAULT 0.0, -- 0.00-5.00
    
    -- Verification
    is_verified BOOLEAN DEFAULT false,
    verification_date TIMESTAMPTZ,
    
    -- Badges & Achievements
    badges JSONB DEFAULT '[]', -- ["Breaking News Expert", "Top Contributor"]
    level INTEGER DEFAULT 1,
    experience_points INTEGER DEFAULT 0,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_reporter_user ON reporter_profiles(user_id);
CREATE INDEX idx_reporter_verified ON reporter_profiles(is_verified);
CREATE INDEX idx_reporter_trust_score ON reporter_profiles(trust_score DESC);

-- ================================
-- 7. NEWS VIEWS TABLE (Analytics)
-- ================================
CREATE TABLE news_views (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    news_id UUID NOT NULL REFERENCES local_news(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    ip_address INET,
    user_agent TEXT,
    duration_seconds INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_views_news ON news_views(news_id);
CREATE INDEX idx_views_user ON news_views(user_id);
CREATE INDEX idx_views_created_at ON news_views(created_at DESC);

-- ================================
-- ROW LEVEL SECURITY (RLS)
-- ================================

-- Enable RLS
ALTER TABLE local_news ENABLE ROW LEVEL SECURITY;
ALTER TABLE news_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE news_reactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE news_validations ENABLE ROW LEVEL SECURITY;
ALTER TABLE news_polls ENABLE ROW LEVEL SECURITY;
ALTER TABLE reporter_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE news_views ENABLE ROW LEVEL SECURITY;

-- RLS Policies: LOCAL NEWS
CREATE POLICY "Public can view published news"
    ON local_news FOR SELECT
    USING (status = 'published' OR status = 'admin_verified');

CREATE POLICY "Users can create news submissions"
    ON local_news FOR INSERT
    WITH CHECK (auth.uid() = reporter_id);

CREATE POLICY "Users can update own submissions"
    ON local_news FOR UPDATE
    USING (auth.uid() = reporter_id AND status = 'pending');

CREATE POLICY "Admins can view all news"
    ON local_news FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM auth.users
            WHERE auth.uid() = id AND raw_user_meta_data->>'role' = 'admin'
        )
    );

CREATE POLICY "Admins can update any news"
    ON local_news FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM auth.users
            WHERE auth.uid() = id AND raw_user_meta_data->>'role' = 'admin'
        )
    );

-- RLS Policies: COMMENTS
CREATE POLICY "Public can view comments on published news"
    ON news_comments FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM local_news
            WHERE id = news_comments.news_id
            AND status IN ('published', 'admin_verified')
        )
    );

CREATE POLICY "Users can create comments"
    ON news_comments FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own comments"
    ON news_comments FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own comments"
    ON news_comments FOR DELETE
    USING (auth.uid() = user_id);

-- RLS Policies: REACTIONS
CREATE POLICY "Public can view reactions"
    ON news_reactions FOR SELECT
    USING (true);

CREATE POLICY "Users can add reactions"
    ON news_reactions FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own reactions"
    ON news_reactions FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own reactions"
    ON news_reactions FOR DELETE
    USING (auth.uid() = user_id);

-- RLS Policies: VALIDATIONS
CREATE POLICY "Public can view validations count"
    ON news_validations FOR SELECT
    USING (true);

CREATE POLICY "Users can add validations"
    ON news_validations FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- RLS Policies: POLLS
CREATE POLICY "Public can view polls"
    ON news_polls FOR SELECT
    USING (true);

-- RLS Policies: REPORTER PROFILES
CREATE POLICY "Public can view reporter profiles"
    ON reporter_profiles FOR SELECT
    USING (true);

CREATE POLICY "Users can create own profile"
    ON reporter_profiles FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own profile"
    ON reporter_profiles FOR UPDATE
    USING (auth.uid() = user_id);

-- RLS Policies: VIEWS
CREATE POLICY "Anyone can record views"
    ON news_views FOR INSERT
    WITH CHECK (true);

-- ================================
-- FUNCTIONS & TRIGGERS
-- ================================

-- Function: Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers
CREATE TRIGGER update_news_updated_at
    BEFORE UPDATE ON local_news
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_comments_updated_at
    BEFORE UPDATE ON news_comments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_reporter_updated_at
    BEFORE UPDATE ON reporter_profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

-- Function: Update comment count
CREATE OR REPLACE FUNCTION update_news_comments_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE local_news
        SET comments_count = comments_count + 1
        WHERE id = NEW.news_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE local_news
        SET comments_count = GREATEST(comments_count - 1, 0)
        WHERE id = OLD.news_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_comments_count
    AFTER INSERT OR DELETE ON news_comments
    FOR EACH ROW
    EXECUTE FUNCTION update_news_comments_count();

-- Function: Update reactions count
CREATE OR REPLACE FUNCTION update_news_reactions()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE local_news
        SET reactions = jsonb_set(
            reactions,
            ARRAY[NEW.reaction_type],
            to_jsonb(COALESCE((reactions->>NEW.reaction_type)::int, 0) + 1)
        )
        WHERE id = NEW.news_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE local_news
        SET reactions = jsonb_set(
            reactions,
            ARRAY[OLD.reaction_type],
            to_jsonb(GREATEST(COALESCE((reactions->>OLD.reaction_type)::int, 0) - 1, 0))
        )
        WHERE id = OLD.news_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_reactions
    AFTER INSERT OR DELETE ON news_reactions
    FOR EACH ROW
    EXECUTE FUNCTION update_news_reactions();

-- ================================
-- SAMPLE DATA (Optional)
-- ================================

-- Insert sample news (for testing)
INSERT INTO local_news (
    title, content, tldr,
    latitude, longitude, location_name,
    category, tags, priority,
    status, ai_verified, credibility_score,
    reporter_name, is_verified_reporter,
    upvotes, view_count, is_breaking
) VALUES
(
    'Traffic Update: Road Closure on Jubilee Hills Road',
    'Due to ongoing metro construction work, Jubilee Hills Road will be closed from 10 AM to 6 PM today. Commuters are advised to take alternative routes via Road No. 36.',
    'Jubilee Hills Road closed 10 AM-6 PM for metro work. Use Road 36 instead.',
    17.4326, 78.4071, 'Jubilee Hills, Hyderabad',
    'traffic', ARRAY['traffic', 'metro', 'construction'],
    'high',
    'published', true, 85,
    'Traffic Reporter', true,
    45, 1200, false
),
(
    'Community Park Opening Tomorrow',
    'A new community park with children''s play area, walking track, and outdoor gym equipment will be inaugurated tomorrow at 9 AM in Banjara Hills.',
    'New park opens tomorrow 9 AM in Banjara Hills.',
    17.4239, 78.4738, 'Banjara Hills, Hyderabad',
    'community', ARRAY['park', 'community', 'opening'],
    'medium',
    'published', true, 90,
    'Community Voice', true,
    78, 2500, false
);

-- Grant permissions
GRANT ALL ON local_news TO authenticated;
GRANT ALL ON news_comments TO authenticated;
GRANT ALL ON news_reactions TO authenticated;
GRANT ALL ON news_validations TO authenticated;
GRANT ALL ON news_polls TO authenticated;
GRANT ALL ON reporter_profiles TO authenticated;
GRANT ALL ON news_views TO authenticated;

-- ================================
-- COMPLETION
-- ================================
-- Local News schema created successfully!
-- Features: Hyperlocal GPS filtering, AI verification, community validation
-- Run: SELECT * FROM local_news WHERE status = 'published' LIMIT 10;
