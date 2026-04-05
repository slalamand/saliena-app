-- ============================================================================
-- SALIENA APP - VERIFIED LOGIN (SKIP OTP) FUNCTION
-- ============================================================================
-- Description: Allows verified residents to log in without an OTP code.
--              If is_verified = TRUE in profiles, the Edge Function
--              auto_sign_in generates a magic-link token server-side.
--              This function is called by the app BEFORE attempting to
--              send an OTP, so unverified users still go through the
--              normal email OTP flow.
-- Run Order: 9 (Run after 01–08)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- FUNCTION: can_skip_otp
-- ----------------------------------------------------------------------------
-- Purpose : Check whether a given email belongs to a verified resident.
--           Called by the Flutter app (anon role) before login so it knows
--           whether to show the OTP screen or go straight in.
-- Returns : TRUE  → user exists AND is_verified = TRUE  → skip OTP
--           FALSE → user not found OR is_verified = FALSE → send OTP
-- Security: DEFINER — runs as the function owner so it can read profiles
--           despite RLS. Safe because it only returns a boolean (no PII).
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.can_skip_otp(p_email TEXT)
RETURNS BOOLEAN
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

  -- NULL means user not found → treat as not verified
  RETURN COALESCE(v_is_verified, FALSE);
END;
$$;

COMMENT ON FUNCTION public.can_skip_otp(TEXT) IS
  'Returns TRUE if the given email belongs to a verified resident who may skip OTP login.';

-- Allow both anon (pre-login) and authenticated callers
GRANT EXECUTE ON FUNCTION public.can_skip_otp(TEXT) TO anon;
GRANT EXECUTE ON FUNCTION public.can_skip_otp(TEXT) TO authenticated;

-- ============================================================================
-- HOW IT WORKS (end-to-end)
-- ============================================================================
--
-- 1. Resident opens the app and types their email.
--
-- 2. Flutter calls: supabase.rpc('can_skip_otp', params: {'p_email': email})
--
-- 3a. Returns TRUE  → Flutter calls the 'auto_sign_in' Edge Function.
--     The Edge Function uses the service-role key (server-side only) to call
--     supabase.auth.admin.generateLink({ type: 'magiclink', email })
--     and returns the one-time token to the app.
--     Flutter then calls verifyOTP(token, OtpType.magiclink) to create a
--     session — user is logged in with no code entry required.
--
-- 3b. Returns FALSE → Flutter sends an OTP via signInWithOtp() as normal.
--     User enters the 6-digit code on the OTP verification screen.
--
-- Admin workflow:
--   To grant a resident skip-OTP access, set:
--     UPDATE profiles SET is_verified = TRUE WHERE email = 'resident@email.com';
--
--   To revoke it (force OTP again):
--     UPDATE profiles SET is_verified = FALSE WHERE email = 'resident@email.com';
--
-- ============================================================================
