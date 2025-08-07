
-- Add user_id column to companies table
ALTER TABLE public.companies 
ADD COLUMN user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;

-- Add user_id column to jobs table  
ALTER TABLE public.jobs 
ADD COLUMN user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;

-- Add user_id column to boq_items table
ALTER TABLE public.boq_items 
ADD COLUMN user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;

-- Update companies RLS policies
DROP POLICY IF EXISTS "Authenticated users can manage companies" ON public.companies;

CREATE POLICY "Users can view their own companies" 
ON public.companies FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own companies" 
ON public.companies FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own companies" 
ON public.companies FOR UPDATE 
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own companies" 
ON public.companies FOR DELETE 
USING (auth.uid() = user_id);

-- Update jobs RLS policies
DROP POLICY IF EXISTS "Authenticated users can manage jobs" ON public.jobs;

CREATE POLICY "Users can view their own jobs" 
ON public.jobs FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own jobs" 
ON public.jobs FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own jobs" 
ON public.jobs FOR UPDATE 
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own jobs" 
ON public.jobs FOR DELETE 
USING (auth.uid() = user_id);

-- Update boq_items RLS policies
DROP POLICY IF EXISTS "Authenticated users can manage boq_items" ON public.boq_items;

CREATE POLICY "Users can view their own boq_items" 
ON public.boq_items FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own boq_items" 
ON public.boq_items FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own boq_items" 
ON public.boq_items FOR UPDATE 
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own boq_items" 
ON public.boq_items FOR DELETE 
USING (auth.uid() = user_id);
