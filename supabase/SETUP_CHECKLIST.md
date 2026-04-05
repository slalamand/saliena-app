# Saliena App - Supabase Setup Checklist

Complete this checklist to fully configure your Supabase backend.

---

## Prerequisites

- [ ] Create a Supabase account at https://supabase.com
- [ ] Create a new Supabase project
- [ ] Note your project details:
  - Project URL: `https://[your-project].supabase.co`
  - Anon (public) key: `eyJ...`
  - Service role key: `eyJ...` (keep secret!)

---

## Step 1: SQL Setup (Run in Order)

Open Supabase Dashboard > SQL Editor and run these files in order:

- [ ] **01_schema.sql** - Creates tables and enums
  - Creates `profiles`, `reports`, `notifications`, `user_roles` tables
  - Creates `user_role` and `report_status` enums
  - Enables Row Level Security (RLS)
  - Expected duration: 1-2 seconds

- [ ] **02_functions.sql** - Creates database functions and triggers
  - Auto-creates profile on user signup
  - Auto-updates timestamps
  - Email verification sync
  - Expected duration: 1-2 seconds

- [ ] **03_rls_policies.sql** - Creates security policies
  - Controls who can access what data
  - Defines permissions for residents, workers, admins
  - Expected duration: 1-2 seconds

- [ ] **04_storage.sql** - Creates storage buckets and policies
  - Creates `report-photos` bucket (5MB limit)
  - Creates `avatars` bucket (2MB limit)
  - Sets up upload/download permissions
  - Expected duration: 1-2 seconds

- [ ] **05_seed_data.sql** - OPTIONAL: Adds test data
  - Creates sample reports
  - Creates sample notifications
  - Only for development/testing!
  - Expected duration: 1-2 seconds

- [ ] **06_auth_config.sql** - Authentication documentation
  - No SQL to run, just read the instructions
  - Explains email OTP setup

**Verification:**
```sql
-- Check tables were created
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Expected: notifications, profiles, reports, user_roles

-- Check functions were created
SELECT routine_name FROM information_schema.routines 
WHERE routine_schema = 'public' 
ORDER BY routine_name;

-- Expected: handle_new_user, is_email_verified, get_my_role, etc.
```

---

## Step 2: Authentication Configuration

### Enable Email Provider

- [ ] Go to: **Authentication > Providers > Email**
- [ ] Enable "Email" provider
- [ ] Enable "Confirm email"
- [ ] Enable "Secure email change"
- [ ] Save changes

### Configure Email OTP

- [ ] Go to: **Authentication > Settings**
- [ ] Set "OTP Expiry" to **3600 seconds** (1 hour)
- [ ] Confirm "OTP Length" is **6 digits**
- [ ] Save changes

### Customize Email Templates

- [ ] Go to: **Authentication > Email Templates**
- [ ] Select **"Magic Link"** template
- [ ] Update the template:

**Subject:**
```
Your Saliena verification code
```

**Body:**
```html
<h2>Your verification code is: {{ .Token }}</h2>
<p>This code will expire in 1 hour.</p>
<p>If you didn't request this code, please ignore this email.</p>
<p>- The Saliena Team</p>
```

- [ ] Save template
- [ ] Send a test email to verify it works

### Configure URLs

- [ ] Go to: **Authentication > URL Configuration**
- [ ] Set "Site URL" to your production URL (e.g., `https://saliena.com`)
- [ ] Add redirect URLs for your app:
  - `com.yourcompany.saliena://auth-callback`
  - `https://yourapp.com/auth/callback`
- [ ] Save changes

---

## Step 3: Storage Configuration

### Verify Buckets

- [ ] Go to: **Storage**
- [ ] Verify `report-photos` bucket exists
  - Public: YES
  - File size limit: 5MB
  - Allowed MIME types: image/jpeg, image/jpg, image/png, image/webp
- [ ] Verify `avatars` bucket exists
  - Public: YES
  - File size limit: 2MB
  - Allowed MIME types: image/jpeg, image/jpg, image/png, image/webp

### Test Upload

- [ ] Upload a test image to `report-photos`
  - Path: `reports/test/test.jpg`
  - Verify you can view it via public URL
- [ ] Delete the test image

---

## Step 4: Realtime Configuration

- [ ] Go to: **Database > Replication**
- [ ] Verify these tables are enabled for realtime:
  - [ ] `reports`
  - [ ] `notifications`
- [ ] If not enabled, add them:
  ```sql
  ALTER PUBLICATION supabase_realtime ADD TABLE reports;
  ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
  ```

---

## Step 5: Security Configuration

### API Keys

- [ ] Go to: **Settings > API**
- [ ] Copy the **anon (public) key** - Safe to use in client apps
- [ ] Copy the **service_role key** - NEVER expose to clients!
- [ ] Store keys securely (environment variables)

### Rate Limiting

- [ ] Go to: **Settings > API > Rate Limiting**
- [ ] Set appropriate limits:
  - API requests: 1000 per minute (default)
  - Storage uploads: 100 per minute (default)
  - Auth requests: 30 per hour per IP (default)

### CORS Settings

- [ ] Go to: **Settings > API > CORS**
- [ ] Add allowed origins for your app
- [ ] Or use `*` for development (change in production!)

---

## Step 6: Flutter App Configuration

### Update Environment Variables

- [ ] Create `.env` file in project root:
  ```
  SUPABASE_URL=https://your-project.supabase.co
  SUPABASE_ANON_KEY=your-anon-key
  ```

- [ ] Verify `.env` is in `.gitignore`

### Test Connection

- [ ] Run the Flutter app
- [ ] Verify Supabase client initializes
- [ ] Check console for connection errors

---

## Step 7: Testing

### Test Authentication

- [ ] Sign up with a new email
  - [ ] Verify you receive the OTP email
  - [ ] Verify you can enter the OTP and sign in
  - [ ] Verify profile is created in database
- [ ] Sign out
- [ ] Sign in with the same email
  - [ ] Verify you receive a new OTP
  - [ ] Verify you can sign in with the OTP

### Test Profile

- [ ] View your profile
- [ ] Update profile (name, phone, address)
- [ ] Upload an avatar
- [ ] Verify changes are saved

### Test Reports

- [ ] Create a new report with up to 3 photos
  - [ ] Upload 1 photo
  - [ ] Upload 2 photos
  - [ ] Upload 3 photos
  - [ ] Try to upload 4th photo (should be prevented)
- [ ] Create a report with 1 video (15s max)
  - [ ] Record video from camera
  - [ ] Select video from gallery
  - [ ] Verify duration validation (15s max)
  - [ ] Verify file size validation (10MB max)
- [ ] Create a report without media
  - [ ] Fill title and description only
  - [ ] Verify confirmation dialog appears
  - [ ] Submit successfully
- [ ] GPS from photo EXIF
  - [ ] Take photo with camera
  - [ ] Verify GPS extracted from photo
  - [ ] Verify green banner shows "Location from photo GPS"
- [ ] GPS fallback to device
  - [ ] Select photo without GPS data
  - [ ] Verify device GPS used
  - [ ] Verify banner shows "Location from device GPS"
- [ ] View report in feed
- [ ] View report on map
- [ ] Update report (if pending)
- [ ] Delete report (if pending)

### Test Offline Functionality

- [ ] Turn off WiFi/mobile data
- [ ] Create a report
  - [ ] Verify orange "Offline" banner appears
  - [ ] Submit report
  - [ ] Verify success message "Report queued for upload"
  - [ ] Verify navigated to Offline Queue screen
- [ ] View queued reports
  - [ ] Verify report appears in queue
  - [ ] Verify media count displayed
  - [ ] Verify timestamp displayed
- [ ] Turn on WiFi/mobile data
  - [ ] Verify auto-retry triggers
  - [ ] Verify success notification
  - [ ] Verify report removed from queue
  - [ ] Verify report appears in My Reports
- [ ] Manual retry
  - [ ] Queue multiple reports while offline
  - [ ] Go to Offline Queue screen
  - [ ] Tap "Retry All"
  - [ ] Verify all reports upload
- [ ] Delete from queue
  - [ ] Queue a report while offline
  - [ ] Delete from queue
  - [ ] Verify report removed

### Test Roles (if using test users)

Create test users with different roles via Dashboard:

- [ ] Create a `worker` user
  - [ ] Update their `role` in profiles table
  - [ ] Test updating report status
- [ ] Create an `office_admin` user
  - [ ] Update their `role` in profiles table
  - [ ] Test viewing all profiles
  - [ ] Test deleting reports

---

## Step 8: Production Preparation

### Security Review

- [ ] All tables have RLS enabled
- [ ] All storage buckets have appropriate policies
- [ ] Service role key is NEVER in client code
- [ ] Environment variables are properly secured
- [ ] Rate limiting is configured

### Performance

- [ ] All necessary indexes are created (done by SQL scripts)
- [ ] Realtime is only enabled for necessary tables
- [ ] Storage file size limits are appropriate

### Monitoring

- [ ] Go to: **Reports > API**
- [ ] Familiarize yourself with API usage metrics
- [ ] Go to: **Reports > Auth**
- [ ] Review authentication metrics

### Backup

- [ ] Go to: **Database > Backups**
- [ ] Verify automatic backups are enabled
- [ ] Note backup schedule (daily by default)

### Email Deliverability

- [ ] If using custom email domain:
  - [ ] Configure SPF records
  - [ ] Configure DKIM records
  - [ ] Configure DMARC records
  - [ ] Test email deliverability
- [ ] If using Supabase's email:
  - [ ] Consider upgrading to custom email provider for better deliverability

---

## Step 9: Documentation

- [ ] Share the following files with your team:
  - [ ] `SETUP_CHECKLIST.md` (this file)
  - [ ] `API_REFERENCE.md` (API documentation)
  - [ ] SQL files in `sql/` folder
- [ ] Document any custom changes you made
- [ ] Create admin guide for managing users/roles

---

## Troubleshooting

### Common Issues

**Problem:** Profile not created on signup  
**Solution:** Check that `handle_new_user` trigger is active:
```sql
SELECT * FROM pg_trigger WHERE tgname = 'on_auth_user_created';
```

**Problem:** RLS blocking queries  
**Solution:** Check your role and policies:
```sql
SELECT * FROM profiles WHERE id = auth.uid();
```

**Problem:** Storage upload fails  
**Solution:** Check bucket policies and file size limits

**Problem:** Realtime not working  
**Solution:** Verify table is in replication publication:
```sql
SELECT * FROM pg_publication_tables WHERE pubname = 'supabase_realtime';
```

**Problem:** OTP emails not arriving  
**Solution:**
- Check spam folder
- Verify email configuration in dashboard
- Check Supabase logs for email errors

### Get Help

- Supabase Documentation: https://supabase.com/docs
- Supabase Discord: https://discord.supabase.com
- Supabase GitHub: https://github.com/supabase/supabase

---

## Setup Complete! 🎉

Once all checkboxes are marked, your Supabase backend is fully configured and ready for production use.

**Next Steps:**
1. Deploy your Flutter app
2. Monitor usage and performance
3. Regularly backup your database
4. Keep Supabase and dependencies updated

---

**Version:** 1.0  
**Last Updated:** 2024
