-- =====================================================
-- Clean Up Database: Remove All Businesses Except Sweet Shop
-- Run this in Supabase SQL Editor
-- =====================================================

-- OPTION 1: Delete all businesses EXCEPT Sweet Shop
DELETE FROM businesses
WHERE name != 'Sweet Shop';

-- Verify only Sweet Shop remains
SELECT id, name, is_featured, is_approved, category, city
FROM businesses
ORDER BY created_at DESC;

-- =====================================================
-- Expected Result: Only 1 row should appear (Sweet Shop)
-- =====================================================

-- OPTION 2: If you want to delete specific businesses by name
-- Uncomment the lines below and add the business names you want to delete

-- DELETE FROM businesses
-- WHERE name IN (
--   'Spice Garden Restaurant',
--   'Fresh Mart Grocery',
--   'Test Business 1',
--   'Test Business 2'
-- );

-- =====================================================
-- After cleanup, restart your app
-- Only Sweet Shop should appear in the Directory Tab
-- =====================================================
