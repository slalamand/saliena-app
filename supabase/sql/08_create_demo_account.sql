-- ============================================================================
-- SALIENA APP - CREATE DEMO ACCOUNT FOR APPLE REVIEWERS
-- ============================================================================
-- Description: Creates a demo account specifically for Apple App Store reviewers
-- Usage: Run this script in Supabase SQL Editor before submitting to App Store
-- ============================================================================

-- ============================================================================
-- DEMO ACCOUNT DETAILS
-- ============================================================================
-- Email: reviewer@saliena-demo.com
-- Role: resident (with full app access)
-- Purpose: Allow Apple reviewers to test all app functionality
-- ============================================================================

DO $$
DECLARE
    demo_email TEXT := 'reviewer@saliena-demo.com';
    demo_password TEXT := 'AppleReview2024!';
    demo_user_id UUID;
BEGIN
    -- Check if demo account already exists
    SELECT id INTO demo_user_id
    FROM auth.users 
    WHERE email = demo_email;
    
    IF demo_user_id IS NOT NULL THEN
        RAISE NOTICE 'Demo account already exists with ID: %', demo_user_id;
        RAISE NOTICE 'Email: %', demo_email;
        RAISE NOTICE 'The account is ready for Apple reviewers.';
        RETURN;
    END IF;
    
    -- Create the demo user in Supabase Auth
    SELECT auth.admin_create_user(
        email => demo_email,
        password => demo_password,
        email_confirm => true  -- Skip email confirmation for reviewers
    ) INTO demo_user_id;
    
    -- Update the demo user's profile with realistic information
    UPDATE public.profiles 
    SET 
        full_name = 'Apple Reviewer',
        phone = '+1-555-REVIEW',
        address = 'Demo Unit, Saliena Estate',
        role = 'resident',
        is_verified = true,  -- Mark as verified by management
        updated_at = NOW()
    WHERE id = demo_user_id;
    
    -- Create some sample reports for the demo account to make the app look active
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
    ) VALUES 
    (
        demo_user_id,
        'Demo: Streetlight Issue',
        'This is a sample report created for demonstration purposes. The streetlight on Demo Street has been flickering intermittently.',
        'https://via.placeholder.com/800x600.jpg?text=Demo+Streetlight',
        56.9496,  -- Riga, Latvia coordinates (adjust for your location)
        24.1052,
        'Demo Street, Saliena Estate',
        'in_progress',
        'device_gps',
        NOW() - INTERVAL '2 days'
    ),
    (
        demo_user_id,
        'Demo: Pothole Repair',
        'Sample pothole report for Apple reviewers to see how issue reporting works in the app.',
        'https://via.placeholder.com/800x600.jpg?text=Demo+Pothole',
        56.9520,
        24.1130,
        'Demo Avenue, Saliena Estate',
        'fixed',
        'device_gps',
        NOW() - INTERVAL '5 days'
    ),
    (
        demo_user_id,
        'Demo: Landscaping Request',
        'Demonstration of a landscaping maintenance request. This shows how residents can report various types of community issues.',
        'https://via.placeholder.com/800x600.jpg?text=Demo+Landscaping',
        56.9480,
        24.1070,
        'Demo Park, Saliena Estate',
        'pending',
        'device_gps',
        NOW() - INTERVAL '1 day'
    );
    
    -- Create a welcome notification for the demo account
    INSERT INTO public.notifications (
        user_id,
        title,
        body,
        data,
        is_read,
        created_at
    ) VALUES (
        demo_user_id,
        'Welcome to Saliena Estate App',
        'This is a demo account for Apple App Store reviewers. You can explore all features of the community issue reporting system.',
        '{"type": "demo_welcome"}'::jsonb,
        false,
        NOW()
    );
    
    -- Success message
    RAISE NOTICE '=== DEMO ACCOUNT CREATED SUCCESSFULLY ===';
    RAISE NOTICE 'Email: %', demo_email;
    RAISE NOTICE 'Password: % (not used - app uses OTP)', demo_password;
    RAISE NOTICE 'User ID: %', demo_user_id;
    RAISE NOTICE '';
    RAISE NOTICE '=== INSTRUCTIONS FOR APPLE REVIEWERS ===';
    RAISE NOTICE '1. Enter email: %', demo_email;
    RAISE NOTICE '2. Tap "Send verification code"';
    RAISE NOTICE '3. Check email for OTP code';
    RAISE NOTICE '4. Enter OTP to access the app';
    RAISE NOTICE '';
    RAISE NOTICE '=== DEMO FEATURES AVAILABLE ===';
    RAISE NOTICE '• View existing community reports';
    RAISE NOTICE '• Create new issue reports';
    RAISE NOTICE '• View reports on interactive map';
    RAISE NOTICE '• See report status updates';
    RAISE NOTICE '• Test all app functionality';
    RAISE NOTICE '';
    RAISE NOTICE 'Sample reports have been created to demonstrate the app functionality.';
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error creating demo account: %', SQLERRM;
        RAISE NOTICE 'Please check if Supabase Auth is properly configured.';
END $$;

-- ============================================================================
-- VERIFICATION QUERY
-- ============================================================================
-- Run this to verify the demo account was created properly:

/*
SELECT 
    p.email,
    p.full_name,
    p.role,
    p.is_verified,
    p.created_at,
    (SELECT COUNT(*) FROM reports WHERE user_id = p.id) as sample_reports_count
FROM public.profiles p
WHERE p.email = 'reviewer@saliena-demo.com';
*/

-- ============================================================================
-- CLEANUP (if needed)
-- ============================================================================
-- To remove the demo account later:

/*
-- Delete demo reports
DELETE FROM public.reports WHERE user_id = (
    SELECT id FROM public.profiles WHERE email = 'reviewer@saliena-demo.com'
);

-- Delete demo notifications
DELETE FROM public.notifications WHERE user_id = (
    SELECT id FROM public.profiles WHERE email = 'reviewer@saliena-demo.com'
);

-- Delete demo profile
DELETE FROM public.profiles WHERE email = 'reviewer@saliena-demo.com';

-- Delete demo auth user
DELETE FROM auth.users WHERE email = 'reviewer@saliena-demo.com';
*/

-- ============================================================================
-- NOTES FOR APP STORE SUBMISSION
-- ============================================================================
-- 
-- Include this information in your App Store Connect submission:
-- 
-- Demo Account:
-- Email: reviewer@saliena-demo.com
-- 
-- Instructions:
-- 1. This app is designed for Saliena Estate residents only
-- 2. Real accounts are created by the management office
-- 3. This demo account allows full access to test all features
-- 4. Use email-based OTP login (no password required)
-- 5. The app includes sample reports to demonstrate functionality
-- 
-- App Features to Test:
-- • Email OTP authentication
-- • View community issue reports
-- • Create new reports with photos
-- • Interactive map view
-- • Report status tracking
-- • Push notifications (if enabled)
-- • Multi-language support
-- 
-- ============================================================================