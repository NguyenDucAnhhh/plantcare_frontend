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

  Future<Map<String, dynamic>> getUserProfileById(String userId) async {
    final response = await _dio.get('/api/users/$userId');
    return response.data;
  }

  Future<List<dynamic>> getUserPosts(String userId) async {
    // Currently backend doesn't have an endpoint for specific user's posts, 
    // but usually it's /api/users/{id}/posts or we filter from all posts.
    // I will mock this by getting all and filtering, or return empty if not supported
    try {
        final response = await _dio.get('/api/posts');
        final List<dynamic> allPosts = response.data;
        return allPosts.where((p) => p['authorId'].toString() == userId).toList();
    } catch(e) {
        return [];
    }
  }

  Future<void> toggleFollow(String userId) async {
    await _dio.post(
      '/api/users/$userId/follow',
      options: Options(responseType: ResponseType.plain),
    );
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _dio.put(
      '/api/users/me/change-password',
      data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
    );
  }

  Future<void> updateNotificationSettings(bool notifyAll, bool notifyCommunity, bool notifyReminder, bool notifySystem) async {
    await _dio.put(
      '/api/users/me/notification-settings',
      data: {
        'notifyAll': notifyAll,
        'notifyCommunity': notifyCommunity,
        'notifyReminder': notifyReminder,
        'notifySystem': notifySystem,
      },
    );
  }
}
