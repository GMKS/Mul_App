-- SIMPLIFIED DATABASE SETUP - NO ON CONFLICT ERRORS
-- Run ALL of this in Supabase SQL Editor

-- ========================================
-- PART 1: Create user_roles table
-- ========================================

CREATE TABLE IF NOT EXISTS public.user_roles (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    role VARCHAR(50) NOT NULL DEFAULT 'user',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, role)
);

-- Add admin user (seenaigmk@gmail.com)
INSERT INTO public.user_roles (user_id, role) 
SELECT id, 'admin' FROM auth.users 
WHERE email = 'seenaigmk@gmail.com'
ON CONFLICT DO NOTHING;

-- ========================================
-- PART 2: Fix user_roles RLS
-- ========================================

ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own roles" ON public.user_roles;
DROP POLICY IF EXISTS "Admins can view all roles" ON public.user_roles;
DROP POLICY IF EXISTS "Authenticated users can view roles" ON public.user_roles;
DROP POLICY IF EXISTS "Users can insert own roles" ON public.user_roles;

CREATE POLICY "Authenticated users can view roles"
    ON public.user_roles
    FOR SELECT
    USING (auth.uid() IS NOT NULL);

CREATE POLICY "Users can insert own roles"
    ON public.user_roles
    FOR INSERT
    WITH CHECK (user_id = auth.uid());

-- ========================================
-- PART 3: Fix business_submissions RLS
-- ========================================

ALTER TABLE public.business_submissions ENABLE ROW LEVEL SECURITY;

-- Drop existing policies
DROP POLICY IF EXISTS "Users can view own submissions" ON public.business_submissions;
DROP POLICY IF EXISTS "Admins can view all submissions" ON public.business_submissions;
DROP POLICY IF EXISTS "Users can insert submissions" ON public.business_submissions;
DROP POLICY IF EXISTS "Admins can update submissions" ON public.business_submissions;
DROP POLICY IF EXISTS "Users can update own submissions" ON public.business_submissions;

-- Anyone can view submissions (for now)
CREATE POLICY "Public can view submissions"
    ON public.business_submissions
    FOR SELECT
    USING (true);

-- Users can insert
CREATE POLICY "Users can insert submissions"
    ON public.business_submissions
    FOR INSERT
    WITH CHECK (auth.uid() IS NOT NULL);

-- Admins can update ANY submission
CREATE POLICY "Admins can update submissions"
    ON public.business_submissions
    FOR UPDATE
    USING (
        auth.uid() IN (
            SELECT user_id FROM public.user_roles WHERE role = 'admin'
        )
    );

-- Users can update their own
CREATE POLICY "Users can update own submissions"
    ON public.business_submissions
    FOR UPDATE
    USING (owner_id = auth.uid());

-- ========================================
-- PART 4: Fix businesses table RLS
-- ========================================

ALTER TABLE public.businesses ENABLE ROW LEVEL SECURITY;

-- Drop ALL existing policies
DROP POLICY IF EXISTS "Users can view businesses" ON public.businesses;
DROP POLICY IF EXISTS "Users can insert own businesses" ON public.businesses;
DROP POLICY IF EXISTS "Users can update own businesses" ON public.businesses;
DROP POLICY IF EXISTS "Anyone can view approved businesses" ON public.businesses;
DROP POLICY IF EXISTS "Admins can view all businesses" ON public.businesses;
DROP POLICY IF EXISTS "Admins can insert approved businesses" ON public.businesses;
DROP POLICY IF EXISTS "Admins can update businesses" ON public.businesses;
DROP POLICY IF EXISTS "Users can insert businesses" ON public.businesses;
DROP POLICY IF EXISTS "Public can view approved" ON public.businesses;
DROP POLICY IF EXISTS "Users view own businesses" ON public.businesses;
DROP POLICY IF EXISTS "Admins view all" ON public.businesses;
DROP POLICY IF EXISTS "Users insert businesses" ON public.businesses;
DROP POLICY IF EXISTS "Admins insert businesses" ON public.businesses;
DROP POLICY IF EXISTS "Users update own" ON public.businesses;
DROP POLICY IF EXISTS "Admins update" ON public.businesses;

-- Create simple policies
CREATE POLICY "Public view approved"
    ON public.businesses
    FOR SELECT
    USING (is_approved = true);

CREATE POLICY "Authenticated view all"
    ON public.businesses
    FOR SELECT
    USING (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated insert"
    ON public.businesses
    FOR INSERT
    WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated update"
    ON public.businesses
    FOR UPDATE
    USING (auth.uid() IS NOT NULL);

-- ========================================
-- PART 5: Create Trigger (SIMPLIFIED)
-- ========================================

-- Drop existing function and trigger
DROP TRIGGER IF EXISTS trigger_approved_submission_to_businesses ON public.business_submissions;
DROP FUNCTION IF EXISTS public.copy_approved_submission_to_businesses();

-- Create simplified function - just insert, no conflict handling
CREATE OR REPLACE FUNCTION public.copy_approved_submission_to_businesses()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'approved' THEN
    -- Simply insert into businesses table
    INSERT INTO public.businesses (
      name, 
      description, 
      category, 
      phone, 
      address, 
      city, 
      state, 
      owner_id, 
      email, 
      whatsapp,
      website_url,
      images,
      is_approved,
      approved_at,
      approved_by
    ) VALUES (
      NEW.name,
      NEW.description,
      NEW.category,
      NEW.phone_number,
      NEW.address,
      NEW.city,
      NEW.state,
      NEW.owner_id,
      NEW.email,
      NEW.whatsapp_number,
      NEW.website_url,
      NEW.images,
      true,
      NEW.reviewed_at,
      NEW.reviewed_by
    );
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger
CREATE TRIGGER trigger_approved_submission_to_businesses
AFTER UPDATE OF status ON public.business_submissions
FOR EACH ROW
WHEN (NEW.status = 'approved' AND OLD.status != 'approved')
EXECUTE FUNCTION public.copy_approved_submission_to_businesses();

-- ========================================
-- PART 6: Verification
-- ========================================

-- Check admin user exists
SELECT 'Admin user:' as info, email FROM auth.users WHERE email = 'seenaigmk@gmail.com';
SELECT 'Admin role:' as info, * FROM public.user_roles WHERE role = 'admin';

-- Check trigger exists
SELECT 'Trigger:' as info, trigger_name FROM information_schema.triggers 
WHERE trigger_name = 'trigger_approved_submission_to_businesses';

-- Check policies
SELECT 'Submissions policies:' as info, policyname FROM pg_policies WHERE tablename = 'business_submissions';
SELECT 'Businesses policies:' as info, policyname FROM pg_policies WHERE tablename = 'businesses';

-- SUCCESS!
SELECT '✅ SETUP COMPLETE!' as status;
