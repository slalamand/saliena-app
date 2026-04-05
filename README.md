# Saliena App - Municipality Issue Reporting

A Flutter mobile application for reporting and managing municipality issues like potholes, broken streetlights, graffiti, and other infrastructure problems.

## Features

✨ **User Features:**
- Email OTP authentication (no passwords)
- Submit issue reports with up to 3 photos and/or 1 video (15 seconds max)
- Reports can be submitted without media (optional)
- GPS location automatically extracted from photo EXIF data (priority) or device GPS (fallback)
- Offline retry mechanism - reports queued when offline and auto-uploaded when connection restored
- View all reports on an interactive map
- Track status of submitted reports (pending → in progress → fixed)
- Multi-language support (English, Latvian, Russian)
- Modern, minimal Apple-inspired design

🔧 **Worker Features:**
- Update report status
- View reporter details
- Manage assigned tasks

👨‍💼 **Admin Features:**
- Manage user roles and permissions
- Delete inappropriate reports
- Full system access

## Tech Stack

- **Frontend:** Flutter 3.x
- **Backend:** Supabase (PostgreSQL, Auth, Storage, Realtime)
- **Maps:** Google Maps / OpenStreetMap
- **State Management:** Bloc pattern
- **Localization:** Flutter intl (en, lv, ru)

---

## 🚀 Quick Start for Clients

### Prerequisites

1. **Flutter SDK** (3.x or higher)
   - Install from: https://docs.flutter.dev/get-started/install

2. **Supabase Account**
   - Create at: https://supabase.com
   - You'll need to create a new project

3. **Code Editor**
   - VS Code (recommended) or Android Studio

---

## 📋 Complete Setup Guide

Follow these steps in order to set up the complete application.

### Step 1: Clone or Extract the Project

```bash
cd path/to/saliena_app
```

### Step 2: Install Flutter Dependencies

```bash
flutter pub get
```

### Step 3: Set Up Supabase Backend

This is the **most important step**. Your Supabase backend needs to be fully configured.

#### 3.1 Create Supabase Project

1. Go to https://supabase.com
2. Sign in or create an account
3. Click "New Project"
4. Fill in:
   - **Name:** Saliena App
   - **Database Password:** (create a strong password)
   - **Region:** Choose closest to your users
5. Wait for project to finish setting up (2-3 minutes)

#### 3.2 Get Your Supabase Credentials

1. In your Supabase project dashboard, go to **Settings > API**
2. Copy these values:
   - **Project URL:** `https://xxxxx.supabase.co`
   - **anon public key:** `eyJxxx...` (long string)

#### 3.3 Run SQL Setup Scripts

**IMPORTANT: Run these files in exact order!**

1. Open Supabase Dashboard → **SQL Editor**
2. Click "New Query"
3. Copy and paste the content of each file below, then click "Run"

Run in this order:

| Order | File | What it does | Time |
|-------|------|--------------|------|
| 1 | `supabase/sql/01_schema.sql` | Creates database tables and structure | 1-2s |
| 2 | `supabase/sql/02_functions.sql` | Creates automated functions and triggers | 1-2s |
| 3 | `supabase/sql/03_rls_policies.sql` | Sets up security rules (who can access what) | 1-2s |
| 4 | `supabase/sql/04_storage.sql` | Creates photo and video storage buckets | 1-2s |
| 5 | `supabase/sql/05_seed_data.sql` | *(OPTIONAL)* Adds test data for development | 1-2s |
| 6 | `supabase/sql/06_auth_config.sql` | *(DOCUMENTATION)* Email OTP configuration guide | Read only |

**To verify setup worked:**

Run this query in SQL Editor:
```sql
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;
```

You should see: `notifications`, `profiles`, `reports`, `user_roles`

**To verify storage buckets:**
```sql
SELECT id, name, public FROM storage.buckets ORDER BY name;
```

You should see: `avatars`, `report-photos`, `report-videos`

#### 3.4 Configure Email Authentication

1. Go to **Authentication > Providers**
2. Enable **Email** provider
3. Enable these options:
   - ✅ Confirm email
   - ✅ Secure email change
4. Go to **Authentication > Email Templates**
5. Select **"Magic Link"** template
6. Replace the body with:
   ```html
   <h2>Your verification code is: {{ .Token }}</h2>
   <p>This code will expire in 1 hour.</p>
   <p>If you didn't request this code, please ignore this email.</p>
   ```
7. Save changes

#### 3.5 Configure Environment Variables

1. Create a `.env` file in the project root:
   ```
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key-here
   ```

2. Replace `your-project` and `your-anon-key-here` with your actual values from Step 3.2

3. **NEVER commit this file to Git!** (It's already in `.gitignore`)

### Step 4: Run the App

```bash
# For iOS
flutter run -d ios

# For Android
flutter run -d android

# For web (testing only)
flutter run -d chrome
```

### Step 5: Test Everything

Follow the testing checklist in `supabase/SETUP_CHECKLIST.md`

---

## 📁 Project Structure

```
saliena_app/
├── lib/
│   ├── blocs/              # State management (Bloc pattern)
│   ├── models/             # Data models
│   ├── repositories/       # Data access layer
│   ├── screens/            # UI screens
│   ├── services/           # Business logic
│   ├── theme/              # Design system (colors, typography)
│   └── main.dart           # App entry point
├── assets/                 # Images, icons, fonts
├── l10n/                   # Localization files (en, lv, ru)
├── supabase/              # Backend configuration
│   ├── sql/               # Database setup scripts
│   │   ├── 01_schema.sql
│   │   ├── 02_functions.sql
│   │   ├── 03_rls_policies.sql
│   │   ├── 04_storage.sql
│   │   ├── 05_seed_data.sql
│   │   └── 06_auth_config.sql
│   ├── API_REFERENCE.md    # Complete API documentation
│   └── SETUP_CHECKLIST.md  # Detailed setup checklist
├── .env                    # Environment variables (create this!)
├── .env.example           # Environment template
└── README.md              # This file
```

---

## 📚 Documentation

### For Developers

- **`supabase/API_REFERENCE.md`** - Complete API documentation with code examples
- **`supabase/SETUP_CHECKLIST.md`** - Detailed setup checklist
- **`DESIGN_SYSTEM.md`** - UI design guidelines
- **`ARCHITECTURE.md`** - App architecture and patterns

### For Database Admins

All SQL files in `supabase/sql/` are heavily commented and explain:
- What each table/function does
- Why it's needed
- How it works
- Security considerations

---

## 🔐 Security

### Authentication
- **Email OTP only** - No passwords stored
- 6-digit codes sent via email
- Codes expire after 1 hour
- Rate limiting on auth requests

### Authorization
- **Row Level Security (RLS)** on all tables
- Users can only access their own data
- Workers can update report status
- Admins have full access

### Storage
- File size limits (5MB for photos, 2MB for avatars)
- Allowed file types: JPG, PNG, WEBP only
- Public read access for viewing
- Upload restricted to authenticated users

### API Keys
- ✅ **anon key** - Safe to use in client apps
- ❌ **service_role key** - NEVER expose to clients!

---

## 👥 User Roles

### Resident (Default)
- Submit reports
- View all reports
- Update/delete own pending reports
- View own profile

### Worker
- Everything residents can do, plus:
- Update report status (pending → in_progress → fixed)
- View reporter details
- Create notifications

### Office Admin
- Everything workers can do, plus:
- View all user profiles
- Change user roles
- Delete any report
- Full system access

**To change a user's role:**
1. Go to Supabase Dashboard → **Table Editor → profiles**
2. Find the user by email
3. Change the `role` column
4. User will have new permissions immediately

---

## 🌍 Localization

The app supports 3 languages:
- 🇬🇧 English (default)
- 🇱🇻 Latvian
- 🇷🇺 Russian

Language files are in `lib/l10n/`:
- `app_en.arb` - English
- `app_lv.arb` - Latvian
- `app_ru.arb` - Russian

Users can switch language in the app settings.

---

## 🐛 Troubleshooting

### "Failed to connect to Supabase"
- Check your `.env` file has correct URL and key
- Verify Supabase project is running
- Check your internet connection

### "Profile not created on signup"
- Verify you ran `02_functions.sql`
- Check trigger exists:
  ```sql
  SELECT * FROM pg_trigger WHERE tgname = 'on_auth_user_created';
  ```

### "Permission denied" errors
- Verify you ran `03_rls_policies.sql`
- Check user is verified (`is_verified = true` in profiles table)

### "Email not received"
- Check spam/junk folder
- Verify email templates are configured
- Check Supabase logs for errors

### Storage upload fails
- Check file size (max 5MB for photos)
- Check file type (JPG, PNG, WEBP only)
- Verify storage policies from `04_storage.sql` ran correctly

**More help:** See `supabase/SETUP_CHECKLIST.md` troubleshooting section

---

## 📱 Building for Production

### iOS

1. Update bundle identifier in `ios/Runner.xcodeproj`
2. Configure signing in Xcode
3. Update app icons and launch screen
4. Build:
   ```bash
   flutter build ios --release
   ```

### Android

1. Update package name in `android/app/build.gradle`
2. Generate signing key
3. Update app icons and launch screen
4. Build:
   ```bash
   flutter build apk --release
   # or
   flutter build appbundle --release
   ```

### Important for Production

- [ ] Change `.env` values to production Supabase project
- [ ] Update Site URL in Supabase Dashboard
- [ ] Configure custom email domain (optional)
- [ ] Enable Supabase backups
- [ ] Set up monitoring and alerts
- [ ] Review rate limiting settings

---

## 🔄 Updating the Database

If you need to add features or modify the database:

1. Make changes in a new SQL file (e.g., `07_my_changes.sql`)
2. Test in development first
3. Create a backup before running in production
4. Run the SQL in production Supabase
5. Update API_REFERENCE.md if APIs changed

---

## 📞 Support

### For Setup Questions
- Review `supabase/SETUP_CHECKLIST.md`
- Check `supabase/API_REFERENCE.md`

### For Technical Issues
- Supabase Documentation: https://supabase.com/docs
- Flutter Documentation: https://docs.flutter.dev

### For Code Issues
- Check existing issues in the project
- Review ARCHITECTURE.md for code structure

---

## 📄 License

[Your License Here]

---

## ✅ Setup Verification

Run through this quick checklist to verify everything is working:

- [ ] Supabase project created
- [ ] All 6 SQL files run successfully
- [ ] Email authentication configured
- [ ] `.env` file created with correct credentials
- [ ] `flutter pub get` completed
- [ ] App runs without errors
- [ ] Can sign up with email
- [ ] Receive OTP code via email
- [ ] Can verify OTP and sign in
- [ ] Can create a report with up to 3 photos
- [ ] Can create a report with 1 video (15s max)
- [ ] Can create a report without media
- [ ] GPS extracted from photo EXIF data
- [ ] Report queued when offline
- [ ] Report auto-uploaded when connection restored
- [ ] Report appears on map
- [ ] Can switch languages

**All checked?** Congratulations! Your Saliena app is fully set up! 🎉

---

**Version:** 1.0  
**Created:** 2024  
**Flutter Version:** 3.x  
**Supabase Version:** Latest
