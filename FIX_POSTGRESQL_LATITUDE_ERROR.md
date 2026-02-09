# Fix: PostgreSQL Error - Missing 'latitude' Column

## 🔴 The Error You Got

```
Failed to submit business:
PostgresException(message: Could not find the 'latitude' column
of 'business_submissions' in the schema cache,
code: PGRST204, details: Bad Request, hint: null)
```

## 🔍 What Went Wrong

The location capture feature was added to save latitude and longitude when submitting a business. However, the `business_submissions` table in your Supabase database is missing these columns.

## ✅ How to Fix (2 Simple Steps)

### Step 1: Run SQL Script in Supabase

1. Go to your **Supabase Dashboard** → **SQL Editor**
2. Copy the entire SQL from: [FIX_BUSINESS_SUBMISSIONS_COLUMNS.sql](FIX_BUSINESS_SUBMISSIONS_COLUMNS.sql)
3. Paste it into the SQL Editor
4. Click **"Run"** button

This will add all missing columns to the `business_submissions` table:

- `latitude` (DOUBLE PRECISION)
- `longitude` (DOUBLE PRECISION)
- Translation columns for all fields (\_te, \_hi)
- Feature flags (is_featured, is_verified, is_ad)

### Step 2: Restart Your App

1. Close the app completely
2. Restart it fresh (not just hot reload)
3. Go back to "Shop Local" screen
4. Tap "Add Shop" button
5. Fill in business details
6. Capture location
7. Submit business
8. **Error should be gone!** ✓

---

## 📊 What Columns Get Added

| Column      | Type    | Purpose                   |
| ----------- | ------- | ------------------------- |
| latitude    | DOUBLE  | GPS latitude coordinate   |
| longitude   | DOUBLE  | GPS longitude coordinate  |
| name_te     | TEXT    | Business name in Telugu   |
| name_hi     | TEXT    | Business name in Hindi    |
| offer_te    | TEXT    | Offer in Telugu           |
| offer_hi    | TEXT    | Offer in Hindi            |
| tagline_te  | TEXT    | Tagline in Telugu         |
| tagline_hi  | TEXT    | Tagline in Hindi          |
| city_te     | TEXT    | City in Telugu            |
| city_hi     | TEXT    | City in Hindi             |
| is_featured | BOOLEAN | Is it a featured business |
| is_verified | BOOLEAN | Is it verified            |
| is_ad       | BOOLEAN | Is it a paid ad           |

---

## ✨ After the Fix

Once you've run the SQL and restarted your app, you'll be able to:

✅ **Add a business** with all details  
✅ **Capture GPS location** while standing at the shop  
✅ **See location** on the green success card  
✅ **Submit business** without errors  
✅ **View in multiple languages** (English/Hindi/Telugu)

---

## 🧪 Testing After Fix

1. Open App
2. Tap "Shop" button
3. Tap "Add Shop" floating button
4. Fill in:
   - Name: Test Shop
   - Category: Grocery
   - Phone: 9876543210
   - Address: Plot 100, Main Road
   - City: Medchal
   - State: Telangana
5. Scroll to "Business Location" (orange card)
6. Tap "Capture Location"
7. Allow GPS permission
8. Wait 3-5 seconds
9. See green success card with coordinates
10. Tap "Submit"
11. **Success!** Business saved with location ✓

---

## 🆘 If Error Still Appears

1. Make sure you ran the SQL in Supabase (not locally)
2. Check that columns were actually added:
   - Go to Supabase → Table Editor
   - Click on `business_submissions` table
   - Verify `latitude` and `longitude` columns exist
3. Do a full app restart (kill the app completely)
4. Try again

---

## 📝 Summary

**Problem:** `business_submissions` table missing location columns  
**Solution:** Run SQL script to add columns  
**Result:** Business submission with location works perfectly!

---

**Just run the SQL and restart the app - you're good to go!** 🎉
