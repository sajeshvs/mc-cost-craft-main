
-- Remove the generated column constraints that are causing insert/update errors
ALTER TABLE public.resources 
DROP COLUMN IF EXISTS used_amount,
DROP COLUMN IF EXISTS wastage_amount,
DROP COLUMN IF EXISTS total_amount;

-- Add these columns back as regular numeric columns (not generated)
ALTER TABLE public.resources 
ADD COLUMN used_amount numeric,
ADD COLUMN wastage_amount numeric,
ADD COLUMN total_amount numeric;

-- Update the migration columns to work with regular inserts/updates
-- Remove the generated constraints from the new columns if they exist
ALTER TABLE public.resources 
ALTER COLUMN offer_rate DROP DEFAULT,
ALTER COLUMN offer_rate SET DEFAULT 0,
ALTER COLUMN bid_rate DROP DEFAULT, 
ALTER COLUMN bid_rate SET DEFAULT 0,
ALTER COLUMN usage_quantity DROP DEFAULT,
ALTER COLUMN usage_quantity SET DEFAULT 0,
ALTER COLUMN usage_amount DROP DEFAULT,
ALTER COLUMN usage_amount SET DEFAULT 0,
ALTER COLUMN wastage_quantity DROP DEFAULT,
ALTER COLUMN wastage_quantity SET DEFAULT 0,
ALTER COLUMN wastage_amount DROP DEFAULT,
ALTER COLUMN wastage_amount SET DEFAULT 0,
ALTER COLUMN total_amount DROP DEFAULT,
ALTER COLUMN total_amount SET DEFAULT 0;
