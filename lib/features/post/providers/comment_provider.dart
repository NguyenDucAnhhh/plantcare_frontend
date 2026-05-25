import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/comment_model.dart';
import '../data/post_repository.dart';

final commentProvider = StateNotifierProvider.family<CommentNotifier, AsyncValue<List<CommentModel>>, String>((ref, postId) {
  final repository = ref.read(postRepositoryProvider);
  return CommentNotifier(repository, postId);
});

class CommentNotifier extends StateNotifier<AsyncValue<List<CommentModel>>> {
  final PostRepository _repository;
  final String _postId;

  CommentNotifier(this._repository, this._postId) : super(const AsyncValue.loading()) {
    loadComments();
  }

  Future<void> loadComments() async {
    state = const AsyncValue.loading();
    try {
      final comments = await _repository.getCommentsByPost(_postId);
      state = AsyncValue.data(comments);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addComment(String content, {String? parentId}) async {
    try {
      final newComment = await _repository.addComment(_postId, content, parentCommentId: parentId);
      if (state.hasValue) {
        state = AsyncValue.data([...state.value!, newComment]);
      }
    } catch (e) {
      throw Exception('Lỗi thêm bình luận: $e');
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      await _repository.deleteComment(_postId, commentId);
      if (state.hasValue) {
        state = AsyncValue.data(
          state.value!.where((c) => c.id != commentId).toList(),
        );
      }
    } catch (e) {
      throw Exception('Lỗi xóa bình luận: $e');
    }
  }
}
