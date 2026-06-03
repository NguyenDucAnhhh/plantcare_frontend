import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/admin_post_model.dart';

import 'admin_reports_provider.dart';

final adminPostsProvider = StateNotifierProvider.autoDispose<AdminPostsNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  return AdminPostsNotifier(ref);
});

class AdminPostsNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final Dio _dio = ApiClient.instance;
  final Ref _ref;

  AdminPostsNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadPosts();
  }

  Future<void> loadPosts({int page = 0, bool silent = false}) async {
    if (page == 0 && !silent) state = const AsyncValue.loading();
    try {
      final response = await _dio.get('/api/admin/posts', queryParameters: {'page': page, 'size': 10});
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        final content = data['content'] as List<dynamic>? ?? [];
        final List<AdminPostModel> posts = content
            .map((e) => AdminPostModel.fromJson(e as Map<String, dynamic>))
            .toList();
        data['content'] = posts;
        state = AsyncValue.data(data);
      } else {
        state = const AsyncValue.data({'content': []});
      }
    } catch (e, st) {
      state = AsyncValue.error('Lỗi khi tải bài đăng: $e', st);
    }
  }

  Future<bool> togglePostVisibility(int id) async {
    try {
      await _dio.put('/api/admin/posts/$id/toggle-visibility');
      
      if (state.hasValue) {
        final data = state.value!;
        final content = data['content'] as List<AdminPostModel>? ?? [];
        final updatedList = content.map((post) {
          if (post.id == id) {
            return AdminPostModel(
              id: post.id,
              authorName: post.authorName,
              authorEmail: post.authorEmail,
              content: post.content,
              imageUrls: post.imageUrls,
              isVisible: !post.isVisible,
              likeCount: post.likeCount,
              createdAt: post.createdAt,
            );
          }
          return post;
        }).toList();
        data['content'] = updatedList;
        state = AsyncValue.data({...data});
      }

      try {
        _ref.read(adminReportsProvider.notifier).fetchReports(silent: true);
      } catch (e) {
        // Ignore if provider is not mounted
      }
      return true;
    } catch (e) {
      rethrow;
    }
  }
}
