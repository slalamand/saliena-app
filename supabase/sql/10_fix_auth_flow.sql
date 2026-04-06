-- ============================================================================
-- SALIENA APP - AUTH FLOW FIX (CRITICAL)
-- ============================================================================
-- Run this in Supabase SQL Editor BEFORE deploying the updated edge function.
-- This script is idempotent — safe to run multiple times.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- FIX 1: full_name DEFAULT so handle_new_user trigger never fails
-- ----------------------------------------------------------------------------
-- Without this, every INSERT into profiles from the trigger fails with a
-- NOT NULL constraint violation → profiles are never auto-created →
-- can_skip_otp always returns FALSE → verified users get sent to OTP.

ALTER TABLE public.profiles
  ALTER COLUMN full_name SET DEFAULT '';

-- ----------------------------------------------------------------------------
-- FIX 2: Repair handle_new_user trigger
-- ----------------------------------------------------------------------------
-- Old version omitted full_name → trigger always failed → no profile row.
-- New version supplies the default and ignores duplicate inserts.

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public.profiles (id, email, role, full_name)
    VALUES (
        NEW.id,
        NEW.email,
        'resident',
        COALESCE(NEW.raw_user_meta_data->>'full_name', '')
    )
    ON CONFLICT (id) DO NOTHING;   -- safe to re-run; never overwrites existing profiles
    RETURN NEW;
END;
$$;

-- Re-attach trigger (idempotent)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- ----------------------------------------------------------------------------
-- FIX 3: Backfill missing profiles for already-existing auth users
-- ----------------------------------------------------------------------------
-- Any user created before this fix may have a row in auth.users but no profile.
-- This creates a minimal profile for them so login works.
-- full_name and is_verified can be updated by the admin afterwards.

INSERT INTO public.profiles (id, email, role, full_name, is_verified)
SELECT
    u.id,
    u.email,
    'resident',
    '',       -- admin should update this
    FALSE     -- admin must explicitly set TRUE to grant skip-OTP
FROM auth.users u
LEFT JOIN public.profiles p ON u.id = p.id
WHERE p.id IS NULL
ON CONFLICT (id) DO NOTHING;

-- Log how many profiles were backfilled
DO $$
DECLARE
    missing_count INT;
BEGIN
    SELECT COUNT(*) INTO missing_count
    FROM auth.users u
    LEFT JOIN public.profiles p ON u.id = p.id
    WHERE p.id IS NULL;

    IF missing_count = 0 THEN
        RAISE NOTICE 'Backfill complete — all auth users already have profiles.';
    ELSE
        RAISE NOTICE 'Backfill complete — % profile(s) still missing (check for errors).', missing_count;
    END IF;
END $$;

-- ----------------------------------------------------------------------------
-- FIX 4: New get_login_status function (replaces can_skip_otp in the app)
-- ----------------------------------------------------------------------------
-- Returns one of three values:
--   'verified'   → user exists AND is_verified = TRUE  → auto sign-in, skip OTP
--   'unverified' → user exists AND is_verified = FALSE → send OTP
--   'not_found'  → email not in profiles               → reject with clear error
--
-- Security: DEFINER — runs as owner, safe for anon callers because it
--           returns only a status string, never any PII.

CREATE OR REPLACE FUNCTION public.get_login_status(p_email TEXT)
RETURNS TEXT
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
    v_is_verified BOOLEAN;
BEGIN
    SELECT is_verified
      INTO v_is_verified
      FROM public.profiles
     WHERE email = LOWER(TRIM(p_email))
     LIMIT 1;

    IF NOT FOUND THEN
        RETURN 'not_found';
    END IF;

    IF v_is_verified THEN
        RETURN 'verified';
    ELSE
        RETURN 'unverified';
    END IF;
END;
$$;

COMMENT ON FUNCTION public.get_login_status(TEXT) IS
    'Returns the login status for a given email: verified | unverified | not_found';

GRANT EXECUTE ON FUNCTION public.get_login_status(TEXT) TO anon;
GRANT EXECUTE ON FUNCTION public.get_login_status(TEXT) TO authenticated;

-- Keep can_skip_otp alive for backward compatibility
-- (it now delegates to get_login_status internally)
CREATE OR REPLACE FUNCTION public.can_skip_otp(p_email TEXT)
RETURNS BOOLEAN
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN get_login_status(p_email) = 'verified';
END;
$$;

GRANT EXECUTE ON FUNCTION public.can_skip_otp(TEXT) TO anon;
GRANT EXECUTE ON FUNCTION public.can_skip_otp(TEXT) TO authenticated;

-- ----------------------------------------------------------------------------
-- QUICK VERIFICATION QUERIES
-- ----------------------------------------------------------------------------
-- Run these after the script to confirm everything worked:

-- 1. Check all auth users have profiles:
--    SELECT COUNT(*) FROM auth.users u LEFT JOIN profiles p ON u.id = p.id WHERE p.id IS NULL;
--    → should return 0

-- 2. Test get_login_status with a real email:
--    SELECT get_login_status('your@email.com');
--    → 'verified', 'unverified', or 'not_found'

-- 3. To mark a user as verified (skip OTP):
--    UPDATE profiles SET is_verified = TRUE, full_name = 'Full Name' WHERE email = 'your@email.com';

-- ============================================================================
-- END OF FIX
-- ============================================================================
