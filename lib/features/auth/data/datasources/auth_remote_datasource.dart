import 'package:saliena_app/features/auth/data/models/user_model.dart';

/// Abstract interface for remote auth data source.
/// This allows swapping Supabase for any other backend.
abstract class AuthRemoteDataSource {
  Future<UserModel> signUp({
    required String email,
    required String phone,
    required String fullName,
    String? address,
  });

  Future<void> signOut();

  Future<void> sendPhoneOtp(String phone);

  Future<void> verifyPhoneOtp({
    required String phone,
    required String otp,
  });

  Future<void> sendEmailOtp(String email);

  Future<void> verifyEmailOtp({
    required String email,
    required String otp,
  });

  Future<String> setup2FA();

  Future<void> verify2FA(String code);

  Future<void> disable2FA();

  Future<UserModel?> getCurrentUser();

  Stream<UserModel?> get authStateChanges;

  Future<void> refreshSession();


  Future<UserModel> updateProfile({
    String? fullName,
    String? phone,
    String? address,
  });

  /// Updates the user's email address.
  Future<void> updateEmail(String newEmail);

  Future<void> deleteAccount();

  /// Checks Supabase to see if this email's profile has is_verified = TRUE.
  /// Used before login to decide whether to skip the OTP screen.
  Future<bool> checkCanSkipOtp(String email);

  /// Signs in a verified user directly (no OTP required).
  /// Calls the auto_sign_in Edge Function, which generates a magic-link
  /// token server-side, then exchanges it for a real Supabase session.
  Future<UserModel> signInAsVerifiedUser(String email);
}
