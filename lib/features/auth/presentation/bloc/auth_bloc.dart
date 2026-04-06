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
        },
      );
    } catch (e) {
      debugPrint('Failed to set up auth state listener: $e');
    }
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthAuthenticated) return;

    if (state is! AuthLoading) {
      emit(const AuthLoading(message: 'Checking authentication...'));
    }

    final result = await _authRepository.getCurrentUser();

    if (result.isFailure || result.value == null) {
      emit(const AuthUnauthenticated());
      return;
    }

    emit(AuthAuthenticated(user: result.value!));
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Checking account...'));

    // ── Step 1: check login status ────────────────────────────────────────
    final statusResult = await _authRepository.getLoginStatus(event.email);

    if (statusResult.isFailure) {
      emit(AuthError(message: statusResult.failure.message));
      return;
    }

    final status = statusResult.value ?? 'not_found';
    debugPrint('=== Sign-in: status=$status for email=${event.email}');

    // ── Step 2a: email not in our system ──────────────────────────────────
    if (status == 'not_found') {
      emit(const AuthError(
        message:
            'This email is not registered in our system. Please contact the management office.',
      ));
      return;
    }

    // ── Step 2b: verified resident — sign in directly, no OTP ─────────────
    if (status == 'verified') {
      emit(const AuthLoading(message: 'Signing you in...'));
      final signInResult =
          await _authRepository.signInVerifiedUser(event.email);

      if (signInResult.isSuccess) {
        debugPrint('=== Verified user sign-in successful');
        emit(AuthAuthenticated(user: signInResult.value!));
        return;
      }

      // Edge Function failed — fall back to OTP email.
      // Verified users NEVER see a terminal error.
      debugPrint(
          '=== Verified user auto-sign-in failed (falling back to OTP): '
          '${signInResult.failure.message}');
      await Future.delayed(const Duration(seconds: 2));
      emit(const AuthLoading(message: 'Sending verification code...'));
      final otpResult = await _authRepository.sendEmailOtp(event.email);
      if (otpResult.isSuccess) {
        emit(AuthAwaitingOtpVerification(email: event.email));
      } else {
        // OTP also failed — still show OTP screen so user can hit Resend.
        debugPrint(
            '=== OTP fallback also failed: ${otpResult.failure.message}');
        emit(AuthAwaitingOtpVerification(
          email: event.email,
          errorMessage:
              'Could not send a code automatically. Tap "Resend code" below.',
        ));
      }
      return;
    }

    // ── Step 2c: unverified resident — send OTP email ─────────────────────
    // IMPORTANT: Always navigate to the OTP screen regardless of whether the
    // email send succeeds.  The email service can return a 500
    // ("Error sending magic link email") for transient reasons or because
    // Supabase's SMTP is not yet configured, but the user may still receive
    // the code via a retry (Resend button) or the admin can supply it
    // directly.  Blocking the user on the login screen with an error is the
    // wrong UX — they should always reach the 6-digit input page.
    emit(const AuthLoading(message: 'Sending verification code...'));
    final result = await _authRepository.sendEmailOtp(event.email);

    if (result.isSuccess) {
      debugPrint('=== OTP sent to unverified user ${event.email}');
      emit(AuthAwaitingOtpVerification(email: event.email));
    } else {
      // Email delivery failed — navigate to OTP screen anyway so the user
      // can tap "Resend code" when the service recovers, or contact management.
      debugPrint(
          '=== OTP send failed for unverified user, navigating to OTP screen: '
          '${result.failure.message}');
      emit(AuthAwaitingOtpVerification(
        email: event.email,
        errorMessage:
            'We could not send a verification code right now. '
            'Tap "Resend code" to try again.',
      ));
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
      emit(AuthError(
          message: result.failure.message, code: result.failure.code));
      return;
    }

    final otpResult = await _authRepository.sendEmailOtp(event.email);

    if (otpResult.isSuccess) {
      emit(AuthAwaitingOtpVerification(
        email: event.email,
        phone: event.phone,
        fullName: event.fullName,
        address: event.address,
      ));
    } else {
      emit(AuthAwaitingOtpVerification(
        email: event.email,
        phone: event.phone,
        fullName: event.fullName,
        address: event.address,
        errorMessage:
            'Account created, but failed to send code: ${otpResult.failure.message}',
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

    if (fullName != null || phone != null || address != null) {
      debugPrint(
          '=== Updating profile with signup data: fullName=$fullName, phone=$phone, address=$address');
      await _authRepository.updateProfile(
        fullName: fullName,
        phone: phone,
        address: address,
      );
    }

    final userResult = await _authRepository.getCurrentUser();
    if (userResult.isSuccess && userResult.value != null) {
      debugPrint('=== OTP verified, emitting AuthAuthenticated');
      emit(AuthAuthenticated(user: userResult.value!));
    } else {
      debugPrint(
          '=== OTP verified but failed to fetch user, triggering auth check');
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
        errorMessage: null,
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
      emit(AuthError(
          message: result.failure.message, code: result.failure.code));
      return;
    }

    final phoneNumber = result.value;
    final userResult = await _authRepository.getCurrentUser();

    if (userResult.isSuccess && userResult.value != null) {
      emit(AuthAwaiting2FASetup(
          user: userResult.value!, phoneNumber: phoneNumber!));
    } else if (userResult.isFailure) {
      emit(AuthError(
          message: userResult.failure.message,
          code: userResult.failure.code));
    }
  }

  Future<void> _onVerify2FARequested(
    AuthVerify2FARequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Verifying 2FA code...'));

    final result = await _authRepository.verify2FA(event.code);

    if (result.isFailure) {
      emit(AuthError(
          message: result.failure.message, code: result.failure.code));
      return;
    }

    final userResult = await _authRepository.getCurrentUser();

    if (userResult.isSuccess && userResult.value != null) {
      emit(AuthAuthenticated(user: userResult.value!));
    } else if (userResult.isFailure) {
      emit(AuthError(
          message: userResult.failure.message,
          code: userResult.failure.code));
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
      emit(AuthError(
          message: result.failure.message, code: result.failure.code));
    }
  }

  void _onAuthStateChanged(
    AuthStateChanged event,
    Emitter<AuthState> emit,
  ) {
    debugPrint(
        '=== _onAuthStateChanged: isAuthenticated=${event.isAuthenticated}, currentState=${state.runtimeType}');

    if (event.isAuthenticated) {
      if (state is! AuthAuthenticated && state is! AuthLoading) {
        debugPrint('=== Session established, triggering auth check');
        add(const AuthCheckRequested());
      }
      return;
    }

    if (!event.isAuthenticated &&
        state is! AuthUnauthenticated &&
        state is! AuthAwaitingOtpVerification) {
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
      emit(AuthError(
          message: result.failure.message, code: result.failure.code));
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
      emit(AuthError(
          message: result.failure.message, code: result.failure.code));
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
      emit(AuthError(
          message: deleteResult.failure.message,
          code: deleteResult.failure.code));
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
