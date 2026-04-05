part of 'auth_bloc.dart';

/// Base class for all authentication states.
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any auth check.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state during auth operations.
class AuthLoading extends AuthState {
  final String? message;

  const AuthLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// User is not authenticated.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// User is authenticated.
class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

/// Waiting for OTP verification.
class AuthAwaitingOtpVerification extends AuthState {
  final String email;
  final String? phone;
  final String? fullName;
  final String? address;
  final String? errorMessage;

  const AuthAwaitingOtpVerification({
    required this.email,
    this.phone,
    this.fullName,
    this.address,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [email, phone, fullName, address, errorMessage];
}

/// Waiting for 2FA setup (for workers/staff).
class AuthAwaiting2FASetup extends AuthState {
  final User user;
  final String phoneNumber;

  const AuthAwaiting2FASetup({
    required this.user,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [user, phoneNumber];
}

/// Waiting for 2FA verification during login.
class AuthAwaiting2FAVerification extends AuthState {
  final User user;

  const AuthAwaiting2FAVerification({required this.user});

  @override
  List<Object?> get props => [user];
}

/// User is authenticated but not verified as Saliena resident.
class AuthAwaitingVerification extends AuthState {
  final User user;

  const AuthAwaitingVerification({required this.user});

  @override
  List<Object?> get props => [user];
}

/// Authentication error occurred.
class AuthError extends AuthState {
  final String message;
  final String? code;

  const AuthError({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

/// Profile was successfully updated.
class AuthProfileUpdated extends AuthState {
  final User user;

  const AuthProfileUpdated({required this.user});

  @override
  List<Object?> get props => [user];
}

/// Email update confirmation was sent.
class AuthEmailUpdateSent extends AuthState {
  const AuthEmailUpdateSent();
}

/// Password was successfully updated.
class AuthPasswordUpdated extends AuthState {
  const AuthPasswordUpdated();
}

/// Account was successfully deleted.
class AuthAccountDeleted extends AuthState {
  const AuthAccountDeleted();
}
