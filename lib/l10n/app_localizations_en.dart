// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Saliena Support';

  @override
  String get welcome => 'Welcome to Saliena Support';

  @override
  String get welcomeSubtitle => 'Report issues in your municipality';

  @override
  String get municipality => 'Municipality';

  @override
  String get getStarted => 'Get Started';

  @override
  String get login => 'Log In';

  @override
  String get signIn => 'Sign In';

  @override
  String get signup => 'Sign Up';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get phone => 'Phone Number';

  @override
  String get fullName => 'Full Name';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get hasAccount => 'Already have an account?';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get signInSubtitle => 'Sign in to manage your municipality requests';

  @override
  String get createAccount => 'Create Account';

  @override
  String get joinCommunity => 'Join Saliena community';

  @override
  String get municipalityPortal => 'Municipality Portal';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetPasswordSubtitle =>
      'Enter your email to receive reset instructions';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get checkEmail => 'Check your email';

  @override
  String resetLinkSent(String email) {
    return 'We have sent a password reset link to $email';
  }

  @override
  String get backToSignIn => 'Back to Sign In';

  @override
  String get emailAddress => 'Email address';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get address => 'Residential Address';

  @override
  String get addressHint => 'Street, City, Postal Code';

  @override
  String get termsAgreement =>
      'By creating an account, you agree to our Terms of Service and Privacy Policy';

  @override
  String get emailRequired => 'Please enter your email';

  @override
  String get emailInvalid => 'Please enter a valid email';

  @override
  String get passwordRequired => 'Please enter your password';

  @override
  String passwordMinLength(int length) {
    return 'Password must be at least $length characters';
  }

  @override
  String get passwordUppercase => 'Password must contain an uppercase letter';

  @override
  String get passwordNumber => 'Password must contain a number';

  @override
  String get nameRequired => 'Please enter your full name';

  @override
  String get nameMinLength => 'Name must be at least 2 characters';

  @override
  String get phoneRequired => 'Please enter your phone number';

  @override
  String get phoneInvalid => 'Please enter a valid phone number';

  @override
  String get confirmPasswordRequired => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String signInWith(String provider) {
    return 'Sign in with $provider';
  }

  @override
  String get verifyPhone => 'Verify Email';

  @override
  String verifyPhoneSubtitle(String email) {
    return 'Enter the code sent to $email';
  }

  @override
  String get otpCode => 'Verification Code';

  @override
  String get resendCode => 'Resend Code';

  @override
  String resendCodeIn(int seconds) {
    return 'Resend code in ${seconds}s';
  }

  @override
  String get setup2FA => 'Set Up Two-Factor Authentication';

  @override
  String get setup2FASubtitle =>
      'Scan this QR code with your authenticator app';

  @override
  String get enter2FACode => 'Enter the 6-digit code from your app';

  @override
  String get verify => 'Verify';

  @override
  String get home => 'Home';

  @override
  String get map => 'Map';

  @override
  String get report => 'Report';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get createReport => 'Create Report';

  @override
  String get reportTitle => 'Title';

  @override
  String get reportTitleHint => 'Brief description of the issue';

  @override
  String get reportDescription => 'Description';

  @override
  String get reportDescriptionHint => 'Provide more details about the issue';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get choosePhoto => 'Choose from Gallery';

  @override
  String get location => 'Location';

  @override
  String get locationDetected => 'Location detected automatically';

  @override
  String get submit => 'Submit';

  @override
  String get submitting => 'Submitting...';

  @override
  String get reportStatus => 'Status';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusInProgress => 'In Progress';

  @override
  String get statusFixed => 'Fixed';

  @override
  String get markAsFixed => 'Mark as Fixed';

  @override
  String reportedBy(String name) {
    return 'Reported by $name';
  }

  @override
  String reportedOn(String date) {
    return 'Reported on $date';
  }

  @override
  String fixedBy(String name) {
    return 'Fixed by $name';
  }

  @override
  String get myReports => 'My Reports';

  @override
  String get communityReports => 'Community Reports';

  @override
  String get allReports => 'All Reports';

  @override
  String get noReports => 'No reports yet';

  @override
  String get noReportsSubtitle =>
      'Be the first to report an issue in your area';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get latvian => 'Latvian';

  @override
  String get russian => 'Russian';

  @override
  String get notifications => 'Notifications';

  @override
  String get security => 'Security';

  @override
  String get about => 'About';

  @override
  String get logout => 'Log Out';

  @override
  String get logoutConfirm => 'Are you sure you want to log out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get close => 'Close';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading...';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNetwork =>
      'No internet connection. Please check your network.';

  @override
  String get errorAuth => 'Authentication failed. Please try again.';

  @override
  String get errorPermission =>
      'You don\'t have permission to perform this action.';

  @override
  String get errorNotFound => 'The requested resource was not found.';

  @override
  String get errorValidation => 'Please check your input and try again.';

  @override
  String get permissionCamera => 'Camera permission is required to take photos';

  @override
  String get permissionLocation =>
      'Location permission is required to report issues';

  @override
  String get permissionStorage =>
      'Storage permission is required to save photos';

  @override
  String get grantPermission => 'Grant Permission';

  @override
  String get verificationPending => 'Verification Pending';

  @override
  String get verificationPendingSubtitle =>
      'Your account is being verified as a Saliena resident. This usually takes 1-2 business days.';

  @override
  String get twoFactorAuth => 'Two-Factor Authentication';

  @override
  String get twoFactorAuthSubtitle =>
      'Enter the code from your authenticator app';

  @override
  String get verifyPhoneNumber => 'Verify Email';

  @override
  String get verifyPhoneNumberSubtitle =>
      'Enter the verification code sent to your email';

  @override
  String get checkYourPhone => 'Check Your Email';

  @override
  String get checkYourPhoneDesc =>
      'A verification code has been sent to your email';

  @override
  String get codeSentTo => 'Code Sent To';

  @override
  String get codeSentToDesc => 'Enter the 6-digit code sent via email:';

  @override
  String get enterVerificationCode => 'Enter Verification Code';

  @override
  String get enterVerificationCodeDesc =>
      'Enter the 6-digit code from your email:';

  @override
  String get verifyCode => 'Verify Code';

  @override
  String get useDifferentAccount => 'Use a different account';

  @override
  String get accountInfo => 'Account Information';

  @override
  String get memberSince => 'Member since';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get changePassword => 'Change Password';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get filterReports => 'Filter Reports';

  @override
  String get applyFilters => 'Apply Filters';

  @override
  String get unknownLocation => 'Unknown location';

  @override
  String get gettingLocation => 'Getting location...';

  @override
  String get notSet => 'Not set';

  @override
  String get verified => 'Verified';

  @override
  String get pending => 'Pending';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String daysAgo(int days) {
    return '$days days ago';
  }

  @override
  String get chooseTheme => 'Choose Theme';

  @override
  String get reportIssue => 'Report Issue';

  @override
  String get addPhoto => 'Add a Photo';

  @override
  String get addPhotoSubtitle =>
      'Take or select a photo of the issue you want to report';

  @override
  String get confirmLocation => 'Confirm Location';

  @override
  String get confirmLocationSubtitle =>
      'Drag the map to adjust the exact location';

  @override
  String get addDetails => 'Add Details';

  @override
  String get addDetailsSubtitle =>
      'Describe the issue to help us understand the problem';

  @override
  String get reportSummary => 'Report Summary';

  @override
  String get photoAdded => 'Photo added';

  @override
  String get locationNotSet => 'Location not set';

  @override
  String get back => 'Back';

  @override
  String get continueStep => 'Continue';

  @override
  String get submitReport => 'Submit Report';

  @override
  String get reportsFeed => 'Reports Feed';

  @override
  String get viewOnMap => 'View on Map';

  @override
  String get deleteReport => 'Delete Report';

  @override
  String get markAsInProgress => 'Mark as In Progress';

  @override
  String get tapToAddPhoto => 'Tap to add photo';

  @override
  String get takePhotoOrGallery => 'Take a photo or choose from gallery';

  @override
  String get reportSubmittedSuccess => 'Report submitted successfully!';

  @override
  String get photoRequired => 'Please add a photo of the issue';

  @override
  String get locationRequired => 'Location Required';

  @override
  String get photo => 'Photo';

  @override
  String get details => 'Details';

  @override
  String get useMyLocation => 'Use my location';

  @override
  String get tapToSelectLocation => 'Tap on the map to select location';

  @override
  String get tapToReportNewIssue => 'Tap to report a new issue';

  @override
  String get viewAll => 'View All';

  @override
  String get verifyingLocation => 'Verifying location...';

  @override
  String get outsideServiceArea => 'Outside Service Area';

  @override
  String get locationPermissionDenied =>
      'Location permission denied. We need your location to verify residency.';

  @override
  String get locationServicesDisabled =>
      'Location services are disabled. Please enable GPS to continue.';

  @override
  String get signupRestrictedToResidents =>
      'Sign-up is restricted to Saliena residents only.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get enableGPS => 'Enable GPS';

  @override
  String get accountDeleted => 'Account deleted successfully';

  @override
  String get accountDeletedMessage =>
      'Your account has been permanently deleted.';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountConfirm =>
      'Are you sure you want to delete your account? This action cannot be undone.';

  @override
  String get deleteAccountWarning =>
      'All your data will be permanently deleted.';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signOutConfirm => 'Are you sure you want to sign out?';

  @override
  String get preferredLanguage => 'Preferred Language';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get mobileNumber => 'Mobile Number';

  @override
  String get residentialAddress => 'Residential Address';

  @override
  String get accountActions => 'Account';

  @override
  String get danger => 'Danger Zone';

  @override
  String get addMedia => 'Add Media';

  @override
  String get addMediaOptional => 'Add Media (Optional)';

  @override
  String addMediaSubtitle(int maxPhotos, int maxSeconds) {
    return 'Add up to $maxPhotos photos and 1 video ($maxSeconds sec max), or skip to continue without media';
  }

  @override
  String get addMoreMedia => 'Add more';

  @override
  String captureWithCamera(int maxPhotos) {
    return 'Capture with camera (up to $maxPhotos photos)';
  }

  @override
  String selectFromGallery(int maxPhotos) {
    return 'Select from gallery (up to $maxPhotos photos)';
  }

  @override
  String get chooseVideo => 'Choose Video';

  @override
  String selectShortVideo(int maxSeconds) {
    return 'Select a short video ($maxSeconds seconds max)';
  }

  @override
  String get noMediaUploaded => 'No media uploaded';

  @override
  String get reportDetails => 'Report Details';

  @override
  String get roleResident => 'Resident';

  @override
  String get roleWorker => 'Worker';

  @override
  String get roleOfficeAdmin => 'Office Admin';

  @override
  String get deleteReportConfirm =>
      'Are you sure you want to delete this report? This action cannot be undone.';

  @override
  String get reportDeleted => 'Report deleted successfully';

  @override
  String get reporterInfo => 'Reporter Information';

  @override
  String get reporterFullName => 'Full Name';

  @override
  String get reporterPhoneNumber => 'Phone Number';

  @override
  String get reports => 'Reports';

  @override
  String get locationFromPhoto => 'Location extracted from photo GPS';

  @override
  String get locationFromDevice => 'Using your current device location';

  @override
  String get locationManual => 'Location adjusted manually';

  @override
  String get dragToAdjust => 'Drag the map to adjust location';

  @override
  String get profileUpdated => 'Profile updated successfully';

  @override
  String get tapToViewAndRetry => 'Tap to view and retry';

  @override
  String get issues => 'Issues';

  @override
  String get aboutSaliena => 'About Saliena';

  @override
  String get developer => 'Developer';

  @override
  String get contact => 'Contact';

  @override
  String get website => 'Website';

  @override
  String get legal => 'Legal';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get openSourceLicenses => 'Open Source Licenses';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get emailSupport => 'Email Support';

  @override
  String get phoneSupport => 'Phone Support';

  @override
  String get frequentlyAskedQuestions => 'Frequently Asked Questions';

  @override
  String get supportHours => 'Support Hours';

  @override
  String get noMedia => 'No Media';

  @override
  String get areYouSureSubmitWithoutMedia =>
      'Are you sure you want to submit without photos or video?';

  @override
  String get submitAnyway => 'Submit Anyway';

  @override
  String get pleaseEnterTitle => 'Please enter a title';

  @override
  String get describeTheIssue => 'Describe the issue';

  @override
  String get noInternetConnection => 'No internet connection';

  @override
  String get reportDataNotFound => 'Report data not found';

  @override
  String deleteReportFromQueue(String title) {
    return 'Delete \"$title\" from queue?';
  }

  @override
  String get nameSurname => 'Name Surname';

  @override
  String get mobile => 'Mobile';

  @override
  String get recordVideo => 'Record Video';

  @override
  String recordVideoWithDuration(int maxSeconds) {
    return 'Record Video (${maxSeconds}s max)';
  }

  @override
  String get locationFromDeviceGPS => 'Location from device GPS';

  @override
  String maximumPhotosAllowed(int maxPhotos) {
    return 'Maximum $maxPhotos photos allowed';
  }

  @override
  String get onlyOneVideoAllowed => 'Only 1 video allowed per report';

  @override
  String onlyMorePhotosAllowed(int remaining) {
    return 'Only $remaining more photos allowed. Added first $remaining.';
  }
}
