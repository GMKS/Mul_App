-- =====================================================
-- SQL Script: Add Sample Featured & Local Business
-- Copy and paste this entire script into Supabase SQL Editor
-- =====================================================

-- 1. ADD FEATURED BUSINESS: Spice Garden Restaurant
-- This will appear in the Featured carousel at the top
INSERT INTO businesses (
  name, name_te, name_hi,
  offer, offer_te, offer_hi,
  tagline, tagline_te, tagline_hi,
  description, description_te, description_hi,
  cta_text, cta_text_te, cta_text_hi,
  category, city, city_te, city_hi,
  address, phone,
  is_featured, is_approved, is_verified, is_ad,
  rating, review_count,
  created_at, updated_at
) VALUES (
  -- English
  'Spice Garden Restaurant',
  -- Telugu
  'స్పైస్ గార్డెన్ రెస్టారెంట్',
  -- Hindi
  'स्पाइस गार्डन रेस्तरां',
  
  -- Offer (English)
  '20% Off on All Orders Above ₹500',
  -- Offer (Telugu)
  '₹500 కంటే ఎక్కువ ఆర్డర్లపై 20% తగ్గింపు',
  -- Offer (Hindi)
  '₹500 से अधिक के सभी ऑर्डर पर 20% छूट',
  
  -- Tagline (English)
  'Authentic South Indian Cuisine',
  -- Tagline (Telugu)
  'నిజమైన దక్షిణ భారత వంటకాలు',
  -- Tagline (Hindi)
  'प्रामाणिक दक्षिण भारतीय व्यंजन',
  
  -- Description (English)
  'Family restaurant serving delicious dosas, idlis and traditional meals',
  -- Description (Telugu)
  'రుచికరమైన దోసలు, ఇడ్లీలు మరియు సాంప్రదాయ భోజనాలను అందించే కుటుంబ రెస్టారెంట్',
  -- Description (Hindi)
  'स्वादिष्ट डोसा, इडली और पारंपरिक भोजन परोसने वाला पारिवारिक रेस्तरां',
  
  -- CTA Text (English)
  'Order Now',
  -- CTA Text (Telugu)
  'ఇప్పుడు ఆర్డర్ చేయండి',
  -- CTA Text (Hindi)
  'अभी ऑर्डर करें',
  
  -- Category & Location
  'Restaurant',
  'Hyderabad',
  'హైదరాబాద్',
  'हैदराबाद',
  
  -- Address & Contact
  'Shop 15, Jubilee Hills, Road No. 36',
  '9876543210',
  
  -- Flags
  true,   -- is_featured (TRUE = shows in carousel)
  true,   -- is_approved (TRUE = visible to users)
  true,   -- is_verified (TRUE = shows verified badge)
  false,  -- is_ad (FALSE = not a paid ad)
  
  -- Rating & Reviews
  4.5,
  156,
  
  -- Timestamps
  NOW(),
  NOW()
);

-- 2. ADD LOCAL BUSINESS: Fresh Mart Grocery
-- This will appear in the Business Directory
INSERT INTO businesses (
  name, name_te, name_hi,
  offer, offer_te, offer_hi,
  tagline, tagline_te, tagline_hi,
  description, description_te, description_hi,
  cta_text, cta_text_te, cta_text_hi,
  category, city, city_te, city_hi,
  address, phone,
  is_featured, is_approved, is_verified, is_ad,
  rating, review_count,
  created_at, updated_at
) VALUES (
  -- English
  'Fresh Mart Grocery',
  -- Telugu
  'ఫ్రెష్ మార్ట్ గ్రోసరీ',
  -- Hindi
  'फ्रेश मार्ट किराना',
  
  -- Offer (English)
  'Free Home Delivery on Orders Above ₹300',
  -- Offer (Telugu)
  '₹300 కంటే ఎక్కువ ఆర్డర్లపై ఉచిత హోం డెలివరీ',
  -- Offer (Hindi)
  '₹300 से अधिक के ऑर्डर पर मुफ्त होम डिलीवरी',
  
  -- Tagline (English)
  'Fresh Fruits & Vegetables Daily',
  -- Tagline (Telugu)
  'ప్రతిరోజు తాజా పండ్లు & కూరగాయలు',
  -- Tagline (Hindi)
  'प्रतिदिन ताजे फल और सब्जियां',
  
  -- Description (English)
  'Your neighborhood grocery store with fresh produce and daily essentials',
  -- Description (Telugu)
  'తాజా ఉత్పత్తులు మరియు రోజువారీ అవసరాలతో మీ పొరుగు కిరాణా దుకాణం',
  -- Description (Hindi)
  'ताजा उत्पाद और दैनिक आवश्यकताओं वाली आपकी पड़ोस की किराना दुकान',
  
  -- CTA Text (English)
  'Shop Now',
  -- CTA Text (Telugu)
  'ఇప్పుడు షాపింగ్ చేయండి',
  -- CTA Text (Hindi)
  'अभी खरीदें',
  
  -- Category & Location
  'Grocery',
  'Hyderabad',
  'హైదరాబాద్',
  'हैदराबाद',
  
  -- Address & Contact
  'Shop 42, Banjara Hills Main Road',
  '9123456789',
  
  -- Flags
  false,  -- is_featured (FALSE = does NOT show in carousel)
  true,   -- is_approved (TRUE = visible to users)
  false,  -- is_verified (FALSE = no verified badge)
  false,  -- is_ad (FALSE = not a paid ad)
  
  -- Rating & Reviews
  4.2,
  89,
  
  -- Timestamps
  NOW(),
  NOW()
);

-- =====================================================
-- Verify the insertion
-- =====================================================
SELECT 
  name,
  name_te,
  name_hi,
  is_featured,
  is_approved,
  category,
  city
FROM businesses
WHERE name IN ('Spice Garden Restaurant', 'Fresh Mart Grocery')
ORDER BY is_featured DESC;

-- =====================================================
-- Expected Result:
-- =====================================================
-- Row 1: Spice Garden Restaurant (is_featured = true)
-- Row 2: Fresh Mart Grocery (is_featured = false)
--
-- After running this script:
-- 1. Restart your app
-- 2. Featured business will appear in carousel at top
-- 3. Local business will appear in Business Directory
-- 4. Switch languages to see translations
-- =====================================================
