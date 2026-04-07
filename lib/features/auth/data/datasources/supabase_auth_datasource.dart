import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:saliena_app/core/error/exceptions.dart' as app_exceptions;
import 'package:saliena_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:saliena_app/features/auth/data/models/user_model.dart';
import 'package:saliena_app/features/auth/domain/entities/user.dart';

/// Supabase implementation of AuthRemoteDataSource.
class SupabaseAuthDataSource implements AuthRemoteDataSource {
  final SupabaseClient _client;

  SupabaseAuthDataSource(this._client);

  @override
  Future<UserModel> signUp({
    required String email,
    required String phone,
    required String fullName,
    String? address,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final randomPassword = 'Aa1${timestamp}xYz';

      final response = await _client.auth.signUp(
        email: email,
        password: randomPassword,
      );

      if (response.user == null) {
        throw const app_exceptions.AppAuthException(message: 'Sign up failed');
      }

      return UserModel(
        id: response.user!.id,
        email: email,
        phone: phone,
        fullName: fullName,
        address: address,
        role: UserRole.resident,
        isVerified: false,
        isEmailVerified: false,
        twoFactorEnabled: false,
        createdAt: DateTime.now(),
      );
    } on AuthException catch (e) {
      throw app_exceptions.AppAuthException(
        message: e.message,
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw app_exceptions.ServerException(
        message: 'An unexpected error occurred',
        originalError: e,
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw app_exceptions.ServerException(
        message: 'Failed to sign out',
        originalError: e,
      );
    }
  }

  @override
  Future<void> sendPhoneOtp(String phone) async {
    try {
      await _client.auth.signInWithOtp(phone: phone);
    } on AuthException catch (e) {
      throw app_exceptions.AppAuthException(
        message: e.message,
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw app_exceptions.AppAuthException(
        message: 'Failed to send phone OTP: ${e.toString()}',
        originalError: e,
      );
    }
  }

  @override
  Future<void> verifyPhoneOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      try {
        await _client.auth.verifyOTP(
          phone: phone,
          token: otp,
          type: OtpType.phoneChange,
        );
      } on AuthException {
        await _client.auth.verifyOTP(
          phone: phone,
          token: otp,
          type: OtpType.sms,
        );
      }

      final userId = _client.auth.currentUser?.id;
      if (userId != null) {
        await _client.from('profiles').update({'phone': phone}).eq('id', userId);
        await _client.auth.refreshSession();
      }
    } on AuthException catch (e) {
      throw app_exceptions.AppAuthException(
        message: e.message,
        code: e.code,
        originalError: e,
      );
    }
  }

  /// Sends a 6-digit email OTP via Supabase signInWithOtp.
  ///
  /// THE CRITICAL FIX (sendEmailOtp):
  ///
  /// The gotrue-dart package throws TWO different exception types from the
  /// same network call:
  ///
  ///   • AuthApiException  — 4xx responses (bad request, not found, etc.)
  ///   • AuthRetryableFetchException — 5xx responses (server error, e.g. the
  ///     "Error sending magic link email" 500 that occurs when Supabase's
  ///     email service is not configured).
  ///
  /// Both are direct subclasses of AuthException — they are SIBLINGS, not
  /// parent/child.  Catching only AuthApiException silently lets
  /// AuthRetryableFetchException escape through the entire call stack
  /// (datasource → repository → bloc event handler), causing the BLoC to
  /// throw, the state to stay at AuthLoading, and the user to see a DartError.
  ///
  /// The fix: catch AuthException (the common base class) so that ALL
  /// supabase auth exceptions — including 500-series retryable ones — are
  /// converted to AppAuthException before they leave this method.
  @override
  Future<void> sendEmailOtp(String email) async {
    try {
      // Primary attempt: user should already exist in auth.users.
      await _client.auth.signInWithOtp(
        email: email,
        shouldCreateUser: false,
      );
    } on AuthException catch (firstError) {
      // AuthException is the base class for ALL gotrue exceptions:
      //   AuthApiException (4xx), AuthRetryableFetchException (5xx),
      //   AuthUnknownException, AuthSessionMissingException, etc.
      // Catching it here means nothing can escape uncaught.
      debugPrint(
        '=== sendEmailOtp(shouldCreateUser:false) failed: '
        '${firstError.runtimeType}: ${firstError.message} '
        '[statusCode: ${firstError.statusCode}]',
      );

      // 422 from Supabase means the email is not in auth.users yet
      // (management-created profiles that never went through normal sign-up).
      // Retry allowing user creation so Supabase creates the auth account.
      final isUserNotFound = firstError.statusCode == '422' ||
          firstError.message.toLowerCase().contains('not found') ||
          firstError.message.toLowerCase().contains('not registered') ||
          firstError.message.toLowerCase().contains('user not found');

      if (isUserNotFound) {
        debugPrint('=== Retrying sendEmailOtp with shouldCreateUser:true');
        try {
          await _client.auth.signInWithOtp(
            email: email,
            shouldCreateUser: true,
          );
          return; // success on retry — exit cleanly
        } on AuthException catch (retryError) {
          throw app_exceptions.AppAuthException(
            message: retryError.message,
            code: retryError.code,
            originalError: retryError,
          );
        } catch (retryFallback) {
          throw app_exceptions.AppAuthException(
            message: 'Failed to send OTP: ${retryFallback.toString()}',
            originalError: retryFallback,
          );
        }
      }

      // Any other error (incl. 500 "Error sending magic link email"):
      // convert to AppAuthException so the repository returns Result.failure
      // and the bloc can handle it gracefully (navigate to OTP screen + Resend).
      throw app_exceptions.AppAuthException(
        message: firstError.message,
        code: firstError.code,
        originalError: firstError,
      );
    } catch (e) {
      // Belt-and-braces: catch absolutely anything that isn't AuthException.
      if (e is app_exceptions.AppAuthException) rethrow;
      throw app_exceptions.AppAuthException(
        message: 'Failed to send verification code: ${e.toString()}',
        originalError: e,
      );
    }
  }

  @override
  Future<void> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _client.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.email,
      );

      if (response.session == null) {
        throw const app_exceptions.AppAuthException(
          message: 'Verification failed - invalid or expired code',
        );
      }

      await _client.auth.refreshSession();
    } on app_exceptions.AppAuthException {
      rethrow;
    } on AuthException catch (e) {
      // Catches AuthApiException, AuthRetryableFetchException, etc.
      throw app_exceptions.AppAuthException(
        message: e.message,
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw app_exceptions.AppAuthException(
        message: 'Verification failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  @override
  Future<String> setup2FA() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw const app_exceptions.AppAuthException(message: 'Not authenticated');
      }

      final profile = await _client
          .from('profiles')
          .select('phone')
          .eq('id', userId)
          .single();

      final phone = profile['phone'] as String?;
      if (phone == null || phone.isEmpty) {
        throw const app_exceptions.AppAuthException(message: 'No phone number on file');
      }

      await _client.auth.signInWithOtp(phone: phone);
      return phone;
    } on app_exceptions.AppAuthException {
      rethrow;
    } on AuthException catch (e) {
      throw app_exceptions.AppAuthException(
        message: e.message,
        code: e.code,
        originalError: e,
      );
    } on PostgrestException catch (e) {
      throw app_exceptions.ServerException(
        message: e.message,
        code: e.code,
        originalError: e,
      );
    }
  }

  @override
  Future<void> verify2FA(String code) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw const app_exceptions.AppAuthException(message: 'Not authenticated');
      }

      final profile = await _client
          .from('profiles')
          .select('phone')
          .eq('id', userId)
          .single();

      final phone = profile['phone'] as String?;
      if (phone == null || phone.isEmpty) {
        throw const app_exceptions.AppAuthException(message: 'No phone number on file');
      }

      await _client.auth.verifyOTP(
        phone: phone,
        token: code,
        type: OtpType.sms,
      );

      await _client.from('profiles').update({
        'two_factor_enabled': true,
      }).eq('id', userId);
    } on app_exceptions.AppAuthException {
      rethrow;
    } on AuthException catch (e) {
      throw app_exceptions.AppAuthException(
        message: e.message,
        code: e.code,
        originalError: e,
      );
    } on PostgrestException catch (e) {
      throw app_exceptions.ServerException(
        message: e.message,
        code: e.code,
        originalError: e,
      );
    }
  }

  @override
  Future<void> disable2FA() async {
    try {
      final factors = await _client.auth.mfa.listFactors();
      for (final factor in factors.totp) {
        await _client.auth.mfa.unenroll(factor.id);
      }

      final userId = _client.auth.currentUser?.id;
      if (userId != null) {
        await _client.from('profiles').update({
          'two_factor_enabled': false,
        }).eq('id', userId);
      }
    } on AuthException catch (e) {
      throw app_exceptions.AppAuthException(
        message: e.message,
        code: e.code,
        originalError: e,
      );
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;
      return await _fetchUserProfile(user.id);
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    try {
      return _client.auth.onAuthStateChange.asyncMap((event) async {
        if (event.session?.user == null) return null;
        try {
          return await _fetchUserProfile(event.session!.user.id);
        } catch (e) {
          return null;
        }
      });
    } catch (e) {
      debugPrint('Warning: Auth state changes not available: $e');
      return Stream.value(null);
    }
  }

  @override
  Future<void> refreshSession() async {
    try {
      await _client.auth.refreshSession();
    } on AuthException catch (e) {
      throw app_exceptions.AppAuthException(
        message: e.message,
        code: e.code,
        originalError: e,
      );
    }
  }

  @override
  Future<UserModel> updateProfile({
    String? fullName,
    String? phone,
    String? address,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw const app_exceptions.AppAuthException(message: 'Not authenticated');
      }

      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (phone != null) updates['phone'] = phone;
      if (address != null) updates['address'] = address;

      await _client.from('profiles').update(updates).eq('id', userId);
      return await _fetchUserProfile(userId);
    } on PostgrestException catch (e) {
      throw app_exceptions.ServerException(
        message: e.message,
        code: e.code,
        originalError: e,
      );
    }
  }

  @override
  Future<void> updateEmail(String newEmail) async {
    try {
      await _client.auth.updateUser(UserAttributes(email: newEmail));
    } on AuthException catch (e) {
      throw app_exceptions.AppAuthException(
        message: e.message,
        code: e.code,
        originalError: e,
      );
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await _client.functions.invoke('delete_user');
      await signOut();
    } catch (e) {
      throw app_exceptions.ServerException(
        message: 'Failed to delete account',
        originalError: e,
      );
    }
  }

  Future<UserModel> _fetchUserProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      final currentUser = _client.auth.currentUser;
      final isEmailVerified =
          currentUser?.id == userId && currentUser?.emailConfirmedAt != null;

      return UserModel.fromJson(response, isEmailVerified: isEmailVerified);
    } on PostgrestException catch (e) {
      throw app_exceptions.ServerException(
        message: e.message,
        code: e.code,
        originalError: e,
      );
    }
  }

  @override
  Future<String> getLoginStatus(String email) async {
    try {
      final result = await _client.rpc(
        'get_login_status',
        params: {'p_email': email.toLowerCase().trim()},
      );
      return result as String? ?? 'not_found';
    } catch (e) {
      debugPrint('getLoginStatus error (defaulting to not_found): $e');
      return 'not_found';
    }
  }

  @override
  Future<bool> checkCanSkipOtp(String email) async {
    try {
      final result = await _client.rpc(
        'can_skip_otp',
        params: {'p_email': email.toLowerCase().trim()},
      );
      return result as bool? ?? false;
    } catch (e) {
      debugPrint('checkCanSkipOtp error (falling back to OTP): $e');
      return false;
    }
  }

  @override
  Future<UserModel> signInAsVerifiedUser(String email) async {
    try {
      final response = await _client.functions.invoke(
        'auto_sign_in',
        body: {'email': email.toLowerCase().trim()},
      );

      final data = response.data as Map<String, dynamic>;

      if (data['skip_otp'] != true) {
        throw app_exceptions.AppAuthException(
          message: data['reason'] as String? ?? 'Verification required',
        );
      }

      final emailOtp = data['email_otp'] as String?;
      if (emailOtp == null || emailOtp.isEmpty) {
        throw const app_exceptions.AppAuthException(
          message: 'Invalid OTP code returned from server',
        );
      }

      final sessionResponse = await _client.auth.verifyOTP(
        email: email.toLowerCase().trim(),
        token: emailOtp,
        type: OtpType.email,
      );

      if (sessionResponse.session == null) {
        throw const app_exceptions.AppAuthException(
          message: 'Failed to establish session — please try again',
        );
      }

      return await _fetchUserProfile(sessionResponse.session!.user.id);
    } on app_exceptions.AppAuthException {
      rethrow;
    } on FunctionException catch (e) {
      throw app_exceptions.ServerException(
        message: e.reasonPhrase ?? 'Auto sign-in failed',
        originalError: e,
      );
    } on AuthException catch (e) {
      throw app_exceptions.AppAuthException(
        message: e.message,
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw app_exceptions.ServerException(
        message: 'Verified sign-in failed: ${e.toString()}',
        originalError: e,
      );
    }
  }
}
