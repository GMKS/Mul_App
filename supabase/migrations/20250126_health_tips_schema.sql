-- Health Tips Feature Database Schema
-- Trusted health guidance with verification, personalization, and alerts
-- Run this migration in Supabase SQL Editor

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE health_tips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(200) NOT NULL,
    short_description TEXT NOT NULL,
    full_content TEXT NOT NULL,
    category VARCHAR(50) NOT NULL,
    content_type VARCHAR(20) DEFAULT 'text',
    image_url TEXT,
    video_url TEXT,
    audio_url TEXT,
    thumbnail_url TEXT,
    infographic_urls TEXT[] DEFAULT '{}',
    verification_source VARCHAR(50) NOT NULL,
    verified_by VARCHAR(200),
    verified_at TIMESTAMPTZ,
    trust_score INTEGER DEFAULT 0,
    city VARCHAR(100),
    cities TEXT[] DEFAULT '{}',
    target_age_group VARCHAR(20),
    target_gender VARCHAR(20),
    tags TEXT[] DEFAULT '{}',
    is_alert BOOLEAN DEFAULT false,
    alert_trigger VARCHAR(30),
    alert_condition TEXT,
    priority VARCHAR(20) DEFAULT 'normal',
    valid_from TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    valid_to TIMESTAMPTZ,
    is_tip_of_the_day BOOLEAN DEFAULT false,
    is_pinned BOOLEAN DEFAULT false,
    view_count INTEGER DEFAULT 0,
    save_count INTEGER DEFAULT 0,
    share_count INTEGER DEFAULT 0,
    helpful_count INTEGER DEFAULT 0,
    not_helpful_count INTEGER DEFAULT 0,
    is_sponsored BOOLEAN DEFAULT false,
    sponsor_name VARCHAR(200),
    sponsor_logo TEXT,
    language VARCHAR(10) DEFAULT 'en',
    translations JSONB DEFAULT '{}',
    status VARCHAR(30) DEFAULT 'draft',
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_tips_category ON health_tips(category);
CREATE INDEX idx_tips_city ON health_tips(city);
CREATE INDEX idx_tips_priority ON health_tips(priority);
CREATE INDEX idx_tips_valid ON health_tips(valid_from, valid_to);
CREATE INDEX idx_tips_tip_of_day ON health_tips(is_tip_of_the_day) WHERE is_tip_of_the_day = true;
CREATE INDEX idx_tips_alerts ON health_tips(is_alert, alert_trigger) WHERE is_alert = true;
CREATE INDEX idx_tips_status ON health_tips(status);
CREATE INDEX idx_tips_created_at ON health_tips(created_at DESC);

CREATE INDEX idx_tips_search ON health_tips USING GIN (
    to_tsvector('english', title || ' ' || short_description || ' ' || full_content)
);

CREATE TABLE health_tip_feedback (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tip_id UUID NOT NULL REFERENCES health_tips(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    is_helpful BOOLEAN NOT NULL,
    comment TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(tip_id, user_id)
);

CREATE INDEX idx_feedback_tip ON health_tip_feedback(tip_id);
CREATE INDEX idx_feedback_user ON health_tip_feedback(user_id);

CREATE TABLE saved_health_tips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tip_id UUID NOT NULL REFERENCES health_tips(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    note TEXT,
    saved_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(tip_id, user_id)
);

CREATE INDEX idx_saved_tip ON saved_health_tips(tip_id);
CREATE INDEX idx_saved_user ON saved_health_tips(user_id);

CREATE TABLE health_alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    trigger VARCHAR(30) NOT NULL,
    priority VARCHAR(20) DEFAULT 'high',
    action_url TEXT,
    tip_id UUID REFERENCES health_tips(id) ON DELETE SET NULL,
    city VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT true
);

CREATE INDEX idx_alerts_city ON health_alerts(city);
CREATE INDEX idx_alerts_active ON health_alerts(is_active, expires_at);
CREATE INDEX idx_alerts_trigger ON health_alerts(trigger);

CREATE TABLE health_alert_reads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    alert_id UUID NOT NULL REFERENCES health_alerts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    read_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(alert_id, user_id)
);

CREATE INDEX idx_alert_reads_user ON health_alert_reads(user_id);

CREATE TABLE health_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    age_group VARCHAR(20),
    gender VARCHAR(20),
    preferred_categories TEXT[] DEFAULT '{}',
    health_conditions TEXT[] DEFAULT '{}',
    daily_reminder BOOLEAN DEFAULT true,
    reminder_time TIME DEFAULT '08:00',
    emergency_alerts BOOLEAN DEFAULT true,
    preferred_language VARCHAR(10) DEFAULT 'en',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_prefs_user ON health_preferences(user_id);

CREATE TABLE health_tip_views (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tip_id UUID NOT NULL REFERENCES health_tips(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    viewed_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_views_tip ON health_tip_views(tip_id);
CREATE INDEX idx_views_user ON health_tip_views(user_id);

ALTER TABLE health_tips ENABLE ROW LEVEL SECURITY;
ALTER TABLE health_tip_feedback ENABLE ROW LEVEL SECURITY;
ALTER TABLE saved_health_tips ENABLE ROW LEVEL SECURITY;
ALTER TABLE health_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE health_alert_reads ENABLE ROW LEVEL SECURITY;
ALTER TABLE health_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE health_tip_views ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public can view published tips"
    ON health_tips FOR SELECT
    USING (status = 'published' AND (valid_to IS NULL OR valid_to > NOW()));

CREATE POLICY "Admins can manage tips"
    ON health_tips FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM auth.users
            WHERE auth.uid() = id AND raw_user_meta_data->>'role' = 'admin'
        )
    );

CREATE POLICY "Users can submit feedback"
    ON health_tip_feedback FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own feedback"
    ON health_tip_feedback FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update own feedback"
    ON health_tip_feedback FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can save tips"
    ON saved_health_tips FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view saved tips"
    ON saved_health_tips FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can unsave tips"
    ON saved_health_tips FOR DELETE
    USING (auth.uid() = user_id);

CREATE POLICY "Public can view active alerts"
    ON health_alerts FOR SELECT
    USING (is_active = true AND (expires_at IS NULL OR expires_at > NOW()));

CREATE POLICY "Users can mark alerts read"
    ON health_alert_reads FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own alert reads"
    ON health_alert_reads FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own preferences"
    ON health_preferences FOR ALL
    USING (auth.uid() = user_id);

CREATE POLICY "Anyone can record views"
    ON health_tip_views FOR INSERT
    WITH CHECK (true);

CREATE OR REPLACE FUNCTION update_health_tips_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_tips_updated_at
    BEFORE UPDATE ON health_tips
    FOR EACH ROW
    EXECUTE FUNCTION update_health_tips_updated_at();

CREATE TRIGGER trigger_prefs_updated_at
    BEFORE UPDATE ON health_preferences
    FOR EACH ROW
    EXECUTE FUNCTION update_health_tips_updated_at();

CREATE OR REPLACE FUNCTION update_tip_feedback_counts()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        IF NEW.is_helpful THEN
            UPDATE health_tips SET helpful_count = helpful_count + 1 WHERE id = NEW.tip_id;
        ELSE
            UPDATE health_tips SET not_helpful_count = not_helpful_count + 1 WHERE id = NEW.tip_id;
        END IF;
    ELSIF TG_OP = 'UPDATE' THEN
        IF OLD.is_helpful AND NOT NEW.is_helpful THEN
            UPDATE health_tips SET helpful_count = GREATEST(helpful_count - 1, 0), not_helpful_count = not_helpful_count + 1 WHERE id = NEW.tip_id;
        ELSIF NOT OLD.is_helpful AND NEW.is_helpful THEN
            UPDATE health_tips SET not_helpful_count = GREATEST(not_helpful_count - 1, 0), helpful_count = helpful_count + 1 WHERE id = NEW.tip_id;
        END IF;
    ELSIF TG_OP = 'DELETE' THEN
        IF OLD.is_helpful THEN
            UPDATE health_tips SET helpful_count = GREATEST(helpful_count - 1, 0) WHERE id = OLD.tip_id;
        ELSE
            UPDATE health_tips SET not_helpful_count = GREATEST(not_helpful_count - 1, 0) WHERE id = OLD.tip_id;
        END IF;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_feedback_counts
    AFTER INSERT OR UPDATE OR DELETE ON health_tip_feedback
    FOR EACH ROW
    EXECUTE FUNCTION update_tip_feedback_counts();

CREATE OR REPLACE FUNCTION update_tip_save_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE health_tips SET save_count = save_count + 1 WHERE id = NEW.tip_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE health_tips SET save_count = GREATEST(save_count - 1, 0) WHERE id = OLD.tip_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_save_count
    AFTER INSERT OR DELETE ON saved_health_tips
    FOR EACH ROW
    EXECUTE FUNCTION update_tip_save_count();

CREATE OR REPLACE FUNCTION update_tip_view_count()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE health_tips SET view_count = view_count + 1 WHERE id = NEW.tip_id;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_view_count
    AFTER INSERT ON health_tip_views
    FOR EACH ROW
    EXECUTE FUNCTION update_tip_view_count();

INSERT INTO health_tips (
    title, short_description, full_content, category, content_type,
    image_url, verification_source, verified_by, trust_score,
    tags, priority, valid_from, is_tip_of_the_day, is_pinned, status
) VALUES
(
    'Stay Hydrated This Summer',
    'Drink at least 8 glasses of water daily to stay healthy during hot weather.',
    'During summer, your body loses more water through sweat. Proper hydration helps regulate body temperature, maintain energy levels, support kidney function, and improve skin health. Tips: Start your day with water, carry a bottle everywhere, eat water-rich fruits.',
    'seasonal',
    'text',
    'https://images.unsplash.com/photo-1523362628745-0c100150b504?w=800',
    'doctorVerified',
    'Dr. Priya Sharma, MBBS',
    95,
    ARRAY['hydration', 'summer', 'water', 'heat'],
    'high',
    NOW() - INTERVAL '30 days',
    true,
    true,
    'published'
),
(
    '5 Minutes of Mindfulness Daily',
    'Simple breathing exercises can reduce stress and improve mental clarity.',
    'Taking just 5 minutes daily for mindfulness can significantly improve your mental health. Practice: Sit comfortably, close eyes, breathe in for 4 counts, hold for 4, exhale for 6. Benefits: Reduces anxiety, improves focus, better sleep.',
    'mentalWellness',
    'text',
    'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=800',
    'doctorVerified',
    'Dr. Ananya Reddy, Psychiatrist',
    92,
    ARRAY['mental-health', 'mindfulness', 'stress', 'meditation'],
    'normal',
    NOW() - INTERVAL '60 days',
    false,
    false,
    'published'
),
(
    'Proper Hand Washing Technique',
    'WHO-recommended 20-second hand washing method to prevent infections.',
    'Proper hand washing can prevent 80% of common infections. Steps: Wet hands, apply soap, rub palms, interlace fingers, clean thumbs, rub fingertips, rinse thoroughly, dry with clean towel. Always wash before eating and after using toilet.',
    'hygiene',
    'text',
    'https://images.unsplash.com/photo-1584515933487-779824d29309?w=800',
    'whoApproved',
    'World Health Organization',
    99,
    ARRAY['hygiene', 'handwashing', 'infection-prevention'],
    'normal',
    NOW() - INTERVAL '180 days',
    false,
    false,
    'published'
);

INSERT INTO health_alerts (
    title, message, trigger, priority, city, expires_at, is_active
) VALUES
(
    '⚠️ High AQI Alert',
    'AQI in Hyderabad has crossed 180. Wear masks outdoors and avoid strenuous activities.',
    'aqi',
    'urgent',
    'Hyderabad',
    NOW() + INTERVAL '12 hours',
    true
),
(
    '🌡️ Heatwave Warning',
    'Temperature expected to reach 44°C. Stay hydrated and avoid outdoor activities between 11 AM - 4 PM.',
    'weather',
    'high',
    'Hyderabad',
    NOW() + INTERVAL '2 days',
    true
);

GRANT ALL ON health_tips TO authenticated;
GRANT ALL ON health_tip_feedback TO authenticated;
GRANT ALL ON saved_health_tips TO authenticated;
GRANT ALL ON health_alerts TO authenticated;
GRANT ALL ON health_alert_reads TO authenticated;
GRANT ALL ON health_preferences TO authenticated;
GRANT ALL ON health_tip_views TO authenticated;
