
-- Add the missing dod_reference column to resource_library table
ALTER TABLE public.resource_library 
ADD COLUMN IF NOT EXISTS dod_reference text;

-- Update the column to allow storing DoD reference information
UPDATE public.resource_library 
SET dod_reference = 'Standard DoD Resource' 
WHERE dod_reference IS NULL;
