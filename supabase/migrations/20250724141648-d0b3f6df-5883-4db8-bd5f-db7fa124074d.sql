
-- Create adjudication_packages table
CREATE TABLE public.adjudication_packages (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  project_id UUID NOT NULL,
  name TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('subcontractor', 'supplier')),
  trade_code TEXT,
  created_by UUID NOT NULL DEFAULT auth.uid(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'finalized')),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  user_id UUID DEFAULT auth.uid()
);

-- Create adjudication_entries table
CREATE TABLE public.adjudication_entries (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  package_id UUID NOT NULL REFERENCES adjudication_packages(id) ON DELETE CASCADE,
  item_type TEXT NOT NULL CHECK (item_type IN ('BOQ', 'Resource')),
  source_id UUID NOT NULL,
  trade_code TEXT,
  page_ref TEXT,
  description TEXT NOT NULL,
  quantity NUMERIC NOT NULL DEFAULT 0,
  unit TEXT NOT NULL,
  base_rate NUMERIC NOT NULL DEFAULT 0,
  price_code TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  user_id UUID DEFAULT auth.uid()
);

-- Create adjudication_quotes table
CREATE TABLE public.adjudication_quotes (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  entry_id UUID NOT NULL REFERENCES adjudication_entries(id) ON DELETE CASCADE,
  vendor_name TEXT NOT NULL,
  currency TEXT NOT NULL DEFAULT 'USD',
  exchange_rate NUMERIC NOT NULL DEFAULT 1,
  quoted_rate NUMERIC NOT NULL DEFAULT 0,
  discount_percent NUMERIC NOT NULL DEFAULT 0,
  factor NUMERIC NOT NULL DEFAULT 1,
  final_rate NUMERIC NOT NULL DEFAULT 0,
  amount NUMERIC NOT NULL DEFAULT 0,
  is_selected BOOLEAN NOT NULL DEFAULT false,
  applied_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  user_id UUID DEFAULT auth.uid()
);

-- Add RLS policies for adjudication_packages
ALTER TABLE public.adjudication_packages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own adjudication_packages" 
  ON public.adjudication_packages 
  FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own adjudication_packages" 
  ON public.adjudication_packages 
  FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own adjudication_packages" 
  ON public.adjudication_packages 
  FOR UPDATE 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own adjudication_packages" 
  ON public.adjudication_packages 
  FOR DELETE 
  USING (auth.uid() = user_id);

-- Add RLS policies for adjudication_entries
ALTER TABLE public.adjudication_entries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own adjudication_entries" 
  ON public.adjudication_entries 
  FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own adjudication_entries" 
  ON public.adjudication_entries 
  FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own adjudication_entries" 
  ON public.adjudication_entries 
  FOR UPDATE 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own adjudication_entries" 
  ON public.adjudication_entries 
  FOR DELETE 
  USING (auth.uid() = user_id);

-- Add RLS policies for adjudication_quotes
ALTER TABLE public.adjudication_quotes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own adjudication_quotes" 
  ON public.adjudication_quotes 
  FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own adjudication_quotes" 
  ON public.adjudication_quotes 
  FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own adjudication_quotes" 
  ON public.adjudication_quotes 
  FOR UPDATE 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own adjudication_quotes" 
  ON public.adjudication_quotes 
  FOR DELETE 
  USING (auth.uid() = user_id);

-- Add triggers for updated_at
CREATE TRIGGER update_adjudication_packages_updated_at
  BEFORE UPDATE ON public.adjudication_packages
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_adjudication_quotes_updated_at
  BEFORE UPDATE ON public.adjudication_quotes
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();
