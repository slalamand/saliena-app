import 'package:equatable/equatable.dart';

/// User roles in the Saliena app.
enum UserRole {
  resident,
  worker,
  officeAdmin;

  /// Returns true if this role can mark reports as fixed.
  bool get canFixReports => this == worker || this == officeAdmin;

  /// Returns true if this role requires 2FA.
  bool get requires2FA => this == worker || this == officeAdmin;

  /// Returns true if this role can verify other users.
  bool get canVerifyUsers => this == officeAdmin;

  /// Parses a role from a string.
  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'worker':
        return UserRole.worker;
      case 'office_admin':
      case 'officeadmin':
        return UserRole.officeAdmin;
      default:
        return UserRole.resident;
    }
  }

  /// Converts the role to a string for storage.
  String toStorageString() {
    switch (this) {
      case UserRole.resident:
        return 'resident';
      case UserRole.worker:
        return 'worker';
      case UserRole.officeAdmin:
        return 'office_admin';
    }
  }
}

/// Domain entity representing a user.
/// This is a pure Dart class with no framework dependencies.
class User extends Equatable {
  final String id;
  final String email;
  final String phone;
  final String fullName;
  final String? address;
  final UserRole role;
  final bool isVerified; // Admin verification
  final bool isEmailVerified; // Email address verification
  final bool twoFactorEnabled;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.phone,
    required this.fullName,
    this.address,
    required this.role,
    required this.isVerified,
    required this.isEmailVerified,
    required this.twoFactorEnabled,
    required this.createdAt,
    this.updatedAt,
  });

  /// Returns true if the user can access the app.
  bool get canAccessApp => isVerified;

  /// Returns true if the user needs to set up 2FA.
  bool get needs2FASetup => false; // 2FA is disabled per user request

  /// Creates a copy of this user with the given fields replaced.
  User copyWith({
    String? id,
    String? email,
    String? phone,
    String? fullName,
    String? address,
    UserRole? role,
    bool? isVerified,
    bool? isEmailVerified,
    bool? twoFactorEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      address: address ?? this.address,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        phone,
        fullName,
        address,
        role,
        isVerified,
        isEmailVerified,
        twoFactorEnabled,
        createdAt,
        updatedAt,
      ];
}
