-- Featured Business Submissions Table
-- For managing featured business applications with admin approval

CREATE TABLE IF NOT EXISTS featured_business_submissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_name VARCHAR(255) NOT NULL,
    tagline VARCHAR(500) NOT NULL,
    description TEXT,
    category VARCHAR(100) NOT NULL DEFAULT 'Other',
    phone_number VARCHAR(20) NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(100) NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    logo_url TEXT,
    images TEXT[], -- Array of image URLs
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    submitter_id UUID REFERENCES auth.users(id),
    approved_by UUID REFERENCES auth.users(id),
    approved_at TIMESTAMP WITH TIME ZONE,
    rejected_at TIMESTAMP WITH TIME ZONE,
    rejection_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_featured_business_status ON featured_business_submissions(status);
CREATE INDEX IF NOT EXISTS idx_featured_business_city ON featured_business_submissions(city);
CREATE INDEX IF NOT EXISTS idx_featured_business_category ON featured_business_submissions(category);
CREATE INDEX IF NOT EXISTS idx_featured_business_created ON featured_business_submissions(created_at DESC);

-- Add updated_at trigger
CREATE OR REPLACE FUNCTION update_featured_business_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER featured_business_updated_at
    BEFORE UPDATE ON featured_business_submissions
    FOR EACH ROW
    EXECUTE FUNCTION update_featured_business_updated_at();

-- Row Level Security
ALTER TABLE featured_business_submissions ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can view approved featured businesses
CREATE POLICY "Public can view approved featured businesses"
ON featured_business_submissions FOR SELECT
USING (status = 'approved');

-- Policy: Authenticated users can submit featured business applications
CREATE POLICY "Authenticated users can submit featured businesses"
ON featured_business_submissions FOR INSERT
TO authenticated
WITH CHECK (true);

-- Policy: Users can view their own submissions
CREATE POLICY "Users can view own submissions"
ON featured_business_submissions FOR SELECT
TO authenticated
USING (submitter_id = auth.uid());

-- Policy: Admin can do everything (assuming admin role check)
-- Note: Adjust this based on your admin role implementation
CREATE POLICY "Admin can manage all featured businesses"
ON featured_business_submissions FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM auth.users
        WHERE auth.users.id = auth.uid()
        AND auth.users.raw_user_meta_data->>'role' = 'admin'
    )
);

-- Sample data for testing
INSERT INTO featured_business_submissions (business_name, tagline, description, category, phone_number, address, city, latitude, longitude, status)
VALUES 
    ('Lakshmi Jewellers', 'Traditional Gold Jewelry Since 1950', 'Finest gold, silver, and diamond jewelry. Traditional and modern designs.', 'Jewellery', '9876543210', 'Shop 12, Begum Bazaar', 'Hyderabad', 17.3850, 78.4867, 'approved'),
    ('Paradise Biryani', 'World Famous Hyderabadi Biryani', 'Authentic Hyderabadi Dum Biryani served since 1953.', 'Restaurant', '9988776655', 'SD Road, Secunderabad', 'Hyderabad', 17.4399, 78.4983, 'approved'),
    ('Tech World Electronics', 'Latest Gadgets & Accessories', 'All electronics, mobiles, laptops, and accessories under one roof.', 'Electronics', '9112233445', 'Ameerpet Main Road', 'Hyderabad', 17.4375, 78.4483, 'pending'),
    ('Fresh Mart Grocery', '24/7 Fresh Groceries Delivered', 'Fresh vegetables, fruits, and daily essentials at best prices.', 'Grocery', '9556677889', 'Madhapur, Cyberabad', 'Hyderabad', 17.4489, 78.3907, 'pending')
ON CONFLICT DO NOTHING;

-- Comment on table
COMMENT ON TABLE featured_business_submissions IS 'Stores featured business submissions for admin approval. Approved businesses are synced to main businesses table with is_featured=true.';
