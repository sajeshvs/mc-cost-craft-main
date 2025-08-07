
-- Create price_code_versions table for tracking rate sheet revisions
CREATE TABLE public.price_code_versions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  price_code TEXT NOT NULL,
  project_id UUID NOT NULL,
  version_number INTEGER NOT NULL DEFAULT 1,
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'submitted', 'approved')),
  change_summary TEXT,
  created_by UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  approved_by UUID,
  approved_at TIMESTAMP WITH TIME ZONE,
  UNIQUE(project_id, price_code, version_number)
);

-- Add Row Level Security (RLS) to price_code_versions
ALTER TABLE public.price_code_versions ENABLE ROW LEVEL SECURITY;

-- Create policies for price_code_versions
CREATE POLICY "Users can view their own price_code_versions" 
  ON public.price_code_versions 
  FOR SELECT 
  USING (created_by = auth.uid());

CREATE POLICY "Users can create their own price_code_versions" 
  ON public.price_code_versions 
  FOR INSERT 
  WITH CHECK (created_by = auth.uid());

CREATE POLICY "Users can update their own price_code_versions" 
  ON public.price_code_versions 
  FOR UPDATE 
  USING (created_by = auth.uid());

CREATE POLICY "Users can delete their own price_code_versions" 
  ON public.price_code_versions 
  FOR DELETE 
  USING (created_by = auth.uid());

-- Add version_id to price_code_analysis table to link to versions
ALTER TABLE public.price_code_analysis
ADD COLUMN version_id UUID REFERENCES public.price_code_versions(id) ON DELETE CASCADE;

-- Create function to get active rate analysis data with version info
CREATE OR REPLACE FUNCTION get_active_rate_analysis(p_project_id UUID, p_price_code TEXT)
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
  version_id UUID,
  version_number INTEGER,
  status TEXT,
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
    pca.version_id,
    pcv.version_number,
    pcv.status,
    pca.user_id,
    pca.created_at,
    pca.updated_at
  FROM price_code_analysis pca
  JOIN price_code_versions pcv ON pca.version_id = pcv.id
  WHERE pca.project_id = p_project_id 
    AND pca.price_code = p_price_code
    AND pcv.status = 'approved'
    AND pca.user_id = auth.uid()
  ORDER BY pca.sort_order ASC;
END;
$$;

-- Create function to get draft rate analysis data
CREATE OR REPLACE FUNCTION get_draft_rate_analysis(p_project_id UUID, p_price_code TEXT)
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
  version_id UUID,
  version_number INTEGER,
  status TEXT,
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
    pca.version_id,
    pcv.version_number,
    pcv.status,
    pca.user_id,
    pca.created_at,
    pca.updated_at
  FROM price_code_analysis pca
  JOIN price_code_versions pcv ON pca.version_id = pcv.id
  WHERE pca.project_id = p_project_id 
    AND pca.price_code = p_price_code
    AND pcv.status = 'draft'
    AND pca.user_id = auth.uid()
  ORDER BY pca.sort_order ASC;
END;
$$;
