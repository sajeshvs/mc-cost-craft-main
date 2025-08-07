
-- Create price_list table with UFGS-based structure
CREATE TABLE public.price_list (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  project_id UUID NOT NULL,
  division TEXT NOT NULL,
  trade_code TEXT,
  price_code TEXT NOT NULL,
  description TEXT NOT NULL,
  unit TEXT NOT NULL DEFAULT 'EA',
  unit_rate NUMERIC NOT NULL DEFAULT 0,
  boq_reference JSONB DEFAULT '[]'::jsonb,
  sort_order INTEGER DEFAULT 0,
  user_id UUID,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  CONSTRAINT unique_price_code_per_project UNIQUE(project_id, price_code)
);

-- Add Row Level Security (RLS)
ALTER TABLE public.price_list ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Users can view their own price_list" 
  ON public.price_list 
  FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own price_list" 
  ON public.price_list 
  FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own price_list" 
  ON public.price_list 
  FOR UPDATE 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own price_list" 
  ON public.price_list 
  FOR DELETE 
  USING (auth.uid() = user_id);

-- Add trigger for updated_at
CREATE TRIGGER update_price_list_updated_at
  BEFORE UPDATE ON public.price_list
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- Add index for performance
CREATE INDEX idx_price_list_project_division ON public.price_list(project_id, division);
CREATE INDEX idx_price_list_price_code ON public.price_list(price_code);
