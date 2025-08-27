class AdminUser {
  final int id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String role;
  final bool enabled;
  final bool nonLocked;
  final bool nonExpired;

  AdminUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.enabled,
    required this.nonLocked,
    required this.nonExpired,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] ?? 0,
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      role: json['role'] ?? '',
      enabled: json['enabled'] ?? false,
      nonLocked: json['nonLocked'] ?? false,
      nonExpired: json['nonExpired'] ?? false,
    );
  }
}
