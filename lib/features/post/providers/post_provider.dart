import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io' as dart_io;
import '../models/post_model.dart';
import '../data/post_repository.dart';

// 1. TẠO CLASS STATE GIỐNG GARDEN
class PostState {
  final List<PostModel> posts;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int page;
  final bool hasMore;

  PostState({
    this.posts = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.page = 0,
    this.hasMore = true,
  });

  PostState copyWith({
    List<PostModel>? posts,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? page,
    bool? hasMore,
  }) {
    return PostState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

// 2. KHAI BÁO PROVIDER GIỐNG GARDEN (Sử dụng autoDispose để tự tải lại khi login mới)
final postProvider = StateNotifierProvider.autoDispose<PostNotifier, PostState>((ref) {
  final repository = ref.watch(postRepositoryProvider);
  return PostNotifier(repository);
});

// 3. CLASS NOTIFIER
class PostNotifier extends StateNotifier<PostState> {
  final PostRepository _repository;

  PostNotifier(this._repository) : super(PostState());

  Future<PostModel?> loadPostById(String postId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final post = await _repository.getPostById(postId);
      
      final currentList = state.posts.toList();
      final index = currentList.indexWhere((p) => p.id == postId);
      if (index >= 0) {
        currentList[index] = post;
      } else {
        currentList.insert(0, post);
      }
      
      state = state.copyWith(isLoading: false, posts: currentList);
      return post;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<void> loadPosts({bool isFollowing = false}) async {
    state = state.copyWith(isLoading: true, error: null, page: 0, hasMore: true);
    try {
      final posts = isFollowing
          ? await _repository.getFollowingPosts(page: 0, size: 5)
          : await _repository.getAllVisiblePosts(page: 0, size: 5);
      state = state.copyWith(
        isLoading: false, 
        posts: posts, 
        hasMore: posts.length >= 5
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMorePosts({bool isFollowing = false}) async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.page + 1;
      final newPosts = isFollowing
          ? await _repository.getFollowingPosts(page: nextPage, size: 5)
          : await _repository.getAllVisiblePosts(page: nextPage, size: 5);
      
      state = state.copyWith(
        isLoadingMore: false,
        posts: [...state.posts, ...newPosts],
        page: nextPage,
        hasMore: newPosts.length >= 5,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  Future<void> refreshPosts({bool isFollowing = false}) async {
    await loadPosts(isFollowing: isFollowing);
  }

  Future<void> createPost(String content, {List<dart_io.File> images = const []}) async {
    try {
      state = state.copyWith(isLoading: true);
      List<String> imageUrls = [];
      if (images.isNotEmpty) {
        imageUrls = await _repository.uploadPostImages(images);
      }

      final newPost = await _repository.createPost(
        content: content,
        imageUrls: imageUrls,
      );

      state = state.copyWith(
        isLoading: false,
        posts: [newPost, ...state.posts],
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      throw Exception('Lỗi tạo bài đăng: $e');
    }
  }

  Future<void> updatePost(String postId, String content, {List<dart_io.File> newImages = const [], List<String> existingImageUrls = const []}) async {
    try {
      state = state.copyWith(isLoading: true);
      List<String> finalImageUrls = List.from(existingImageUrls);

      if (newImages.isNotEmpty) {
        final uploadedUrls = await _repository.uploadPostImages(newImages);
        finalImageUrls.addAll(uploadedUrls);
      }

      final updatedPost = await _repository.updatePost(
        postId,
        content: content,
        imageUrls: finalImageUrls,
      );

      state = state.copyWith(
        isLoading: false,
        posts: state.posts.map((p) => p.id == postId ? updatedPost : p).toList(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      throw Exception('Lỗi sửa bài đăng: $e');
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _repository.deletePost(postId);
      state = state.copyWith(
        posts: state.posts.where((p) => p.id != postId).toList(),
      );
    } catch (e) {
      throw Exception('Lỗi xóa bài đăng: $e');
    }
  }

  Future<void> toggleLike(String postId) async {
    // Optimistic UI update giống code cũ nhưng dùng PostState
    final previousPosts = state.posts;
    state = state.copyWith(
      posts: state.posts.map((post) {
        if (post.id == postId) {
          return post.copyWith(
            isLiked: !post.isLiked,
            likeCount: post.isLiked ? post.likeCount - 1 : post.likeCount + 1,
          );
        }
        return post;
      }).toList(),
    );

    try {
      await _repository.toggleLike(postId);
    } catch (e) {
      state = state.copyWith(posts: previousPosts);
      throw Exception('Lỗi thả tim: $e');
    }
  }

  Future<void> reportPost(String postId, String reason) async {
    try {
      await _repository.reportPost(postId, reason);
    } catch (e) {
      throw Exception('Lỗi khi báo cáo bài viết: $e');
    }
  }
}
