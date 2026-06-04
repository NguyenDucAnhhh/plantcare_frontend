import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/profile_repository.dart';
import '../../post/models/post_model.dart';

class ProfileState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? profile;
  final List<PostModel> posts;

  ProfileState({
    this.isLoading = false,
    this.error,
    this.profile,
    this.posts = const [],
  });

  ProfileState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? profile,
    List<PostModel>? posts,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      profile: profile ?? this.profile,
      posts: posts ?? this.posts,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository _repository;

  ProfileNotifier(this._repository) : super(ProfileState()) {
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final futures = await Future.wait([
        _repository.getMyProfile(),
        _repository.getMyPosts(),
      ]);

      final postsData = futures[1] as List<dynamic>;

      state = state.copyWith(
        isLoading: false,
        profile: futures[0] as Map<String, dynamic>,
        posts: postsData.map((p) => PostModel.fromJson(p)).toList(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      await _repository.updateProfile(data);
      await loadProfileData();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      await _repository.changePassword(oldPassword, newPassword);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateNotificationSettings(bool notifyAll, bool notifyCommunity, bool notifyReminder, bool notifySystem) async {
    try {
      await _repository.updateNotificationSettings(notifyAll, notifyCommunity, notifyReminder, notifySystem);
      
      if (state.profile != null) {
        final updatedProfile = Map<String, dynamic>.from(state.profile!);
        updatedProfile['notifyAll'] = notifyAll;
        updatedProfile['notifyCommunity'] = notifyCommunity;
        updatedProfile['notifyReminder'] = notifyReminder;
        updatedProfile['notifySystem'] = notifySystem;
        
        state = state.copyWith(profile: updatedProfile);
      }
    } catch (e) {
      // Handle error or throw
      rethrow;
    }
  }
}

final profileRepositoryProvider = Provider((ref) => ProfileRepository());

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileNotifier(repository);
});
