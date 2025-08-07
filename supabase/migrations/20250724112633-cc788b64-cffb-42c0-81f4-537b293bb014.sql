
-- Create table for subcontractor quotes
CREATE TABLE public.subcontractor_quotes (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  project_id UUID NOT NULL,
  boq_item_id UUID NOT NULL,
  trade_code TEXT NOT NULL,
  price_code TEXT,
  description TEXT NOT NULL,
  quantity NUMERIC NOT NULL DEFAULT 0,
  base_rate NUMERIC NOT NULL DEFAULT 0,
  quote_vendor TEXT NOT NULL,
  quote_value NUMERIC NOT NULL DEFAULT 0,
  discount_percent NUMERIC NOT NULL DEFAULT 0,
  factor NUMERIC NOT NULL DEFAULT 1,
  final_rate NUMERIC NOT NULL DEFAULT 0,
  selected BOOLEAN NOT NULL DEFAULT false,
  inserted_to_boq BOOLEAN NOT NULL DEFAULT false,
  created_by UUID NOT NULL DEFAULT auth.uid(),
  user_id UUID DEFAULT auth.uid(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create table for supplier quotes
CREATE TABLE public.supplier_quotes (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  project_id UUID NOT NULL,
  resource_id UUID NOT NULL,
  vendor_name TEXT NOT NULL,
  quote_value NUMERIC NOT NULL DEFAULT 0,
  discount_percent NUMERIC NOT NULL DEFAULT 0,
  factor NUMERIC NOT NULL DEFAULT 1,
  final_rate NUMERIC NOT NULL DEFAULT 0,
  selected BOOLEAN NOT NULL DEFAULT false,
  inserted_to_resources BOOLEAN NOT NULL DEFAULT false,
  created_by UUID NOT NULL DEFAULT auth.uid(),
  user_id UUID DEFAULT auth.uid(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Add RLS policies for subcontractor_quotes
ALTER TABLE public.subcontractor_quotes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own subcontractor_quotes" 
  ON public.subcontractor_quotes 
  FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own subcontractor_quotes" 
  ON public.subcontractor_quotes 
  FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own subcontractor_quotes" 
  ON public.subcontractor_quotes 
  FOR UPDATE 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own subcontractor_quotes" 
  ON public.subcontractor_quotes 
  FOR DELETE 
  USING (auth.uid() = user_id);

-- Add RLS policies for supplier_quotes
ALTER TABLE public.supplier_quotes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own supplier_quotes" 
  ON public.supplier_quotes 
  FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own supplier_quotes" 
  ON public.supplier_quotes 
  FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own supplier_quotes" 
  ON public.supplier_quotes 
  FOR UPDATE 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own supplier_quotes" 
  ON public.supplier_quotes 
  FOR DELETE 
  USING (auth.uid() = user_id);

-- Add triggers for updated_at timestamps
CREATE TRIGGER update_subcontractor_quotes_updated_at 
  BEFORE UPDATE ON public.subcontractor_quotes 
  FOR EACH ROW 
  EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_supplier_quotes_updated_at 
  BEFORE UPDATE ON public.supplier_quotes 
  FOR EACH ROW 
  EXECUTE FUNCTION public.update_updated_at_column();
