-- =====================================================
-- Check and Fix Sweet Shop Translations
-- Run this in Supabase SQL Editor
-- =====================================================

-- 1. Check current Sweet Shop data
SELECT 
  id,
  name, name_te, name_hi,
  offer, offer_te, offer_hi,
  tagline, tagline_te, tagline_hi,
  city, city_te, city_hi,
  cta_text, cta_text_te, cta_text_hi,
  is_featured, is_approved
FROM businesses
WHERE name = 'Sweet Shop';

-- =====================================================
-- 2. Update Sweet Shop with Complete Translations
-- =====================================================

UPDATE businesses
SET 
  -- Name translations
  name = 'Sweet Shop',
  name_te = 'స్వీట్ షాప్',
  name_hi = 'स्वीट शॉप',
  
  -- Offer translations (this is what shows as the tagline on the card)
  offer = 'Offer 10% on First shopping',
  offer_te = 'మొదటి షాపింగ్‌పై 10% ఆఫర్',
  offer_hi = 'पहली खरीदारी पर 10% की छूट',
  
  -- Tagline/Description translations
  tagline = 'Credit card facility available',
  tagline_te = 'క్రెడిట్ కార్డ్ సౌకర్యం అందుబాటులో ఉంది',
  tagline_hi = 'क्रेडिट कार्ड सुविधा उपलब्ध',
  
  description = 'Credit card facility available',
  description_te = 'క్రెడిట్ కార్డ్ సౌకర్యం అందుబాటులో ఉంది',
  description_hi = 'क्रेडिट कार्ड सुविधा उपलब्ध',
  
  -- City translations
  city = 'Hyderabad',
  city_te = 'హైదరాబాద్',
  city_hi = 'हैदराबाद',
  
  -- CTA Button translations
  cta_text = 'Shop Now',
  cta_text_te = 'ఇప్పుడు షాపింగ్ చేయండి',
  cta_text_hi = 'अभी खरीदें',
  
  -- Flags
  is_featured = true,  -- Set to true to show in carousel
  is_approved = true,
  is_verified = false,
  is_ad = false,
  
  -- Update timestamp
  updated_at = NOW()

WHERE name = 'Sweet Shop';

-- =====================================================
-- 3. Verify the update
-- =====================================================

SELECT 
  name, name_te, name_hi,
  offer, offer_te, offer_hi,
  city, city_te, city_hi,
  cta_text, cta_text_te, cta_text_hi,
  is_featured, is_approved
FROM businesses
WHERE name = 'Sweet Shop';

-- =====================================================
-- Expected Result After Update:
-- =====================================================
-- All fields should have English, Telugu (_te), and Hindi (_hi) translations
-- is_featured should be true (to show in carousel)
-- is_approved should be true (to be visible)
--
-- After running this:
-- 1. Restart your app
-- 2. Switch to English: "Sweet Shop" / "Offer 10% on First shopping" / "Hyderabad"
-- 3. Switch to Telugu: "స్వీట్ షాప్" / "మొదటి షాపింగ్‌పై 10% ఆఫర్" / "హైదరాబాద్"
-- 4. Switch to Hindi: "स्वीट शॉप" / "पहली खरीदारी पर 10% की छूट" / "हैदराबाद"
-- =====================================================
