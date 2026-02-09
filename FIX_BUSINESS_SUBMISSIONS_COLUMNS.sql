-- =====================================================
-- Fix: Add Missing Location Columns to Business Tables
-- Run this in Supabase SQL Editor
-- =====================================================

-- 1. Add latitude and longitude to business_submissions table
ALTER TABLE business_submissions
ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION,
ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION,
ADD COLUMN IF NOT EXISTS name_te TEXT,
ADD COLUMN IF NOT EXISTS name_hi TEXT,
ADD COLUMN IF NOT EXISTS offer TEXT,
ADD COLUMN IF NOT EXISTS offer_te TEXT,
ADD COLUMN IF NOT EXISTS offer_hi TEXT,
ADD COLUMN IF NOT EXISTS tagline TEXT,
ADD COLUMN IF NOT EXISTS tagline_te TEXT,
ADD COLUMN IF NOT EXISTS tagline_hi TEXT,
ADD COLUMN IF NOT EXISTS description_te TEXT,
ADD COLUMN IF NOT EXISTS description_hi TEXT,
ADD COLUMN IF NOT EXISTS city_te TEXT,
ADD COLUMN IF NOT EXISTS city_hi TEXT,
ADD COLUMN IF NOT EXISTS cta_text TEXT,
ADD COLUMN IF NOT EXISTS cta_text_te TEXT,
ADD COLUMN IF NOT EXISTS cta_text_hi TEXT,
ADD COLUMN IF NOT EXISTS is_featured BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS is_verified BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS is_ad BOOLEAN DEFAULT false;

-- 2. Verify columns were added
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name='business_submissions' 
ORDER BY ordinal_position;

-- =====================================================
-- Expected Result:
-- =====================================================
-- New columns added to business_submissions:
-- - latitude (DOUBLE PRECISION)
-- - longitude (DOUBLE PRECISION)
-- - name_te, name_hi (TEXT) - for translations
-- - offer, offer_te, offer_hi (TEXT)
-- - tagline, tagline_te, tagline_hi (TEXT)
-- - description_te, description_hi (TEXT)
-- - city_te, city_hi (TEXT)
-- - cta_text, cta_text_te, cta_text_hi (TEXT)
-- - is_featured, is_verified, is_ad (BOOLEAN)
--
-- After running this:
-- 1. Restart your app
-- 2. Try adding a business again
-- 3. Capture location
-- 4. Submit business
-- 5. Error should be gone! ✓
-- =====================================================
