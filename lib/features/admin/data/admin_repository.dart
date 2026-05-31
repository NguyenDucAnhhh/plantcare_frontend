import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class AdminRepository {
  final Dio _dio;

  AdminRepository() : _dio = ApiClient.instance;

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _dio.get('/api/admin/dashboard/stats');
      if (response.statusCode == 200) {
        return response.data;
      }
      return {};
    } catch (e) {
      throw Exception('Failed to get dashboard stats: $e');
    }
  }

  Future<Map<String, dynamic>> getUsers(int page, int size) async {
    try {
      final response = await _dio.get('/api/admin/users', queryParameters: {'page': page, 'size': size});
      if (response.statusCode == 200) {
        return response.data;
      }
      return {};
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  Future<void> toggleUserStatus(int id) async {
    try {
      await _dio.put('/api/admin/users/$id/toggle-status');
    } catch (e) {
      throw Exception('Failed to toggle user status: $e');
    }
  }

  Future<void> changeUserRole(int id, String role) async {
    try {
      await _dio.put('/api/admin/users/$id/role', queryParameters: {'role': role});
    } catch (e) {
      throw Exception('Failed to change user role: $e');
    }
  }

  Future<Map<String, dynamic>> getReports(int page, int size) async {
    try {
      final response = await _dio.get('/api/admin/reports', queryParameters: {'page': page, 'size': size});
      if (response.statusCode == 200) {
        return response.data;
      }
      return {};
    } catch (e) {
      throw Exception('Failed to get reports: $e');
    }
  }

  Future<void> resolveReport(int id, String action) async {
    try {
      await _dio.put('/api/admin/reports/$id/resolve', queryParameters: {'action': action});
    } catch (e) {
      throw Exception('Failed to resolve report: $e');
    }
  }
}
