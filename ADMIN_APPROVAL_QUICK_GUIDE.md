# 🔐 Admin Approval Guide - Local Deals

## ✅ Understanding What Happened

### 1. **The Message You Saw (Expected Behavior)**

The message "No deals available right now" is **correct** because:

- Your submitted deal has `approval_status = 'pending'`
- The app only shows `approved` deals to regular users
- This prevents spam/inappropriate deals from appearing immediately

### 2. **Your Deal is Safe!**

Your submitted deal is stored in the database, waiting for admin approval.

---

## 📍 Where to Find Submitted Deals

### **Option 1: Supabase Dashboard (Recommended)**

#### Step 1: Open Supabase

1. Go to: https://app.supabase.com
2. Select your project
3. Click **"Table Editor"** in the left sidebar

#### Step 2: View Pending Deals

1. Select the **`local_deals`** table
2. Click **"Filter"** button
3. Add filter: `approval_status` equals `pending`
4. You'll see all pending deals

#### Step 3: Approve a Deal

**Method A: Direct Edit**

1. Find your deal in the table
2. Click on the row to edit
3. Change `approval_status` from `pending` to `approved`
4. Set `approved_at` to current timestamp (optional)
5. Click **"Save"**

**Method B: SQL Editor**

1. Click **"SQL Editor"** in left sidebar
2. Click **"New Query"**
3. Run this SQL:

```sql
-- View all pending deals
SELECT
    id,
    title,
    business_name,
    category,
    discount_type,
    original_price,
    discounted_price,
    created_at,
    approval_status
FROM local_deals
WHERE approval_status = 'pending'
ORDER BY created_at DESC;
```

4. Copy the `id` of the deal you want to approve
5. Run this SQL (replace YOUR_DEAL_ID):

```sql
-- Approve a specific deal
UPDATE local_deals
SET
    approval_status = 'approved',
    approved_at = NOW()
WHERE id = 'YOUR_DEAL_ID';
```

---

## 🚀 Quick Approval Commands

### Approve the Most Recent Deal

```sql
UPDATE local_deals
SET
    approval_status = 'approved',
    approved_at = NOW()
WHERE id = (
    SELECT id
    FROM local_deals
    WHERE approval_status = 'pending'
    ORDER BY created_at DESC
    LIMIT 1
);
```

### Approve All Pending Deals (Use Carefully!)

```sql
UPDATE local_deals
SET
    approval_status = 'approved',
    approved_at = NOW()
WHERE approval_status = 'pending';
```

### Reject a Deal

```sql
UPDATE local_deals
SET
    approval_status = 'rejected',
    rejection_reason = 'Reason for rejection here'
WHERE id = 'YOUR_DEAL_ID';
```

---

## 👀 View Your Submitted Deal Details

### See All Information

```sql
SELECT *
FROM local_deals
WHERE approval_status = 'pending'
ORDER BY created_at DESC
LIMIT 1;
```

### Human-Readable View

```sql
SELECT
    title AS "Deal Title",
    business_name AS "Business",
    category AS "Category",
    discount_type AS "Discount Type",
    CASE
        WHEN discount_type = 'percentage' THEN discount_percent || '%'
        WHEN discount_type = 'flat' THEN '₹' || discount_amount
    END AS "Discount",
    '₹' || original_price AS "Original Price",
    '₹' || discounted_price AS "Final Price",
    city || ', ' || area AS "Location",
    TO_CHAR(created_at, 'DD Mon YYYY HH24:MI') AS "Submitted At",
    approval_status AS "Status"
FROM local_deals
WHERE approval_status = 'pending'
ORDER BY created_at DESC;
```

---

## 🎯 Step-by-Step Approval Process

### Visual Walkthrough

```
1. LOGIN TO SUPABASE
   ↓
2. SELECT YOUR PROJECT
   ↓
3. CLICK "SQL EDITOR"
   ↓
4. PASTE APPROVAL SQL
   ↓
5. CLICK "RUN" (or press Ctrl+Enter)
   ↓
6. ✅ DEAL APPROVED!
   ↓
7. CHECK APP - Deal appears immediately
```

---

## 📱 After Approval - What Happens

### Immediate Effects:

1. ✅ Deal becomes visible in the app
2. ✅ Shows in "Local Deals" section
3. ✅ Appears in "See All" screen
4. ✅ Real-time update to all users (if they're online)

### In the App:

```
Before Approval:
🏷️ Local Deals    [0 offers]
[Empty state message]

After Approval:
🏷️ Local Deals    [1 offer]
[Your deal card appears]
```

---

## 🔍 Common Issues & Solutions

### Issue 1: "Can't find my deal"

**Solution:**

```sql
-- Search by business name or title
SELECT id, title, business_name, approval_status, created_at
FROM local_deals
WHERE business_name ILIKE '%your business name%'
   OR title ILIKE '%keyword%'
ORDER BY created_at DESC;
```

### Issue 2: "Deal approved but not showing"

**Check:**

```sql
-- Verify deal is actually approved and active
SELECT
    approval_status,
    is_active,
    expires_at,
    CASE
        WHEN expires_at < NOW() THEN 'EXPIRED'
        ELSE 'ACTIVE'
    END as status
FROM local_deals
WHERE id = 'YOUR_DEAL_ID';
```

**Fix if expired:**

```sql
-- Extend expiry date
UPDATE local_deals
SET expires_at = NOW() + INTERVAL '30 days'
WHERE id = 'YOUR_DEAL_ID';
```

### Issue 3: "App showing old data"

**Solution:**

- Pull to refresh in the app
- Or close and reopen the app
- Real-time updates should work automatically

---

## 🎨 Admin Dashboard View (SQL Query)

### Complete Admin Overview

```sql
-- Dashboard: Deals by Status
SELECT
    approval_status,
    COUNT(*) as count,
    MIN(created_at) as oldest,
    MAX(created_at) as newest
FROM local_deals
GROUP BY approval_status;

-- Pending Deals Summary
SELECT
    id,
    title,
    business_name,
    category,
    city,
    EXTRACT(EPOCH FROM (NOW() - created_at))/3600 AS hours_pending,
    created_at
FROM local_deals
WHERE approval_status = 'pending'
ORDER BY created_at ASC;
```

---

## 📊 Batch Approval Commands

### Approve All Deals from Today

```sql
UPDATE local_deals
SET
    approval_status = 'approved',
    approved_at = NOW()
WHERE approval_status = 'pending'
  AND DATE(created_at) = CURRENT_DATE;
```

### Approve Deals from Specific Category

```sql
UPDATE local_deals
SET
    approval_status = 'approved',
    approved_at = NOW()
WHERE approval_status = 'pending'
  AND category = 'Grocery'; -- Change category as needed
```

### Approve Deals with Specific Discount Type

```sql
UPDATE local_deals
SET
    approval_status = 'approved',
    approved_at = NOW()
WHERE approval_status = 'pending'
  AND discount_type = 'percentage'; -- or 'flat'
```

---

## 🔐 Set Yourself as Admin (Optional)

To access admin features in the future:

```sql
-- Update your user metadata to include admin role
-- Replace 'YOUR_EMAIL@example.com' with your actual email
UPDATE auth.users
SET raw_user_meta_data =
    raw_user_meta_data || '{"role": "admin"}'::jsonb
WHERE email = 'YOUR_EMAIL@example.com';
```

---

## 📝 Quick Reference Card

### Most Common Commands

| Action             | SQL Command                                                                                                                                                       |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **View Pending**   | `SELECT * FROM local_deals WHERE approval_status = 'pending';`                                                                                                    |
| **Approve Latest** | `UPDATE local_deals SET approval_status = 'approved' WHERE id = (SELECT id FROM local_deals WHERE approval_status = 'pending' ORDER BY created_at DESC LIMIT 1);` |
| **Approve All**    | `UPDATE local_deals SET approval_status = 'approved' WHERE approval_status = 'pending';`                                                                          |
| **Reject**         | `UPDATE local_deals SET approval_status = 'rejected', rejection_reason = 'text' WHERE id = 'deal_id';`                                                            |

---

## 🎯 Your Next Steps

### Right Now:

1. ✅ Open Supabase Dashboard
2. ✅ Go to SQL Editor
3. ✅ Run: `SELECT * FROM local_deals WHERE approval_status = 'pending' ORDER BY created_at DESC;`
4. ✅ Copy the deal `id`
5. ✅ Run: `UPDATE local_deals SET approval_status = 'approved', approved_at = NOW() WHERE id = 'YOUR_ID';`
6. ✅ Open your app and pull to refresh
7. ✅ Your deal should appear! 🎉

### For Future:

- Bookmark this guide
- Create a Supabase SQL snippet for quick approvals
- Consider building an admin panel UI (future enhancement)

---

## 🆘 Still Can't Find Your Deal?

### Emergency Search

```sql
-- Find EVERYTHING submitted in last 24 hours
SELECT
    id,
    title,
    business_name,
    approval_status,
    created_at,
    '✅ Found it!' as note
FROM local_deals
WHERE created_at > NOW() - INTERVAL '24 hours'
ORDER BY created_at DESC;
```

If this returns empty, the deal might not have been saved. Check:

1. Were there any error messages during submission?
2. Check browser console for errors
3. Verify database connection is working

---

## 📞 Need Help?

If you're still stuck:

1. Check Supabase logs for errors
2. Verify the `local_deals` table exists
3. Ensure RLS policies are set up correctly
4. Run the migration file: `20260203_fix_permissions_flexible_pricing.sql`

---

**Quick Tip:** After approving your first deal, you'll see it appear in the app immediately thanks to real-time updates! 🚀
