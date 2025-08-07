-- Create estimation tables for BOQ estimation functionality

-- Create estimation_sheets table
CREATE TABLE public.estimation_sheets (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  boq_item_id UUID NOT NULL,
  total_rate DECIMAL(15,4) NOT NULL DEFAULT 0,
  total_amount DECIMAL(15,4) NOT NULL DEFAULT 0,
  currency VARCHAR(3) NOT NULL DEFAULT 'USD',
  notes TEXT,
  user_id UUID,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create estimation_resources table
CREATE TABLE public.estimation_resources (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  estimation_sheet_id UUID NOT NULL,
  boq_item_id UUID NOT NULL,
  resource_type VARCHAR(50) NOT NULL CHECK (resource_type IN ('Labor', 'Material', 'Equipment', 'Subcontract', 'Others')),
  resource_name VARCHAR(255) NOT NULL,
  unit VARCHAR(50) NOT NULL,
  rate DECIMAL(15,4) NOT NULL DEFAULT 0,
  coefficient DECIMAL(15,6) NOT NULL DEFAULT 1,
  total DECIMAL(15,4) NOT NULL DEFAULT 0,
  comments TEXT,
  sort_order INTEGER DEFAULT 0,
  user_id UUID,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create resource_library table
CREATE TABLE public.resource_library (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  resource_code VARCHAR(50) NOT NULL,
  resource_name VARCHAR(255) NOT NULL,
  resource_type VARCHAR(50) NOT NULL CHECK (resource_type IN ('Labor', 'Material', 'Equipment', 'Subcontract', 'Others')),
  unit VARCHAR(50) NOT NULL,
  default_rate DECIMAL(15,4) NOT NULL DEFAULT 0,
  default_productivity DECIMAL(15,6) NOT NULL DEFAULT 1,
  notes TEXT,
  user_id UUID,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create estimation_history table
CREATE TABLE public.estimation_history (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  estimation_sheet_id UUID NOT NULL,
  boq_item_id UUID NOT NULL,
  version_number INTEGER NOT NULL,
  total_rate DECIMAL(15,4) NOT NULL,
  total_amount DECIMAL(15,4) NOT NULL,
  change_summary TEXT,
  snapshot_data JSONB,
  user_id UUID,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create estimation_attachments table
CREATE TABLE public.estimation_attachments (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  estimation_sheet_id UUID,
  estimation_resource_id UUID,
  file_name VARCHAR(255) NOT NULL,
  file_size BIGINT,
  file_type VARCHAR(100),
  storage_path TEXT NOT NULL,
  user_id UUID,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create global_settings table
CREATE TABLE public.global_settings (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  setting_key VARCHAR(100) NOT NULL,
  setting_value JSONB NOT NULL,
  user_id UUID,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE(setting_key, user_id)
);

-- Enable Row Level Security
ALTER TABLE public.estimation_sheets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.estimation_resources ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.resource_library ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.estimation_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.estimation_attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.global_settings ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for estimation_sheets
CREATE POLICY "Users can view their own estimation_sheets" ON public.estimation_sheets
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own estimation_sheets" ON public.estimation_sheets
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own estimation_sheets" ON public.estimation_sheets
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own estimation_sheets" ON public.estimation_sheets
  FOR DELETE USING (auth.uid() = user_id);

-- Create RLS policies for estimation_resources
CREATE POLICY "Users can view their own estimation_resources" ON public.estimation_resources
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own estimation_resources" ON public.estimation_resources
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own estimation_resources" ON public.estimation_resources
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own estimation_resources" ON public.estimation_resources
  FOR DELETE USING (auth.uid() = user_id);

-- Create RLS policies for resource_library
CREATE POLICY "Users can view their own resource_library" ON public.resource_library
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own resource_library" ON public.resource_library
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own resource_library" ON public.resource_library
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own resource_library" ON public.resource_library
  FOR DELETE USING (auth.uid() = user_id);

-- Create RLS policies for estimation_history
CREATE POLICY "Users can view their own estimation_history" ON public.estimation_history
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own estimation_history" ON public.estimation_history
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Create RLS policies for estimation_attachments
CREATE POLICY "Users can view their own estimation_attachments" ON public.estimation_attachments
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own estimation_attachments" ON public.estimation_attachments
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own estimation_attachments" ON public.estimation_attachments
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own estimation_attachments" ON public.estimation_attachments
  FOR DELETE USING (auth.uid() = user_id);

-- Create RLS policies for global_settings
CREATE POLICY "Users can view their own global_settings" ON public.global_settings
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own global_settings" ON public.global_settings
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own global_settings" ON public.global_settings
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own global_settings" ON public.global_settings
  FOR DELETE USING (auth.uid() = user_id);

-- Create function to update timestamps
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for automatic timestamp updates
CREATE TRIGGER update_estimation_sheets_updated_at
  BEFORE UPDATE ON public.estimation_sheets
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_estimation_resources_updated_at
  BEFORE UPDATE ON public.estimation_resources
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_resource_library_updated_at
  BEFORE UPDATE ON public.resource_library
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_global_settings_updated_at
  BEFORE UPDATE ON public.global_settings
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- Create indexes for better performance
CREATE INDEX idx_estimation_sheets_boq_item_id ON public.estimation_sheets(boq_item_id);
CREATE INDEX idx_estimation_sheets_user_id ON public.estimation_sheets(user_id);
CREATE INDEX idx_estimation_resources_sheet_id ON public.estimation_resources(estimation_sheet_id);
CREATE INDEX idx_estimation_resources_boq_item_id ON public.estimation_resources(boq_item_id);
CREATE INDEX idx_estimation_resources_user_id ON public.estimation_resources(user_id);
CREATE INDEX idx_resource_library_code ON public.resource_library(resource_code);
CREATE INDEX idx_resource_library_user_id ON public.resource_library(user_id);
CREATE INDEX idx_estimation_history_sheet_id ON public.estimation_history(estimation_sheet_id);
CREATE INDEX idx_estimation_history_boq_item_id ON public.estimation_history(boq_item_id);
CREATE INDEX idx_estimation_attachments_sheet_id ON public.estimation_attachments(estimation_sheet_id);
CREATE INDEX idx_global_settings_key_user ON public.global_settings(setting_key, user_id);