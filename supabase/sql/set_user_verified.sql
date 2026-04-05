-- ============================================================================
-- QUICK FIX - Set reviewer user as verified
-- ============================================================================
-- Run this in Supabase SQL Editor to mark the reviewer user as verified
-- ============================================================================

-- Update the reviewer user to be verified
UPDATE profiles 
SET is_verified = TRUE 
WHERE email = 'reviewer@saliena-demo.com';

-- Verify the update worked
SELECT 
  email,
  is_verified,
  role,
  'User is now verified and can skip OTP' AS message
FROM profiles
WHERE email = 'reviewer@saliena-demo.com';
