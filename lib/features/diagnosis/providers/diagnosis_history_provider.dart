import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

final diagnosisHistoryProvider = FutureProvider<List<dynamic>>((ref) async {
  final dio = ApiClient.instance;
  final response = await dio.get('/api/diagnosis/history');
  return response.data as List<dynamic>;
});
