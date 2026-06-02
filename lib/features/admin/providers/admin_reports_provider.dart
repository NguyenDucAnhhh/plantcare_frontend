import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/admin_repository.dart';
import '../models/admin_report_model.dart';
import 'admin_provider.dart';

import 'admin_posts_provider.dart';

class AdminReportsNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final AdminRepository _repository;
  final Ref _ref;

  AdminReportsNotifier(this._repository, this._ref) : super(const AsyncValue.loading()) {
    fetchReports();
  }

  Future<void> fetchReports({int page = 0, bool silent = false}) async {
    if (page == 0 && !silent) state = const AsyncValue.loading();
    try {
      final Map<String, dynamic> data = await _repository.getReports(page, 10);
      final content = data['content'] as List<dynamic>? ?? [];
      final parsedReports = content.map((r) => AdminReportModel.fromJson(r)).toList();
      data['content'] = parsedReports;
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> resolveReport(int id, String action) async {
    try {
      await _repository.resolveReport(id, action);
      fetchReports(silent: true);
      _ref.invalidate(adminPostsProvider);
    } catch (e) {
      rethrow;
    }
  }
}

final adminReportsProvider = StateNotifierProvider.autoDispose<AdminReportsNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  return AdminReportsNotifier(ref.read(adminRepositoryProvider), ref);
});

final reportSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');
final reportFilterStatusProvider = StateProvider.autoDispose<String>((ref) => 'all');
