-- Fix RLS policy for businesses table to allow admin approvals
-- Run this in Supabase SQL Editor

-- Disable RLS temporarily to recreate policies
ALTER TABLE public.businesses DISABLE ROW LEVEL SECURITY;

-- Enable RLS back
ALTER TABLE public.businesses ENABLE ROW LEVEL SECURITY;

-- Drop existing policies
DROP POLICY IF EXISTS "Users can view businesses" ON public.businesses;
DROP POLICY IF EXISTS "Users can insert own businesses" ON public.businesses;
DROP POLICY IF EXISTS "Users can update own businesses" ON public.businesses;
DROP POLICY IF EXISTS "Anyone can view approved businesses" ON public.businesses;

-- Create new policies that allow admin operations

-- 1. Everyone can view approved businesses
CREATE POLICY "Anyone can view approved businesses"
    ON public.businesses
    FOR SELECT
    USING (is_approved = true);

-- 2. Authenticated users can view their own businesses (approved or not)
CREATE POLICY "Users can view own businesses"
    ON public.businesses
    FOR SELECT
    USING (owner_id = auth.uid());

-- 3. Admins can view all businesses
CREATE POLICY "Admins can view all businesses"
    ON public.businesses
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM user_roles
            WHERE user_roles.user_id = auth.uid()
            AND user_roles.role = 'admin'
        )
    );

-- 4. Users can insert businesses (will be moved to businesses table after approval)
CREATE POLICY "Users can insert businesses"
    ON public.businesses
    FOR INSERT
    WITH CHECK (owner_id = auth.uid() OR auth.uid() IS NOT NULL);

-- 5. Admins can insert approved businesses from submissions
CREATE POLICY "Admins can insert approved businesses"
    ON public.businesses
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM user_roles
            WHERE user_roles.user_id = auth.uid()
            AND user_roles.role = 'admin'
        )
    );

-- 6. Users can update their own businesses
CREATE POLICY "Users can update own businesses"
    ON public.businesses
    FOR UPDATE
    USING (owner_id = auth.uid())
    WITH CHECK (owner_id = auth.uid());

-- 7. Admins can update any business
CREATE POLICY "Admins can update businesses"
    ON public.businesses
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM user_roles
            WHERE user_roles.user_id = auth.uid()
            AND user_roles.role = 'admin'
        )
    );

-- Verify policies
SELECT * FROM pg_policies WHERE tablename = 'businesses' ORDER BY policyname;
