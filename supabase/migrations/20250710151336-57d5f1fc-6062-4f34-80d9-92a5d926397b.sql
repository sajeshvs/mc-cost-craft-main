
-- Create Resource Library table
CREATE TABLE public.resource_library (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  resource_code TEXT NOT NULL,
  resource_name TEXT NOT NULL,
  resource_type TEXT NOT NULL CHECK (resource_type IN ('Labor', 'Material', 'Equipment', 'Subcontract', 'Others')),
  unit TEXT NOT NULL,
  default_rate NUMERIC DEFAULT 0,
  default_productivity NUMERIC DEFAULT 1,
  notes TEXT,
  user_id UUID REFERENCES auth.users,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE(resource_code, user_id)
);

-- Enable RLS for resource_library
ALTER TABLE public.resource_library ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for resource_library
CREATE POLICY "Users can view their own resources" 
  ON public.resource_library 
  FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own resources" 
  ON public.resource_library 
  FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own resources" 
  ON public.resource_library 
  FOR UPDATE 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own resources" 
  ON public.resource_library 
  FOR DELETE 
  USING (auth.uid() = user_id);

-- Add comments column to estimation_resources for per-resource comments
ALTER TABLE public.estimation_resources ADD COLUMN comments TEXT;

-- Create estimation_history table for audit logs
CREATE TABLE public.estimation_history (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  estimation_sheet_id UUID NOT NULL,
  boq_item_id UUID NOT NULL,
  version_number INTEGER NOT NULL DEFAULT 1,
  total_rate NUMERIC NOT NULL DEFAULT 0,
  total_amount NUMERIC NOT NULL DEFAULT 0,
  change_summary TEXT,
  snapshot_data JSONB,
  user_id UUID REFERENCES auth.users,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable RLS for estimation_history
ALTER TABLE public.estimation_history ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for estimation_history
CREATE POLICY "Users can view their own estimation history" 
  ON public.estimation_history 
  FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own estimation history" 
  ON public.estimation_history 
  FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

-- Create attachments table for file uploads
CREATE TABLE public.estimation_attachments (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  estimation_sheet_id UUID,
  estimation_resource_id UUID,
  file_name TEXT NOT NULL,
  file_size INTEGER,
  file_type TEXT,
  storage_path TEXT NOT NULL,
  user_id UUID REFERENCES auth.users,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable RLS for estimation_attachments
ALTER TABLE public.estimation_attachments ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for estimation_attachments
CREATE POLICY "Users can view their own attachments" 
  ON public.estimation_attachments 
  FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own attachments" 
  ON public.estimation_attachments 
  FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own attachments" 
  ON public.estimation_attachments 
  FOR DELETE 
  USING (auth.uid() = user_id);

-- Create global_settings table for currency and other settings
CREATE TABLE public.global_settings (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  setting_key TEXT NOT NULL,
  setting_value JSONB NOT NULL,
  user_id UUID REFERENCES auth.users,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE(setting_key, user_id)
);

-- Enable RLS for global_settings
ALTER TABLE public.global_settings ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for global_settings
CREATE POLICY "Users can view their own settings" 
  ON public.global_settings 
  FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own settings" 
  ON public.global_settings 
  FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own settings" 
  ON public.global_settings 
  FOR UPDATE 
  USING (auth.uid() = user_id);

-- Create storage bucket for estimation attachments
INSERT INTO storage.buckets (id, name, public) 
VALUES ('estimation-attachments', 'estimation-attachments', true);

-- Create storage policies for estimation attachments
CREATE POLICY "Users can upload their own files" 
  ON storage.objects 
  FOR INSERT 
  WITH CHECK (bucket_id = 'estimation-attachments' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can view their own files" 
  ON storage.objects 
  FOR SELECT 
  USING (bucket_id = 'estimation-attachments');

CREATE POLICY "Users can delete their own files" 
  ON storage.objects 
  FOR DELETE 
  USING (bucket_id = 'estimation-attachments' AND auth.uid()::text = (storage.foldername(name))[1]);
