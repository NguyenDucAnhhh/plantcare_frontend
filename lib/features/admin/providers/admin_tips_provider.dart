import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../tips/data/care_tip_model.dart';
import '../../tips/providers/care_tip_provider.dart';

final adminTipsProvider = StateNotifierProvider.autoDispose<AdminTipsNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  return AdminTipsNotifier(ref);
});

class AdminTipsNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final Dio _dio = ApiClient.instance;
  final Ref _ref;

  AdminTipsNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadTips();
  }

  Future<void> loadTips({int page = 0, bool silent = false}) async {
    if (page == 0 && !silent) state = const AsyncValue.loading();
    try {
      final response = await _dio.get('/api/admin/tips', queryParameters: {'page': page, 'size': 10});
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        final content = data['content'] as List<dynamic>? ?? [];
        final List<CareTipModel> tips = content
            .map((e) => CareTipModel.fromJson(e as Map<String, dynamic>))
            .toList();
        data['content'] = tips;
        state = AsyncValue.data(data);
      } else {
        state = const AsyncValue.data({'content': []});
      }
    } catch (e, st) {
      state = AsyncValue.error('Lỗi khi tải mẹo chăm sóc: $e', st);
    }
  }

  Future<bool> deleteTip(int id) async {
    try {
      await _dio.delete(
        '/api/care-tips/$id',
        options: Options(responseType: ResponseType.plain),
      );
      if (state.hasValue) {
        final data = state.value!;
        final content = data['content'] as List<CareTipModel>? ?? [];
        final updatedList = content.where((tip) => tip.id != id).toList();
        data['content'] = updatedList;
        state = AsyncValue.data({...data});
      }
      
      // Also update user-side provider if mounted
      try {
        _ref.read(careTipProvider.notifier).loadTips();
      } catch (e) {
        // Ignore
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
}
