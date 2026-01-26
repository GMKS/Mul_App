-- Complete Database Setup for Business Approval System
-- Run ALL of this in Supabase SQL Editor in order

-- ========================================
-- PART 1: Create user_roles table (if doesn't exist)
-- ========================================

CREATE TABLE IF NOT EXISTS public.user_roles (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    role VARCHAR(50) NOT NULL DEFAULT 'user',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, role)
);

-- Add your admin user
INSERT INTO public.user_roles (user_id, role) 
SELECT id, 'admin' FROM auth.users 
WHERE email = 'seenaigmk@gmail.com'
ON CONFLICT DO NOTHING;

-- ========================================
-- PART 2: Fix user_roles RLS Policy
-- ========================================

ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own roles" ON public.user_roles;
DROP POLICY IF EXISTS "Admins can view all roles" ON public.user_roles;

CREATE POLICY "Authenticated users can view roles"
    ON public.user_roles
    FOR SELECT
    USING (auth.uid() IS NOT NULL);

CREATE POLICY "Users can insert own roles"
    ON public.user_roles
    FOR INSERT
    WITH CHECK (user_id = auth.uid());

-- ========================================
-- PART 3: Fix businesses table RLS Policy
-- ========================================

ALTER TABLE public.businesses ENABLE ROW LEVEL SECURITY;

-- Drop all existing policies
DROP POLICY IF EXISTS "Users can view businesses" ON public.businesses;
DROP POLICY IF EXISTS "Users can insert own businesses" ON public.businesses;
DROP POLICY IF EXISTS "Users can update own businesses" ON public.businesses;
DROP POLICY IF EXISTS "Anyone can view approved businesses" ON public.businesses;
DROP POLICY IF EXISTS "Admins can view all businesses" ON public.businesses;
DROP POLICY IF EXISTS "Admins can insert approved businesses" ON public.businesses;
DROP POLICY IF EXISTS "Admins can update businesses" ON public.businesses;
DROP POLICY IF EXISTS "Users can insert businesses" ON public.businesses;

-- Everyone can view approved businesses
CREATE POLICY "Public can view approved"
    ON public.businesses
    FOR SELECT
    USING (is_approved = true);

-- Authenticated users can view their own businesses
CREATE POLICY "Users view own businesses"
    ON public.businesses
    FOR SELECT
    USING (owner_id = auth.uid());

-- Admins can view ALL businesses
CREATE POLICY "Admins view all"
    ON public.businesses
    FOR SELECT
    USING (
        auth.uid() IN (
            SELECT user_id FROM public.user_roles WHERE role = 'admin'
        )
    );

-- Users can insert businesses
CREATE POLICY "Users insert businesses"
    ON public.businesses
    FOR INSERT
    WITH CHECK (auth.uid() IS NOT NULL);

-- Admins can insert (for approved submissions)
CREATE POLICY "Admins insert businesses"
    ON public.businesses
    FOR INSERT
    WITH CHECK (
        auth.uid() IN (
            SELECT user_id FROM public.user_roles WHERE role = 'admin'
        )
    );

-- Users can update their own
CREATE POLICY "Users update own"
    ON public.businesses
    FOR UPDATE
    USING (owner_id = auth.uid());

-- Admins can update any
CREATE POLICY "Admins update"
    ON public.businesses
    FOR UPDATE
    USING (
        auth.uid() IN (
            SELECT user_id FROM public.user_roles WHERE role = 'admin'
        )
    );

-- ========================================
-- PART 4: Create Trigger Function
-- ========================================

CREATE OR REPLACE FUNCTION public.copy_approved_submission_to_businesses()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'approved' THEN
    -- Insert into businesses table when submission is approved
    -- No ON CONFLICT clause - just insert directly
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

-- Drop existing trigger
DROP TRIGGER IF EXISTS trigger_approved_submission_to_businesses ON public.business_submissions;

-- Create trigger to run AFTER status update
CREATE TRIGGER trigger_approved_submission_to_businesses
AFTER UPDATE OF status ON public.business_submissions
FOR EACH ROW
WHEN (NEW.status = 'approved' AND OLD.status != 'approved')
EXECUTE FUNCTION public.copy_approved_submission_to_businesses();

-- ========================================
-- PART 5: Verify Everything
-- ========================================

-- Check policies
SELECT policyname, cmd FROM pg_policies WHERE tablename = 'user_roles';
SELECT policyname, cmd FROM pg_policies WHERE tablename = 'businesses';

-- Check trigger
SELECT trigger_name FROM information_schema.triggers 
WHERE trigger_name = 'trigger_approved_submission_to_businesses';

-- Check admin user
SELECT email FROM auth.users WHERE email = 'seenaigmk@gmail.com';
SELECT * FROM public.user_roles WHERE role = 'admin';

-- ========================================
-- SUCCESS MESSAGE
-- ========================================
-- If you see all the above queries return results, everything is setup correctly!
-- You can now approve/reject businesses without errors.
