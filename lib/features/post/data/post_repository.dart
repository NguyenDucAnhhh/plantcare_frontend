import 'dart:io';
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
    try {
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
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng vào Cài đặt -> Đăng xuất và Đăng nhập lại.');
      }
      throw Exception('Lỗi khi lấy danh sách bài đăng: $e');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  // Lấy danh sách bài đăng của mình
  Future<List<PostModel>> getMyPosts() async {
    try {
      final response = await _dio.get(ApiConstants.myPosts,);
      if (response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((json) => PostModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách bài đăng của tôi: $e');
    }
  }

  // Lấy danh sách bài đăng của những người mình đang theo dõi
  Future<List<PostModel>> getFollowingPosts({int page = 0, int size = 5}) async {
    try {
      final response = await _dio.get('${ApiConstants.posts}/following', queryParameters: {
        'page': page,
        'size': size,
      });
      final List<dynamic> data = response.data;
      return data.map((json) => PostModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy bài đăng đang theo dõi: $e');
    }
  }

  // Tìm kiếm bài đăng
  Future<List<PostModel>> searchPosts(String keyword, {int page = 0, int size = 20}) async {
    try {
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
    } catch (e) {
      throw Exception('Lỗi khi tìm kiếm bài đăng: $e');
    }
  }


  // Upload nhiều ảnh
  Future<List<String>> uploadPostImages(List<dynamic> files) async {
    try {
      if (files.isEmpty) return [];
      return await ApiClient.uploadMultipleImages(files, 'posts');
    } catch (e) {
      throw Exception('Lỗi upload ảnh: $e');
    }
  }

  // Lấy 1 bài đăng theo ID
  Future<PostModel> getPostById(String postId) async {
    try {
      final response = await _dio.get('${ApiConstants.posts}/$postId');
      if (response.data != null) {
        return PostModel.fromJson(response.data);
      }
      throw Exception('Không tìm thấy bài đăng');
    } catch (e) {
      throw Exception('Lỗi khi lấy thông tin bài đăng: $e');
    }
  }

  // Tạo bài đăng mới
  Future<PostModel> createPost({required String content, List<String> imageUrls = const []}) async {
    try {
      final response = await _dio.post(
        ApiConstants.posts,
        data: {
          'content': content,
          'imageUrls': imageUrls,
        },
      );
      return PostModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Lỗi khi tạo bài đăng: $e');
    }
  }

  // Cập nhật bài đăng
  Future<PostModel> updatePost(String postId, {required String content, List<String> imageUrls = const []}) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.posts}/$postId',
        data: {
          'content': content,
          'imageUrls': imageUrls,
        },
      );
      return PostModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Lỗi khi cập nhật bài đăng: $e');
    }
  }

  // Xóa bài đăng
  Future<void> deletePost(String postId) async {
    try {
      await _dio.delete(
        '${ApiConstants.posts}/$postId',
        options: Options(responseType: ResponseType.plain),
      );
    } catch (e) {
      throw Exception('Lỗi khi xóa bài đăng: $e');
    }
  }

  // Bấm Like
  Future<void> toggleLike(String postId) async {
    try {
      await _dio.post(
        '${ApiConstants.posts}/$postId/like',
        options: Options(responseType: ResponseType.plain),
      );
    } catch (e) {
      throw Exception('Lỗi khi thả tim: $e');
    }
  }

  // ====== BÌNH LUẬN ======
  Future<List<CommentModel>> getCommentsByPost(String postId) async {
    try {
      final response = await _dio.get('${ApiConstants.posts}/$postId/comments');
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
        '${ApiConstants.posts}/$postId/comments',
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


  // ====== BÁO CÁO ======
  Future<void> reportPost(String postId, String reason) async {
    try {
      await _dio.post(
        ApiConstants.reports,
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
