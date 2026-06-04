import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';

class ProfileRepository {
  final Dio _dio = ApiClient.instance;

  Future<Map<String, dynamic>> getMyProfile() async {
    final response = await _dio.get(ApiConstants.myProfile);
    return response.data;
  }

  Future<List<dynamic>> getMyGardens() async {
    final response = await _dio.get(ApiConstants.gardens);
    return response.data as List<dynamic>;
  }

  Future<List<dynamic>> getMyPosts() async {
    final response = await _dio.get(ApiConstants.myPosts);
    return response.data as List<dynamic>;
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    await _dio.put(ApiConstants.myProfile, data: data);
  }

  Future<Map<String, dynamic>> uploadAvatar(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _dio.post(ApiConstants.updateAvatar, data: formData);
    return response.data;
  }

  Future<Map<String, dynamic>> getUserProfileById(String userId) async {
    final response = await _dio.get('${ApiConstants.userProfile}/$userId');
    return response.data;
  }

  Future<List<dynamic>> getUserPosts(String userId) async {
    try {
        final response = await _dio.get('${ApiConstants.userPosts}/$userId');
        return response.data;
    } catch(e) {
        return [];
    }
  }

  Future<List<dynamic>> searchUsers(String keyword) async {
    try {
      final response = await _dio.get(
        ApiConstants.searchUsers,
        queryParameters: {'keyword': keyword},
      );
      if (response.data != null) {
        return response.data as List<dynamic>;
      }
      return [];
    } catch (e) {
      throw Exception('Lỗi khi tìm kiếm người dùng: $e');
    }
  }


  Future<void> toggleFollow(String userId) async {
    await _dio.post(
      '${ApiConstants.userProfile}/$userId/follow',
      options: Options(responseType: ResponseType.plain),
    );
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _dio.put(
      ApiConstants.changePassword,
      data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
    );
  }

  Future<void> updateNotificationSettings(bool notifyAll, bool notifyCommunity, bool notifyReminder, bool notifySystem) async {
    await _dio.put(
      ApiConstants.notificationSettings,
      data: {
        'notifyAll': notifyAll,
        'notifyCommunity': notifyCommunity,
        'notifyReminder': notifyReminder,
        'notifySystem': notifySystem,
      },
    );
  }
}
