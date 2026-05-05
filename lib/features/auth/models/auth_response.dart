/// Model du lieu tra ve tu Spring Boot sau khi Login/Register thanh cong
class AuthResponse {
  final String token;
  final String email;
  final String fullName;
  final String role;

  AuthResponse({
    required this.token,
    required this.email,
    required this.fullName,
    required this.role,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      role: json['role'] ?? 'USER',
    );
  }
}
