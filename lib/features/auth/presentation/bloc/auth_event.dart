part of 'auth_bloc.dart';

/// Base class for all authentication events.
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check if user is already authenticated on app start.
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// User requested to sign in.
class AuthSignInRequested extends AuthEvent {
  final String email;

  const AuthSignInRequested({
    required this.email,
  });

  @override
  List<Object?> get props => [email];
}

/// User requested to sign up.
class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String phone;
  final String fullName;
  final String? address;

  const AuthSignUpRequested({
    required this.email,
    required this.phone,
    required this.fullName,
    this.address,
  });

  @override
  List<Object?> get props => [email, phone, fullName, address];
}

/// User requested to verify OTP.
class AuthVerifyOtpRequested extends AuthEvent {
  final String otp;

  const AuthVerifyOtpRequested({required this.otp});

  @override
  List<Object?> get props => [otp];
}

/// User requested to resend OTP.
class AuthResendOtpRequested extends AuthEvent {
  const AuthResendOtpRequested();
}

/// User requested to set up 2FA.
class AuthSetup2FARequested extends AuthEvent {
  const AuthSetup2FARequested();
}

/// User submitted 2FA verification code.
class AuthVerify2FARequested extends AuthEvent {
  final String code;

  const AuthVerify2FARequested({required this.code});

  @override
  List<Object?> get props => [code];
}

/// User requested to sign out.
class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

/// Auth state changed externally (e.g., token expired).
class AuthStateChanged extends AuthEvent {
  final bool isAuthenticated;

  const AuthStateChanged({required this.isAuthenticated});

  @override
  List<Object?> get props => [isAuthenticated];
}

/// User requested to update profile.
class AuthUpdateProfileRequested extends AuthEvent {
  final String? fullName;
  final String? phone;
  final String? address;

  const AuthUpdateProfileRequested({this.fullName, this.phone, this.address});

  @override
  List<Object?> get props => [fullName, phone, address];
}

/// User requested to update email.
class AuthUpdateEmailRequested extends AuthEvent {
  final String newEmail;

  const AuthUpdateEmailRequested({required this.newEmail});

  @override
  List<Object?> get props => [newEmail];
}

/// User requested to delete their account.
class AuthDeleteAccountRequested extends AuthEvent {
  const AuthDeleteAccountRequested();

  @override
  List<Object?> get props => [];
}

/// User requested to cancel OTP verification and go back.
class AuthCancelOtpRequested extends AuthEvent {
  const AuthCancelOtpRequested();
}
