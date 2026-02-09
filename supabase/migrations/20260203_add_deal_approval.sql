-- =====================================================
-- Add Admin Approval System for Local Deals
-- Run this in your Supabase SQL Editor
-- =====================================================

-- 1. Add approval_status column to local_deals table
ALTER TABLE public.local_deals 
ADD COLUMN IF NOT EXISTS approval_status VARCHAR(20) DEFAULT 'pending' CHECK (approval_status IN ('pending', 'approved', 'rejected'));

-- 2. Add columns for approval tracking
ALTER TABLE public.local_deals 
ADD COLUMN IF NOT EXISTS approved_by UUID REFERENCES auth.users(id),
ADD COLUMN IF NOT EXISTS approved_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS rejection_reason TEXT;

-- 3. Update existing records to be approved (for backward compatibility)
UPDATE public.local_deals 
SET approval_status = 'approved' 
WHERE approval_status IS NULL OR approval_status = 'pending';

-- 4. Create index for faster queries on approval status
CREATE INDEX IF NOT EXISTS idx_local_deals_approval_status 
ON public.local_deals(approval_status);

-- 5. Create index for pending approvals (admin dashboard)
CREATE INDEX IF NOT EXISTS idx_local_deals_pending 
ON public.local_deals(approval_status, created_at DESC) 
WHERE approval_status = 'pending';

-- 6. Create function to auto-set approval timestamp
CREATE OR REPLACE FUNCTION set_deal_approval_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.approval_status = 'approved' AND OLD.approval_status != 'approved' THEN
        NEW.approved_at = NOW();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 7. Create trigger for approval timestamp
DROP TRIGGER IF EXISTS trigger_set_deal_approval_timestamp ON public.local_deals;
CREATE TRIGGER trigger_set_deal_approval_timestamp
    BEFORE UPDATE ON public.local_deals
    FOR EACH ROW
    EXECUTE FUNCTION set_deal_approval_timestamp();

-- 8. Update RLS policies to only show approved deals to regular users
-- Drop existing policy if it exists
DROP POLICY IF EXISTS "Users can view approved deals" ON public.local_deals;

-- Create new policy for viewing approved deals only
CREATE POLICY "Users can view approved deals" 
ON public.local_deals FOR SELECT 
TO authenticated
USING (approval_status = 'approved' AND is_active = true);

-- 9. Allow admins to view all deals (pending, approved, rejected)
DROP POLICY IF EXISTS "Admins can view all deals" ON public.local_deals;

CREATE POLICY "Admins can view all deals" 
ON public.local_deals FOR SELECT 
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM auth.users 
        WHERE auth.users.id = auth.uid() 
        AND auth.users.raw_user_meta_data->>'role' = 'admin'
    )
);

-- 10. Allow users to insert deals (will be pending by default)
DROP POLICY IF EXISTS "Users can create deals" ON public.local_deals;

CREATE POLICY "Users can create deals" 
ON public.local_deals FOR INSERT 
TO authenticated
WITH CHECK (created_by = auth.uid());

-- 11. Allow admins to update deal approval status
DROP POLICY IF EXISTS "Admins can approve or reject deals" ON public.local_deals;

CREATE POLICY "Admins can approve or reject deals" 
ON public.local_deals FOR UPDATE 
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM auth.users 
        WHERE auth.users.id = auth.uid() 
        AND auth.users.raw_user_meta_data->>'role' = 'admin'
    )
);

-- 12. Create view for pending deals (admin dashboard)
CREATE OR REPLACE VIEW pending_deals_view AS
SELECT 
    ld.*,
    u.email as creator_email,
    u.raw_user_meta_data->>'full_name' as creator_name
FROM public.local_deals ld
LEFT JOIN auth.users u ON ld.created_by = u.id
WHERE ld.approval_status = 'pending'
ORDER BY ld.created_at DESC;

-- Success message
DO $$
BEGIN
    RAISE NOTICE 'Admin approval system added successfully!';
    RAISE NOTICE 'New deals will be pending by default and require admin approval.';
END $$;
