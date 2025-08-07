
-- Create the price_code_analysis table that's missing
CREATE TABLE IF NOT EXISTS public.price_code_analysis (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  project_id UUID NOT NULL,
  price_code TEXT NOT NULL,
  resource_code TEXT NOT NULL,
  resource_name TEXT NOT NULL,
  category TEXT NOT NULL CHECK (category IN ('P', 'M', 'E', 'S', 'C')),
  unit TEXT NOT NULL,
  quantity NUMERIC NOT NULL DEFAULT 0,
  unit_rate NUMERIC NOT NULL DEFAULT 0,
  wastage_percent NUMERIC NOT NULL DEFAULT 0,
  total_amount NUMERIC NOT NULL DEFAULT 0,
  sort_order INTEGER DEFAULT 0,
  user_id UUID,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Add Row Level Security for price_code_analysis
ALTER TABLE public.price_code_analysis ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist to avoid conflicts
DROP POLICY IF EXISTS "Users can view their own price_code_analysis" ON public.price_code_analysis;
DROP POLICY IF EXISTS "Users can create their own price_code_analysis" ON public.price_code_analysis;
DROP POLICY IF EXISTS "Users can update their own price_code_analysis" ON public.price_code_analysis;
DROP POLICY IF EXISTS "Users can delete their own price_code_analysis" ON public.price_code_analysis;

-- Create RLS policies
CREATE POLICY "Users can view their own price_code_analysis" 
  ON public.price_code_analysis 
  FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own price_code_analysis" 
  ON public.price_code_analysis 
  FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own price_code_analysis" 
  ON public.price_code_analysis 
  FOR UPDATE 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own price_code_analysis" 
  ON public.price_code_analysis 
  FOR DELETE 
  USING (auth.uid() = user_id);

-- Add missing split rate columns to price_list table if they don't exist
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'price_list' AND column_name = 'split_labor') THEN
    ALTER TABLE public.price_list ADD COLUMN split_labor NUMERIC DEFAULT 0;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'price_list' AND column_name = 'split_material') THEN
    ALTER TABLE public.price_list ADD COLUMN split_material NUMERIC DEFAULT 0;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'price_list' AND column_name = 'split_equipment') THEN
    ALTER TABLE public.price_list ADD COLUMN split_equipment NUMERIC DEFAULT 0;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'price_list' AND column_name = 'split_subcontractor') THEN
    ALTER TABLE public.price_list ADD COLUMN split_subcontractor NUMERIC DEFAULT 0;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'price_list' AND column_name = 'split_consultant') THEN
    ALTER TABLE public.price_list ADD COLUMN split_consultant NUMERIC DEFAULT 0;
  END IF;
END $$;

-- Add price code and amount columns to boq_items table if they don't exist
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'boq_items' AND column_name = 'price_code') THEN
    ALTER TABLE public.boq_items ADD COLUMN price_code TEXT;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'boq_items' AND column_name = 'net_rate') THEN
    ALTER TABLE public.boq_items ADD COLUMN net_rate NUMERIC DEFAULT 0;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'boq_items' AND column_name = 'amount') THEN
    ALTER TABLE public.boq_items ADD COLUMN amount NUMERIC DEFAULT 0;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'boq_items' AND column_name = 'amount_labor') THEN
    ALTER TABLE public.boq_items ADD COLUMN amount_labor NUMERIC DEFAULT 0;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'boq_items' AND column_name = 'amount_material') THEN
    ALTER TABLE public.boq_items ADD COLUMN amount_material NUMERIC DEFAULT 0;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'boq_items' AND column_name = 'amount_equipment') THEN
    ALTER TABLE public.boq_items ADD COLUMN amount_equipment NUMERIC DEFAULT 0;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'boq_items' AND column_name = 'amount_subcontractor') THEN
    ALTER TABLE public.boq_items ADD COLUMN amount_subcontractor NUMERIC DEFAULT 0;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'boq_items' AND column_name = 'amount_consultant') THEN
    ALTER TABLE public.boq_items ADD COLUMN amount_consultant NUMERIC DEFAULT 0;
  END IF;
END $$;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_price_code_analysis_project_price ON public.price_code_analysis(project_id, price_code);
CREATE INDEX IF NOT EXISTS idx_boq_items_price_code ON public.boq_items(price_code);
CREATE INDEX IF NOT EXISTS idx_price_list_project_division ON public.price_list(project_id, division);

-- Add trigger to update updated_at column for price_code_analysis
DROP TRIGGER IF EXISTS update_price_code_analysis_updated_at ON public.price_code_analysis;
CREATE TRIGGER update_price_code_analysis_updated_at
  BEFORE UPDATE ON public.price_code_analysis
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- Recreate the RPC function to ensure it exists
CREATE OR REPLACE FUNCTION get_price_code_analysis(p_project_id UUID, p_price_code TEXT)
RETURNS TABLE (
  id UUID,
  project_id UUID,
  price_code TEXT,
  resource_code TEXT,
  resource_name TEXT,
  category TEXT,
  unit TEXT,
  quantity NUMERIC,
  unit_rate NUMERIC,
  wastage_percent NUMERIC,
  total_amount NUMERIC,
  sort_order INTEGER,
  user_id UUID,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    pca.id,
    pca.project_id,
    pca.price_code,
    pca.resource_code,
    pca.resource_name,
    pca.category,
    pca.unit,
    pca.quantity,
    pca.unit_rate,
    pca.wastage_percent,
    pca.total_amount,
    pca.sort_order,
    pca.user_id,
    pca.created_at,
    pca.updated_at
  FROM price_code_analysis pca
  WHERE pca.project_id = p_project_id 
    AND pca.price_code = p_price_code
    AND pca.user_id = auth.uid()
  ORDER BY pca.sort_order ASC;
END;
$$;
