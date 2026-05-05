import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Kho ket sat bao mat - Luu JWT Token ma khong lo bi lay cap
/// flutter_secure_storage su dung Android Keystore / iOS Keychain
class SecureStorage {
  SecureStorage._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _keyToken = 'jwt_token';
  static const _keyEmail = 'user_email';
  static const _keyRole = 'user_role';

  // === LUU TOKEN KHI DANG NHAP THANH CONG ===
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  // === LAY TOKEN DE GAN VAO HEADER ===
  static Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  // === LUU EMAIL NGUOI DUNG ===
  static Future<void> saveEmail(String email) async {
    await _storage.write(key: _keyEmail, value: email);
  }

  static Future<String?> getEmail() async {
    return await _storage.read(key: _keyEmail);
  }

  static Future<void> saveRole(String role) async {
    await _storage.write(key: _keyRole, value: role);
  }

  static Future<String?> getRole() async {
    return await _storage.read(key: _keyRole);
  }

  // === XOA TOKEN KHI DANG XUAT ===
  static Future<void> clear() async {
    await _storage.deleteAll();
  }

  // === KIEM TRA DA DANG NHAP CHUA ===
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
