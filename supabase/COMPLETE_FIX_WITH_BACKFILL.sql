-- ========================================
-- COMPLETE BUSINESS FIX + BACKFILL
-- Run this ENTIRE script in Supabase SQL Editor
-- ========================================

-- PART 1: Setup user_roles
CREATE TABLE IF NOT EXISTS public.user_roles (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    role VARCHAR(50) NOT NULL DEFAULT 'user',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, role)
);

INSERT INTO public.user_roles (user_id, role) 
SELECT id, 'admin' FROM auth.users 
WHERE email = 'seenaigmk@gmail.com'
ON CONFLICT DO NOTHING;

ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own roles" ON public.user_roles;
DROP POLICY IF EXISTS "Admins can view all roles" ON public.user_roles;
DROP POLICY IF EXISTS "Authenticated users can view roles" ON public.user_roles;
DROP POLICY IF EXISTS "Users can insert own roles" ON public.user_roles;

CREATE POLICY "Authenticated users can view roles"
    ON public.user_roles FOR SELECT
    USING (auth.uid() IS NOT NULL);

CREATE POLICY "Users can insert own roles"
    ON public.user_roles FOR INSERT
    WITH CHECK (user_id = auth.uid());

-- PART 2: Fix business_submissions RLS
ALTER TABLE public.business_submissions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own submissions" ON public.business_submissions;
DROP POLICY IF EXISTS "Admins can view all submissions" ON public.business_submissions;
DROP POLICY IF EXISTS "Users can insert submissions" ON public.business_submissions;
DROP POLICY IF EXISTS "Admins can update submissions" ON public.business_submissions;
DROP POLICY IF EXISTS "Users can update own submissions" ON public.business_submissions;
DROP POLICY IF EXISTS "Public can view submissions" ON public.business_submissions;

CREATE POLICY "Public can view submissions"
    ON public.business_submissions FOR SELECT
    USING (true);

CREATE POLICY "Users can insert submissions"
    ON public.business_submissions FOR INSERT
    WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Admins can update submissions"
    ON public.business_submissions FOR UPDATE
    USING (
        auth.uid() IN (
            SELECT user_id FROM public.user_roles WHERE role = 'admin'
        )
    );

CREATE POLICY "Users can update own submissions"
    ON public.business_submissions FOR UPDATE
    USING (owner_id = auth.uid());

-- PART 3: Fix businesses table RLS
ALTER TABLE public.businesses ENABLE ROW LEVEL SECURITY;

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
DROP POLICY IF EXISTS "Public view approved" ON public.businesses;
DROP POLICY IF EXISTS "Authenticated view all" ON public.businesses;
DROP POLICY IF EXISTS "Authenticated insert" ON public.businesses;
DROP POLICY IF EXISTS "Authenticated update" ON public.businesses;

CREATE POLICY "Public view approved"
    ON public.businesses FOR SELECT
    USING (is_approved = true);

CREATE POLICY "Authenticated view all"
    ON public.businesses FOR SELECT
    USING (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated insert"
    ON public.businesses FOR INSERT
    WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated update"
    ON public.businesses FOR UPDATE
    USING (auth.uid() IS NOT NULL);

-- PART 4: Create Trigger
DROP TRIGGER IF EXISTS trigger_approved_submission_to_businesses ON public.business_submissions;
DROP FUNCTION IF EXISTS public.copy_approved_submission_to_businesses();

CREATE OR REPLACE FUNCTION public.copy_approved_submission_to_businesses()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'approved' THEN
    INSERT INTO public.businesses (
      name, description, category, phone, address, city, state,
      owner_id, email, whatsapp, website_url, images,
      is_approved, approved_at, approved_by
    ) VALUES (
      NEW.name, NEW.description, NEW.category, NEW.phone_number,
      NEW.address, NEW.city, NEW.state, NEW.owner_id, NEW.email,
      NEW.whatsapp_number, NEW.website_url, NEW.images,
      true, NEW.reviewed_at, NEW.reviewed_by
    );
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trigger_approved_submission_to_businesses
AFTER UPDATE OF status ON public.business_submissions
FOR EACH ROW
WHEN (NEW.status = 'approved' AND OLD.status != 'approved')
EXECUTE FUNCTION public.copy_approved_submission_to_businesses();

-- ========================================
-- PART 5: BACKFILL EXISTING APPROVED BUSINESSES
-- This copies all already-approved submissions into businesses table
-- ========================================

INSERT INTO public.businesses (
  name, description, category, phone, address, city, state,
  owner_id, email, whatsapp, website_url, images,
  is_approved, approved_at, approved_by, created_at, updated_at
)
SELECT
  bs.name,
  bs.description,
  bs.category,
  bs.phone_number,
  bs.address,
  bs.city,
  bs.state,
  bs.owner_id,
  bs.email,
  bs.whatsapp_number,
  bs.website_url,
  bs.images,
  true,
  COALESCE(bs.reviewed_at, bs.created_at),
  bs.reviewed_by,
  bs.created_at,
  bs.updated_at
FROM public.business_submissions bs
WHERE bs.status = 'approved'
AND NOT EXISTS (
  SELECT 1 FROM public.businesses b
  WHERE b.owner_id = bs.owner_id AND b.name = bs.name
);

-- ========================================
-- PART 6: VERIFICATION QUERIES
-- ========================================

-- Check how many approved submissions exist
SELECT 'Approved submissions in business_submissions:' as info, COUNT(*) as count 
FROM public.business_submissions 
WHERE status = 'approved';

-- Check how many businesses are in businesses table
SELECT 'Approved businesses in businesses table:' as info, COUNT(*) as count 
FROM public.businesses 
WHERE is_approved = true;

-- Check admin user
SELECT 'Admin user:' as info, email FROM auth.users WHERE email = 'seenaigmk@gmail.com';

-- Check trigger exists
SELECT 'Trigger exists:' as info, trigger_name 
FROM information_schema.triggers 
WHERE trigger_name = 'trigger_approved_submission_to_businesses';

-- Check policies
SELECT 'Submissions policies:' as info, COUNT(*) as count 
FROM pg_policies WHERE tablename = 'business_submissions';

SELECT 'Businesses policies:' as info, COUNT(*) as count 
FROM pg_policies WHERE tablename = 'businesses';

-- List all approved businesses (should show 6)
SELECT 
  'Approved businesses list:' as info,
  id, 
  name, 
  category, 
  city,
  is_approved,
  approved_at
FROM public.businesses 
WHERE is_approved = true
ORDER BY approved_at DESC;

-- ========================================
-- ✅ SUCCESS!
-- If you see 6 approved businesses listed above, it worked!
-- Now hot reload your app (press 'r' in terminal)
-- ========================================

SELECT '✅ SETUP COMPLETE! Your 6 approved businesses should now appear in the app!' as status;
