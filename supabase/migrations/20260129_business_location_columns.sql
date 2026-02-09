-- Migration: Add latitude and longitude columns to business_submissions and businesses tables
-- Date: 2026-01-29
-- Purpose: Enable GPS location capture for businesses

-- Add location columns to business_submissions table (if not exists)
DO $$ 
BEGIN
    -- Add latitude column to business_submissions
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'business_submissions' AND column_name = 'latitude'
    ) THEN
        ALTER TABLE business_submissions ADD COLUMN latitude DOUBLE PRECISION;
    END IF;

    -- Add longitude column to business_submissions
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'business_submissions' AND column_name = 'longitude'
    ) THEN
        ALTER TABLE business_submissions ADD COLUMN longitude DOUBLE PRECISION;
    END IF;

    -- Add latitude column to businesses (if not exists)
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'businesses' AND column_name = 'latitude'
    ) THEN
        ALTER TABLE businesses ADD COLUMN latitude DOUBLE PRECISION;
    END IF;

    -- Add longitude column to businesses (if not exists)
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'businesses' AND column_name = 'longitude'
    ) THEN
        ALTER TABLE businesses ADD COLUMN longitude DOUBLE PRECISION;
    END IF;
END $$;

-- Add comments for documentation
COMMENT ON COLUMN business_submissions.latitude IS 'GPS latitude coordinate of business location';
COMMENT ON COLUMN business_submissions.longitude IS 'GPS longitude coordinate of business location';
COMMENT ON COLUMN businesses.latitude IS 'GPS latitude coordinate of business location';
COMMENT ON COLUMN businesses.longitude IS 'GPS longitude coordinate of business location';

-- Create index for geospatial queries (optional but recommended for performance)
CREATE INDEX IF NOT EXISTS idx_businesses_location 
ON businesses (latitude, longitude) 
WHERE latitude IS NOT NULL AND longitude IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_business_submissions_location 
ON business_submissions (latitude, longitude) 
WHERE latitude IS NOT NULL AND longitude IS NOT NULL;
