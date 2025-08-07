
-- Create companies table
CREATE TABLE public.companies (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  code TEXT NOT NULL UNIQUE,
  country TEXT NOT NULL,
  base_currency TEXT NOT NULL,
  logo_url TEXT,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create jobs table
CREATE TABLE public.jobs (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  company_id UUID REFERENCES public.companies(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  client TEXT NOT NULL,
  project_location TEXT NOT NULL,
  currency TEXT NOT NULL,
  logo_url TEXT,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create boq_items table
CREATE TABLE public.boq_items (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  job_id UUID REFERENCES public.jobs(id) ON DELETE CASCADE NOT NULL,
  item_no TEXT NOT NULL,
  description TEXT NOT NULL,
  unit TEXT NOT NULL,
  quantity DECIMAL(15,4) DEFAULT 0,
  level_type TEXT DEFAULT 'item', -- 'item', 'level_1', 'level_2', ..., 'level_9', 'comment'
  page_number INTEGER,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Add Row Level Security (RLS)
ALTER TABLE public.companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.boq_items ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for companies (temporarily allowing all authenticated users)
CREATE POLICY "Authenticated users can manage companies" 
  ON public.companies 
  FOR ALL 
  USING (auth.role() = 'authenticated');

-- Create RLS policies for jobs
CREATE POLICY "Authenticated users can manage jobs" 
  ON public.jobs 
  FOR ALL 
  USING (auth.role() = 'authenticated');

-- Create RLS policies for boq_items
CREATE POLICY "Authenticated users can manage boq_items" 
  ON public.boq_items 
  FOR ALL 
  USING (auth.role() = 'authenticated');

-- Create indexes for better performance
CREATE INDEX idx_jobs_company_id ON public.jobs(company_id);
CREATE INDEX idx_boq_items_job_id ON public.boq_items(job_id);
CREATE INDEX idx_boq_items_sort_order ON public.boq_items(job_id, sort_order);
