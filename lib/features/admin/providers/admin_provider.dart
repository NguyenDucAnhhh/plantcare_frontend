import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/admin_repository.dart';
import '../models/admin_user_model.dart';

final adminRepositoryProvider = Provider((ref) => AdminRepository());

final adminStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.read(adminRepositoryProvider);
  return repository.getDashboardStats();
});

class AdminUsersNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final AdminRepository _repository;

  AdminUsersNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchUsers();
  }

  Future<void> fetchUsers({int page = 0, bool silent = false}) async {
    if (page == 0 && !silent) state = const AsyncValue.loading();
    try {
      final Map<String, dynamic> data = await _repository.getUsers(page, 10);
      final content = data['content'] as List<dynamic>? ?? [];
      final parsedUsers = content.map((u) => AdminUserModel.fromJson(u)).toList();
      data['content'] = parsedUsers;
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleUserStatus(int id) async {
    try {
      await _repository.toggleUserStatus(id);
      if (state.hasValue) {
        final data = state.value!;
        final content = data['content'] as List<AdminUserModel>? ?? [];
        final updatedList = content.map((user) {
          if (user.id == id) {
            return AdminUserModel(
              id: user.id,
              fullName: user.fullName,
              email: user.email,
              avatarUrl: user.avatarUrl,
              role: user.role,
              isActive: !user.isActive,
              createdAt: user.createdAt,
              postCount: user.postCount,
            );
          }
          return user;
        }).toList();
        data['content'] = updatedList;
        state = AsyncValue.data({...data}); // Force rebuild
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> changeUserRole(int id, String role) async {
    try {
      await _repository.changeUserRole(id, role);
      if (state.hasValue) {
        final data = state.value!;
        final content = data['content'] as List<AdminUserModel>? ?? [];
        final updatedList = content.map((user) {
          if (user.id == id) {
            return AdminUserModel(
              id: user.id,
              fullName: user.fullName,
              email: user.email,
              avatarUrl: user.avatarUrl,
              role: role,
              isActive: user.isActive,
              createdAt: user.createdAt,
              postCount: user.postCount,
            );
          }
          return user;
        }).toList();
        data['content'] = updatedList;
        state = AsyncValue.data({...data}); // Force rebuild
      }
    } catch (e) {
      rethrow;
    }
  }
}

final adminUsersProvider = StateNotifierProvider<AdminUsersNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  return AdminUsersNotifier(ref.read(adminRepositoryProvider));
});
