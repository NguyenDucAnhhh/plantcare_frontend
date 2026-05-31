import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

final adminStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    final dio = ApiClient.instance;
    final response = await dio.get('/api/admin/dashboard/stats');
    return response.data as Map<String, dynamic>;
  } catch (e) {
    // Return dummy data on failure or if endpoint doesn't exist yet
    return {
      'totalUsers': 0,
      'totalPosts': 0,
      'totalReports': 0,
      'totalTips': 0,
    };
  }
});
