# Saliena App - API Reference

Complete reference for interacting with the Supabase backend.

## Table of Contents
- [Authentication](#authentication)
- [Profiles](#profiles)
- [Reports](#reports)
- [Notifications](#notifications)
- [Storage](#storage)
- [Database Functions](#database-functions)

---

## Authentication

Saliena uses **Email OTP only** - no passwords required.

### Sign Up

```dart
final response = await supabase.auth.signUp(
  email: 'user@example.com',
  password: generateRandomPassword(), // Auto-generated, never shown to user
  data: {
    'full_name': 'John Doe',
    'phone': '+1234567890', // Optional
  },
);
```

**What happens:**
1. User account created in `auth.users`
2. Profile automatically created in `profiles` table via trigger
3. 6-digit OTP sent to email
4. User must verify OTP to complete signup

### Send OTP (Sign In)

```dart
final response = await supabase.auth.signInWithOtp(
  email: 'user@example.com',
  shouldCreateUser: false, // Don't create new user for signin
);
```

**What happens:**
1. 6-digit OTP sent to email
2. User enters OTP in app

### Verify OTP

```dart
final response = await supabase.auth.verifyOTP(
  email: 'user@example.com',
  token: '123456', // 6-digit code from email
  type: OtpType.email,
);
```

**Response:**
- Success: User session created, returns user and session data
- Failure: Returns error (invalid code, expired, etc.)

### Sign Out

```dart
await supabase.auth.signOut();
```

### Get Current User

```dart
final user = supabase.auth.currentUser;
final session = supabase.auth.currentSession;
```

---

## Profiles

User profile data extends `auth.users` with app-specific information.

### Get Own Profile

```dart
final response = await supabase
  .from('profiles')
  .select()
  .eq('id', supabase.auth.currentUser!.id)
  .single();
```

**Response:**
```json
{
  "id": "uuid",
  "email": "user@example.com",
  "full_name": "John Doe",
  "phone": "+1234567890",
  "address": "123 Main St",
  "role": "resident",
  "is_verified": true,
  "avatar_url": "https://...",
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T00:00:00Z"
}
```

### Update Own Profile

```dart
final response = await supabase
  .from('profiles')
  .update({
    'full_name': 'Jane Doe',
    'phone': '+9876543210',
    'address': '456 Oak St',
  })
  .eq('id', supabase.auth.currentUser!.id);
```

**Note:** Cannot update `role` or `is_verified` (restricted by RLS)

### Get All Profiles (Workers/Admins Only)

```dart
final response = await supabase
  .from('profiles')
  .select()
  .order('created_at', ascending: false);
```

**Permissions:**
- `resident`: Can only see own profile
- `worker`: Can see all profiles (for report details)
- `office_admin`: Can see and update all profiles

### Upload Avatar

```dart
final file = File('path/to/avatar.jpg');
final userId = supabase.auth.currentUser!.id;
final fileName = '$userId/avatar.jpg';

await supabase.storage
  .from('avatars')
  .upload(fileName, file, fileOptions: FileOptions(upsert: true));

final avatarUrl = supabase.storage
  .from('avatars')
  .getPublicUrl(fileName);

// Update profile with avatar URL
await supabase
  .from('profiles')
  .update({'avatar_url': avatarUrl})
  .eq('id', userId);
```

---

## Reports

Municipality issue reports with photos and GPS location.

### Create Report

```dart
// 1. Upload photos first (up to 3)
final photoUrls = <String>[];
for (var i = 0; i < photoFiles.length && i < 3; i++) {
  final file = photoFiles[i];
  final userId = supabase.auth.currentUser!.id;
  final fileName = 'reports/$userId/${DateTime.now().millisecondsSinceEpoch}_$i.jpg';

  await supabase.storage
    .from('report-photos')
    .upload(fileName, file);

  final photoUrl = supabase.storage
    .from('report-photos')
    .getPublicUrl(fileName);
  
  photoUrls.add(photoUrl);
}

// 2. Upload video (optional, max 15 seconds)
String? videoUrl;
if (videoFile != null) {
  final userId = supabase.auth.currentUser!.id;
  final fileName = 'reports/$userId/${DateTime.now().millisecondsSinceEpoch}_video.mp4';

  await supabase.storage
    .from('report-videos')
    .upload(fileName, videoFile);

  videoUrl = supabase.storage
    .from('report-videos')
    .getPublicUrl(fileName);
}

// 3. Create report record
final response = await supabase
  .from('reports')
  .insert({
    'user_id': userId,
    'title': 'Broken Streetlight',
    'description': 'The streetlight is not working...',
    'photo_url': photoUrls.isNotEmpty ? photoUrls.first : null, // First photo or null
    'video_url': videoUrl, // Can be null
    'latitude': 56.9496,
    'longitude': 24.1052,
    'address': 'Main Street, Riga',
    'location_source': 'photo_exif', // or 'device_gps', 'manual'
    'status': 'pending',
  })
  .select()
  .single();
```

**Requirements:**
- User must be verified (`is_verified = true`)
- Media is optional (both photo_url and video_url can be null)
- Location (lat/long) is required
- Photos: Maximum 3 per report
- Video: Maximum 1 per report, 15 seconds max, 10MB max
- Location source: `photo_exif` (priority), `device_gps` (fallback), or `manual`

### Get All Reports

```dart
final response = await supabase
  .from('reports')
  .select()
  .order('created_at', ascending: false);
```

**All authenticated users can view all reports** (for map display)

### Get Reports by Status

```dart
final response = await supabase
  .from('reports')
  .select()
  .eq('status', 'pending')
  .order('created_at', ascending: false);
```

**Status values:** `pending`, `in_progress`, `fixed`

### Get User's Reports

```dart
final response = await supabase
  .from('reports')
  .select()
  .eq('user_id', supabase.auth.currentUser!.id)
  .order('created_at', ascending: false);
```

### Get Reports with Reporter Details

```dart
// Use the custom function for joined data
final response = await supabase
  .rpc('get_reports_with_details', params: {
    'p_status': 'pending', // Optional: null for all
    'p_user_id': null, // Optional: filter by user
    'p_limit': 50,
    'p_offset': 0,
  });
```

**Response includes:**
- All report fields
- `reporter_name` (user's full name)
- `reporter_email`
- `fixer_name` (if fixed)

### Update Report (User)

```dart
// Users can only update their own pending reports
final response = await supabase
  .from('reports')
  .update({
    'title': 'Updated Title',
    'description': 'Updated description',
  })
  .eq('id', reportId)
  .eq('user_id', supabase.auth.currentUser!.id)
  .eq('status', 'pending');
```

### Update Report Status (Workers/Admins)

```dart
// Workers can update any report's status
final response = await supabase
  .from('reports')
  .update({
    'status': 'in_progress',
    // When marking as fixed:
    // 'status': 'fixed',
    // 'fixed_by': workerId,
    // 'fixed_at': DateTime.now().toIso8601String(),
  })
  .eq('id', reportId);
```

**Permissions:**
- `resident`: Can update own pending reports only
- `worker`: Can update any report's status
- `office_admin`: Can update and delete any report

### Delete Report

```dart
// Users can delete own pending reports
// Admins can delete any report
final response = await supabase
  .from('reports')
  .delete()
  .eq('id', reportId);
```

### Subscribe to Report Changes (Realtime)

```dart
final subscription = supabase
  .from('reports')
  .stream(primaryKey: ['id'])
  .listen((List<Map<String, dynamic>> data) {
    // Handle realtime updates
    print('Reports updated: $data');
  });

// Cancel subscription when done
subscription.cancel();
```

---

## Notifications

In-app notifications for users.

### Get User Notifications

```dart
final response = await supabase
  .from('notifications')
  .select()
  .eq('user_id', supabase.auth.currentUser!.id)
  .order('created_at', ascending: false);
```

**Response:**
```json
[
  {
    "id": "uuid",
    "user_id": "uuid",
    "title": "Report Status Updated",
    "body": "Your report is now in progress",
    "data": {"report_id": "uuid", "status": "in_progress"},
    "is_read": false,
    "created_at": "2024-01-01T00:00:00Z"
  }
]
```

### Get Unread Notifications

```dart
final response = await supabase
  .from('notifications')
  .select()
  .eq('user_id', supabase.auth.currentUser!.id)
  .eq('is_read', false)
  .order('created_at', ascending: false);
```

### Mark Notification as Read

```dart
await supabase
  .from('notifications')
  .update({'is_read': true})
  .eq('id', notificationId);
```

### Mark All Notifications as Read

```dart
await supabase
  .from('notifications')
  .update({'is_read': true})
  .eq('user_id', supabase.auth.currentUser!.id);
```

### Delete Notification

```dart
await supabase
  .from('notifications')
  .delete()
  .eq('id', notificationId);
```

### Create Notification (Workers/Admins)

```dart
// Only workers and admins can create notifications
await supabase
  .from('notifications')
  .insert({
    'user_id': recipientUserId,
    'title': 'Report Fixed',
    'body': 'Your report has been resolved',
    'data': {'report_id': reportId, 'status': 'fixed'},
  });
```

### Subscribe to Notifications (Realtime)

```dart
final subscription = supabase
  .from('notifications')
  .stream(primaryKey: ['id'])
  .eq('user_id', supabase.auth.currentUser!.id)
  .listen((List<Map<String, dynamic>> data) {
    // Handle new notifications
    print('New notification: $data');
  });
```

---

## Storage

File storage for report photos and user avatars.

### Buckets

1. **report-photos** (Public)
   - Max size: 5MB per photo
   - Formats: JPG, JPEG, PNG, WEBP
   - Path: `reports/{user_id}/{timestamp}_{index}.jpg`
   - Maximum 3 photos per report

2. **report-videos** (Public)
   - Max size: 10MB per video
   - Formats: MP4, MOV, AVI
   - Path: `reports/{user_id}/{timestamp}_video.mp4`
   - Maximum 1 video per report, 15 seconds max

3. **avatars** (Public)
   - Max size: 2MB
   - Formats: JPG, JPEG, PNG, WEBP
   - Path: `{user_id}/avatar.jpg`

### Upload Report Photo

```dart
final file = File('path/to/photo.jpg');
final userId = supabase.auth.currentUser!.id;
final fileName = 'reports/$userId/${Uuid().v4()}.jpg';

await supabase.storage
  .from('report-photos')
  .upload(fileName, file);

final publicUrl = supabase.storage
  .from('report-photos')
  .getPublicUrl(fileName);
```

### Delete Photo

```dart
await supabase.storage
  .from('report-photos')
  .remove([fileName]);
```

### Get Public URL

```dart
final url = supabase.storage
  .from('report-photos')
  .getPublicUrl('reports/user-id/photo.jpg');
```

---

## Database Functions

Custom SQL functions for complex queries.

### is_email_verified

Check if a user's email is verified.

```dart
final response = await supabase
  .rpc('is_email_verified', params: {
    'user_id': userId,
  });
// Returns: true or false
```

### get_my_role

Get the current user's role.

```dart
final response = await supabase.rpc('get_my_role');
// Returns: 'resident', 'worker', or 'office_admin'
```

### get_reports_with_details

Get reports with reporter and fixer information (see [Reports](#get-reports-with-reporter-details) section).

---

## Error Handling

Common error codes and handling:

```dart
try {
  final response = await supabase.from('reports').select();
} on PostgrestException catch (error) {
  // Database errors
  print('Error: ${error.message}');
  print('Code: ${error.code}');
} on AuthException catch (error) {
  // Authentication errors
  print('Auth Error: ${error.message}');
} catch (error) {
  // Other errors
  print('Unexpected Error: $error');
}
```

**Common Error Codes:**
- `PGRST116`: No rows returned (not found)
- `42501`: Insufficient privileges (RLS blocked)
- `23505`: Unique constraint violation
- `23503`: Foreign key violation

---

## Rate Limiting

Configure in Supabase Dashboard:
- API requests: 1000 per minute per user
- Storage uploads: 100 per minute per user
- Auth requests: 30 per hour per IP

---

## Testing

Use the test data from `05_seed_data.sql` for development:
- Sample users with different roles
- Sample reports with various statuses
- Sample notifications

---

## Support

- Supabase Documentation: https://supabase.com/docs
- Flutter Supabase Client: https://pub.dev/packages/supabase_flutter
- Issue Tracker: [Your repository]

---

**Version:** 1.0  
**Last Updated:** 2024
