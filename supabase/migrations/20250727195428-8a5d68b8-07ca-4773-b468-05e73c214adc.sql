
-- Create markup_items table
CREATE TABLE public.markup_items (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  project_id UUID NOT NULL,
  ref_type TEXT NOT NULL CHECK (ref_type IN ('trade', 'item')),
  ref_id TEXT NOT NULL,
  ref_description TEXT NOT NULL,
  base_amount NUMERIC NOT NULL DEFAULT 0,
  markup_type TEXT NOT NULL CHECK (markup_type IN ('Overhead', 'Profit', 'Risk', 'Escalation', 'Rounding', 'Other')),
  markup_percent NUMERIC NOT NULL DEFAULT 0,
  markup_value NUMERIC NOT NULL DEFAULT 0,
  total_with_markup NUMERIC NOT NULL DEFAULT 0,
  remarks TEXT,
  user_id UUID REFERENCES auth.users,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Add Row Level Security (RLS)
ALTER TABLE public.markup_items ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Users can view their own markup_items" 
  ON public.markup_items 
  FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own markup_items" 
  ON public.markup_items 
  FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own markup_items" 
  ON public.markup_items 
  FOR UPDATE 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own markup_items" 
  ON public.markup_items 
  FOR DELETE 
  USING (auth.uid() = user_id);

-- Create trigger to update updated_at column
CREATE TRIGGER update_markup_items_updated_at
  BEFORE UPDATE ON public.markup_items
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- Create indexes for better performance
CREATE INDEX idx_markup_items_project_id ON public.markup_items(project_id);
CREATE INDEX idx_markup_items_user_id ON public.markup_items(user_id);
CREATE INDEX idx_markup_items_ref_type ON public.markup_items(ref_type);
CREATE INDEX idx_markup_items_markup_type ON public.markup_items(markup_type);
