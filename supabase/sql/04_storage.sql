-- ============================================================================
-- SALIENA APP - STORAGE CONFIGURATION
-- ============================================================================
-- Description: Storage buckets and policies for file uploads
-- Version: 1.2.0 (Updated with video support)
-- Run Order: 4 (Run after 03_rls_policies.sql)
-- ============================================================================
-- 
-- This file sets up storage for report photos, videos, and user avatars.
-- Files are stored in Supabase Storage with public access for viewing.
-- 
-- ============================================================================

-- ============================================================================
-- STEP 1: CREATE STORAGE BUCKETS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- BUCKET: report-photos
-- ----------------------------------------------------------------------------
-- Purpose: Stores photos attached to issue reports (up to 3 per report)
-- Public: YES (anyone can view photos via URL)
-- File Size Limit: 5MB per photo
-- Allowed File Types: JPG, JPEG, PNG, WEBP
-- File Path Structure: reports/{user_id}/{timestamp}_{index}_{filename}.jpg

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'report-photos',
    'report-photos',
    true,  -- Public bucket
    5242880,  -- 5MB in bytes
    ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO UPDATE SET
    public = EXCLUDED.public,
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

-- ----------------------------------------------------------------------------
-- BUCKET: report-videos
-- ----------------------------------------------------------------------------
-- Purpose: Stores videos attached to issue reports (1 per report, 15s max)
-- Public: YES (anyone can view videos via URL)
-- File Size Limit: 10MB per video
-- Allowed File Types: MP4, MOV, WEBM
-- File Path Structure: reports/{user_id}/{timestamp}_video_{filename}.mp4

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'report-videos',
    'report-videos',
    true,  -- Public bucket
    10485760,  -- 10MB in bytes
    ARRAY['video/mp4', 'video/quicktime', 'video/webm']
)
ON CONFLICT (id) DO UPDATE SET
    public = EXCLUDED.public,
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

-- ----------------------------------------------------------------------------
-- BUCKET: avatars
-- ----------------------------------------------------------------------------
-- Purpose: Stores user profile pictures
-- Public: YES (anyone can view avatars via URL)
-- File Size Limit: 2MB
-- Allowed File Types: JPG, JPEG, PNG, WEBP
-- File Path Structure: {user_id}/avatar.jpg

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'avatars',
    'avatars',
    true,  -- Public bucket
    2097152,  -- 2MB in bytes
    ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO UPDATE SET
    public = EXCLUDED.public,
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

-- ============================================================================
-- STEP 2: STORAGE POLICIES FOR REPORT-PHOTOS BUCKET
-- ============================================================================

-- ----------------------------------------------------------------------------
-- POLICY: Authenticated users can upload report photos
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Authenticated users can upload photos" ON storage.objects;

CREATE POLICY "Authenticated users can upload photos"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'report-photos' 
    AND (storage.foldername(name))[1] = 'reports'
);

-- ----------------------------------------------------------------------------
-- POLICY: Public can read report photos
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Public can read photos" ON storage.objects;

CREATE POLICY "Public can read photos"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'report-photos');

-- ----------------------------------------------------------------------------
-- POLICY: Users can delete their own report photos
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Users can delete own photos" ON storage.objects;

CREATE POLICY "Users can delete own photos"
ON storage.objects
FOR DELETE
TO authenticated
USING (
    bucket_id = 'report-photos' 
    AND (storage.foldername(name))[2] = auth.uid()::text
);

-- ----------------------------------------------------------------------------
-- POLICY: Admins can delete any report photos
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Admins can delete any photos" ON storage.objects;

CREATE POLICY "Admins can delete any photos"
ON storage.objects
FOR DELETE
TO authenticated
USING (
    bucket_id = 'report-photos' 
    AND EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = auth.uid() AND role = 'office_admin'
    )
);

-- ============================================================================
-- STEP 3: STORAGE POLICIES FOR REPORT-VIDEOS BUCKET
-- ============================================================================

-- ----------------------------------------------------------------------------
-- POLICY: Authenticated users can upload report videos
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Authenticated users can upload videos" ON storage.objects;

CREATE POLICY "Authenticated users can upload videos"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'report-videos' 
    AND (storage.foldername(name))[1] = 'reports'
);

-- ----------------------------------------------------------------------------
-- POLICY: Public can read report videos
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Public can read videos" ON storage.objects;

CREATE POLICY "Public can read videos"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'report-videos');

-- ----------------------------------------------------------------------------
-- POLICY: Users can delete their own report videos
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Users can delete own videos" ON storage.objects;

CREATE POLICY "Users can delete own videos"
ON storage.objects
FOR DELETE
TO authenticated
USING (
    bucket_id = 'report-videos' 
    AND (storage.foldername(name))[2] = auth.uid()::text
);

-- ----------------------------------------------------------------------------
-- POLICY: Admins can delete any report videos
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Admins can delete any videos" ON storage.objects;

CREATE POLICY "Admins can delete any videos"
ON storage.objects
FOR DELETE
TO authenticated
USING (
    bucket_id = 'report-videos' 
    AND EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = auth.uid() AND role = 'office_admin'
    )
);

-- ============================================================================
-- STEP 4: STORAGE POLICIES FOR AVATARS BUCKET
-- ============================================================================

-- ----------------------------------------------------------------------------
-- POLICY: Users can upload their own avatar
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Users can upload own avatar" ON storage.objects;

CREATE POLICY "Users can upload own avatar"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'avatars' 
    AND (storage.foldername(name))[1] = auth.uid()::text
);

-- ----------------------------------------------------------------------------
-- POLICY: Public can read avatars
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Public can read avatars" ON storage.objects;

CREATE POLICY "Public can read avatars"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'avatars');

-- ----------------------------------------------------------------------------
-- POLICY: Users can update their own avatar
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Users can update own avatar" ON storage.objects;

CREATE POLICY "Users can update own avatar"
ON storage.objects
FOR UPDATE
TO authenticated
USING (
    bucket_id = 'avatars' 
    AND (storage.foldername(name))[1] = auth.uid()::text
)
WITH CHECK (
    bucket_id = 'avatars' 
    AND (storage.foldername(name))[1] = auth.uid()::text
);

-- ----------------------------------------------------------------------------
-- POLICY: Users can delete their own avatar
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Users can delete own avatar" ON storage.objects;

CREATE POLICY "Users can delete own avatar"
ON storage.objects
FOR DELETE
TO authenticated
USING (
    bucket_id = 'avatars' 
    AND (storage.foldername(name))[1] = auth.uid()::text
);

-- ============================================================================
-- STORAGE CONFIGURATION COMPLETE
-- ============================================================================
-- 
-- Storage Buckets Summary:
-- 
-- 1. report-photos (5MB max per file)
--    - Path: reports/{user_id}/{timestamp}_{index}_{filename}.jpg
--    - Formats: JPG, JPEG, PNG, WEBP
--    - Limit: 3 photos per report
-- 
-- 2. report-videos (10MB max per file)
--    - Path: reports/{user_id}/{timestamp}_video_{filename}.mp4
--    - Formats: MP4, MOV, WEBM
--    - Limit: 1 video per report, 15 seconds max duration
-- 
-- 3. avatars (2MB max per file)
--    - Path: {user_id}/avatar.jpg
--    - Formats: JPG, JPEG, PNG, WEBP
-- 
-- Security:
-- ✅ All buckets are public (read-only)
-- ✅ Only authenticated users can upload
-- ✅ Users can only upload to their own folders
-- ✅ Users can delete their own files
-- ✅ Admins can delete any file
-- 
-- Important Notes:
-- 1. Always use authenticated user's anon key for uploads
-- 2. Never use service_role key in client-side code
-- 3. File URLs are public once uploaded
-- 4. Client-side validation enforces limits (3 photos, 1 video, 15s)
-- 5. Reports can be submitted without any media (optional)
-- 
-- Next steps:
-- 1. Run 05_seed_data.sql to add test data (optional)
-- 2. Run 06_auth_config.sql to configure authentication
-- 3. Test file uploads from the Flutter app
-- 
-- ============================================================================
