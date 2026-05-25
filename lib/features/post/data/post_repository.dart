import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository();
});

class PostRepository {
  final Dio _dio = ApiClient.instance;

  PostRepository();

  // Lấy danh sách tất cả bài viết trên Newfeed
  Future<List<PostModel>> getAllVisiblePosts() async {
    try {
      final response = await _dio.get('/api/posts');
      if (response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((json) => PostModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng vào Cài đặt -> Đăng xuất và Đăng nhập lại.');
      }
      throw Exception('Lỗi khi lấy danh sách bài viết: $e');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  // Lấy danh sách bài viết của mình
  Future<List<PostModel>> getMyPosts() async {
    try {
      final response = await _dio.get('/api/posts/me');
      if (response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((json) => PostModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách bài viết của tôi: $e');
    }
  }

  // Lấy danh sách bài viết của những người mình đang theo dõi
  Future<List<PostModel>> getFollowingPosts() async {
    try {
      final response = await _dio.get('/api/posts/following');
      if (response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((json) => PostModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách bài viết đang theo dõi: $e');
    }
  }

  // Upload nhiều ảnh
  Future<List<String>> uploadPostImages(List<File> files) async {
    try {
      if (files.isEmpty) return [];
      
      List<MultipartFile> multipartFiles = [];
      for (var file in files) {
        multipartFiles.add(await MultipartFile.fromFile(file.path));
      }

      FormData formData = FormData.fromMap({
        'files': multipartFiles,
      });

      final response = await _dio.post(
        '/api/posts/images/upload',
        data: formData,
      );

      if (response.data != null) {
        return List<String>.from(response.data);
      }
      return [];
    } catch (e) {
      throw Exception('Lỗi upload ảnh: $e');
    }
  }

  // Lấy 1 bài viết theo ID
  Future<PostModel> getPostById(String postId) async {
    try {
      final response = await _dio.get('/api/posts/$postId');
      if (response.data != null) {
        return PostModel.fromJson(response.data);
      }
      throw Exception('Không tìm thấy bài viết');
    } catch (e) {
      throw Exception('Lỗi khi lấy thông tin bài viết: $e');
    }
  }

  // Tạo bài viết mới
  Future<PostModel> createPost({required String content, List<String> imageUrls = const []}) async {
    try {
      final response = await _dio.post(
        '/api/posts',
        data: {
          'content': content,
          'imageUrls': imageUrls,
        },
      );
      return PostModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Lỗi khi tạo bài viết: $e');
    }
  }

  // Cập nhật bài viết
  Future<PostModel> updatePost(String postId, {required String content, List<String> imageUrls = const []}) async {
    try {
      final response = await _dio.put(
        '/api/posts/$postId',
        data: {
          'content': content,
          'imageUrls': imageUrls,
        },
      );
      return PostModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Lỗi khi cập nhật bài viết: $e');
    }
  }

  // Xóa bài viết
  Future<void> deletePost(String postId) async {
    try {
      await _dio.delete(
        '/api/posts/$postId',
        options: Options(responseType: ResponseType.plain),
      );
    } catch (e) {
      throw Exception('Lỗi khi xóa bài viết: $e');
    }
  }

  // Bấm Like
  Future<void> toggleLike(String postId) async {
    try {
      await _dio.post(
        '/api/posts/$postId/like',
        options: Options(responseType: ResponseType.plain),
      );
    } catch (e) {
      throw Exception('Lỗi khi thả tim: $e');
    }
  }

  // ====== BÌNH LUẬN ======
  Future<List<CommentModel>> getCommentsByPost(String postId) async {
    try {
      final response = await _dio.get('/api/posts/$postId/comments');
      if (response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((json) => CommentModel.fromJson(json, postId)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Lỗi khi lấy bình luận: $e');
    }
  }

  Future<CommentModel> addComment(String postId, String content, {String? parentCommentId}) async {
    try {
      final response = await _dio.post(
        '/api/posts/$postId/comments',
        data: {
          'content': content,
          'parentCommentId': parentCommentId != null ? int.parse(parentCommentId) : null,
        },
      );
      return CommentModel.fromJson(response.data, postId);
    } catch (e) {
      throw Exception('Lỗi khi thêm bình luận: $e');
    }
  }

  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await _dio.delete('/api/posts/$postId/comments/$commentId');
    } catch (e) {
      throw Exception('Lỗi khi xóa bình luận: $e');
    }
  }

  // ====== BÁO CÁO ======
  Future<void> reportPost(String postId, String reason) async {
    try {
      await _dio.post(
        '/api/reports',
        data: {
          'postId': int.parse(postId),
          'reason': reason,
        },
      );
    } catch (e) {
      throw Exception('Lỗi khi báo cáo: $e');
    }
  }
}
