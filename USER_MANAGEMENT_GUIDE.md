# Saliena Estate - User Management Guide

## Overview

The Saliena Estate app uses **managed user creation** - residents cannot sign up themselves. All accounts are created by the management office.

## How It Works

1. **Management office creates accounts** for residents
2. **Residents log in** using their email address
3. **App sends OTP** to their email for verification
4. **No passwords needed** - everything is email-based

## Adding New Residents

### Method 1: Using Supabase Dashboard (Easiest)

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your project
3. Go to **Authentication** → **Users**
4. Click **"Add User"**
5. Enter resident's email
6. Set any temporary password (they won't use it)
7. Click **"Create User"**
8. Go to **Table Editor** → **profiles**
9. Find the new user and click to edit
10. Update their information:
    - **full_name**: "John Smith"
    - **phone**: "+1234567890" 
    - **address**: "Apt 123, Saliena Estate"
    - **role**: "resident"
    - **is_verified**: ✅ `true`

### Method 2: Using SQL Script (For Multiple Users)

1. Go to **SQL Editor** in Supabase Dashboard
2. Open the file `supabase/sql/07_add_user.sql`
3. Edit the variables at the top:
   ```sql
   user_email TEXT := 'resident@example.com';
   user_full_name TEXT := 'John Smith';
   user_phone TEXT := '+1234567890';
   user_address TEXT := 'Apt 123, Saliena Estate';
   user_role TEXT := 'resident';
   ```
4. Run the script
5. Repeat for each new resident

## User Roles

- **resident** - Can submit and view reports
- **worker** - Can update report status + all resident features  
- **office_admin** - Can manage users + all worker features

## How Residents Log In

1. Open the app
2. Enter their email address
3. Tap "Send verification code"
4. Check email for OTP code
5. Enter the code to log in

## Managing Existing Users

### View All Users
```sql
SELECT 
    email, full_name, phone, address, role, is_verified, created_at
FROM public.profiles 
ORDER BY created_at DESC;
```

### Change User Role
```sql
UPDATE public.profiles 
SET role = 'worker'  -- or 'office_admin'
WHERE email = 'user@example.com';
```

### Remove User
```sql
DELETE FROM public.profiles WHERE email = 'user@example.com';
```

## Troubleshooting

### "Signups not allowed for otp"
This error appears when:
- Public signup is enabled in Supabase (should be disabled)
- User tries to access signup screen (now removed)

**Fix**: The app now routes to login instead of signup.

### User Can't Log In
Check if:
- User exists in **Authentication** → **Users**
- User's profile has `is_verified = true`
- Email address is correct

### User Missing Profile Data
If a user exists in Auth but not in profiles table:
```sql
INSERT INTO public.profiles (id, email, full_name, role, is_verified)
SELECT id, email, 'Full Name Here', 'resident', true
FROM auth.users 
WHERE email = 'user@example.com';
```

## Security Notes

- ✅ Public signup is disabled
- ✅ Only management can create accounts  
- ✅ All authentication uses email OTP (no passwords)
- ✅ Users are verified by management (`is_verified = true`)
- ✅ Role-based permissions control access

## Quick Setup Checklist

- [ ] Disable public signup in Supabase Auth settings
- [ ] Create first admin user with role `office_admin`
- [ ] Test login flow with OTP
- [ ] Add resident accounts as needed
- [ ] Verify app routes to login (not signup)

## Support

If you need help:
1. Check this guide first
2. Review the SQL scripts in `supabase/sql/`
3. Check Supabase dashboard for user status
4. Verify database permissions and RLS policies