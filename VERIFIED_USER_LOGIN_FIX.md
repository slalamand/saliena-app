# Verified User Login Fix

## Problem
When a verified user (with `is_verified = TRUE` in Supabase) tries to sign in, they are being sent to the OTP verification screen with a "wait 58 seconds" message instead of being signed in directly.

## Root Cause
The verified user login flow requires two components in Supabase:
1. SQL function `can_skip_otp()` - checks if user is verified
2. Edge Function `auto_sign_in` - generates magic link token for verified users

If either of these is missing or not deployed, the system falls back to the normal OTP flow.

## Solution Steps

### Step 1: Deploy the SQL Function

1. Go to your Supabase Dashboard: https://eaydzmsghcylzryfezab.supabase.co
2. Navigate to **SQL Editor**
3. Click **New Query**
4. Copy and paste the contents of `supabase/sql/09_verified_login.sql`
5. Click **Run** to execute the SQL

This will create the `can_skip_otp()` function that checks if a user is verified.

### Step 2: Deploy the Edge Function

You need to deploy the `auto_sign_in` Edge Function. Run these commands:

```bash
# Install Supabase CLI if you haven't already
npm install -g supabase

# Login to Supabase
supabase login

# Link your project
supabase link --project-ref eaydzmsghcylzryfezab

# Deploy the Edge Function
supabase functions deploy auto_sign_in
```

### Step 3: Verify the User is Marked as Verified

1. Go to your Supabase Dashboard
2. Navigate to **Table Editor** → **profiles**
3. Find the user `reviewer@saliena-demo.com`
4. Make sure the `is_verified` column is set to `TRUE` (checked)

### Step 4: Test the Login

1. Open the app
2. Enter `reviewer@saliena-demo.com`
3. Click "Send verification code"
4. You should now be signed in directly without seeing the OTP screen

## Debugging

If it still doesn't work after following the steps above:

### Check if the SQL function exists:
1. Go to Supabase Dashboard → SQL Editor
2. Run this query:
```sql
SELECT can_skip_otp('reviewer@saliena-demo.com');
```
3. It should return `true`

### Check if the Edge Function is deployed:
1. Go to Supabase Dashboard → Edge Functions
2. You should see `auto_sign_in` in the list
3. Check the logs for any errors

### Check the app logs:
1. Run the app in debug mode
2. Look for these log messages:
   - `=== Sign-in: canSkip=true for email=reviewer@saliena-demo.com`
   - `=== Verified user sign-in successful`
3. If you see `=== Verified user sign-in failed:`, the error message will tell you what went wrong

## Code Changes Made

I've updated `lib/features/auth/presentation/bloc/auth_bloc.dart` to:
1. Add debug logging to track the sign-in flow
2. Show a proper error message if the verified sign-in fails (instead of silently falling back to OTP)
3. This will help identify what's going wrong

## Quick Test Without Deployment

If you want to test that the code changes work before deploying to Supabase, you can temporarily set `is_verified = FALSE` for the user and test the normal OTP flow to make sure that still works.
