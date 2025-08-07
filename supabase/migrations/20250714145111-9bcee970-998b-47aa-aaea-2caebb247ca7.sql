
-- First, let's check and fix the resources table structure
-- Remove any generated column constraints that are causing issues
ALTER TABLE public.resources 
ALTER COLUMN used_amount DROP DEFAULT,
ALTER COLUMN wastage_amount DROP DEFAULT, 
ALTER COLUMN total_amount DROP DEFAULT;

-- Make sure these are regular columns, not generated
ALTER TABLE public.resources 
ALTER COLUMN used_amount SET DEFAULT 0,
ALTER COLUMN wastage_amount SET DEFAULT 0,
ALTER COLUMN total_amount SET DEFAULT 0;

-- Add missing columns from the migration if they don't exist
DO $$ 
BEGIN
    -- Add offer_rate if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'resources' AND column_name = 'offer_rate') THEN
        ALTER TABLE public.resources ADD COLUMN offer_rate numeric NOT NULL DEFAULT 0;
    END IF;
    
    -- Add offer_currency if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'resources' AND column_name = 'offer_currency') THEN
        ALTER TABLE public.resources ADD COLUMN offer_currency text NOT NULL DEFAULT 'USD';
    END IF;
    
    -- Add bid_rate if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'resources' AND column_name = 'bid_rate') THEN
        ALTER TABLE public.resources ADD COLUMN bid_rate numeric NOT NULL DEFAULT 0;
    END IF;
    
    -- Add usage_quantity if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'resources' AND column_name = 'usage_quantity') THEN
        ALTER TABLE public.resources ADD COLUMN usage_quantity numeric NOT NULL DEFAULT 0;
    END IF;
    
    -- Add usage_amount if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'resources' AND column_name = 'usage_amount') THEN
        ALTER TABLE public.resources ADD COLUMN usage_amount numeric DEFAULT 0;
    END IF;
    
    -- Add wastage_quantity if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'resources' AND column_name = 'wastage_quantity') THEN
        ALTER TABLE public.resources ADD COLUMN wastage_quantity numeric DEFAULT 0;
    END IF;
END $$;

-- Update existing data to populate the new columns
UPDATE public.resources 
SET 
    bid_rate = COALESCE(rate, 0),
    offer_rate = COALESCE(rate, 0),
    usage_quantity = COALESCE(used_quantity, 0),
    usage_amount = COALESCE(used_amount, rate * used_quantity, 0),
    wastage_quantity = COALESCE((used_quantity * wastage_percent) / 100, 0)
WHERE bid_rate IS NULL OR offer_rate IS NULL OR usage_quantity IS NULL;

-- Update wastage_amount and total_amount
UPDATE public.resources 
SET 
    wastage_amount = COALESCE(bid_rate * wastage_quantity, 0),
    total_amount = COALESCE(usage_amount + (bid_rate * wastage_quantity), 0)
WHERE wastage_amount IS NULL OR total_amount IS NULL;
