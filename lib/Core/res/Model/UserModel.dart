class UserModel {
  final int? id;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String? role;
  final bool? nonExpired;
  final bool? nonLocked;
  final bool? enabled;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    this.id,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.role,
    this.nonExpired,
    this.nonLocked,
    this.enabled,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      fullName: json['fullName'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      role: json['role'] as String?,
      nonExpired: json['nonExpired'] as bool?,
      nonLocked: json['nonLocked'] as bool?,
      enabled: json['enabled'] as bool?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'nonExpired': nonExpired,
      'nonLocked': nonLocked,
      'enabled': enabled,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
