import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../core/widgets/app_avatar.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_form_bottom_sheet.dart';
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
        AppSnackbar.showError(context, ErrorMapper.parseError(next.error));
      }
    });

    final profileState = ref.watch(profileProvider);

    if (profileState.isLoading && profileState.profile == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
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
      body: Column(
        children: [
          ProfileHeader(
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
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // === CONTENT ===
          Expanded(
            child: profileState.isLoading
                ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
                : (profileState.posts.isEmpty
                ? _buildEmptyState(
                'Bạn chưa có bài đăng nào', Icons.article_outlined)
                : _buildPostsGrid(profileState.posts)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.bodyGrey.copyWith(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsGrid(List<dynamic> posts) {
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        // Lấy danh sách ảnh từ Map
        final List<dynamic> imageUrls = post['imageUrls'] ?? [];
        final String? firstImage = imageUrls.isNotEmpty
            ? imageUrls[0]
            : post['imageUrl'];

        return GestureDetector(
          // KHI NHẤN VÀO ẢNH: Chuyển sang trang chi tiết bài đăng
          onTap: () => context.push('/post/${post['id']}'),
          child: Container(
            color: Colors.grey.shade200,
            child: firstImage != null
                ? Image.network(firstImage, fit: BoxFit.cover)
                : Container(
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    color: Colors.white,
                    child: Text(
                      post['content'] ?? '',
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
