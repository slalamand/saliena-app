-- ============================================================================
-- SALIENA APP - SEED DATA (OPTIONAL)
-- ============================================================================
-- Description: Test data for development and demonstration
-- Version: 1.0
-- Run Order: 5 (Run after 04_storage.sql) - OPTIONAL
-- ============================================================================
-- 
-- WARNING: This file creates test users and data for development only.
-- DO NOT run this in production!
-- 
-- This script will:
-- 1. Create test users with different roles
-- 2. Create sample reports with various statuses
-- 3. Create sample notifications
-- 
-- ============================================================================

-- ============================================================================
-- IMPORTANT: USER CREATION
-- ============================================================================
-- 
-- You cannot directly create users via SQL in Supabase.
-- Users must be created through the Auth API or Supabase Dashboard.
-- 
-- To create test users:
-- 1. Go to Supabase Dashboard > Authentication > Users
-- 2. Click "Add User"
-- 3. Enter email and let them verify via email OTP
-- 
-- OR use the Supabase CLI:
-- supabase auth signup test@example.com
-- 
-- After creating users via the dashboard, update their profiles below.
-- ============================================================================

-- ============================================================================
-- STEP 1: UPDATE TEST USER PROFILES
-- ============================================================================
-- 
-- Replace these UUIDs with actual user IDs from your auth.users table
-- To get user IDs, run: SELECT id, email FROM auth.users;
-- 

-- Example: Update a user to be an office admin
-- UPDATE public.profiles 
-- SET 
--     role = 'office_admin',
--     full_name = 'Admin User',
--     phone = '+1234567890',
--     is_verified = true
-- WHERE email = 'admin@example.com';

-- Example: Update a user to be a worker
-- UPDATE public.profiles 
-- SET 
--     role = 'worker',
--     full_name = 'Worker User',
--     phone = '+1234567891',
--     is_verified = true
-- WHERE email = 'worker@example.com';

-- Example: Update a user to be a resident
-- UPDATE public.profiles 
-- SET 
--     role = 'resident',
--     full_name = 'Resident User',
--     phone = '+1234567892',
--     is_verified = true
-- WHERE email = 'resident@example.com';

-- ============================================================================
-- STEP 2: CREATE SAMPLE REPORTS
-- ============================================================================
-- 
-- These are example reports for testing the map and feed views.
-- Replace user_id with actual user IDs from your profiles table.
-- 

-- Get a user ID to use for sample reports
DO $$
DECLARE
    sample_user_id UUID;
BEGIN
    -- Get the first verified resident user
    SELECT id INTO sample_user_id
    FROM public.profiles
    WHERE role = 'resident' AND is_verified = true
    LIMIT 1;

    -- Only create sample data if we have a user
    IF sample_user_id IS NOT NULL THEN
        
        -- Sample Report 1: Pending pothole
        INSERT INTO public.reports (
            user_id,
            title,
            description,
            photo_url,
            latitude,
            longitude,
            address,
            status,
            location_source,
            created_at
        ) VALUES (
            sample_user_id,
            'Large Pothole on Main Street',
            'There is a large pothole on Main Street near the intersection with Oak Avenue. It has been causing damage to vehicles and is a safety hazard.',
            'https://via.placeholder.com/800x600.jpg?text=Pothole',
            56.9496,  -- Riga, Latvia coordinates
            24.1052,
            'Main Street, Riga',
            'pending',
            'device_gps',
            NOW() - INTERVAL '2 hours'
        );

        -- Sample Report 2: In-progress streetlight repair
        INSERT INTO public.reports (
            user_id,
            title,
            description,
            photo_url,
            latitude,
            longitude,
            address,
            status,
            location_source,
            created_at,
            updated_at
        ) VALUES (
            sample_user_id,
            'Broken Streetlight',
            'The streetlight on Elm Street has been out for several days. The area is very dark at night and feels unsafe.',
            'https://via.placeholder.com/800x600.jpg?text=Streetlight',
            56.9520,
            24.1130,
            'Elm Street, Riga',
            'in_progress',
            'device_gps',
            NOW() - INTERVAL '1 day',
            NOW() - INTERVAL '6 hours'
        );

        -- Sample Report 3: Fixed graffiti removal
        INSERT INTO public.reports (
            user_id,
            title,
            description,
            photo_url,
            latitude,
            longitude,
            address,
            status,
            fixed_by,
            fixed_at,
            location_source,
            created_at,
            updated_at
        ) VALUES (
            sample_user_id,
            'Graffiti on Public Building',
            'Vandalism on the side of the community center building. Multiple graffiti tags need to be removed.',
            'https://via.placeholder.com/800x600.jpg?text=Graffiti',
            56.9480,
            24.1070,
            'Community Center, Riga',
            'fixed',
            sample_user_id,  -- In real scenario, this would be a worker's ID
            NOW() - INTERVAL '1 hour',
            'device_gps',
            NOW() - INTERVAL '3 days',
            NOW() - INTERVAL '1 hour'
        );

        -- Sample Report 4: Pending sidewalk damage
        INSERT INTO public.reports (
            user_id,
            title,
            description,
            photo_url,
            latitude,
            longitude,
            address,
            status,
            location_source,
            created_at
        ) VALUES (
            sample_user_id,
            'Damaged Sidewalk',
            'Several concrete panels on the sidewalk are cracked and uneven, creating a tripping hazard for pedestrians.',
            'https://via.placeholder.com/800x600.jpg?text=Sidewalk',
            56.9470,
            24.1090,
            'Park Avenue, Riga',
            'pending',
            'photo_exif',
            NOW() - INTERVAL '5 hours'
        );

        -- Sample Report 5: Pending trash accumulation
        INSERT INTO public.reports (
            user_id,
            title,
            description,
            photo_url,
            latitude,
            longitude,
            address,
            status,
            location_source,
            created_at
        ) VALUES (
            sample_user_id,
            'Illegal Dumping',
            'Large pile of trash and construction debris dumped in the park. Needs immediate removal.',
            'https://via.placeholder.com/800x600.jpg?text=Trash',
            56.9510,
            24.1100,
            'Central Park, Riga',
            'pending',
            'manual',
            NOW() - INTERVAL '12 hours'
        );

        RAISE NOTICE 'Sample reports created successfully for user: %', sample_user_id;
    ELSE
        RAISE NOTICE 'No verified resident found. Create users first, then run this script.';
    END IF;
END $$;

-- ============================================================================
-- STEP 3: CREATE SAMPLE NOTIFICATIONS
-- ============================================================================

DO $$
DECLARE
    sample_user_id UUID;
BEGIN
    -- Get the first verified user
    SELECT id INTO sample_user_id
    FROM public.profiles
    WHERE is_verified = true
    LIMIT 1;

    IF sample_user_id IS NOT NULL THEN
        
        -- Welcome notification
        INSERT INTO public.notifications (
            user_id,
            title,
            body,
            data,
            is_read,
            created_at
        ) VALUES (
            sample_user_id,
            'Welcome to Saliena!',
            'Thank you for joining. You can now submit reports about issues in your municipality.',
            '{"type": "welcome"}'::jsonb,
            false,
            NOW() - INTERVAL '1 day'
        );

        -- Report status update notification
        INSERT INTO public.notifications (
            user_id,
            title,
            body,
            data,
            is_read,
            created_at
        ) VALUES (
            sample_user_id,
            'Report Status Updated',
            'Your report "Broken Streetlight" is now being worked on.',
            '{"type": "report_update", "report_id": "sample-id", "status": "in_progress"}'::jsonb,
            false,
            NOW() - INTERVAL '6 hours'
        );

        -- Report completed notification
        INSERT INTO public.notifications (
            user_id,
            title,
            body,
            data,
            is_read,
            created_at
        ) VALUES (
            sample_user_id,
            'Report Completed',
            'Your report "Graffiti on Public Building" has been resolved!',
            '{"type": "report_completed", "report_id": "sample-id", "status": "fixed"}'::jsonb,
            true,
            NOW() - INTERVAL '1 hour'
        );

        RAISE NOTICE 'Sample notifications created successfully for user: %', sample_user_id;
    ELSE
        RAISE NOTICE 'No verified user found. Create users first, then run this script.';
    END IF;
END $$;

-- ============================================================================
-- STEP 4: POPULATE USER_ROLES HELPER TABLE
-- ============================================================================

-- Insert all role types for reference
INSERT INTO public.user_roles (id, role)
SELECT id, role
FROM public.profiles
ON CONFLICT (id) DO UPDATE SET role = EXCLUDED.role;

-- ============================================================================
-- SEED DATA COMPLETE
-- ============================================================================
-- 
-- What was created:
-- - Sample reports with various statuses (pending, in_progress, fixed)
-- - Sample notifications for users
-- - User roles helper data
-- 
-- Next steps:
-- 1. Verify data in Supabase Dashboard > Table Editor
-- 2. Test the Flutter app with this sample data
-- 3. Test different user roles and permissions
-- 
-- To reset seed data:
-- DELETE FROM public.notifications;
-- DELETE FROM public.reports;
-- 
-- ============================================================================
