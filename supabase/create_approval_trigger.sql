-- Create trigger to automatically move approved submissions to businesses table
-- Run this in Supabase SQL Editor

-- Function to copy approved submission to businesses table
CREATE OR REPLACE FUNCTION public.copy_approved_submission_to_businesses()
RETURNS TRIGGER AS $$
BEGIN
  -- When a submission is marked as approved, insert it into the businesses table
  IF NEW.status = 'approved' AND OLD.status != 'approved' THEN
    INSERT INTO public.businesses (
      name, 
      description, 
      category, 
      phone, 
      address, 
      city, 
      state, 
      owner_id, 
      email, 
      whatsapp,
      website_url,
      images,
      is_approved,
      approved_at,
      approved_by
    ) VALUES (
      NEW.name,
      NEW.description,
      NEW.category,
      NEW.phone_number,
      NEW.address,
      NEW.city,
      NEW.state,
      NEW.owner_id,
      NEW.email,
      NEW.whatsapp_number,
      NEW.website_url,
      NEW.images,
      true,
      NEW.reviewed_at,
      NEW.reviewed_by
    )
    ON CONFLICT (name, owner_id) DO NOTHING;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS trigger_approved_submission_to_businesses ON public.business_submissions;

-- Create trigger
CREATE TRIGGER trigger_approved_submission_to_businesses
AFTER UPDATE ON public.business_submissions
FOR EACH ROW
EXECUTE FUNCTION public.copy_approved_submission_to_businesses();

-- Test: Check if trigger is created
SELECT trigger_name, trigger_schema, event_object_table FROM information_schema.triggers 
WHERE trigger_name = 'trigger_approved_submission_to_businesses';
