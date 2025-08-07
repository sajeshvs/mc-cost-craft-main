
-- Add new columns to resources table to support the new resource structure
ALTER TABLE public.resources 
ADD COLUMN offer_rate numeric NOT NULL DEFAULT 0,
ADD COLUMN offer_currency text NOT NULL DEFAULT 'USD',
ADD COLUMN bid_rate numeric NOT NULL DEFAULT 0,
ADD COLUMN usage_quantity numeric NOT NULL DEFAULT 0,
ADD COLUMN usage_amount numeric,
ADD COLUMN wastage_quantity numeric;

-- Update existing data to use new columns
UPDATE public.resources 
SET bid_rate = rate, 
    offer_rate = rate,
    usage_quantity = used_quantity,
    usage_amount = rate * used_quantity,
    wastage_quantity = (used_quantity * wastage_percent) / 100;

-- Drop old columns after data migration
ALTER TABLE public.resources 
DROP COLUMN rate,
DROP COLUMN used_quantity,
DROP COLUMN used_amount;
