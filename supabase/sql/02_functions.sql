-- ============================================================================
-- SALIENA APP - DATABASE FUNCTIONS AND TRIGGERS
-- ============================================================================
-- Description: Functions and triggers for automated database operations
-- Version: 1.0
-- Run Order: 2 (Run after 01_schema.sql)
-- ============================================================================

-- ============================================================================
-- STEP 1: USER MANAGEMENT FUNCTIONS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- FUNCTION: handle_new_user
-- ----------------------------------------------------------------------------
-- Purpose: Automatically create a profile when a new user signs up
-- Trigger: AFTER INSERT on auth.users
-- Security: DEFINER (runs with elevated privileges)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER 
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    INSERT INTO public.profiles (id, email, role)
    VALUES (NEW.id, NEW.email, 'resident');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.handle_new_user IS 'Automatically creates a profile entry when a new user signs up via Supabase Auth.';

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Create trigger on auth.users table
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- ----------------------------------------------------------------------------
-- FUNCTION: is_email_verified
-- ----------------------------------------------------------------------------
-- Purpose: Check if a user's email is verified
-- Returns: TRUE if email is confirmed, FALSE otherwise
-- Security: DEFINER (can read auth.users)
CREATE OR REPLACE FUNCTION public.is_email_verified(user_id UUID)
RETURNS BOOLEAN
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
    email_confirmed_at TIMESTAMPTZ;
BEGIN
    SELECT u.email_confirmed_at INTO email_confirmed_at
    FROM auth.users u
    WHERE u.id = user_id;
    
    RETURN email_confirmed_at IS NOT NULL;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.is_email_verified IS 'Checks if a user has verified their email address.';

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION public.is_email_verified(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_email_verified(UUID) TO anon;

-- ----------------------------------------------------------------------------
-- FUNCTION: get_my_role
-- ----------------------------------------------------------------------------
-- Purpose: Get the role of the currently authenticated user
-- Returns: user_role enum value
-- Security: DEFINER
CREATE OR REPLACE FUNCTION public.get_my_role()
RETURNS user_role
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    user_role_value user_role;
BEGIN
    SELECT role INTO user_role_value
    FROM public.profiles
    WHERE id = auth.uid();
    
    RETURN user_role_value;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.get_my_role IS 'Returns the role of the currently authenticated user.';

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION public.get_my_role() TO authenticated;

-- ============================================================================
-- STEP 2: VERIFICATION FUNCTIONS (REMOVED)
-- ============================================================================
-- NOTE: auto_verify_profile and prevent_verified_change triggers were removed
-- because they caused conflicts during Supabase Auth email confirmation.
-- 
-- is_verified is now a simple field controlled by office_admin users only.
-- It represents "admin has verified this person is a Saliena resident",
-- which is separate from email confirmation.

-- Drop the problematic triggers if they exist in the database
DROP TRIGGER IF EXISTS auto_verify_profile_trigger ON public.profiles;
DROP TRIGGER IF EXISTS prevent_verified_change_trigger ON public.profiles;
DROP FUNCTION IF EXISTS public.auto_verify_profile();
DROP FUNCTION IF EXISTS public.prevent_verified_change();

-- ============================================================================
-- STEP 3: TIMESTAMP UPDATE FUNCTIONS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- FUNCTION: update_updated_at
-- ----------------------------------------------------------------------------
-- Purpose: Automatically update the updated_at timestamp
-- Trigger: BEFORE UPDATE on tables with updated_at column
-- Security: INVOKER
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER
AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.update_updated_at IS 'Automatically updates the updated_at timestamp when a row is modified.';

-- Drop existing triggers if they exist
DROP TRIGGER IF EXISTS update_profiles_updated_at ON public.profiles;
DROP TRIGGER IF EXISTS update_reports_updated_at ON public.reports;

-- Apply to profiles table
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at();

-- Apply to reports table
CREATE TRIGGER update_reports_updated_at
    BEFORE UPDATE ON public.reports
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at();

-- ============================================================================
-- STEP 4: HELPER FUNCTIONS FOR REPORTS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- FUNCTION: get_reports_with_details
-- ----------------------------------------------------------------------------
-- Purpose: Get reports with reporter and fixer information
-- Parameters:
--   - p_status: Filter by status (NULL for all)
--   - p_user_id: Filter by user (NULL for all)
--   - p_limit: Maximum number of results (default 50)
--   - p_offset: Pagination offset (default 0)
-- Returns: Table with report details
CREATE OR REPLACE FUNCTION public.get_reports_with_details(
    p_status report_status DEFAULT NULL,
    p_user_id UUID DEFAULT NULL,
    p_limit INT DEFAULT 50,
    p_offset INT DEFAULT 0
)
RETURNS TABLE (
    id UUID,
    user_id UUID,
    title TEXT,
    description TEXT,
    photo_url TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    address TEXT,
    location_source TEXT,
    status report_status,
    fixed_by UUID,
    fixed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    reporter_name TEXT,
    reporter_email TEXT,
    fixer_name TEXT
)
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.id,
        r.user_id,
        r.title,
        r.description,
        r.photo_url,
        r.latitude,
        r.longitude,
        r.address,
        r.location_source,
        r.status,
        r.fixed_by,
        r.fixed_at,
        r.created_at,
        r.updated_at,
        p.full_name as reporter_name,
        p.email as reporter_email,
        f.full_name as fixer_name
    FROM public.reports r
    INNER JOIN public.profiles p ON r.user_id = p.id
    LEFT JOIN public.profiles f ON r.fixed_by = f.id
    WHERE 
        (p_status IS NULL OR r.status = p_status)
        AND (p_user_id IS NULL OR r.user_id = p_user_id)
    ORDER BY r.created_at DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.get_reports_with_details IS 'Fetches reports with reporter and fixer information. Supports filtering and pagination.';

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION public.get_reports_with_details(report_status, UUID, INT, INT) TO authenticated;

-- ============================================================================
-- FUNCTIONS AND TRIGGERS SETUP COMPLETE
-- ============================================================================
-- Next steps:
-- 1. Run 03_rls_policies.sql to set up Row Level Security
-- 2. Test triggers by creating a test user
-- ============================================================================
