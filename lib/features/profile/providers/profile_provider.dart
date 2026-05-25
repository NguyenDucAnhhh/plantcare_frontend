import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/profile_repository.dart';

class ProfileState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? profile;
  final List<dynamic> gardens;
  final List<dynamic> posts;

  ProfileState({
    this.isLoading = false,
    this.error,
    this.profile,
    this.gardens = const [],
    this.posts = const [],
  });

  ProfileState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? profile,
    List<dynamic>? gardens,
    List<dynamic>? posts,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      profile: profile ?? this.profile,
      gardens: gardens ?? this.gardens,
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
        _repository.getMyGardens(),
        _repository.getMyPosts(),
      ]);

      state = state.copyWith(
        isLoading: false,
        profile: futures[0] as Map<String, dynamic>,
        gardens: futures[1] as List<dynamic>,
        posts: futures[2] as List<dynamic>,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      await _repository.changePassword(oldPassword, newPassword);
      return true;
    } catch (e) {
      return false;
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
