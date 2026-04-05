-- ============================================================================
-- SALIENA APP - ADD USER SCRIPT
-- ============================================================================
-- Description: Script to add new residents to the Saliena Estate app
-- Usage: Replace the values below and run in Supabase SQL Editor
-- ============================================================================

-- ============================================================================
-- INSTRUCTIONS:
-- 1. Replace the values in the variables below
-- 2. Run this script in Supabase SQL Editor
-- 3. The user can now log in with their email using OTP
-- ============================================================================

DO $$
DECLARE
    -- CHANGE THESE VALUES FOR EACH NEW USER
    user_email TEXT := 'resident@example.com';           -- User's email address
    user_full_name TEXT := 'John Smith';                 -- Full name
    user_phone TEXT := '+1234567890';                    -- Phone number (optional)
    user_address TEXT := 'Apt 123, Saliena Estate';      -- Address (optional)
    user_role TEXT := 'resident';                        -- Role: 'resident', 'worker', or 'office_admin'
    
    -- Generated values
    temp_password TEXT;
    new_user_id UUID;
BEGIN
    -- Generate a temporary password (user won't use this)
    temp_password := 'Temp' || extract(epoch from now())::text || '!';
    
    -- Create the user in Supabase Auth
    SELECT auth.admin_create_user(
        email => user_email,
        password => temp_password,
        email_confirm => true  -- Skip email confirmation
    ) INTO new_user_id;
    
    -- Update the user's profile with their information
    UPDATE public.profiles 
    SET 
        full_name = user_full_name,
        phone = user_phone,
        address = user_address,
        role = user_role::user_role,
        is_verified = true,  -- Mark as verified by management
        updated_at = NOW()
    WHERE id = new_user_id;
    
    -- Confirm the user was created successfully
    RAISE NOTICE 'User created successfully!';
    RAISE NOTICE 'Email: %', user_email;
    RAISE NOTICE 'Name: %', user_full_name;
    RAISE NOTICE 'Role: %', user_role;
    RAISE NOTICE 'User ID: %', new_user_id;
    RAISE NOTICE '';
    RAISE NOTICE 'The user can now log in using their email address.';
    RAISE NOTICE 'They will receive an OTP code via email to complete login.';
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error creating user: %', SQLERRM;
        RAISE NOTICE 'Make sure the email is not already in use.';
END $$;

-- ============================================================================
-- BULK USER CREATION EXAMPLE
-- ============================================================================
-- To create multiple users at once, you can use this pattern:

/*
DO $$
DECLARE
    users_to_create RECORD;
    temp_password TEXT;
    new_user_id UUID;
BEGIN
    -- List of users to create
    FOR users_to_create IN 
        SELECT * FROM (VALUES
            ('john.smith@example.com', 'John Smith', '+1234567890', 'Apt 101, Saliena Estate', 'resident'),
            ('jane.doe@example.com', 'Jane Doe', '+1234567891', 'Apt 102, Saliena Estate', 'resident'),
            ('worker@example.com', 'Bob Worker', '+1234567892', 'Staff Office', 'worker'),
            ('admin@example.com', 'Alice Admin', '+1234567893', 'Management Office', 'office_admin')
        ) AS t(email, full_name, phone, address, role)
    LOOP
        -- Generate temporary password
        temp_password := 'Temp' || extract(epoch from now())::text || '!';
        
        -- Create user
        SELECT auth.admin_create_user(
            email => users_to_create.email,
            password => temp_password,
            email_confirm => true
        ) INTO new_user_id;
        
        -- Update profile
        UPDATE public.profiles 
        SET 
            full_name = users_to_create.full_name,
            phone = users_to_create.phone,
            address = users_to_create.address,
            role = users_to_create.role::user_role,
            is_verified = true,
            updated_at = NOW()
        WHERE id = new_user_id;
        
        RAISE NOTICE 'Created user: % (%) - %', users_to_create.full_name, users_to_create.email, users_to_create.role;
    END LOOP;
    
    RAISE NOTICE 'All users created successfully!';
END $$;
*/

-- ============================================================================
-- VIEW EXISTING USERS
-- ============================================================================
-- Run this query to see all existing users:

/*
SELECT 
    p.email,
    p.full_name,
    p.phone,
    p.address,
    p.role,
    p.is_verified,
    p.created_at
FROM public.profiles p
ORDER BY p.created_at DESC;
*/

-- ============================================================================
-- UPDATE USER ROLE
-- ============================================================================
-- To change a user's role (e.g., promote resident to worker):

/*
UPDATE public.profiles 
SET 
    role = 'worker',  -- Change to: 'resident', 'worker', or 'office_admin'
    updated_at = NOW()
WHERE email = 'user@example.com';
*/

-- ============================================================================
-- DELETE USER
-- ============================================================================
-- To remove a user completely:

/*
-- First delete from profiles (this will cascade to reports, notifications, etc.)
DELETE FROM public.profiles WHERE email = 'user@example.com';

-- Then delete from auth (optional, or they can be disabled instead)
-- Note: This requires the user ID from auth.users table
DELETE FROM auth.users WHERE email = 'user@example.com';
*/