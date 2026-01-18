-- Supabase SQL for Events and Festivals Feature
-- Run these SQL statements in your Supabase SQL Editor

-- =====================================================
-- 1. Create Events Table
-- =====================================================
CREATE TABLE IF NOT EXISTS public.events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    category TEXT NOT NULL DEFAULT 'general',
    start_datetime TIMESTAMP WITH TIME ZONE NOT NULL,
    end_datetime TIMESTAMP WITH TIME ZONE NOT NULL,
    location_name TEXT NOT NULL,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    distance_category TEXT NOT NULL DEFAULT 'nearby',
    organizer_name TEXT NOT NULL,
    contact_info TEXT,
    image_url TEXT,
    ticket_url TEXT,
    ticket_price DECIMAL(10,2),
    is_approved BOOLEAN DEFAULT FALSE,
    is_expired BOOLEAN DEFAULT FALSE,
    is_featured BOOLEAN DEFAULT FALSE,
    religion TEXT,
    tags TEXT[] DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 2. Create Indexes for Better Query Performance
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_events_approved ON public.events(is_approved);
CREATE INDEX IF NOT EXISTS idx_events_expired ON public.events(is_expired);
CREATE INDEX IF NOT EXISTS idx_events_featured ON public.events(is_featured);
CREATE INDEX IF NOT EXISTS idx_events_category ON public.events(category);
CREATE INDEX IF NOT EXISTS idx_events_start_datetime ON public.events(start_datetime);
CREATE INDEX IF NOT EXISTS idx_events_end_datetime ON public.events(end_datetime);
CREATE INDEX IF NOT EXISTS idx_events_distance_category ON public.events(distance_category);
CREATE INDEX IF NOT EXISTS idx_events_religion ON public.events(religion);

-- =====================================================
-- 3. Enable Row Level Security (RLS)
-- =====================================================
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can read approved events
CREATE POLICY "Public can view approved events" ON public.events
    FOR SELECT
    USING (is_approved = true AND is_expired = false);

-- Policy: Authenticated users can create events
CREATE POLICY "Authenticated users can create events" ON public.events
    FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- Policy: Users can update their own events
CREATE POLICY "Users can update own events" ON public.events
    FOR UPDATE
    USING (auth.uid() = created_by);

-- Policy: Admins can do everything (you'll need to create admin role)
CREATE POLICY "Admins full access" ON public.events
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.user_profiles 
            WHERE user_id = auth.uid() AND role = 'admin'
        )
    );

-- =====================================================
-- 4. Auto-update timestamp trigger
-- =====================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_events_updated_at
    BEFORE UPDATE ON public.events
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- 5. Cron Job for Auto-Expiry (requires pg_cron extension)
-- =====================================================
-- Enable pg_cron if not already enabled:
-- CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Direct SQL-based auto-expire (alternative to Edge Function)
-- This runs daily at midnight
SELECT cron.schedule(
    'auto-expire-events',
    '0 0 * * *',
    $$
    UPDATE public.events 
    SET is_expired = true 
    WHERE end_datetime < NOW() 
    AND is_expired = false;
    $$
);

-- =====================================================
-- 6. Insert Sample Events for Testing
-- =====================================================
INSERT INTO public.events (
    title, description, category, start_datetime, end_datetime,
    location_name, latitude, longitude, distance_category,
    organizer_name, contact_info, is_approved, is_featured, religion
) VALUES
-- Today's Event (Live)
(
    'Diwali Mela 2024',
    'Grand celebration of Diwali with fireworks, cultural programs, and food stalls. Join us for an unforgettable evening!',
    'festival',
    NOW() - INTERVAL '1 hour',
    NOW() + INTERVAL '5 hours',
    'City Central Park',
    12.9716,
    77.5946,
    '0-100km',
    'Cultural Committee',
    '+91 9876543210',
    true,
    true,
    'hindu'
),
-- Tomorrow's Event
(
    'Community Sports Meet',
    'Annual sports competition featuring cricket, volleyball, and athletics. Open for all age groups.',
    'sports',
    (CURRENT_DATE + INTERVAL '1 day' + INTERVAL '9 hours'),
    (CURRENT_DATE + INTERVAL '1 day' + INTERVAL '17 hours'),
    'Municipal Stadium',
    12.9352,
    77.6245,
    '0-100km',
    'Sports Association',
    '+91 9876543211',
    true,
    false,
    NULL
),
-- This Week Event
(
    'Art Exhibition: Colors of India',
    'Showcasing traditional and contemporary Indian art by local artists. Free entry for all.',
    'art',
    (CURRENT_DATE + INTERVAL '3 days' + INTERVAL '10 hours'),
    (CURRENT_DATE + INTERVAL '5 days' + INTERVAL '18 hours'),
    'Art Gallery',
    12.9721,
    77.6096,
    '0-100km',
    'Art Foundation',
    '+91 9876543212',
    true,
    true,
    NULL
),
-- Religious Event
(
    'Ganesh Chaturthi Celebration',
    'Traditional Ganesh Chaturthi pooja and visarjan procession.',
    'religious',
    (CURRENT_DATE + INTERVAL '5 days' + INTERVAL '6 hours'),
    (CURRENT_DATE + INTERVAL '5 days' + INTERVAL '22 hours'),
    'Temple Road',
    12.9789,
    77.5914,
    '100-200km',
    'Temple Trust',
    '+91 9876543213',
    true,
    false,
    'hindu'
),
-- Music Festival
(
    'Summer Music Festival',
    'Live performances by top artists. Food, fun, and great music!',
    'music',
    (CURRENT_DATE + INTERVAL '7 days' + INTERVAL '16 hours'),
    (CURRENT_DATE + INTERVAL '7 days' + INTERVAL '23 hours'),
    'Open Air Theater',
    12.9656,
    77.6085,
    '0-100km',
    'Music Academy',
    '+91 9876543214',
    true,
    true,
    NULL
);

-- =====================================================
-- 7. Useful Queries
-- =====================================================

-- Get today's events
-- SELECT * FROM events WHERE DATE(start_datetime) = CURRENT_DATE AND is_approved = true;

-- Get live events (currently happening)
-- SELECT * FROM events WHERE NOW() BETWEEN start_datetime AND end_datetime AND is_approved = true;

-- Get upcoming events this week
-- SELECT * FROM events WHERE start_datetime BETWEEN NOW() AND (NOW() + INTERVAL '7 days') AND is_approved = true ORDER BY start_datetime;

-- Get pending approvals
-- SELECT * FROM events WHERE is_approved = false ORDER BY created_at DESC;

-- Get events by category
-- SELECT * FROM events WHERE category = 'festival' AND is_approved = true AND is_expired = false;
