-- =====================================================
-- Supabase Database Setup for Business Approval System
-- =====================================================

-- 1. Create business_submissions table (for pending approvals)
CREATE TABLE IF NOT EXISTS public.business_submissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255),
    whatsapp_number VARCHAR(20),
    website_url VARCHAR(500),
    images TEXT[], -- Array of image URLs
    documents TEXT[], -- Array of document URLs
    status VARCHAR(20) DEFAULT 'pending', -- pending, approved, rejected, suspended
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    reviewed_at TIMESTAMP WITH TIME ZONE,
    reviewed_by UUID REFERENCES auth.users(id),
    rejection_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Create businesses table (for approved businesses)
CREATE TABLE IF NOT EXISTS public.businesses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(100) NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(255),
    whatsapp VARCHAR(20),
    website_url VARCHAR(500),
    owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    images TEXT[], -- Array of image URLs
    videos TEXT[], -- Array of video URLs
    is_approved BOOLEAN DEFAULT FALSE,
    is_verified BOOLEAN DEFAULT FALSE,
    is_featured BOOLEAN DEFAULT FALSE,
    featured_rank INTEGER,
    rating DECIMAL(3, 2) DEFAULT 0.0,
    review_count INTEGER DEFAULT 0,
    subscription_plan VARCHAR(50) DEFAULT 'free', -- free, basic, premium, enterprise
    priority_score INTEGER DEFAULT 0,
    engagement_score INTEGER DEFAULT 0,
    approved_at TIMESTAMP WITH TIME ZONE,
    approved_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Create notifications table
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL, -- business_approved, business_rejected, etc.
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Create user_roles table (BEFORE RLS policies that reference it)
CREATE TABLE IF NOT EXISTS public.user_roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    role VARCHAR(50) NOT NULL, -- admin, moderator, user
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, role)
);

-- 5. Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_business_submissions_status ON public.business_submissions(status);
CREATE INDEX IF NOT EXISTS idx_business_submissions_owner ON public.business_submissions(owner_id);
CREATE INDEX IF NOT EXISTS idx_business_submissions_submitted ON public.business_submissions(submitted_at DESC);

CREATE INDEX IF NOT EXISTS idx_businesses_approved ON public.businesses(is_approved);
CREATE INDEX IF NOT EXISTS idx_businesses_featured ON public.businesses(is_featured);
CREATE INDEX IF NOT EXISTS idx_businesses_category ON public.businesses(category);
CREATE INDEX IF NOT EXISTS idx_businesses_owner ON public.businesses(owner_id);
CREATE INDEX IF NOT EXISTS idx_businesses_city ON public.businesses(city);

CREATE INDEX IF NOT EXISTS idx_notifications_user ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON public.notifications(read);

CREATE INDEX IF NOT EXISTS idx_user_roles_user ON public.user_roles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_roles_role ON public.user_roles(role);

-- 6. Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 7. Apply updated_at triggers
DROP TRIGGER IF EXISTS update_business_submissions_updated_at ON public.business_submissions;
CREATE TRIGGER update_business_submissions_updated_at
    BEFORE UPDATE ON public.business_submissions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_businesses_updated_at ON public.businesses;
CREATE TRIGGER update_businesses_updated_at
    BEFORE UPDATE ON public.businesses
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 8. Row Level Security (RLS) Policies

-- Enable RLS
ALTER TABLE public.business_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.businesses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

-- Business Submissions Policies
-- Users can insert their own submissions
CREATE POLICY "Users can insert own submissions"
    ON public.business_submissions
    FOR INSERT
    WITH CHECK (auth.uid() = owner_id);

-- Users can view their own submissions
CREATE POLICY "Users can view own submissions"
    ON public.business_submissions
    FOR SELECT
    USING (auth.uid() = owner_id);

-- Admins can view all submissions
CREATE POLICY "Admins can view all submissions"
    ON public.business_submissions
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.user_roles
            WHERE user_id = auth.uid() AND role = 'admin'
        )
    );

-- Admins can update submissions (approve/reject)
CREATE POLICY "Admins can update submissions"
    ON public.business_submissions
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.user_roles
            WHERE user_id = auth.uid() AND role = 'admin'
        )
    );

-- Businesses Policies
-- Anyone can view approved businesses
CREATE POLICY "Anyone can view approved businesses"
    ON public.businesses
    FOR SELECT
    USING (is_approved = TRUE);

-- Owners can view their own businesses
CREATE POLICY "Owners can view own businesses"
    ON public.businesses
    FOR SELECT
    USING (auth.uid() = owner_id);

-- Admins can view all businesses
CREATE POLICY "Admins can view all businesses"
    ON public.businesses
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.user_roles
            WHERE user_id = auth.uid() AND role = 'admin'
        )
    );

-- Admins can insert businesses
CREATE POLICY "Admins can insert businesses"
    ON public.businesses
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.user_roles
            WHERE user_id = auth.uid() AND role = 'admin'
        )
    );

-- Owners can update their own businesses
CREATE POLICY "Owners can update own businesses"
    ON public.businesses
    FOR UPDATE
    USING (auth.uid() = owner_id);

-- Admins can update any business
CREATE POLICY "Admins can update businesses"
    ON public.businesses
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.user_roles
            WHERE user_id = auth.uid() AND role = 'admin'
        )
    );

-- Notifications Policies
-- Users can view their own notifications
CREATE POLICY "Users can view own notifications"
    ON public.notifications
    FOR SELECT
    USING (auth.uid() = user_id);

-- Users can update their own notifications (mark as read)
CREATE POLICY "Users can update own notifications"
    ON public.notifications
    FOR UPDATE
    USING (auth.uid() = user_id);

-- Admins can insert notifications
CREATE POLICY "Admins can insert notifications"
    ON public.notifications
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.user_roles
            WHERE user_id = auth.uid() AND role = 'admin'
        )
    );

-- User Roles Policies
-- All authenticated users can view all roles (prevents infinite recursion)
CREATE POLICY "Authenticated users can view roles"
    ON public.user_roles
    FOR SELECT
    USING (auth.uid() IS NOT NULL);

-- 9. Create storage bucket for business images
-- Run this in Supabase Dashboard > Storage
-- Bucket name: business-images
-- Public: true
-- File size limit: 5MB
-- Allowed MIME types: image/jpeg, image/png, image/webp

-- 10. Storage policies (Run in Supabase Dashboard > Storage > Policies)

-- Policy 1: Allow authenticated users to upload
-- Click "New policy" next to business-images bucket
-- Policy name: Authenticated users can upload business images
-- Operation: INSERT
-- Target roles: authenticated
-- WITH CHECK expression:
CREATE POLICY "Authenticated users can upload business images"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'business-images');

-- Policy 2: Allow public to read
-- Click "New policy" next to business-images bucket
-- Policy name: Anyone can read business images
-- Operation: SELECT
-- Target roles: public, authenticated, anon
-- USING expression:
CREATE POLICY "Anyone can read business images"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'business-images');

-- Policy 3: Allow users to delete their own images
-- Click "New policy" next to business-images bucket
-- Policy name: Users can delete their own business images
-- Operation: DELETE
-- Target roles: authenticated
-- USING expression:
CREATE POLICY "Users can delete their own business images"
ON storage.objects
FOR DELETE
TO authenticated
USING (
    bucket_id = 'business-images' 
    AND auth.uid()::text = (storage.foldername(name))[1]
);

-- =====================================================
-- Sample Data for Testing
-- =====================================================

-- Create admin user role (replace with your user ID)
-- INSERT INTO public.user_roles (user_id, role)
-- VALUES ('YOUR_USER_ID_HERE', 'admin');

-- Sample business submission
-- INSERT INTO public.business_submissions (
--     name, description, category, phone_number, address, city, state, owner_id
-- ) VALUES (
--     'Test Restaurant',
--     'Best food in town with authentic flavors',
--     'Restaurant',
--     '9876543210',
--     '123 Main Street',
--     'Mumbai',
--     'Maharashtra',
--     'YOUR_USER_ID_HERE'
-- );

-- =====================================================
-- Cleanup (if needed)
-- =====================================================

-- DROP TABLE IF EXISTS public.business_submissions CASCADE;
-- DROP TABLE IF EXISTS public.businesses CASCADE;
-- DROP TABLE IF EXISTS public.notifications CASCADE;
-- DROP TABLE IF EXISTS public.user_roles CASCADE;
