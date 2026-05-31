class AdminUserModel {
  final int id;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final String role;
  final bool isActive;
  final String createdAt;
  final int postCount;

  AdminUserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.postCount,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['id'],
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      avatarUrl: json['avatarUrl'],
      role: json['role'] ?? 'USER',
      isActive: json['active'] ?? json['isActive'] ?? true,
      createdAt: json['createdAt'] ?? '',
      postCount: json['postCount'] ?? 0,
    );
  }
}
