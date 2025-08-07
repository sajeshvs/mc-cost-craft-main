
-- Add missing columns to resources table to match the TypeScript interface
ALTER TABLE public.resources 
ADD COLUMN IF NOT EXISTS offer_rate numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS offer_currency text DEFAULT 'USD',
ADD COLUMN IF NOT EXISTS bid_rate numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS usage_quantity numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS usage_amount numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS wastage_quantity numeric DEFAULT 0;

-- Update existing records to populate the new columns with sensible defaults
UPDATE public.resources 
SET 
  offer_rate = COALESCE(rate, 0),
  bid_rate = COALESCE(rate, 0),
  usage_quantity = COALESCE(used_quantity, 0),
  usage_amount = COALESCE(used_amount, rate * used_quantity, 0),
  wastage_quantity = COALESCE((used_quantity * wastage_percent) / 100, 0)
WHERE offer_rate IS NULL OR bid_rate IS NULL OR usage_quantity IS NULL;
