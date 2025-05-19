// lib/data/models/auth/user_model.dart
enum UserRole { tenant, landlord, admin }

class UserModel {
  final String id;
  final String? email;
  final String? phone;
  final String fullName;
  final UserRole role;
  final bool isVerified;
  final DateTime? createdAt;
  final String? photoUrl;

  UserModel({
    required this.id,
    this.email,
    this.phone,
    required this.fullName,
    required this.role,
    required this.isVerified,
    this.createdAt,
    this.photoUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      fullName: json['full_name'] as String,
      role: _parseUserRole(json['role'] as String),
      isVerified: json['is_verified'] as bool? ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
      photoUrl: json['photo_url'] as String?,
    );
  }

  static UserRole _parseUserRole(String role) {
    switch (role.toLowerCase()) {
      case 'landlord':
        return UserRole.landlord;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.tenant;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'full_name': fullName,
      'role': role.toString().split('.').last,
      'is_verified': isVerified,
      'created_at': createdAt?.toIso8601String(),
      'photo_url': photoUrl,
    };
  }
}