import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/profile_repository.dart';
import 'profile_provider.dart';
import '../../post/models/post_model.dart';

class PublicProfileState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? profile;
  final List<PostModel> posts;
  final bool isFollowing;

  PublicProfileState({
    this.isLoading = false,
    this.error,
    this.profile,
    this.posts = const [],
    this.isFollowing = false,
  });

  PublicProfileState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? profile,
    List<PostModel>? posts,
    bool? isFollowing,
  }) {
    return PublicProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      profile: profile ?? this.profile,
      posts: posts ?? this.posts,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}

class PublicProfileNotifier extends StateNotifier<PublicProfileState> {
  final ProfileRepository _repository;
  final String _userId;

  PublicProfileNotifier(this._repository, this._userId) : super(PublicProfileState()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final futures = await Future.wait([
        _repository.getUserProfileById(_userId),
        _repository.getUserPosts(_userId),
      ]);

      final profileData = futures[0] as Map<String, dynamic>;
      final postsData = futures[1] as List<dynamic>;

      // We don't have isFollowing from backend in the profile response easily, 
      // but maybe we can check myFollowings if we want to be exact, 
      // or we just default to false and toggle.
      // Wait, let's just default to false for now, or check if currentUser's followings contain this userId.
      // For now assume false or add it to backend later.

      state = state.copyWith(
        isLoading: false,
        profile: profileData,
        posts: postsData.map((p) => PostModel.fromJson(p)).toList(),
        isFollowing: profileData['isFollowing'] ?? profileData['following'] ?? false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> toggleFollow() async {
    if (state.profile == null) return;
    
    final wasFollowing = state.isFollowing;
    final currentFollowers = state.profile!['followersCount'] ?? 0;

    // Optimistic Update
    state = state.copyWith(
      isFollowing: !wasFollowing,
      profile: {
        ...state.profile!,
        'followersCount': wasFollowing ? currentFollowers - 1 : currentFollowers + 1,
      },
    );

    try {
      await _repository.toggleFollow(_userId);
    } catch (e) {
      // Revert
      state = state.copyWith(
        isFollowing: wasFollowing,
        profile: {
          ...state.profile!,
          'followersCount': currentFollowers,
        },
      );
      throw Exception('Lỗi khi theo dõi: $e');
    }
  }
}

final publicProfileProvider = StateNotifierProvider.family<PublicProfileNotifier, PublicProfileState, String>((ref, userId) {
  final repository = ref.watch(profileRepositoryProvider);
  return PublicProfileNotifier(repository, userId);
});
