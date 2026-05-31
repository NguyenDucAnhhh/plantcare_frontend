import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/post_repository.dart';
import '../../profile/data/profile_repository.dart';
import '../models/post_model.dart';

final communitySearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

final searchPostsProvider = FutureProvider.autoDispose.family<List<PostModel>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  final repository = ref.read(postRepositoryProvider);
  return repository.searchPosts(query);
});

final searchProfileRepositoryProvider = Provider((ref) => ProfileRepository());

final searchUsersProvider = FutureProvider.autoDispose.family<List<Map<String, dynamic>>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  final repository = ref.read(searchProfileRepositoryProvider);
  final users = await repository.searchUsers(query);
  return users.cast<Map<String, dynamic>>();
});
