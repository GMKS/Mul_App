# Fix Featured Businesses Translation Issue

## Problem

Featured Businesses cards showing English text even when Telugu or Hindi is selected.

## Root Cause

The database `businesses` table doesn't have translation columns (`name_te`, `name_hi`, etc.) for existing businesses.

## Solution

### Step 1: Add Translation Columns to Database

1. Open your **Supabase Dashboard**
2. Go to **SQL Editor**
3. Open the file: `database/add_business_translations.sql`
4. Copy and paste the SQL into Supabase SQL Editor
5. Click **Run** to execute

This will:

- Add multilingual columns (name_te, name_hi, offer_te, offer_hi, etc.)
- Add Telugu and Hindi translations for "Bata Shoe Shop"
- Add translations for "Joseph Bible House"
- Set default CTA button translations for all featured businesses

### Step 2: Hot Reload the App

After running the SQL:

1. In VS Code terminal, press `r` for hot reload
2. Switch language to Telugu - should see తెలుగు text
3. Switch to Hindi - should see हिंदी text
4. Switch to English - should see English text

### Step 3: Add Translations for Other Businesses

For any other businesses you want to translate, use this template:

```sql
UPDATE businesses
SET
  name_te = 'తెలుగు పేరు',
  name_hi = 'हिंदी नाम',
  offer_te = 'తెలుగు ఆఫర్',
  offer_hi = 'हिंदी ऑफर',
  tagline_te = 'తెలుగు ట్యాగ్‌లైన్',
  tagline_hi = 'हिंदी टैगलाइन',
  cta_text_te = 'స్టోర్ చూడండి',
  cta_text_hi = 'स्टोर पर जाएं'
WHERE name = 'Business Name in English';
```

## What Changed in Code

**File: lib/widgets/business_teasers_carousel.dart**

- Updated Supabase query to explicitly fetch translation columns
- Added logging to track how many businesses are fetched
- Deduplication now works on base English name before localization

## Testing Checklist

- [ ] Run SQL migration in Supabase
- [ ] Hot reload app
- [ ] Test Telugu language - all cards show Telugu text
- [ ] Test Hindi language - all cards show Hindi text
- [ ] Test English language - all cards show English text
- [ ] No duplicate businesses appear
- [ ] No overflow errors when scrolling

## Need More Businesses?

To add more Featured Businesses with translations:

```sql
INSERT INTO businesses (
  name, name_te, name_hi,
  offer, offer_te, offer_hi,
  category, city, phone,
  is_featured, is_approved, is_verified,
  cta_text, cta_text_te, cta_text_hi
) VALUES (
  'Business Name',
  'తెలుగు పేరు',
  'हिंदी नाम',
  'Special Offer',
  'ప్రత్యేక ఆఫర్',
  'विशेष ऑफर',
  'retail',
  'Hyderabad',
  '9999999999',
  true,
  true,
  true,
  'Visit Store',
  'స్టోర్ చూడండి',
  'स्टोर पर जाएं'
);
```
