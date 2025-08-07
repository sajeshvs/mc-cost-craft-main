
-- Create a function to get price code analysis data
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
