
-- Create trades table for UFGS divisions and subtrades
CREATE TABLE public.trades (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  project_id UUID NOT NULL,
  division TEXT NOT NULL CHECK (division ~ '^(0[1-9]|[1-4][0-8])$'),
  subtrade_letter TEXT NOT NULL CHECK (subtrade_letter ~ '^[A-Z]$'),
  trade_code TEXT GENERATED ALWAYS AS (division || subtrade_letter) STORED,
  description TEXT NOT NULL,
  color_code TEXT DEFAULT NULL,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  user_id UUID DEFAULT auth.uid()
);

-- Add unique constraint for trade_code per project
ALTER TABLE public.trades ADD CONSTRAINT trades_project_trade_code_unique UNIQUE (project_id, trade_code);

-- Add foreign key constraint to jobs table (assuming trades belong to jobs/projects)
ALTER TABLE public.trades ADD CONSTRAINT trades_project_id_fkey 
  FOREIGN KEY (project_id) REFERENCES public.jobs(id) ON DELETE CASCADE;

-- Create indexes for performance
CREATE INDEX idx_trades_project_id ON public.trades(project_id);
CREATE INDEX idx_trades_division ON public.trades(division);
CREATE INDEX idx_trades_trade_code ON public.trades(trade_code);

-- Enable Row Level Security
ALTER TABLE public.trades ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Users can view their own trades" 
  ON public.trades 
  FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own trades" 
  ON public.trades 
  FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own trades" 
  ON public.trades 
  FOR UPDATE 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own trades" 
  ON public.trades 
  FOR DELETE 
  USING (auth.uid() = user_id);

-- Create trigger to update updated_at column
CREATE TRIGGER update_trades_updated_at
  BEFORE UPDATE ON public.trades
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- Insert default UFGS divisions and subtrades data
INSERT INTO public.trades (project_id, division, subtrade_letter, description, user_id, sort_order) VALUES
-- Division 03 - Concrete
('00000000-0000-0000-0000-000000000000', '03', 'A', 'Reinforced Concrete', auth.uid(), 1),
('00000000-0000-0000-0000-000000000000', '03', 'B', 'Concrete Sealers', auth.uid(), 2),
('00000000-0000-0000-0000-000000000000', '03', 'C', 'Concrete Formwork', auth.uid(), 3),

-- Division 04 - Masonry
('00000000-0000-0000-0000-000000000000', '04', 'A', 'Unit Masonry', auth.uid(), 4),
('00000000-0000-0000-0000-000000000000', '04', 'B', 'Structural Stone', auth.uid(), 5),
('00000000-0000-0000-0000-000000000000', '04', 'C', 'Stone Cladding', auth.uid(), 6),

-- Division 07 - Thermal & Moisture Protection
('00000000-0000-0000-0000-000000000000', '07', 'A', 'Waterproofing', auth.uid(), 7),
('00000000-0000-0000-0000-000000000000', '07', 'B', 'Roofing', auth.uid(), 8),
('00000000-0000-0000-0000-000000000000', '07', 'C', 'Insulation', auth.uid(), 9),
('00000000-0000-0000-0000-000000000000', '07', 'D', 'Firestopping', auth.uid(), 10),
('00000000-0000-0000-0000-000000000000', '07', 'E', 'Air Barrier', auth.uid(), 11);
