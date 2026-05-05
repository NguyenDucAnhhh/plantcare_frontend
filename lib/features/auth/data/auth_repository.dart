import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/auth_response.dart';

/// Lop giao tiep voi Spring Boot - Chi lam dung 1 viec: Goi API
class AuthRepository {
  final Dio _dio = ApiClient.instance;

  /// Dang ky tai khoan moi
  Future<AuthResponse> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiConstants.register,
      data: {
        'fullName': fullName,
        'email': email,
        'password': password,
      },
    );
    final authResponse = AuthResponse.fromJson(response.data);
    await SecureStorage.saveToken(authResponse.token);
    await SecureStorage.saveEmail(authResponse.email);
    await SecureStorage.saveRole(authResponse.role ?? 'USER');
    return authResponse;
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    final authResponse = AuthResponse.fromJson(response.data);
    await SecureStorage.saveToken(authResponse.token);
    await SecureStorage.saveEmail(authResponse.email);
    await SecureStorage.saveRole(authResponse.role ?? 'USER');
    return authResponse;
  }

  /// Dang xuat - Xoa Token khoi ket sat
  Future<void> logout() async {
    await SecureStorage.clear();
  }
}
