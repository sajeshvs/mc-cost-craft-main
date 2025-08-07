-- Create storage bucket for estimation attachments
INSERT INTO storage.buckets (id, name, public) VALUES ('estimation-attachments', 'estimation-attachments', false);

-- Create storage policies for estimation attachments
CREATE POLICY "Users can view their own estimation attachments" 
ON storage.objects 
FOR SELECT 
USING (bucket_id = 'estimation-attachments' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can upload their own estimation attachments" 
ON storage.objects 
FOR INSERT 
WITH CHECK (bucket_id = 'estimation-attachments' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can update their own estimation attachments" 
ON storage.objects 
FOR UPDATE 
USING (bucket_id = 'estimation-attachments' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can delete their own estimation attachments" 
ON storage.objects 
FOR DELETE 
USING (bucket_id = 'estimation-attachments' AND auth.uid()::text = (storage.foldername(name))[1]);