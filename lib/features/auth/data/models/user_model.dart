import 'package:saliena_app/features/auth/domain/entities/user.dart';

/// Data model for User that handles serialization.
/// This class knows about JSON/Supabase structure - domain entity does not.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.phone,
    required super.fullName,
    super.address,
    required super.role,
    required super.isVerified,
    required super.isEmailVerified,
    required super.twoFactorEnabled,
    required super.createdAt,
    super.updatedAt,
  });

  /// Creates a UserModel from a Supabase/JSON response.
  factory UserModel.fromJson(Map<String, dynamic> json, {bool isEmailVerified = false}) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String? ?? '',
      fullName: json['full_name'] as String,
      address: json['address'] as String?,
      role: UserRole.fromString(json['role'] as String? ?? 'resident'),
      isVerified: json['is_verified'] as bool? ?? false,
      isEmailVerified: isEmailVerified,
      twoFactorEnabled: json['two_factor_enabled'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Converts the model to JSON for Supabase/API.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'full_name': fullName,
      if (address != null) 'address': address,
      'role': role.toStorageString(),
      'is_verified': isVerified,
      'two_factor_enabled': twoFactorEnabled,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  /// Creates a UserModel from a domain User entity.
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      phone: user.phone,
      fullName: user.fullName,
      address: user.address,
      role: user.role,
      isVerified: user.isVerified,
      isEmailVerified: user.isEmailVerified,
      twoFactorEnabled: user.twoFactorEnabled,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  /// Converts to domain entity (already is one via inheritance).
  User toEntity() => this;
}
