
-- Create enum types for markup workflow
CREATE TYPE markup_status AS ENUM ('draft', 'submitted', 'approved', 'archived');
CREATE TYPE markup_mode AS ENUM ('trade', 'item');

-- Create markup_versions table
CREATE TABLE public.markup_versions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  project_id UUID NOT NULL,
  mode markup_mode NOT NULL,
  status markup_status NOT NULL DEFAULT 'draft',
  created_by UUID NOT NULL DEFAULT auth.uid(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  approved_by UUID,
  approved_at TIMESTAMP WITH TIME ZONE,
  remarks TEXT,
  version_number INTEGER NOT NULL,
  user_id UUID DEFAULT auth.uid(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create markup_lines table
CREATE TABLE public.markup_lines (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  version_id UUID NOT NULL REFERENCES markup_versions(id) ON DELETE CASCADE,
  ref_id TEXT NOT NULL, -- trade_code or boq_ref
  ref_description TEXT NOT NULL,
  base_rate NUMERIC NOT NULL DEFAULT 0,
  site_overhead_percent NUMERIC NOT NULL DEFAULT 0,
  ho_ga_percent NUMERIC NOT NULL DEFAULT 0,
  profit_percent NUMERIC NOT NULL DEFAULT 0,
  contingencies_percent NUMERIC NOT NULL DEFAULT 0,
  escalation_percent NUMERIC NOT NULL DEFAULT 0,
  tax_percent NUMERIC NOT NULL DEFAULT 0,
  total_markup_value NUMERIC NOT NULL DEFAULT 0,
  grand_total NUMERIC NOT NULL DEFAULT 0,
  tax_amount NUMERIC NOT NULL DEFAULT 0,
  final_total NUMERIC NOT NULL DEFAULT 0,
  remarks TEXT,
  user_id UUID DEFAULT auth.uid(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Add RLS policies for markup_versions
ALTER TABLE public.markup_versions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own markup_versions" 
  ON public.markup_versions 
  FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own markup_versions" 
  ON public.markup_versions 
  FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own markup_versions" 
  ON public.markup_versions 
  FOR UPDATE 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own markup_versions" 
  ON public.markup_versions 
  FOR DELETE 
  USING (auth.uid() = user_id);

-- Add RLS policies for markup_lines
ALTER TABLE public.markup_lines ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own markup_lines" 
  ON public.markup_lines 
  FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own markup_lines" 
  ON public.markup_lines 
  FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own markup_lines" 
  ON public.markup_lines 
  FOR UPDATE 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own markup_lines" 
  ON public.markup_lines 
  FOR DELETE 
  USING (auth.uid() = user_id);

-- Add unique constraint for version numbers per project and mode
ALTER TABLE public.markup_versions 
ADD CONSTRAINT unique_version_per_project_mode 
UNIQUE (project_id, mode, version_number);

-- Add trigger to auto-increment version numbers
CREATE OR REPLACE FUNCTION public.set_markup_version_number()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.version_number IS NULL THEN
    SELECT COALESCE(MAX(version_number), 0) + 1
    INTO NEW.version_number
    FROM public.markup_versions
    WHERE project_id = NEW.project_id AND mode = NEW.mode;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_markup_version_number_trigger
  BEFORE INSERT ON public.markup_versions
  FOR EACH ROW
  EXECUTE FUNCTION public.set_markup_version_number();

-- Add updated_at triggers
CREATE TRIGGER update_markup_versions_updated_at
  BEFORE UPDATE ON public.markup_versions
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_markup_lines_updated_at
  BEFORE UPDATE ON public.markup_lines
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();
