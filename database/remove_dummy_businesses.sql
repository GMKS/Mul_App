-- Remove Dummy/Test Businesses from Featured Businesses
-- Run this in Supabase SQL Editor

-- OPTION 1: View all featured businesses first to see what you have
SELECT 
  id,
  name,
  category,
  city,
  is_featured,
  created_at
FROM businesses 
WHERE is_featured = true
ORDER BY created_at DESC;

-- OPTION 2: Remove specific businesses by name
-- Replace 'Business Name' with the actual name you see in the app

DELETE FROM businesses 
WHERE LOWER(name) = LOWER('Joseph Bible House');

DELETE FROM businesses 
WHERE LOWER(name) = LOWER('Bata Shoe Shop');

-- OPTION 3: Remove ALL featured businesses EXCEPT the ones you want to keep
-- Uncomment and modify this to keep only specific businesses

-- DELETE FROM businesses 
-- WHERE is_featured = true 
-- AND LOWER(name) NOT IN (
--   'bata shoe shop',
--   'business name to keep 2'
-- );

-- OPTION 4: Remove ALL featured businesses (CAUTION: This deletes everything!)
-- Uncomment the line below only if you want to start fresh

-- DELETE FROM businesses WHERE is_featured = true;

-- OPTION 5: Just unflag them as featured (keeps data but hides from carousel)
-- This is safer than deleting

UPDATE businesses 
SET is_featured = false 
WHERE LOWER(name) IN (
  'joseph bible house',
  'sri lakshmi jewellers',
  'quick home services',
  'fresh farm organics',
  'city health clinic',
  'anand sweets'
);

-- OPTION 6: Delete specific businesses by ID (if you know the ID)
-- Find IDs from OPTION 1 query above

-- DELETE FROM businesses WHERE id = 'specific-id-here';
-- DELETE FROM businesses WHERE id = 'another-id-here';

-- After deletion, verify what's left
SELECT 
  name,
  name_te,
  name_hi,
  is_featured
FROM businesses 
WHERE is_featured = true
ORDER BY created_at DESC;
