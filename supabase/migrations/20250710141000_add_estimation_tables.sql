
-- Create estimation_sheets table to store BOQ item estimations
CREATE TABLE public.estimation_sheets (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  boq_item_id UUID REFERENCES public.boq_items(id) ON DELETE CASCADE NOT NULL,
  total_rate DECIMAL(15,4) DEFAULT 0,
  total_amount DECIMAL(15,4) DEFAULT 0,
  currency TEXT DEFAULT 'USD',
  notes TEXT,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE(boq_item_id)
);

-- Create estimation_resources table for resource breakdown
CREATE TABLE public.estimation_resources (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  estimation_sheet_id UUID REFERENCES public.estimation_sheets(id) ON DELETE CASCADE NOT NULL,
  resource_type TEXT NOT NULL CHECK (resource_type IN ('Labor', 'Material', 'Equipment', 'Subcontract', 'Others')),
  resource_name TEXT NOT NULL,
  unit TEXT NOT NULL,
  rate DECIMAL(15,4) DEFAULT 0,
  coefficient DECIMAL(15,4) DEFAULT 1,
  total DECIMAL(15,4) DEFAULT 0,
  comments TEXT,
  sort_order INTEGER DEFAULT 0,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.estimation_sheets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.estimation_resources ENABLE ROW LEVEL SECURITY;

-- RLS policies for estimation_sheets
CREATE POLICY "Users can view their own estimation_sheets"
  ON public.estimation_sheets FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own estimation_sheets"
  ON public.estimation_sheets FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own estimation_sheets"
  ON public.estimation_sheets FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own estimation_sheets"
  ON public.estimation_sheets FOR DELETE
  USING (auth.uid() = user_id);

-- RLS policies for estimation_resources
CREATE POLICY "Users can view their own estimation_resources"
  ON public.estimation_resources FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own estimation_resources"
  ON public.estimation_resources FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own estimation_resources"
  ON public.estimation_resources FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own estimation_resources"
  ON public.estimation_resources FOR DELETE
  USING (auth.uid() = user_id);

-- Create indexes for performance
CREATE INDEX idx_estimation_sheets_boq_item_id ON public.estimation_sheets(boq_item_id);
CREATE INDEX idx_estimation_resources_sheet_id ON public.estimation_resources(estimation_sheet_id);
CREATE INDEX idx_estimation_resources_sort_order ON public.estimation_resources(estimation_sheet_id, sort_order);
