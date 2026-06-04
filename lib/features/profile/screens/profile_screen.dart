import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

import '../providers/profile_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_form_bottom_sheet.dart';
import '../widgets/profile_posts_grid.dart';
import '../../../core/utils/error_mapper.dart';
import '../../../core/utils/app_snackbar.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Bien cuc bo de thay doi avatar truoc khi luu len server
  String? localAvatarPath;

  @override
  void initState() {
    super.initState();
    // Tự động tải lại dữ liệu mỗi khi vào màn hình Profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileState = ref.read(profileProvider);
      // Chỉ gọi API nếu dữ liệu đang trống
      if (profileState.profile == null) {
        ref.read(profileProvider.notifier).loadProfileData();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showEditProfileBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ProfileFormBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(profileProvider, (previous, next) {
      if (next.error != null && next.error!.isNotEmpty && (previous?.error != next.error)) {
        AppSnackbar.showError(context, ErrorMapper.parseError(next.error!));
      }
    });

    final profileState = ref.watch(profileProvider);

    if (profileState.isLoading && profileState.profile == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final profile = profileState.profile ?? {};

    final fullName = profile['fullName'] ?? 'Người dùng';
    final bio = profile['bio'] ?? 'Chưa có thông tin giới thiệu';
    final followers = profile['followersCount'] ?? 0;
    final following = profile['followingCount'] ?? 0;
    final avatarUrl = profile['avatarUrl'];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => ref.read(profileProvider.notifier).loadProfileData(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: ProfileHeader(
                avatarUrl: avatarUrl,
                localPath: localAvatarPath,
                fullName: fullName,
                followersCount: followers,
                followingCount: following,
                bio: bio,
                rightActions: [
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: Colors.white),
                    onPressed: () => context.push('/settings'),
                  ),
                ],
                actionRow: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _showEditProfileBottomSheet,
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Chỉnh sửa'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            if (profileState.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              )
            else
              ProfilePostsGrid(posts: profileState.posts),
          ],
        ),
      ),
    );
  }
}
