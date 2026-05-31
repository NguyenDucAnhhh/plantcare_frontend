import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class DiagnosisHistoryNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  DiagnosisHistoryNotifier() : super(const AsyncValue.loading()) {
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    try {
      state = const AsyncValue.loading();
      final dio = ApiClient.instance;
      final response = await dio.get('/api/diagnosis/history');
      state = AsyncValue.data(response.data as List<dynamic>);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> rateDiagnosis(int id, int rating) async {
    try {
      final dio = ApiClient.instance;
      await dio.post('/api/diagnosis/$id/rate', data: {'rating': rating});
      fetchHistory(); // Refresh
      return true;
    } catch (e) {
      return false;
    }
  }
}

final diagnosisHistoryProvider = StateNotifierProvider<DiagnosisHistoryNotifier, AsyncValue<List<dynamic>>>((ref) {
  return DiagnosisHistoryNotifier();
});
