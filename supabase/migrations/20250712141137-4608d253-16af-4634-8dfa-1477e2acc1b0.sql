
-- Create the resources table
CREATE TABLE public.resources (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  project_id UUID NOT NULL,
  resource_code TEXT NOT NULL,
  category TEXT NOT NULL CHECK (category IN ('P', 'M', 'E', 'S', 'C')),
  division TEXT NOT NULL,
  resource_name TEXT NOT NULL,
  unit TEXT NOT NULL DEFAULT 'EA',
  rate NUMERIC NOT NULL DEFAULT 0,
  used_quantity NUMERIC NOT NULL DEFAULT 0,
  used_amount NUMERIC GENERATED ALWAYS AS (rate * used_quantity) STORED,
  wastage_percent NUMERIC NOT NULL DEFAULT 0,
  wastage_amount NUMERIC GENERATED ALWAYS AS ((rate * used_quantity) * (wastage_percent / 100)) STORED,
  total_amount NUMERIC GENERATED ALWAYS AS ((rate * used_quantity) + ((rate * used_quantity) * (wastage_percent / 100))) STORED,
  sort_order INTEGER NOT NULL DEFAULT 0,
  user_id UUID,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Add unique constraint for resource_code per project
ALTER TABLE public.resources ADD CONSTRAINT unique_resource_code_per_project 
UNIQUE (project_id, resource_code);

-- Create index for better performance
CREATE INDEX idx_resources_project_category_division 
ON public.resources (project_id, category, division);

-- Enable Row Level Security
ALTER TABLE public.resources ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Users can view their own resources" 
ON public.resources FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own resources" 
ON public.resources FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own resources" 
ON public.resources FOR UPDATE 
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own resources" 
ON public.resources FOR DELETE 
USING (auth.uid() = user_id);

-- Create trigger for updated_at
CREATE TRIGGER update_resources_updated_at
  BEFORE UPDATE ON public.resources
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();
