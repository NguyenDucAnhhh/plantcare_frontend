import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import 'package:dio/dio.dart';

class AdminDiagnosesNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  AdminDiagnosesNotifier() : super(const AsyncValue.loading()) {
    fetchDiagnoses();
  }

  String _status = 'all';
  int? _rating;
  String _confidence = 'all';
  String _search = '';
  int _page = 0;

  void setFilters({String? status, int? rating, String? confidence, String? search}) {
    if (status != null) _status = status;
    if (rating != null) _rating = rating == -99 ? null : rating; // -99 is our dummy value for clearing rating
    if (confidence != null) _confidence = confidence;
    if (search != null) _search = search;
    _page = 0; // reset page on filter change
    fetchDiagnoses();
  }

  Future<void> fetchDiagnoses({int page = 0}) async {
    try {
      if (page == 0) state = const AsyncValue.loading();
      
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
      _page = page;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> evaluateDiagnosis(int id, bool isCorrect, String note) async {
    try {
      final dio = ApiClient.instance;
      await dio.patch('/api/admin/diagnoses/$id/evaluate', data: {
        'isCorrect': isCorrect,
        'adminNote': note
      });
      fetchDiagnoses(page: _page); // Refresh current page
      return true;
    } catch (e) {
      return false;
    }
  }
}

final adminDiagnosesProvider = StateNotifierProvider<AdminDiagnosesNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  return AdminDiagnosesNotifier();
});
