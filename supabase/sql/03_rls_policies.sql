-- ============================================================================
-- SALIENA APP - ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================
-- Description: Security policies that control who can access what data
-- Version: 1.0
-- Run Order: 3 (Run after 02_functions.sql)
-- ============================================================================
-- 
-- IMPORTANT: RLS ensures users can only access data they're authorized to see.
-- Even with the anon or authenticated key, users cannot bypass these policies.
-- 
-- Role Permissions Summary:
-- - resident: Can view own profile, create reports, view all reports
-- - worker: Same as resident + can update report status
-- - office_admin: Full access to all data and operations
-- ============================================================================

-- ============================================================================
-- PROFILES TABLE POLICIES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- POLICY: Users can read their own profile
-- ----------------------------------------------------------------------------
-- Who: Any authenticated user
-- What: SELECT their own profile data
-- Why: Users need to see their own profile information
DROP POLICY IF EXISTS "Users can read own profile" ON public.profiles;

CREATE POLICY "Users can read own profile"
ON public.profiles
FOR SELECT
TO authenticated
USING (auth.uid() = id);

-- ----------------------------------------------------------------------------
-- POLICY: Users can update their own profile
-- ----------------------------------------------------------------------------
-- Who: Any authenticated user
-- What: UPDATE their own profile data
-- Why: Users need to edit their profile information
-- Note: is_verified cannot be changed (protected by trigger)
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;

CREATE POLICY "Users can update own profile"
ON public.profiles
FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- ----------------------------------------------------------------------------
-- POLICY: Office admins can read all profiles
-- ----------------------------------------------------------------------------
-- Who: office_admin role only
-- What: SELECT any profile
-- Why: Admins need to manage all users
DROP POLICY IF EXISTS "Office admins can read all profiles" ON public.profiles;

CREATE POLICY "Office admins can read all profiles"
ON public.profiles
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = auth.uid() AND role = 'office_admin'
    )
);

-- ----------------------------------------------------------------------------
-- POLICY: Office admins can update all profiles
-- ----------------------------------------------------------------------------
-- Who: office_admin role only
-- What: UPDATE any profile (including role changes, verification)
-- Why: Admins need to manage user roles and permissions
DROP POLICY IF EXISTS "Office admins can update profiles" ON public.profiles;

CREATE POLICY "Office admins can update profiles"
ON public.profiles
FOR UPDATE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = auth.uid() AND role = 'office_admin'
    )
);

-- ----------------------------------------------------------------------------
-- POLICY: Workers can read profiles
-- ----------------------------------------------------------------------------
-- Who: worker or office_admin role
-- What: SELECT any profile
-- Why: Workers need to see reporter details when handling reports
DROP POLICY IF EXISTS "Workers can read profiles" ON public.profiles;

CREATE POLICY "Workers can read profiles"
ON public.profiles
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = auth.uid() AND role IN ('worker', 'office_admin')
    )
);

-- ============================================================================
-- REPORTS TABLE POLICIES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- POLICY: Authenticated users can read all reports
-- ----------------------------------------------------------------------------
-- Who: Any authenticated user
-- What: SELECT any report
-- Why: All users need to see reports on the map and feed
DROP POLICY IF EXISTS "Authenticated users can read reports" ON public.reports;

CREATE POLICY "Authenticated users can read reports"
ON public.reports
FOR SELECT
TO authenticated
USING (true);

-- ----------------------------------------------------------------------------
-- POLICY: Verified users can create reports
-- ----------------------------------------------------------------------------
-- Who: Verified users only (is_verified = true)
-- What: INSERT new reports
-- Why: Only verified users should be able to submit reports
-- Note: Prevents spam and ensures accountability
DROP POLICY IF EXISTS "Verified users can create reports" ON public.reports;

CREATE POLICY "Verified users can create reports"
ON public.reports
FOR INSERT
TO authenticated
WITH CHECK (
    auth.uid() = user_id AND
    EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = auth.uid() AND is_verified = true
    )
);

-- ----------------------------------------------------------------------------
-- POLICY: Users can update their own pending reports
-- ----------------------------------------------------------------------------
-- Who: Report creator
-- What: UPDATE their own reports (only if status is 'pending')
-- Why: Users can edit reports they just submitted, but not after work begins
DROP POLICY IF EXISTS "Users can update own pending reports" ON public.reports;

CREATE POLICY "Users can update own pending reports"
ON public.reports
FOR UPDATE
TO authenticated
USING (
    auth.uid() = user_id AND status = 'pending'
)
WITH CHECK (
    auth.uid() = user_id AND status = 'pending'
);

-- ----------------------------------------------------------------------------
-- POLICY: Workers can update report status
-- ----------------------------------------------------------------------------
-- Who: worker or office_admin role
-- What: UPDATE any report (change status, assign fixed_by, etc.)
-- Why: Workers need to manage report lifecycle
DROP POLICY IF EXISTS "Workers can update report status" ON public.reports;

CREATE POLICY "Workers can update report status"
ON public.reports
FOR UPDATE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = auth.uid() AND role IN ('worker', 'office_admin')
    )
);

-- ----------------------------------------------------------------------------
-- POLICY: Office admins can delete any report
-- ----------------------------------------------------------------------------
-- Who: office_admin role only
-- What: DELETE any report
-- Why: Admins need to remove inappropriate or duplicate reports
DROP POLICY IF EXISTS "Office admins can delete reports" ON public.reports;

CREATE POLICY "Office admins can delete reports"
ON public.reports
FOR DELETE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = auth.uid() AND role = 'office_admin'
    )
);

-- ----------------------------------------------------------------------------
-- POLICY: Users can delete their own pending reports
-- ----------------------------------------------------------------------------
-- Who: Report creator
-- What: DELETE their own reports (only if status is 'pending')
-- Why: Users can remove reports they just submitted before work begins
DROP POLICY IF EXISTS "Users can delete own pending reports" ON public.reports;

CREATE POLICY "Users can delete own pending reports"
ON public.reports
FOR DELETE
TO authenticated
USING (
    auth.uid() = user_id AND status = 'pending'
);

-- ============================================================================
-- NOTIFICATIONS TABLE POLICIES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- POLICY: Users can read their own notifications
-- ----------------------------------------------------------------------------
-- Who: Any authenticated user
-- What: SELECT their own notifications
-- Why: Users need to see their notification inbox
DROP POLICY IF EXISTS "Users can read own notifications" ON public.notifications;

CREATE POLICY "Users can read own notifications"
ON public.notifications
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- ----------------------------------------------------------------------------
-- POLICY: Users can update their own notifications
-- ----------------------------------------------------------------------------
-- Who: Any authenticated user
-- What: UPDATE their own notifications (mark as read)
-- Why: Users need to mark notifications as read
DROP POLICY IF EXISTS "Users can update own notifications" ON public.notifications;

CREATE POLICY "Users can update own notifications"
ON public.notifications
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- ----------------------------------------------------------------------------
-- POLICY: System can insert notifications
-- ----------------------------------------------------------------------------
-- Who: Service role (backend/server-side only)
-- What: INSERT notifications for any user
-- Why: System needs to create notifications for users
-- Note: This policy allows INSERT via service role key only
DROP POLICY IF EXISTS "System can insert notifications" ON public.notifications;

CREATE POLICY "System can insert notifications"
ON public.notifications
FOR INSERT
TO authenticated
WITH CHECK (
    -- Workers and admins can create notifications
    EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = auth.uid() AND role IN ('worker', 'office_admin')
    )
);

-- ----------------------------------------------------------------------------
-- POLICY: Users can delete their own notifications
-- ----------------------------------------------------------------------------
-- Who: Any authenticated user
-- What: DELETE their own notifications
-- Why: Users need to clear their notification inbox
DROP POLICY IF EXISTS "Users can delete own notifications" ON public.notifications;

CREATE POLICY "Users can delete own notifications"
ON public.notifications
FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- ============================================================================
-- USER_ROLES TABLE POLICIES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- POLICY: Authenticated users can read user_roles
-- ----------------------------------------------------------------------------
-- Who: Any authenticated user
-- What: SELECT from user_roles table
-- Why: Helper table for role lookups
DROP POLICY IF EXISTS "Authenticated users can read user_roles" ON public.user_roles;

CREATE POLICY "Authenticated users can read user_roles"
ON public.user_roles
FOR SELECT
TO authenticated
USING (true);

-- ============================================================================
-- RLS POLICIES SETUP COMPLETE
-- ============================================================================
-- 
-- Testing RLS Policies:
-- 1. Create test users with different roles
-- 2. Try to access data you shouldn't have access to (should fail)
-- 3. Verify that each role can only do what they're supposed to
-- 
-- Common Issues:
-- - If queries return empty results, check RLS policies
-- - Use service_role key in backend for admin operations (bypasses RLS)
-- - Never expose service_role key to clients!
-- 
-- Next steps:
-- 1. Run 04_storage.sql to set up file storage
-- 2. Test each policy with different user roles
-- ============================================================================
