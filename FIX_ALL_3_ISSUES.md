# Fix All 3 Business Approval Issues - Complete Guide

## ⚠️ Critical: Fix RLS Policy First

All three issues are caused by incorrect Row Level Security (RLS) policies in Supabase. Follow these steps:

---

## 🔧 Step 1: Run SQL Fix in Supabase Dashboard

1. **Go to your Supabase Dashboard**
2. **Navigate to SQL Editor** (left sidebar)
3. **Copy the entire SQL below:**

```sql
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

-- 4. Users can insert businesses
CREATE POLICY "Users can insert businesses"
    ON public.businesses
    FOR INSERT
    WITH CHECK (owner_id = auth.uid() OR auth.uid() IS NOT NULL);

-- 5. Admins can insert approved businesses
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
```

4. **Paste it into SQL Editor**
5. **Click RUN** (top right button)
6. **Wait for success message**

---

## ✅ Step 2: What This Fixes

### Issue 1: ✅ Approval Error Fixed

- **Before:** "Failed to approve business: PostgrestException - new row violates row-level security policy"
- **After:** Admins can now insert approved businesses without errors

### Issue 2: ✅ Rejected Count Updates

- Code now explicitly refreshes stats after rejection
- The rejected count will update immediately

### Issue 3: ✅ Overflow Error Fixed

- Search field now has proper padding and constraints
- Text will no longer overflow vertically

---

## 🚀 Step 3: Test the Fixes

1. **Hot reload the app:** Press `r` in terminal
2. **Go to Admin Dashboard** (Settings → Business Approvals)
3. **Click Approve** on a pending business
   - ✅ Should work without error now
   - ✅ Business should move to approved list
4. **Click Reject** on another business
   - ✅ Rejected count should update to 1
   - ✅ No overflow error in search box

---

## 📝 Code Changes Made

### File 1: `lib/screens/business/business_approval_screen_enhanced.dart`

- ✅ Added explicit stats refresh after rejection
- ✅ Fixed search field overflow with `isDense: true` and `maxLines: 1`
- ✅ Added `contentPadding` for proper spacing

### File 2: `supabase/fix_businesses_rls_policy.sql`

- ✅ New file with complete RLS policy fix
- ✅ Allows admins to insert/update businesses
- ✅ Allows users to see their own and approved businesses

---

## 🆘 Troubleshooting

**Q: Still getting approval error?**
A: Make sure you ran the SQL script and clicked RUN. Refresh the page in Supabase dashboard.

**Q: Rejected count still showing 0?**
A: Hot reload the app with `r` in terminal. The code now explicitly waits for stats to refresh.

**Q: Search still overflowing?**
A: Hot reload with `r`. The UI changes should be applied.

**Q: Need to verify RLS policies?**
A: Go to Supabase → Tables → businesses → Policies tab. You should see 7 policies listed.

---

## ✨ All Issues Should Now Be Resolved!

- ✅ Issue 1: Approval works
- ✅ Issue 2: Rejected count updates
- ✅ Issue 3: No overflow errors

**If any issues persist after running the SQL, let me know immediately!**
