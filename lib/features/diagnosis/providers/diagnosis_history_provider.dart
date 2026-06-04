import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/diagnosis_repository.dart';

class DiagnosisHistoryNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  final DiagnosisRepository _repository;

  DiagnosisHistoryNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    try {
      state = const AsyncValue.loading();
      final data = await _repository.getDiagnosisHistory();
      state = AsyncValue.data(data);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> rateDiagnosis(int id, int rating) async {
    try {
      await _repository.rateDiagnosis(id, rating);
      fetchHistory(); // Refresh
      return true;
    } catch (e) {
      return false;
    }
  }
}

final diagnosisHistoryProvider = StateNotifierProvider<DiagnosisHistoryNotifier, AsyncValue<List<dynamic>>>((ref) {
  final repository = ref.watch(diagnosisRepositoryProvider);
  return DiagnosisHistoryNotifier(repository);
});
