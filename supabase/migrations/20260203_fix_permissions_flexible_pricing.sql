-- =====================================================
-- Fix Permission Error & Add Flexible Pricing System
-- Run this in your Supabase SQL Editor
-- =====================================================

-- PART 1: FIX PERMISSION ERROR
-- =====================================================

-- Drop problematic RLS policies that reference auth.users
DROP POLICY IF EXISTS "Admins can view all deals" ON public.local_deals;
DROP POLICY IF EXISTS "Admins can approve or reject deals" ON public.local_deals;
DROP POLICY IF EXISTS "Users can create deals" ON public.local_deals;
DROP POLICY IF EXISTS "Users can view approved deals" ON public.local_deals;

-- Recreate simpler policies without auth.users join
-- Allow all authenticated users to view approved deals
CREATE POLICY "Users can view approved deals" 
ON public.local_deals FOR SELECT 
TO authenticated
USING (approval_status = 'approved' AND is_active = true);

-- Allow authenticated users to insert their own deals
CREATE POLICY "Users can create deals" 
ON public.local_deals FOR INSERT 
TO authenticated
WITH CHECK (true); -- Allow insert, created_by will be set by application

-- Allow users to update their own deals (if pending)
CREATE POLICY "Users can update own pending deals" 
ON public.local_deals FOR UPDATE 
TO authenticated
USING (created_by = auth.uid() AND approval_status = 'pending');

-- Admins: Create admin role check function
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN (
        SELECT COALESCE(
            (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin',
            false
        )
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Allow admins to view all deals
CREATE POLICY "Admins can view all deals" 
ON public.local_deals FOR SELECT 
TO authenticated
USING (is_admin());

-- Allow admins to update any deal
CREATE POLICY "Admins can update any deal" 
ON public.local_deals FOR UPDATE 
TO authenticated
USING (is_admin());

-- PART 2: ADD FLEXIBLE PRICING SYSTEM
-- =====================================================

-- Add new pricing columns
ALTER TABLE public.local_deals 
ADD COLUMN IF NOT EXISTS discount_type VARCHAR(20) DEFAULT 'percentage' CHECK (discount_type IN ('percentage', 'flat'));

-- Rename/adjust existing columns for clarity
-- original_price and discounted_price remain but become optional
ALTER TABLE public.local_deals 
ALTER COLUMN original_price DROP NOT NULL,
ALTER COLUMN discounted_price DROP NOT NULL,
ALTER COLUMN discount_percent DROP NOT NULL;

-- Add discount_amount column for flat discounts
ALTER TABLE public.local_deals 
ADD COLUMN IF NOT EXISTS discount_amount DECIMAL(10, 2);

-- Add flag for product-level pricing (future feature)
ALTER TABLE public.local_deals 
ADD COLUMN IF NOT EXISTS has_product_pricing BOOLEAN DEFAULT false;

-- Create table for product-level pricing (for deals with multiple products)
CREATE TABLE IF NOT EXISTS public.deal_products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    deal_id UUID NOT NULL REFERENCES public.local_deals(id) ON DELETE CASCADE,
    product_name VARCHAR(255) NOT NULL,
    original_price DECIMAL(10, 2),
    discounted_price DECIMAL(10, 2),
    discount_percent INTEGER,
    discount_amount DECIMAL(10, 2),
    discount_type VARCHAR(20) DEFAULT 'percentage' CHECK (discount_type IN ('percentage', 'flat')),
    stock_quantity INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(deal_id, product_name)
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_deal_products_deal_id ON public.deal_products(deal_id);

-- Create function to calculate discount
CREATE OR REPLACE FUNCTION calculate_discount(
    p_discount_type VARCHAR,
    p_discount_value DECIMAL,
    p_original_price DECIMAL
) RETURNS JSONB AS $$
DECLARE
    v_discounted_price DECIMAL;
    v_discount_percent INTEGER;
    v_discount_amount DECIMAL;
BEGIN
    IF p_discount_type = 'percentage' THEN
        -- Percentage discount
        v_discount_percent := p_discount_value::INTEGER;
        v_discount_amount := ROUND(p_original_price * (p_discount_value / 100.0), 2);
        v_discounted_price := p_original_price - v_discount_amount;
    ELSE
        -- Flat amount discount
        v_discount_amount := p_discount_value;
        v_discounted_price := GREATEST(p_original_price - p_discount_value, 0);
        v_discount_percent := CASE 
            WHEN p_original_price > 0 THEN ROUND((v_discount_amount / p_original_price * 100.0)::NUMERIC, 0)::INTEGER
            ELSE 0
        END;
    END IF;
    
    RETURN jsonb_build_object(
        'discounted_price', v_discounted_price,
        'discount_percent', v_discount_percent,
        'discount_amount', v_discount_amount
    );
END;
$$ LANGUAGE plpgsql;

-- Create trigger function to auto-calculate discounts on insert/update
CREATE OR REPLACE FUNCTION auto_calculate_deal_discount()
RETURNS TRIGGER AS $$
DECLARE
    v_result JSONB;
BEGIN
    -- Only calculate if we have original price and discount info
    IF NEW.original_price IS NOT NULL AND 
       ((NEW.discount_type = 'percentage' AND NEW.discount_percent IS NOT NULL) OR
        (NEW.discount_type = 'flat' AND NEW.discount_amount IS NOT NULL)) THEN
        
        IF NEW.discount_type = 'percentage' THEN
            v_result := calculate_discount('percentage', NEW.discount_percent, NEW.original_price);
        ELSE
            v_result := calculate_discount('flat', NEW.discount_amount, NEW.original_price);
        END IF;
        
        NEW.discounted_price := (v_result->>'discounted_price')::DECIMAL;
        NEW.discount_percent := (v_result->>'discount_percent')::INTEGER;
        NEW.discount_amount := (v_result->>'discount_amount')::DECIMAL;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for auto-calculation
DROP TRIGGER IF EXISTS trigger_auto_calculate_deal_discount ON public.local_deals;
CREATE TRIGGER trigger_auto_calculate_deal_discount
    BEFORE INSERT OR UPDATE ON public.local_deals
    FOR EACH ROW
    EXECUTE FUNCTION auto_calculate_deal_discount();

-- Update the view to include new pricing fields
DROP VIEW IF EXISTS pending_deals_view;
CREATE OR REPLACE VIEW pending_deals_view AS
SELECT 
    ld.*
FROM public.local_deals ld
WHERE ld.approval_status = 'pending'
ORDER BY ld.created_at DESC;

-- Create view for active deals with pricing info
CREATE OR REPLACE VIEW active_deals_with_pricing AS
SELECT 
    id,
    title,
    description,
    business_name,
    category,
    emoji,
    discount_type,
    CASE 
        WHEN discount_type = 'percentage' THEN discount_percent || '%'
        WHEN discount_type = 'flat' THEN '₹' || discount_amount
        ELSE ''
    END as discount_display,
    original_price,
    discounted_price,
    discount_percent,
    discount_amount,
    city,
    state,
    area,
    latitude,
    longitude,
    expires_at,
    is_featured,
    is_sponsored,
    approval_status,
    created_at
FROM public.local_deals
WHERE approval_status = 'approved' 
  AND is_active = true
  AND expires_at > NOW()
ORDER BY 
    is_featured DESC,
    is_sponsored DESC,
    priority_rank DESC,
    created_at DESC;

-- Success message
DO $$
BEGIN
    RAISE NOTICE '✅ Permission fix applied successfully!';
    RAISE NOTICE '✅ Flexible pricing system added!';
    RAISE NOTICE 'New features:';
    RAISE NOTICE '  - Discount Type: percentage or flat amount';
    RAISE NOTICE '  - Auto-calculation of prices';
    RAISE NOTICE '  - Optional original/sale prices';
    RAISE NOTICE '  - Product-level pricing support';
END $$;
