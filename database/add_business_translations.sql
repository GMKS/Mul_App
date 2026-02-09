-- Add multilingual columns to businesses table for Featured Businesses
-- Run this in Supabase SQL Editor

-- 1. Add translation columns if they don't exist
ALTER TABLE businesses 
ADD COLUMN IF NOT EXISTS name_te TEXT,
ADD COLUMN IF NOT EXISTS name_hi TEXT,
ADD COLUMN IF NOT EXISTS offer_te TEXT,
ADD COLUMN IF NOT EXISTS offer_hi TEXT,
ADD COLUMN IF NOT EXISTS tagline_te TEXT,
ADD COLUMN IF NOT EXISTS tagline_hi TEXT,
ADD COLUMN IF NOT EXISTS description_te TEXT,
ADD COLUMN IF NOT EXISTS description_hi TEXT,
ADD COLUMN IF NOT EXISTS cta_text_te TEXT,
ADD COLUMN IF NOT EXISTS cta_text_hi TEXT;

-- 2. Update existing "Bata Shoe Shop" with translations
UPDATE businesses 
SET 
  name_te = 'బాటా షూ స్టోర్',
  name_hi = 'बाटा शू शॉप',
  offer_te = 'గోల్డ్ మేకింగ్ ఛార్జీలపై 20% తగ్గింపు',
  offer_hi = 'सोने के मेकिंग चार्ज पर 20% छूट',
  tagline_te = 'గోల్డ్ మేకింగ్ ఛార్జీలపై 20% తగ్గింపు',
  tagline_hi = 'सोने के मेकिंग चार्ज पर 20% छूट',
  cta_text_te = 'స్టోర్ చూడండి',
  cta_text_hi = 'स्टोर पर जाएं'
WHERE LOWER(name) = 'bata shoe shop';

-- 3. Update "Joseph Bible House" with translations
UPDATE businesses 
SET 
  name_te = 'జోసెఫ్ బైబిల్ హౌస్',
  name_hi = 'जोसेफ बाइबल हाउस',
  offer_te = 'గోల్డ్ మేకింగ్ ఛార్జీలపై 50% తగ్గింపు',
  offer_hi = 'सोने के मेकिंग चार्ज पर 50% छूट',
  tagline_te = 'గోల్డ్ మేకింగ్ ఛార్జీలపై 50% తగ్గింపు',
  tagline_hi = 'सोने के मेकिंग चार्ज पर 50% छूट',
  cta_text_te = 'స్టోర్ చూడండి',
  cta_text_hi = 'स्टोर पर जाएं'
WHERE LOWER(name) = 'joseph bible house';

-- 4. Add translations for any other featured businesses
-- Generic translation for "Visit Store" CTA
UPDATE businesses 
SET 
  cta_text_te = 'స్టోర్ చూడండి',
  cta_text_hi = 'स्टोर पर जाएं'
WHERE is_featured = true AND cta_text_te IS NULL;

-- 5. Verify the updates
SELECT 
  name,
  name_te,
  name_hi,
  offer_te,
  offer_hi,
  cta_text_te,
  cta_text_hi,
  is_featured
FROM businesses 
WHERE is_featured = true
ORDER BY created_at DESC;
