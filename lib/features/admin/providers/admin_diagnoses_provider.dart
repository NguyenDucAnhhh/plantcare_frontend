import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_client.dart';

class AdminDiagnosesNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  AdminDiagnosesNotifier() : super(const AsyncValue.loading()) {
    fetchDiagnoses();
  }

  String _status = 'all';
  int? _rating;
  String _confidence = 'all';
  String _search = '';

  void setFilters({String? status, int? rating, String? confidence, String? search}) {
    if (status != null) _status = status;
    if (rating != null) _rating = rating == -99 ? null : rating; // -99 is our dummy value for clearing rating
    if (confidence != null) _confidence = confidence;
    if (search != null) _search = search;
    fetchDiagnoses();
  }

  Future<void> fetchDiagnoses({int page = 0, bool silent = false}) async {
    try {
      if (page == 0 && !silent) state = const AsyncValue.loading();
      
      final dio = ApiClient.instance;
      
      Map<String, dynamic> query = {
        'page': page,
        'size': 10,
      };
      
      if (_status != 'all') query['status'] = _status;
      if (_rating != null) query['rating'] = _rating;
      if (_confidence != 'all') query['confidence'] = _confidence;
      if (_search.isNotEmpty) query['search'] = _search;

      final response = await dio.get('/api/admin/diagnoses', queryParameters: query);
      
      if (page == 0) {
        state = AsyncValue.data(response.data as Map<String, dynamic>);
      } else {
        // Append data for pagination if needed, or if PaginatedDataTable handles its own, we just return the full page
        // Wait, PaginatedDataTable usually requires all data or a custom DataTableSource that fetches. 
        // We will just return the whole response and let DataTableSource handle or we fetch page by page.
        state = AsyncValue.data(response.data as Map<String, dynamic>);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> evaluateDiagnosis(int id, bool isCorrect, String note) async {
    try {
      final dio = ApiClient.instance;
      await dio.patch('/api/admin/diagnoses/$id/evaluate', data: {
        'isCorrect': isCorrect,
        'adminNote': note
      });
      
      if (state.hasValue) {
        final data = state.value!;
        final content = data['content'] as List<dynamic>? ?? [];
        final updatedList = content.map((diagDynamic) {
          if (diagDynamic is Map<String, dynamic> && diagDynamic['id'] == id) {
            final newDiag = Map<String, dynamic>.from(diagDynamic);
            newDiag['status'] = 'REVIEWED';
            newDiag['adminIsCorrect'] = isCorrect;
            newDiag['adminNote'] = note;
            return newDiag;
          }
          return diagDynamic;
        }).toList();
        data['content'] = updatedList;
        state = AsyncValue.data({...data});
      }
    } catch (e) {
      rethrow;
    }
  }
}

final adminDiagnosesProvider = StateNotifierProvider<AdminDiagnosesNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  return AdminDiagnosesNotifier();
});
