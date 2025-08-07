
-- Add the missing columns to the resources table
ALTER TABLE public.resources 
ADD COLUMN IF NOT EXISTS discount_percent NUMERIC NOT NULL DEFAULT 0,
ADD COLUMN IF NOT EXISTS final_rate NUMERIC GENERATED ALWAYS AS (
  CASE 
    WHEN offer_rate IS NOT NULL AND offer_rate > 0 
    THEN offer_rate * (1 - discount_percent / 100.0)
    ELSE COALESCE(bid_rate, rate, 0) * (1 - discount_percent / 100.0)
  END
) STORED,
ADD COLUMN IF NOT EXISTS linked_price_codes JSONB DEFAULT '[]'::jsonb;

-- Update computed columns to use final_rate
ALTER TABLE public.resources 
DROP COLUMN IF EXISTS used_amount,
DROP COLUMN IF EXISTS wastage_amount,
DROP COLUMN IF EXISTS total_amount;

-- Add new computed columns
ALTER TABLE public.resources 
ADD COLUMN used_amount NUMERIC GENERATED ALWAYS AS (
  CASE 
    WHEN final_rate IS NOT NULL AND usage_quantity IS NOT NULL 
    THEN final_rate * usage_quantity
    WHEN final_rate IS NOT NULL AND used_quantity IS NOT NULL
    THEN final_rate * used_quantity
    ELSE 0
  END
) STORED,
ADD COLUMN wastage_amount NUMERIC GENERATED ALWAYS AS (
  CASE 
    WHEN final_rate IS NOT NULL AND usage_quantity IS NOT NULL 
    THEN final_rate * (usage_quantity * wastage_percent / 100.0)
    WHEN final_rate IS NOT NULL AND used_quantity IS NOT NULL
    THEN final_rate * (used_quantity * wastage_percent / 100.0)
    ELSE 0
  END
) STORED,
ADD COLUMN total_amount NUMERIC GENERATED ALWAYS AS (
  COALESCE(used_amount, 0) + COALESCE(wastage_amount, 0)
) STORED;

-- Create index for better performance on price code lookups
CREATE INDEX IF NOT EXISTS idx_resources_linked_price_codes 
ON public.resources USING GIN (linked_price_codes);

-- Drop and recreate the trigger to handle updated_at
DROP TRIGGER IF EXISTS update_resources_updated_at ON public.resources;
CREATE TRIGGER update_resources_updated_at
  BEFORE UPDATE ON public.resources
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();
