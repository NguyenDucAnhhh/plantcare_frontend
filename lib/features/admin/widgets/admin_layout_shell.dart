import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/storage/secure_storage.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../providers/admin_provider.dart';
import '../providers/admin_reports_provider.dart';
import '../providers/admin_posts_provider.dart';
import '../providers/admin_diagnoses_provider.dart';

class AdminLayoutShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AdminLayoutShell({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final email = profileState.profile?['email'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8), // Nền xám nhạt
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(context, ref, profileState),

          // Main content
          Expanded(
            child: Column(
              children: [
                _buildTopBar(context, email),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(28.0),
                    // Nơi GoRouter sẽ bơm nội dung trang vào (dashboard, users, posts...)
                    child: navigationShell,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, WidgetRef ref, ProfileState profileState) {
    final adminName = profileState.profile?['fullName'] ?? 'Admin';
    return Container(
      width: 250,
      color: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.eco_rounded,
                      color: AppColors.primaryLight, size: 22),
                ),
                const SizedBox(width: 12),
                Text('PlantCare',
                    style: AppTextStyles.heading3
                        .copyWith(color: Colors.white, fontSize: 18)),
              ],
            ),
          ),
          const Divider(color: Colors.white12),
          const SizedBox(height: 8),

          // Menu items
          _sidebarItem(Icons.dashboard_outlined, 'Tổng quan', 0),
          _sidebarItem(Icons.people_outline, 'Người dùng', 1),
          _sidebarItem(Icons.article_outlined, 'Bài đăng', 2),
          _sidebarItem(Icons.report_outlined, 'Tố cáo', 3),
          _sidebarItem(Icons.lightbulb_outline, 'Mẹo chăm sóc', 4),
          _sidebarItem(Icons.medical_services_outlined, 'Chẩn đoán AI', 5),

          const Spacer(),
          const Divider(color: Colors.white12),

          // Admin info + Logout
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.person, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(adminName,
                      style: AppTextStyles.body
                          .copyWith(color: Colors.white70, fontSize: 13),
                      overflow: TextOverflow.ellipsis),
                ),
                IconButton(
                  icon: const Icon(Icons.lock_outline, color: Colors.white54, size: 18),
                  tooltip: 'Đổi mật khẩu',
                  onPressed: () => context.push('/change-password'),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white54, size: 18),
                  tooltip: 'Đăng xuất',
                  onPressed: () => _showLogoutDialog(context, ref),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String title, int index) {
    final isActive = navigationShell.currentIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon,
            color: isActive ? Colors.white : Colors.white70, size: 22),
        title: Text(
          title,
          style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.white70,
              fontSize: 15),
        ),
        onTap: () {
          // GoRouter handles the branch switching, preserving state
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, String email) {
    String title = 'Tổng quan hệ thống';
    switch (navigationShell.currentIndex) {
      case 0:
        title = 'Tổng quan hệ thống';
        break;
      case 1:
        title = 'Quản lý người dùng';
        break;
      case 2:
        title = 'Quản lý bài đăng';
        break;
      case 3:
        title = 'Kiểm duyệt tố cáo';
        break;
      case 4:
        title = 'Mẹo chăm sóc';
        break;
      case 5:
        title = 'Lịch sử chẩn đoán AI';
        break;
    }

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          Text(title,
              style:
                  AppTextStyles.heading1.copyWith(color: AppColors.textDark, fontSize: 24)),
          const Spacer(),
          Text(email,
              style: AppTextStyles.bodyGrey),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Xác nhận đăng xuất',
            textAlign: TextAlign.center,
            style: AppTextStyles.heading2,
          ),
          content: Text(
            'Bạn có chắc chắn muốn đăng xuất không?',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyGrey,
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            ElevatedButton(
              onPressed: () async {
                await SecureStorage.clear();
                
                ref.invalidate(authProvider);
                ref.invalidate(profileProvider);
                // Invalidate admin providers to prevent caching
                ref.invalidate(adminUsersProvider);
                ref.invalidate(adminReportsProvider);
                ref.invalidate(adminPostsProvider);
                ref.invalidate(adminDiagnosesProvider);
                
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
                if (context.mounted) {
                  context.go('/admin');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                elevation: 0,
              ),
              child: const Text('Đăng xuất', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            OutlinedButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textDark,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Hủy', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
