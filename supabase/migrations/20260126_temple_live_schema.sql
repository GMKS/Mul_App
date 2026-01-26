-- Temple Live Feature - Database Schema
-- Supabase Migration Script

-- =====================================================
-- TEMPLES TABLE
-- Main table for temple/religious place information
-- =====================================================
CREATE TABLE IF NOT EXISTS temples (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100),
    country VARCHAR(100) DEFAULT 'India',
    religion VARCHAR(50), -- hinduism, islam, christianity, sikhism, buddhism, jainism
    deity VARCHAR(255),
    description TEXT,
    address TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    timings VARCHAR(255),
    stream_url TEXT, -- Live stream URL (YouTube, RTMP, etc.)
    thumbnail_url TEXT,
    is_live BOOLEAN DEFAULT FALSE,
    is_verified BOOLEAN DEFAULT FALSE,
    viewer_count INTEGER DEFAULT 0,
    live_started_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for live temples query
CREATE INDEX idx_temples_is_live ON temples(is_live);
CREATE INDEX idx_temples_city ON temples(city);
CREATE INDEX idx_temples_religion ON temples(religion);

-- =====================================================
-- TEMPLE SCHEDULES TABLE
-- Daily schedules and events for temples
-- =====================================================
CREATE TABLE IF NOT EXISTS temple_schedules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    temple_id UUID NOT NULL REFERENCES temples(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    event_type VARCHAR(50) NOT NULL, -- 'pooja', 'aarti', 'darshan', 'festival', 'special'
    scheduled_time TIME NOT NULL, -- Time of day
    day_of_week INTEGER[], -- Array of days (0=Sunday, 6=Saturday), NULL means daily
    is_special BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_temple_schedules_temple_id ON temple_schedules(temple_id);

-- =====================================================
-- TEMPLE EVENTS TABLE
-- Upcoming special events and festivals
-- =====================================================
CREATE TABLE IF NOT EXISTS temple_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    temple_id UUID NOT NULL REFERENCES temples(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    event_type VARCHAR(50) NOT NULL, -- 'pooja', 'festival', 'special', 'darshan'
    event_date TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date TIMESTAMP WITH TIME ZONE,
    is_special BOOLEAN DEFAULT FALSE,
    image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_temple_events_temple_id ON temple_events(temple_id);
CREATE INDEX idx_temple_events_date ON temple_events(event_date);

-- =====================================================
-- TEMPLE SUBSCRIPTIONS TABLE
-- User subscriptions for temple alerts
-- =====================================================
CREATE TABLE IF NOT EXISTS temple_subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    temple_id UUID NOT NULL REFERENCES temples(id) ON DELETE CASCADE,
    user_id UUID NOT NULL, -- References your auth.users table
    notify_live BOOLEAN DEFAULT TRUE,
    notify_pooja BOOLEAN DEFAULT TRUE,
    notify_festivals BOOLEAN DEFAULT TRUE,
    notify_special_events BOOLEAN DEFAULT TRUE,
    subscribed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(temple_id, user_id)
);

CREATE INDEX idx_temple_subscriptions_user_id ON temple_subscriptions(user_id);
CREATE INDEX idx_temple_subscriptions_temple_id ON temple_subscriptions(temple_id);

-- =====================================================
-- TEMPLE IMAGES TABLE
-- Gallery images for temples
-- =====================================================
CREATE TABLE IF NOT EXISTS temple_images (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    temple_id UUID NOT NULL REFERENCES temples(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    caption VARCHAR(255),
    is_primary BOOLEAN DEFAULT FALSE,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_temple_images_temple_id ON temple_images(temple_id);

-- =====================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =====================================================

-- Enable RLS
ALTER TABLE temples ENABLE ROW LEVEL SECURITY;
ALTER TABLE temple_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE temple_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE temple_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE temple_images ENABLE ROW LEVEL SECURITY;

-- Public read access for temples
CREATE POLICY "Public read access for temples" ON temples
    FOR SELECT USING (true);

-- Public read access for schedules
CREATE POLICY "Public read access for temple_schedules" ON temple_schedules
    FOR SELECT USING (true);

-- Public read access for events
CREATE POLICY "Public read access for temple_events" ON temple_events
    FOR SELECT USING (true);

-- Public read access for images
CREATE POLICY "Public read access for temple_images" ON temple_images
    FOR SELECT USING (true);

-- Users can manage their own subscriptions
CREATE POLICY "Users can view their own subscriptions" ON temple_subscriptions
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own subscriptions" ON temple_subscriptions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own subscriptions" ON temple_subscriptions
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own subscriptions" ON temple_subscriptions
    FOR DELETE USING (auth.uid() = user_id);

-- =====================================================
-- SAMPLE DATA
-- Insert some sample temples for testing
-- =====================================================
INSERT INTO temples (name, city, state, religion, deity, description, timings, is_live, thumbnail_url) VALUES
('Tirupati Balaji Temple', 'Tirupati', 'Andhra Pradesh', 'hinduism', 'Lord Venkateswara', 'One of the most visited religious sites in the world', '3:00 AM - 12:00 AM', true, 'https://picsum.photos/400/300?random=201'),
('Golden Temple', 'Amritsar', 'Punjab', 'sikhism', 'Waheguru', 'The holiest Gurdwara and the most important pilgrimage site of Sikhism', 'Open 24 hours', true, 'https://picsum.photos/400/300?random=202'),
('Kashi Vishwanath Temple', 'Varanasi', 'Uttar Pradesh', 'hinduism', 'Lord Shiva', 'One of the twelve Jyotirlingas dedicated to Lord Shiva', '3:00 AM - 11:00 PM', true, 'https://picsum.photos/400/300?random=203'),
('ISKCON Temple', 'Bangalore', 'Karnataka', 'hinduism', 'Lord Krishna', 'International Society for Krishna Consciousness temple', '4:15 AM - 8:30 PM', false, 'https://picsum.photos/400/300?random=204'),
('Siddhivinayak Temple', 'Mumbai', 'Maharashtra', 'hinduism', 'Lord Ganesha', 'One of the richest temples in Mumbai', '5:30 AM - 9:50 PM', false, 'https://picsum.photos/400/300?random=205'),
('Jama Masjid', 'Delhi', 'Delhi', 'islam', NULL, 'One of the largest mosques in India', '7:00 AM - 12:00 PM, 1:30 PM - 6:30 PM', false, 'https://picsum.photos/400/300?random=206'),
('Basilica of Bom Jesus', 'Goa', 'Goa', 'christianity', 'Jesus Christ', 'UNESCO World Heritage Site containing remains of St. Francis Xavier', '9:00 AM - 6:30 PM', false, 'https://picsum.photos/400/300?random=207'),
('Mahabodhi Temple', 'Bodh Gaya', 'Bihar', 'buddhism', 'Buddha', 'UNESCO World Heritage Site - Place of Buddha''s enlightenment', '5:00 AM - 9:00 PM', false, 'https://picsum.photos/400/300?random=208');

-- =====================================================
-- FUNCTIONS FOR REAL-TIME UPDATES
-- =====================================================

-- Function to update viewer count
CREATE OR REPLACE FUNCTION update_viewer_count(p_temple_id UUID, p_increment INTEGER)
RETURNS void AS $$
BEGIN
    UPDATE temples 
    SET viewer_count = GREATEST(0, viewer_count + p_increment),
        updated_at = NOW()
    WHERE id = p_temple_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to set temple live status
CREATE OR REPLACE FUNCTION set_temple_live_status(p_temple_id UUID, p_is_live BOOLEAN, p_stream_url TEXT DEFAULT NULL)
RETURNS void AS $$
BEGIN
    UPDATE temples 
    SET is_live = p_is_live,
        stream_url = COALESCE(p_stream_url, stream_url),
        live_started_at = CASE WHEN p_is_live THEN NOW() ELSE NULL END,
        viewer_count = CASE WHEN p_is_live THEN 0 ELSE viewer_count END,
        updated_at = NOW()
    WHERE id = p_temple_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- REALTIME SUBSCRIPTIONS
-- Enable realtime for live updates
-- =====================================================
ALTER PUBLICATION supabase_realtime ADD TABLE temples;
