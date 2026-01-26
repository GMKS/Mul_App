-- Fix infinite recursion in user_roles RLS policy
-- Run this script in Supabase SQL Editor

-- Drop existing problematic policies
DROP POLICY IF EXISTS "Users can view own roles" ON public.user_roles;
DROP POLICY IF EXISTS "Admins can view all roles" ON public.user_roles;

-- Create a simpler policy that allows all authenticated users to view roles
-- This prevents infinite recursion
CREATE POLICY "Authenticated users can view roles"
    ON public.user_roles
    FOR SELECT
    USING (auth.uid() IS NOT NULL);

-- Verify the policy
SELECT * FROM pg_policies WHERE tablename = 'user_roles';
