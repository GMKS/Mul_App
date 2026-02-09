-- =====================================================
-- Supabase Database Setup for Local Deals System
-- Run this in your Supabase SQL Editor
-- =====================================================

-- 1. Create local_deals table
CREATE TABLE IF NOT EXISTS public.local_deals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Basic Deal Information
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    
    -- Business Information
    business_id UUID REFERENCES public.businesses(id) ON DELETE CASCADE,
    business_name VARCHAR(255) NOT NULL,
    business_phone VARCHAR(20),
    business_address TEXT,
    
    -- Deal Details
    category VARCHAR(100) NOT NULL, -- Grocery, Health, Food, Services, Devotional, Electronics, Fashion, etc.
    emoji VARCHAR(10) DEFAULT '🏷️',
    image_url TEXT,
    
    -- Pricing
    original_price DECIMAL(10, 2) NOT NULL,
    discounted_price DECIMAL(10, 2) NOT NULL,
    discount_percent INTEGER NOT NULL,
    
    -- Offer Details
    promo_code VARCHAR(50),
    terms_conditions TEXT,
    affiliate_link TEXT,
    
    -- Location Targeting
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) DEFAULT 'Telangana',
    area VARCHAR(100), -- Specific area within city
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    radius_km INTEGER DEFAULT 10, -- Target radius in kilometers
    
    -- Timing
    starts_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    
    -- Status & Visibility
    is_active BOOLEAN DEFAULT TRUE,
    is_sponsored BOOLEAN DEFAULT FALSE,
    is_featured BOOLEAN DEFAULT FALSE,
    priority_rank INTEGER DEFAULT 0, -- Higher = appears first
    
    -- Tracking
    views_count INTEGER DEFAULT 0,
    claims_count INTEGER DEFAULT 0,
    max_claims INTEGER, -- NULL = unlimited
    
    -- Metadata
    created_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Create deal_claims table (tracks who claimed which deal)
CREATE TABLE IF NOT EXISTS public.deal_claims (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    deal_id UUID NOT NULL REFERENCES public.local_deals(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    claimed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    redeemed_at TIMESTAMP WITH TIME ZONE,
    is_redeemed BOOLEAN DEFAULT FALSE,
    UNIQUE(deal_id, user_id) -- Each user can claim a deal only once
);

-- 3. Create deal_categories table for managing categories
CREATE TABLE IF NOT EXISTS public.deal_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL UNIQUE,
    emoji VARCHAR(10) NOT NULL,
    color VARCHAR(7) NOT NULL, -- Hex color code
    icon_name VARCHAR(50),
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Insert default categories
INSERT INTO public.deal_categories (name, emoji, color, icon_name, display_order) VALUES
    ('Grocery', '🥬', '#4CAF50', 'shopping_basket', 1),
    ('Food', '🍕', '#FF9800', 'restaurant', 2),
    ('Health', '🏥', '#E91E63', 'local_hospital', 3),
    ('Services', '🔧', '#2196F3', 'build', 4),
    ('Electronics', '📱', '#00BCD4', 'devices', 6),
    ('Fashion', '👗', '#FF5722', 'checkroom', 7),
    ('Beauty', '💄', '#F06292', 'face', 8),
    ('Education', '📚', '#795548', 'school', 9),
    ('Travel', '✈️', '#3F51B5', 'flight', 10),
    ('Entertainment', '🎬', '#9E9E9E', 'movie', 11)
ON CONFLICT (name) DO NOTHING;

-- 5. Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_local_deals_city ON public.local_deals(city);
CREATE INDEX IF NOT EXISTS idx_local_deals_category ON public.local_deals(category);
CREATE INDEX IF NOT EXISTS idx_local_deals_active ON public.local_deals(is_active);
CREATE INDEX IF NOT EXISTS idx_local_deals_expires ON public.local_deals(expires_at);
CREATE INDEX IF NOT EXISTS idx_local_deals_sponsored ON public.local_deals(is_sponsored);
CREATE INDEX IF NOT EXISTS idx_local_deals_featured ON public.local_deals(is_featured);
CREATE INDEX IF NOT EXISTS idx_local_deals_priority ON public.local_deals(priority_rank DESC);
CREATE INDEX IF NOT EXISTS idx_deal_claims_user ON public.deal_claims(user_id);
CREATE INDEX IF NOT EXISTS idx_deal_claims_deal ON public.deal_claims(deal_id);

-- 6. Create updated_at trigger
CREATE OR REPLACE FUNCTION update_local_deals_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_local_deals_updated_at ON public.local_deals;
CREATE TRIGGER update_local_deals_updated_at
    BEFORE UPDATE ON public.local_deals
    FOR EACH ROW
    EXECUTE FUNCTION update_local_deals_updated_at();

-- 7. Enable Row Level Security (RLS)
ALTER TABLE public.local_deals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.deal_claims ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.deal_categories ENABLE ROW LEVEL SECURITY;

-- 8. RLS Policies for local_deals

-- Everyone can view active deals
CREATE POLICY "Anyone can view active deals"
    ON public.local_deals
    FOR SELECT
    USING (is_active = TRUE AND expires_at > NOW());

-- Business owners can manage their own deals
CREATE POLICY "Business owners can insert deals"
    ON public.local_deals
    FOR INSERT
    WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Business owners can update own deals"
    ON public.local_deals
    FOR UPDATE
    USING (auth.uid() = created_by);

CREATE POLICY "Business owners can delete own deals"
    ON public.local_deals
    FOR DELETE
    USING (auth.uid() = created_by);

-- Admins can manage all deals
CREATE POLICY "Admins can manage all deals"
    ON public.local_deals
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.user_roles
            WHERE user_id = auth.uid() AND role = 'admin'
        )
    );

-- 9. RLS Policies for deal_claims

-- Users can view their own claims
CREATE POLICY "Users can view own claims"
    ON public.deal_claims
    FOR SELECT
    USING (auth.uid() = user_id);

-- Users can claim deals
CREATE POLICY "Users can claim deals"
    ON public.deal_claims
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Users can update their own claims (mark as redeemed)
CREATE POLICY "Users can update own claims"
    ON public.deal_claims
    FOR UPDATE
    USING (auth.uid() = user_id);

-- 10. RLS Policies for deal_categories

-- Everyone can view categories
CREATE POLICY "Anyone can view categories"
    ON public.deal_categories
    FOR SELECT
    USING (is_active = TRUE);

-- Only admins can manage categories
CREATE POLICY "Admins can manage categories"
    ON public.deal_categories
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.user_roles
            WHERE user_id = auth.uid() AND role = 'admin'
        )
    );

-- 11. Function to increment deal views
CREATE OR REPLACE FUNCTION increment_deal_views(deal_id UUID)
RETURNS void AS $$
BEGIN
    UPDATE public.local_deals
    SET views_count = views_count + 1
    WHERE id = deal_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 12. Function to claim a deal
CREATE OR REPLACE FUNCTION claim_deal(p_deal_id UUID, p_user_id UUID)
RETURNS JSON AS $$
DECLARE
    v_deal RECORD;
    v_result JSON;
BEGIN
    -- Get deal info
    SELECT * INTO v_deal FROM public.local_deals WHERE id = p_deal_id;
    
    -- Check if deal exists and is active
    IF v_deal IS NULL THEN
        RETURN json_build_object('success', false, 'message', 'Deal not found');
    END IF;
    
    IF NOT v_deal.is_active THEN
        RETURN json_build_object('success', false, 'message', 'Deal is no longer active');
    END IF;
    
    IF v_deal.expires_at < NOW() THEN
        RETURN json_build_object('success', false, 'message', 'Deal has expired');
    END IF;
    
    -- Check max claims
    IF v_deal.max_claims IS NOT NULL AND v_deal.claims_count >= v_deal.max_claims THEN
        RETURN json_build_object('success', false, 'message', 'Deal has reached maximum claims');
    END IF;
    
    -- Check if already claimed
    IF EXISTS (SELECT 1 FROM public.deal_claims WHERE deal_id = p_deal_id AND user_id = p_user_id) THEN
        RETURN json_build_object('success', false, 'message', 'You have already claimed this deal');
    END IF;
    
    -- Insert claim
    INSERT INTO public.deal_claims (deal_id, user_id) VALUES (p_deal_id, p_user_id);
    
    -- Increment claims count
    UPDATE public.local_deals SET claims_count = claims_count + 1 WHERE id = p_deal_id;
    
    RETURN json_build_object('success', true, 'message', 'Deal claimed successfully!', 'promo_code', v_deal.promo_code);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 13. Insert sample deals for testing (using Hyderabad)
INSERT INTO public.local_deals (
    title, description, business_name, category, emoji,
    original_price, discounted_price, discount_percent,
    city, state, area, expires_at, is_sponsored, is_featured, priority_rank
) VALUES
    ('50% Off Fresh Vegetables', 'Get fresh organic vegetables delivered to your doorstep', 'Raitu Bazaar', 'Grocery', '🥬', 500.00, 250.00, 50, 'Hyderabad', 'Telangana', 'Kompally', NOW() + INTERVAL '7 days', true, true, 100),
    ('Free Health Checkup', 'Complete body checkup worth ₹999 absolutely free', 'Apollo Clinic', 'Health', '🏥', 999.00, 0.00, 100, 'Hyderabad', 'Telangana', 'Kukatpally', NOW() + INTERVAL '15 days', false, true, 90),
    ('30% Off Pooja Items', 'All pooja essentials, flowers & prasad items', 'Sri Lakshmi Pooja Store', 'Devotional', '🪷', 300.00, 210.00, 30, 'Hyderabad', 'Telangana', 'Secunderabad', NOW() + INTERVAL '10 days', false, false, 50),
    ('AC Service at ₹299', 'Complete AC cleaning, gas refill & maintenance', 'Quick Home Services', 'Services', '❄️', 799.00, 299.00, 63, 'Hyderabad', 'Telangana', 'Gachibowli', NOW() + INTERVAL '5 days', true, false, 80),
    ('Buy 1 Get 1 Free Biryani', 'Authentic Hyderabadi Dum Biryani - Chicken/Mutton', 'Paradise Biryani', 'Food', '🍗', 400.00, 200.00, 50, 'Hyderabad', 'Telangana', 'Himayatnagar', NOW() + INTERVAL '3 days', true, true, 95),
    ('₹500 Off on Electronics', 'Smartphones, Laptops & Accessories', 'Bajaj Electronics', 'Electronics', '📱', 5000.00, 4500.00, 10, 'Hyderabad', 'Telangana', 'Ameerpet', NOW() + INTERVAL '20 days', false, false, 40),
    ('Flat 40% on Ethnic Wear', 'Sarees, Lehengas & Kurtis for all occasions', 'Kalanjali', 'Fashion', '👗', 2000.00, 1200.00, 40, 'Hyderabad', 'Telangana', 'Jubilee Hills', NOW() + INTERVAL '12 days', false, true, 70),
    ('Free Mehendi Design', 'Bridal & Party mehendi designs', 'Mehendi by Priya', 'Beauty', '💄', 500.00, 0.00, 100, 'Hyderabad', 'Telangana', 'Banjara Hills', NOW() + INTERVAL '8 days', false, false, 30)
ON CONFLICT DO NOTHING;

-- 14. Create view for active deals with business info
CREATE OR REPLACE VIEW public.active_deals_view AS
SELECT 
    d.*,
    c.color as category_color,
    c.icon_name as category_icon,
    CASE 
        WHEN d.expires_at < NOW() + INTERVAL '1 day' THEN 'expiring_soon'
        WHEN d.expires_at < NOW() + INTERVAL '3 days' THEN 'limited_time'
        ELSE 'active'
    END as urgency_status,
    EXTRACT(EPOCH FROM (d.expires_at - NOW())) / 3600 as hours_remaining
FROM public.local_deals d
LEFT JOIN public.deal_categories c ON d.category = c.name
WHERE d.is_active = TRUE AND d.expires_at > NOW()
ORDER BY d.is_featured DESC, d.is_sponsored DESC, d.priority_rank DESC, d.expires_at ASC;

-- 15. Grant permissions
GRANT SELECT ON public.active_deals_view TO authenticated;
GRANT SELECT ON public.active_deals_view TO anon;

-- =====================================================
-- REALTIME SUBSCRIPTION SETUP
-- This enables real-time updates for all users
-- =====================================================

-- Enable realtime for local_deals table
ALTER PUBLICATION supabase_realtime ADD TABLE public.local_deals;

-- Note: After running this SQL, enable Realtime in Supabase Dashboard:
-- 1. Go to Database → Replication
-- 2. Enable "local_deals" table for realtime
-- 3. Users will automatically receive deal updates!

COMMENT ON TABLE public.local_deals IS 'Local deals and offers with real-time updates for all users';
COMMENT ON TABLE public.deal_claims IS 'Tracks which users claimed which deals';
COMMENT ON TABLE public.deal_categories IS 'Deal categories with colors and icons';
