# Fix Business Submission Error - Quick Guide

## Problem

Getting error: "PostgrestException: infinite recursion detected in policy for relation 'user_roles'"

## Root Cause

The RLS policy on `user_roles` table has circular dependency - it queries itself to check admin status.

## Solution Steps

### Step 1: Run SQL Fix in Supabase

1. Go to your Supabase Dashboard
2. Navigate to **SQL Editor**
3. Copy and paste the contents of `supabase/fix_user_roles_policy.sql`
4. Click **Run** to execute

### What the Fix Does

- **Removes** the problematic policies that cause infinite recursion:
  - "Users can view own roles"
  - "Admins can view all roles"
- **Adds** a simpler policy that allows all authenticated users to view roles:
  - "Authenticated users can view roles"

### Step 2: Verify the Fix

After running the SQL, you can verify by running:

```sql
SELECT * FROM pg_policies WHERE tablename = 'user_roles';
```

You should see only one SELECT policy named "Authenticated users can view roles".

### Step 3: Test Business Submission

1. Hot reload your app: `r` in the terminal
2. Navigate to "Add Your Business"
3. Fill in the form (notice +91 is now pre-filled!)
4. Submit your business

The submission should now work without the recursion error!

## What Was Fixed in Code

### 1. Phone Number Default Prefix (+91)

- Phone number field now starts with "+91 "
- WhatsApp number field now starts with "+91 "
- Users can continue typing after the prefix

### 2. Database Policy Fixed

- Removed recursive admin check in user_roles
- Now uses simple authenticated check
- Prevents infinite recursion error

## Files Modified

- ✅ `lib/screens/business/submit_business_screen_enhanced.dart` - Added +91 prefix
- ✅ `supabase/business_approval_setup.sql` - Fixed policy definition
- ✅ `supabase/fix_user_roles_policy.sql` - Migration script to apply fix

## Testing Checklist

- [ ] Run the SQL fix in Supabase Dashboard
- [ ] Hot reload the app
- [ ] Check that phone fields show "+91 " by default
- [ ] Submit a business and verify it succeeds
- [ ] Check that business appears in admin dashboard
