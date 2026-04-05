import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:saliena_app/core/error/exceptions.dart' as app_exceptions;
import 'package:saliena_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:saliena_app/features/auth/data/models/user_model.dart';
import 'package:saliena_app/features/auth/domain/entities/user.dart';

/// Supabase implementation of AuthRemoteDataSource.
/// This class is the ONLY place where Supabase auth logic exists.
/// To swap backends, create a new implementation of AuthRemoteDataSource.
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
      // Generate a compliant random password since Supabase requires it, but we won't use it
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final randomPassword = 'Aa1${timestamp}xYz';
      
      // DO NOT pass metadata - trigger only inserts id, email, role
      // Profile fields (full_name, phone, address) are written AFTER login
      final response = await _client.auth.signUp(
        email: email,
        password: randomPassword,
      );

      if (response.user == null) {
        throw const app_exceptions.AppAuthException(message: 'Sign up failed');
      }

      // Return a minimal user model - profile fields will be updated after OTP verification
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
    } on AuthApiException catch (e) {
      throw app_exceptions.AppAuthException(
        message: e.message,
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      if (e is AuthException) rethrow;
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
      // Always use signInWithOtp to ensure an SMS is sent.
      // updateUser(phone: ...) acts as a "Phone Change" and may not send an SMS
      // if the phone number hasn't actually changed (which is the case during login verification).
      await _client.auth.signInWithOtp(phone: phone);
    } on AuthApiException catch (e) {
      throw app_exceptions.AppAuthException(
        message: e.message,
        code: e.code,
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
      // Try phoneChange verification first (common for authenticated users)
      try {
        await _client.auth.verifyOTP(
          phone: phone,
          token: otp,
          type: OtpType.phoneChange,
        );
      } on AuthException {
        // Fallback to SMS verification if phoneChange fails
        await _client.auth.verifyOTP(
          phone: phone,
          token: otp,
          type: OtpType.sms,
        );
      }
      
      // Sync phone to profile after verification
      final userId = _client.auth.currentUser?.id;
      if (userId != null) {
        await _client.from('profiles').update({
          'phone': phone,
        }).eq('id', userId);
        
        // Refresh session to ensure currentUser.phoneConfirmedAt is updated
        await _client.auth.refreshSession();
      }
    } on AuthApiException catch (e) {
      throw app_exceptions.AppAuthException(
        message: e.message,
        code: e.code,
        originalError: e,
      );
    }
  }

  @override
  Future<void> sendEmailOtp(String email) async {
    try {
      // Use signInWithOtp to generate an Email OTP (Magic Link code).
      // This is compatible with verifyOTP(type: OtpType.email).
      await _client.auth.signInWithOtp(
        email: email,
        shouldCreateUser: false,
      );
    } on AuthApiException catch (e) {
      throw app_exceptions.AppAuthException(
        message: e.message,
        code: e.code,
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
      // Verify using OtpType.email as requested.
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
      
      // Refresh session to ensure currentUser.emailConfirmedAt is updated in the local session
      await _client.auth.refreshSession();
    } on AuthApiException catch (e) {
      throw app_exceptions.AppAuthException(
        message: e.message,
        code: e.code,
        originalError: e,
      );
    } on AuthException catch (e) {
      throw app_exceptions.AppAuthException(
        message: e.message,
        originalError: e,
      );
    } catch (e) {
      if (e is app_exceptions.AppAuthException) rethrow;
      throw app_exceptions.AppAuthException(
        message: 'Verification failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  @override
  Future<String> setup2FA() async {
    try {
      // Get the user's phone number from their profile
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
      
      // Send OTP to the phone number
      await _client.auth.signInWithOtp(phone: phone);
      
      // Return the phone number so the UI can display it
      return phone;
    } on AuthApiException catch (e) {
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
      // Get the user's phone number from their profile
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
      
      // Verify the phone OTP
      await _client.auth.verifyOTP(
        phone: phone,
        token: code,
        type: OtpType.sms,
      );

      // Update profile to mark 2FA as enabled
      await _client.from('profiles').update({
        'two_factor_enabled': true,
      }).eq('id', userId);
    } on AuthApiException catch (e) {
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
    } on AuthApiException catch (e) {
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
      // If auth state changes can't be accessed, return empty stream
      debugPrint('Warning: Auth state changes not available: $e');
      return Stream.value(null);
    }
  }

  @override
  Future<void> refreshSession() async {
    try {
      await _client.auth.refreshSession();
    } on AuthApiException catch (e) {
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
      await _client.auth.updateUser(
        UserAttributes(email: newEmail),
      );
    } on AuthApiException catch (e) {
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
      // Call edge function — it handles actual auth user deletion server-side
      await _client.functions.invoke('delete_user');
      await signOut();
    } catch (e) {
      throw app_exceptions.ServerException(
        message: 'Failed to delete account',
        originalError: e,
      );
    }
  }

  /// Fetches the user profile from the profiles table.
  Future<UserModel> _fetchUserProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      final currentUser = _client.auth.currentUser;
      final isEmailVerified = currentUser?.id == userId && currentUser?.emailConfirmedAt != null;

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
  Future<bool> checkCanSkipOtp(String email) async {
    try {
      // Calls the SECURITY DEFINER SQL function — safe for anon callers.
      final result = await _client.rpc(
        'can_skip_otp',
        params: {'p_email': email.toLowerCase().trim()},
      );
      return result as bool? ?? false;
    } catch (e) {
      // If the RPC fails for any reason, fall back to normal OTP flow.
      debugPrint('checkCanSkipOtp error (falling back to OTP): $e');
      return false;
    }
  }

  @override
  Future<UserModel> signInAsVerifiedUser(String email) async {
    try {
      // Call the Edge Function — it uses the service-role key server-side
      // to generate a magic-link token via admin.generateLink().
      // The Flutter app exchanges that token via verifyOTP(type: magiclink)
      // to create a session, completely bypassing the OTP rate limiter.
      final response = await _client.functions.invoke(
        'auto_sign_in',
        body: {'email': email.toLowerCase().trim()},
      );

      final data = response.data as Map<String, dynamic>;

      if (data['skip_otp'] != true) {
        // Edge Function explicitly said OTP is still needed.
        throw app_exceptions.AppAuthException(
          message: data['reason'] as String? ?? 'Verification required',
        );
      }

      final token = data['token'] as String?;
      if (token == null || token.isEmpty) {
        throw const app_exceptions.AppAuthException(
          message: 'Invalid token returned from server',
        );
      }

      // Exchange the magic-link token for a live session.
      // verifyOTP with type magiclink is not subject to the email OTP
      // 60-second rate limit — no more "wait 58 s" error.
      final sessionResponse = await _client.auth.verifyOTP(
        email: email.toLowerCase().trim(),
        token: token,
        type: OtpType.magiclink,
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
    } on AuthApiException catch (e) {
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
