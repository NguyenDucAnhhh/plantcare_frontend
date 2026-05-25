import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final Dio _dio = ApiClient.instance;

  Future<List<NotificationModel>> getMyNotifications() async {
    try {
      final response = await _dio.get('/api/notifications');
      final data = response.data as List;
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải thông báo: $e');
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _dio.patch(
        '/api/notifications/$id/read',
        options: Options(responseType: ResponseType.plain),
      );
    } catch (e) {
      throw Exception('Lỗi khi đánh dấu đã đọc: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _dio.patch(
        '/api/notifications/read-all',
        options: Options(responseType: ResponseType.plain),
      );
    } catch (e) {
      throw Exception('Lỗi khi đánh dấu đã đọc tất cả: $e');
    }
  }
}
