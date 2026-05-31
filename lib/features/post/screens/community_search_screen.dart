import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../providers/community_search_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../widgets/post_card.dart';
import '../../../core/widgets/custom_tab_switcher.dart';

class CommunitySearchScreen extends ConsumerStatefulWidget {
  const CommunitySearchScreen({super.key});

  @override
  ConsumerState<CommunitySearchScreen> createState() => _CommunitySearchScreenState();
}

class _CommunitySearchScreenState extends ConsumerState<CommunitySearchScreen> {
  int _selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(communitySearchQueryProvider.notifier).state = query;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(communitySearchQueryProvider);
    final isQueryEmpty = query.trim().isEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        titleSpacing: 0,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm bài đăng, người dùng...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          CustomTabSwitcher(
            tabs: const ['Bài đăng', 'Người dùng'],
            selectedIndex: _selectedTabIndex,
            onTabChanged: (index) {
              setState(() => _selectedTabIndex = index);
            },
          ),
          Expanded(
            child: isQueryEmpty
                ? const Center(
                    child: Text(
                      'Nhập từ khóa để bắt đầu tìm kiếm',
                    ),
                  )
                : (_selectedTabIndex == 0
                    ? _buildPostsTab(query, ref)
                    : _buildUsersTab(query, ref)),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsTab(String query, WidgetRef ref) {
    final postsAsync = ref.watch(searchPostsProvider(query));

    return postsAsync.when(
      data: (posts) {
        if (posts.isEmpty) {
          return const Center(child: Text('Không tìm kiếm thấy bài đăng nào.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return PostCard(post: posts[index]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, st) => Center(child: Text('Lỗi: $e', style: AppTextStyles.body.copyWith(color: AppColors.error))),
    );
  }

  Widget _buildUsersTab(String query, WidgetRef ref) {
    final usersAsync = ref.watch(searchUsersProvider(query));

    return usersAsync.when(
      data: (users) {
        if (users.isEmpty) {
          return const Center(child: Text('Không tìm thấy người dùng nào.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundImage: user['avatarUrl'] != null ? NetworkImage(user['avatarUrl']) : null,
                  backgroundColor: Colors.grey.shade200,
                  child: user['avatarUrl'] == null ? const Icon(Icons.person, color: Colors.grey) : null,
                ),
                title: Text(
                  user['fullName'] ?? 'Unknown', 
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, fontSize: 16)
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    final currentUserId = ref.read(profileProvider).profile?['id'];
                    if (user['id'] == currentUserId) {
                      context.push('/profile');
                    } else {
                      context.push('/user/${user['id']}');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: const Text('Xem', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, st) => Center(child: Text('Lỗi: $e', style: AppTextStyles.body.copyWith(color: AppColors.error))),
    );
  }
}
