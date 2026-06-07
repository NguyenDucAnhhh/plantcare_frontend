import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../../../core/constants/api_constants.dart';

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository();
});

class PostRepository {
  final Dio _dio = ApiClient.instance;

  PostRepository();

  // Lấy danh sách tất cả bài đăng trên Newfeed
  Future<List<PostModel>> getAllVisiblePosts({int page = 0, int size = 5}) async {
    final response = await _dio.get(
      ApiConstants.posts,
      queryParameters: {
        'page': page,
        'size': size,
      },
    );
    if (response.data != null) {
      final List<dynamic> data = response.data; // It's already a list from backend
      return data.map((json) => PostModel.fromJson(json)).toList();
    }
    return [];
  }

  // Lấy danh sách bài đăng của mình
  Future<List<PostModel>> getMyPosts() async {
    final response = await _dio.get(ApiConstants.myPosts,);
    if (response.data != null) {
      final List<dynamic> data = response.data;
      return data.map((json) => PostModel.fromJson(json)).toList();
    }
    return [];
  }

  // Lấy danh sách bài đăng của những người mình đang theo dõi
  Future<List<PostModel>> getFollowingPosts({int page = 0, int size = 5}) async {
    final response = await _dio.get('${ApiConstants.posts}/following', queryParameters: {
      'page': page,
      'size': size,
    });
    final List<dynamic> data = response.data;
    return data.map((json) => PostModel.fromJson(json)).toList();
  }

  // Tìm kiếm bài đăng
  Future<List<PostModel>> searchPosts(String keyword, {int page = 0, int size = 20}) async {
    final response = await _dio.get(
      ApiConstants.searchPosts,
      queryParameters: {
        'keyword': keyword,
        'page': page,
        'size': size,
      },
    );
    if (response.data != null) {
      final List<dynamic> data = response.data;
      return data.map((json) => PostModel.fromJson(json)).toList();
    }
    return [];
  }


  // Upload nhiều ảnh
  Future<List<String>> uploadPostImages(List<dynamic> files) async {
    if (files.isEmpty) return [];
    return await ApiClient.uploadMultipleImages(files, 'posts');
  }

  // Lấy 1 bài đăng theo ID
  Future<PostModel> getPostById(String postId) async {
    final response = await _dio.get('${ApiConstants.posts}/$postId');
    if (response.data != null) {
      return PostModel.fromJson(response.data);
    }
    throw Exception('Không tìm thấy bài đăng');
  }

  // Tạo bài đăng mới
  Future<PostModel> createPost({required String content, List<String> imageUrls = const []}) async {
    final response = await _dio.post(
      ApiConstants.posts,
      data: {
        'content': content,
        'imageUrls': imageUrls,
      },
    );
    return PostModel.fromJson(response.data);
  }

  // Cập nhật bài đăng
  Future<PostModel> updatePost(String postId, {required String content, List<String> imageUrls = const []}) async {
    final response = await _dio.put(
      '${ApiConstants.posts}/$postId',
      data: {
        'content': content,
        'imageUrls': imageUrls,
      },
    );
    return PostModel.fromJson(response.data);
  }

  // Xóa bài đăng
  Future<void> deletePost(String postId) async {
    await _dio.delete(
      '${ApiConstants.posts}/$postId',
      options: Options(responseType: ResponseType.plain),
    );
  }

  // Bấm Like
  Future<void> toggleLike(String postId) async {
    await _dio.post(
      '${ApiConstants.posts}/$postId/like',
      options: Options(responseType: ResponseType.plain),
    );
  }

  // ====== BÌNH LUẬN ======
  Future<List<CommentModel>> getCommentsByPost(String postId) async {
    final response = await _dio.get('${ApiConstants.posts}/$postId/comments');
    if (response.data != null) {
      final List<dynamic> data = response.data;
      return data.map((json) => CommentModel.fromJson(json, postId)).toList();
    }
    return [];
  }

  Future<CommentModel> addComment(String postId, String content, {String? parentCommentId}) async {
    final response = await _dio.post(
      '${ApiConstants.posts}/$postId/comments',
      data: {
        'content': content,
        'parentCommentId': parentCommentId != null ? int.parse(parentCommentId) : null,
      },
    );
    return CommentModel.fromJson(response.data, postId);
  }


  // ====== BÁO CÁO ======
  Future<void> reportPost(String postId, String reason) async {
    await _dio.post(
      ApiConstants.reports,
      data: {
        'postId': int.parse(postId),
        'reason': reason,
      },
    );
  }
}
