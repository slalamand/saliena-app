-- ============================================================================
-- VERIFICATION SCRIPT - Check if verified login is set up correctly
-- ============================================================================
-- Run this in Supabase SQL Editor to verify your setup
-- ============================================================================

-- Check 1: Does the can_skip_otp function exist?
SELECT 
  'can_skip_otp function' AS check_name,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM pg_proc 
      WHERE proname = 'can_skip_otp'
    ) THEN '✅ EXISTS'
    ELSE '❌ MISSING - Run 09_verified_login.sql'
  END AS status;

-- Check 2: Is the reviewer user verified?
SELECT 
  'reviewer@saliena-demo.com verified status' AS check_name,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM profiles 
      WHERE email = 'reviewer@saliena-demo.com' 
      AND is_verified = TRUE
    ) THEN '✅ VERIFIED'
    WHEN EXISTS (
      SELECT 1 FROM profiles 
      WHERE email = 'reviewer@saliena-demo.com'
    ) THEN '⚠️  USER EXISTS BUT NOT VERIFIED'
    ELSE '❌ USER NOT FOUND'
  END AS status;

-- Check 3: Test the can_skip_otp function
SELECT 
  'can_skip_otp test' AS check_name,
  CASE 
    WHEN can_skip_otp('reviewer@saliena-demo.com') = TRUE 
    THEN '✅ RETURNS TRUE'
    ELSE '❌ RETURNS FALSE'
  END AS status;

-- Show all users and their verification status
SELECT 
  email,
  is_verified,
  role,
  created_at
FROM profiles
ORDER BY created_at DESC;
