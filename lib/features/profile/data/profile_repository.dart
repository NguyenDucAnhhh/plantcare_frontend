import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class ProfileRepository {
  final Dio _dio = ApiClient.instance;

  Future<Map<String, dynamic>> getMyProfile() async {
    final response = await _dio.get('/api/users/me');
    return response.data;
  }

  Future<List<dynamic>> getMyGardens() async {
    final response = await _dio.get('/api/gardens');
    return response.data as List<dynamic>;
  }

  Future<List<dynamic>> getMyPosts() async {
    final response = await _dio.get('/api/posts/me');
    return response.data as List<dynamic>;
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    await _dio.put('/api/users/me', data: data);
  }

  Future<Map<String, dynamic>> uploadAvatar(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _dio.post('/api/users/me/avatar/upload', data: formData);
    return response.data;
  }
}
