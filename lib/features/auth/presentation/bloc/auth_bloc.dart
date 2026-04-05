import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:saliena_app/features/auth/domain/entities/user.dart';
import 'package:saliena_app/features/auth/domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// BLoC for managing authentication state.
/// Handles sign in, sign up, OTP verification, and 2FA flows.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _authStateSubscription;

  AuthBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthVerifyOtpRequested>(_onVerifyOtpRequested);
    on<AuthResendOtpRequested>(_onResendOtpRequested);
    on<AuthCancelOtpRequested>(_onCancelOtpRequested);
    on<AuthSetup2FARequested>(_onSetup2FARequested);
    on<AuthVerify2FARequested>(_onVerify2FARequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthStateChanged>(_onAuthStateChanged);
    on<AuthUpdateProfileRequested>(_onUpdateProfileRequested);
    on<AuthUpdateEmailRequested>(_onUpdateEmailRequested);
    on<AuthDeleteAccountRequested>(_onDeleteAccountRequested);

    // Listen to auth state changes with error handling
    try {
      _authStateSubscription = _authRepository.authStateChanges.listen(
        (user) {
          add(AuthStateChanged(isAuthenticated: user != null));
        },
        onError: (error) {
          debugPrint('Auth state change error: $error');
          // Don't crash the app, just log the error
        },
      );
    } catch (e) {
      debugPrint('Failed to set up auth state listener: $e');
      // Continue without the listener - auth will still work via manual checks
    }
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! AuthLoading) {
      emit(const AuthLoading(message: 'Checking authentication...'));
    }

    final result = await _authRepository.getCurrentUser();

    if (result.isFailure || result.value == null) {
      emit(const AuthUnauthenticated());
      return;
    }

    final user = result.value!;
    // Session exists = authenticated. Let user into app.
    // Admin verification (isVerified) is a separate concern handled in-app.
    emit(AuthAuthenticated(user: user));
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Checking account...'));

    // ── Step 1: check if this resident has is_verified = TRUE ────────────
    // This calls the can_skip_otp() SQL function (SECURITY DEFINER, anon-safe).
    // If anything goes wrong the check returns false and we fall through to OTP.
    final skipCheck = await _authRepository.checkCanSkipOtp(event.email);
    final canSkip = skipCheck.isSuccess && (skipCheck.value ?? false);

    if (canSkip) {
      // ── Step 2a: verified resident — sign in directly (no OTP screen) ──
      // Calls the auto_sign_in Edge Function which generates a server-side
      // magic-link token and returns it. We exchange it for a real session.
      final signInResult = await _authRepository.signInVerifiedUser(event.email);

      if (signInResult.isSuccess) {
        emit(AuthAuthenticated(user: signInResult.value!));
        return;
      }
      // Edge Function failed (e.g. token expired mid-flight) — fall through
      // to the OTP flow so the user is never completely blocked.
    }

    // ── Step 2b: not verified (or skip failed) — send OTP as normal ──────
    emit(const AuthLoading(message: 'Sending verification code...'));
    final result = await _authRepository.sendEmailOtp(event.email);

    if (result.isSuccess) {
      emit(AuthAwaitingOtpVerification(email: event.email));
    } else {
      emit(AuthError(message: result.failure.message, code: result.failure.code));
    }
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Creating account...'));

    final result = await _authRepository.signUp(
      email: event.email,
      phone: event.phone,
      fullName: event.fullName,
      address: event.address,
    );

    if (result.isFailure) {
      emit(AuthError(message: result.failure.message, code: result.failure.code));
      return;
    }

    // Send OTP for email verification
    final otpResult = await _authRepository.sendEmailOtp(event.email);
    
    if (otpResult.isSuccess) {
      emit(AuthAwaitingOtpVerification(
        email: event.email,
        phone: event.phone,
        fullName: event.fullName,
        address: event.address,
      ));
    } else {
      // Even if sending OTP fails, the account is created.
      // We show the error but still move to verification screen so they can try "Resend".
      emit(AuthAwaitingOtpVerification(
        email: event.email,
        phone: event.phone,
        fullName: event.fullName,
        address: event.address,
        errorMessage: 'Account created, but failed to send code: ${otpResult.failure.message}',
      ));
    }
  }

  Future<void> _onVerifyOtpRequested(
    AuthVerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint('=== _onVerifyOtpRequested called with OTP: ${event.otp}');
    final currentState = state;
    
    if (currentState is! AuthAwaitingOtpVerification) {
      debugPrint('=== EARLY RETURN: State is NOT AuthAwaitingOtpVerification!');
      return;
    }
    
    final email = currentState.email;
    final phone = currentState.phone;
    final fullName = currentState.fullName;
    final address = currentState.address;
    
    emit(const AuthLoading(message: 'Verifying code...'));

    final result = await _authRepository.verifyEmailOtp(
      email: email,
      otp: event.otp,
    );

    if (result.isFailure) {
      emit(AuthAwaitingOtpVerification(
        email: email,
        phone: phone,
        fullName: fullName,
        address: address,
        errorMessage: result.failure.message,
      ));
      return;
    }

    // OTP verified successfully - session is now established.
    // Update profile with signup data if available (fullName, phone, address)
    if (fullName != null || phone != null || address != null) {
      debugPrint('=== Updating profile with signup data: fullName=$fullName, phone=$phone, address=$address');
      await _authRepository.updateProfile(
        fullName: fullName,
        phone: phone,
        address: address,
      );
    }

    // Fetch user and emit AuthAuthenticated directly for reliable navigation
    final userResult = await _authRepository.getCurrentUser();
    if (userResult.isSuccess && userResult.value != null) {
      debugPrint('=== OTP verified, emitting AuthAuthenticated');
      emit(AuthAuthenticated(user: userResult.value!));
    } else {
      debugPrint('=== OTP verified but failed to fetch user, triggering auth check');
      add(const AuthCheckRequested());
    }
  }

  Future<void> _onResendOtpRequested(
    AuthResendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AuthAwaitingOtpVerification) return;

    emit(const AuthLoading(message: 'Sending new code...'));

    final result = await _authRepository.sendEmailOtp(currentState.email);

    if (result.isSuccess) {
      emit(AuthAwaitingOtpVerification(
        email: currentState.email,
        phone: currentState.phone,
        fullName: currentState.fullName,
        address: currentState.address,
        errorMessage: null, // Clear any previous error
      ));
    } else {
      emit(AuthAwaitingOtpVerification(
        email: currentState.email,
        phone: currentState.phone,
        fullName: currentState.fullName,
        address: currentState.address,
        errorMessage: result.failure.message,
      ));
    }
  }

  void _onCancelOtpRequested(
    AuthCancelOtpRequested event,
    Emitter<AuthState> emit,
  ) {
    emit(const AuthUnauthenticated());
  }

  Future<void> _onSetup2FARequested(
    AuthSetup2FARequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Setting up 2FA...'));

    final result = await _authRepository.setup2FA();

    if (result.isFailure) {
      emit(AuthError(message: result.failure.message, code: result.failure.code));
      return;
    }

    final phoneNumber = result.value;
    final userResult = await _authRepository.getCurrentUser();
    
    if (userResult.isSuccess && userResult.value != null) {
      emit(AuthAwaiting2FASetup(user: userResult.value!, phoneNumber: phoneNumber));
    } else if (userResult.isFailure) {
      emit(AuthError(message: userResult.failure.message, code: userResult.failure.code));
    }
  }

  Future<void> _onVerify2FARequested(
    AuthVerify2FARequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Verifying 2FA code...'));

    final result = await _authRepository.verify2FA(event.code);

    if (result.isFailure) {
      emit(AuthError(message: result.failure.message, code: result.failure.code));
      return;
    }

    final userResult = await _authRepository.getCurrentUser();
    
    if (userResult.isSuccess && userResult.value != null) {
      emit(AuthAuthenticated(user: userResult.value!));
    } else if (userResult.isFailure) {
      emit(AuthError(message: userResult.failure.message, code: userResult.failure.code));
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Signing out...'));

    final result = await _authRepository.signOut();

    if (result.isSuccess) {
      emit(const AuthUnauthenticated());
    } else {
      emit(AuthError(message: result.failure.message, code: result.failure.code));
    }
  }

  void _onAuthStateChanged(
    AuthStateChanged event,
    Emitter<AuthState> emit,
  ) {
    debugPrint('=== _onAuthStateChanged: isAuthenticated=${event.isAuthenticated}, currentState=${state.runtimeType}');
    
    // Session exists → trigger auth check to load user and go to app
    if (event.isAuthenticated) {
      // Always trigger auth check when session becomes valid
      // This handles post-OTP verification automatically
      if (state is! AuthAuthenticated) {
        debugPrint('=== Session established, triggering auth check');
        add(const AuthCheckRequested());
      }
      return;
    }
    
    // Session null → unauthenticated
    if (!event.isAuthenticated && state is! AuthUnauthenticated && state is! AuthAwaitingOtpVerification) {
      debugPrint('=== Session lost, going to unauthenticated');
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onUpdateProfileRequested(
    AuthUpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) return;

    emit(const AuthLoading(message: 'Updating profile...'));

    final result = await _authRepository.updateProfile(
      fullName: event.fullName,
      phone: event.phone,
      address: event.address,
    );

    if (result.isSuccess) {
      emit(AuthProfileUpdated(user: result.value));
      emit(AuthAuthenticated(user: result.value));
    } else {
      emit(AuthError(message: result.failure.message, code: result.failure.code));
      emit(currentState);
    }
  }

  Future<void> _onUpdateEmailRequested(
    AuthUpdateEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) return;

    emit(const AuthLoading(message: 'Updating email...'));

    final result = await _authRepository.updateEmail(event.newEmail);

    if (result.isSuccess) {
      emit(const AuthEmailUpdateSent());
      emit(currentState);
    } else {
      emit(AuthError(message: result.failure.message, code: result.failure.code));
      emit(currentState);
    }
  }


  Future<void> _onDeleteAccountRequested(
    AuthDeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    
    emit(const AuthLoading(message: 'Deleting account...'));

    final deleteResult = await _authRepository.deleteAccount();

    if (deleteResult.isSuccess) {
      emit(const AuthAccountDeleted());
      emit(const AuthUnauthenticated());
    } else {
      emit(AuthError(message: deleteResult.failure.message, code: deleteResult.failure.code));
      if (currentState is AuthAuthenticated) {
        emit(currentState);
      }
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
