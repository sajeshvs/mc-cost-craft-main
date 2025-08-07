
-- Add new table for price code analysis (Rate Analysis Sheet data)
CREATE TABLE public.price_code_analysis (
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

-- Add split rate columns to price_list table
ALTER TABLE public.price_list ADD COLUMN split_labor NUMERIC DEFAULT 0;
ALTER TABLE public.price_list ADD COLUMN split_material NUMERIC DEFAULT 0;
ALTER TABLE public.price_list ADD COLUMN split_equipment NUMERIC DEFAULT 0;
ALTER TABLE public.price_list ADD COLUMN split_subcontractor NUMERIC DEFAULT 0;
ALTER TABLE public.price_list ADD COLUMN split_consultant NUMERIC DEFAULT 0;

-- Add price code and amount columns to boq_items table
ALTER TABLE public.boq_items ADD COLUMN price_code TEXT;
ALTER TABLE public.boq_items ADD COLUMN net_rate NUMERIC DEFAULT 0;
ALTER TABLE public.boq_items ADD COLUMN amount NUMERIC DEFAULT 0;
ALTER TABLE public.boq_items ADD COLUMN amount_labor NUMERIC DEFAULT 0;
ALTER TABLE public.boq_items ADD COLUMN amount_material NUMERIC DEFAULT 0;
ALTER TABLE public.boq_items ADD COLUMN amount_equipment NUMERIC DEFAULT 0;
ALTER TABLE public.boq_items ADD COLUMN amount_subcontractor NUMERIC DEFAULT 0;
ALTER TABLE public.boq_items ADD COLUMN amount_consultant NUMERIC DEFAULT 0;

-- Create indexes for better performance
CREATE INDEX idx_price_code_analysis_project_price ON public.price_code_analysis(project_id, price_code);
CREATE INDEX idx_boq_items_price_code ON public.boq_items(price_code);
CREATE INDEX idx_price_list_project_division ON public.price_list(project_id, division);

-- Add trigger to update updated_at column for price_code_analysis
CREATE TRIGGER update_price_code_analysis_updated_at
  BEFORE UPDATE ON public.price_code_analysis
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();
