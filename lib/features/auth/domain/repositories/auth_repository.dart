import 'package:saliena_app/core/utils/result.dart';
import 'package:saliena_app/features/auth/domain/entities/user.dart';

/// Abstract repository interface for authentication.
/// This interface defines the contract that any auth backend must implement.
/// Supabase implementation is in the data layer - easily swappable.
abstract class AuthRepository {
  /// Signs in a user with email only (sends OTP).
  Future<Result<void>> signIn({
    required String email,
  });

  /// Signs up a new user.
  Future<Result<User>> signUp({
    required String email,
    required String phone,
    required String fullName,
    String? address,
  });

  /// Signs out the current user.
  Future<Result<void>> signOut();

  /// Sends an OTP to the user's phone for verification.
  Future<Result<void>> sendPhoneOtp(String phone);

  /// Verifies the phone OTP.
  Future<Result<void>> verifyPhoneOtp({
    required String phone,
    required String otp,
  });

  /// Sends an OTP to the user's email for verification.
  Future<Result<void>> sendEmailOtp(String email);

  /// Verifies the email OTP.
  Future<Result<void>> verifyEmailOtp({
    required String email,
    required String otp,
  });

  /// Sets up 2FA for the current user.
  /// Returns the TOTP secret for the authenticator app.
  Future<Result<String>> setup2FA();

  /// Verifies the 2FA code during login.
  Future<Result<void>> verify2FA(String code);

  /// Disables 2FA for the current user.
  Future<Result<void>> disable2FA();

  /// Gets the currently authenticated user.
  Future<Result<User?>> getCurrentUser();

  /// Stream of auth state changes.
  Stream<User?> get authStateChanges;

  /// Refreshes the current session.
  Future<Result<void>> refreshSession();


  /// Updates the user's profile.
  Future<Result<User>> updateProfile({
    String? fullName,
    String? phone,
    String? address,
  });

  /// Updates the user's email address.
  Future<Result<void>> updateEmail(String newEmail);


  /// Deletes the user's account.
  Future<Result<void>> deleteAccount();

  /// Returns the login status for a given email address.
  /// Possible values: 'verified' | 'unverified' | 'not_found'
  ///   'verified'   → skip OTP, go straight to home
  ///   'unverified' → send OTP, show verification screen
  ///   'not_found'  → email not in system, show clear error
  Future<Result<String>> getLoginStatus(String email);

  /// Checks whether the given email belongs to a verified resident who can
  /// skip the OTP step. Returns true → skip OTP, false → send OTP.
  Future<Result<bool>> checkCanSkipOtp(String email);

  /// Signs in a verified resident directly without an OTP code.
  /// Fails with an AuthFailure if the user is not verified.
  Future<Result<User>> signInVerifiedUser(String email);
}
