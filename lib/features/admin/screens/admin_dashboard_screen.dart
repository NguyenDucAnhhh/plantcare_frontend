import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/storage/secure_storage.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../diagnosis/providers/diagnosis_history_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Row(
        children: [
          // === SIDEBAR ===
          _buildSidebar(context, ref, user?.fullName ?? 'Admin'),

          // === NOI DUNG CHINH ===
          Expanded(
            child: Column(
              children: [
                _buildTopBar(context, user?.email ?? ''),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: _buildDashboardContent(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, WidgetRef ref, String adminName) {
    return Container(
      width: 240,
      color: const Color(0xFF1E293B),
      child: Column(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(24),
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
          _sidebarItem(Icons.dashboard_outlined, 'Tổng quan', isActive: true),
          _sidebarItem(Icons.people_outline, 'Người dùng'),
          _sidebarItem(Icons.article_outlined, 'Bài đăng'),
          _sidebarItem(Icons.report_outlined, 'Tố cáo'),
          _sidebarItem(Icons.lightbulb_outline, 'Cẩm nang'),

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
                  icon: const Icon(Icons.logout, color: Colors.white54, size: 18),
                  tooltip: 'Đăng xuất',
                  onPressed: () async {
                    await SecureStorage.clear();
                    
                    ref.invalidate(authProvider);
                    ref.invalidate(profileProvider);
                    ref.invalidate(diagnosisHistoryProvider);
                    
                    if (context.mounted) context.go('/admin');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String label, {bool isActive = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primaryLight.withOpacity(0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon,
            color: isActive ? AppColors.primaryLight : Colors.white54,
            size: 20),
        title: Text(label,
            style: AppTextStyles.body.copyWith(
              color: isActive ? Colors.white : Colors.white60,
              fontWeight:
                  isActive ? FontWeight.w600 : FontWeight.w400,
              fontSize: 14,
            )),
        dense: true,
        onTap: () {},
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, String email) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      color: const Color(0xFF1A2332),
      child: Row(
        children: [
          Text('Tổng quan hệ thống',
              style:
                  AppTextStyles.heading3.copyWith(color: Colors.white70)),
          const Spacer(),
          Text(email,
              style: AppTextStyles.bodyGrey.copyWith(color: Colors.white38)),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Chào mừng trở lại! 👋',
            style: AppTextStyles.heading2.copyWith(color: Colors.white)),
        const SizedBox(height: 6),
        Text('Dưới đây là tóm tắt hoạt động hệ thống PlantCare.',
            style: AppTextStyles.bodyGrey),
        const SizedBox(height: 28),

        // === STAT CARDS ===
        Row(
          children: [
            _statCard('Người dùng', '1,204', Icons.people_outline,
                AppColors.accentBlue),
            const SizedBox(width: 16),
            _statCard('Bài đăng', '3,891', Icons.article_outlined,
                AppColors.accentPurple),
            const SizedBox(width: 16),
            _statCard('Tố cáo mới', '12', Icons.report_outlined,
                Colors.orange),
            const SizedBox(width: 16),
            _statCard('Cẩm nang', '47', Icons.lightbulb_outline,
                AppColors.primaryLight),
          ],
        ),
        const SizedBox(height: 32),

        // Quick links
        Text('Thao tác nhanh',
            style: AppTextStyles.heading3.copyWith(color: Colors.white70)),
        const SizedBox(height: 16),
        Row(
          children: [
            _quickLink(
                'Xem danh sách Tố cáo', Icons.gavel_outlined, Colors.orange),
            const SizedBox(width: 12),
            _quickLink('Đăng Cẩm nang mới', Icons.add_circle_outline,
                AppColors.primaryLight),
            const SizedBox(width: 12),
            _quickLink('Mở Swagger UI', Icons.api_outlined, Colors.blue,
                onTap: () => launchSwagger()),
          ],
        ),
      ],
    );
  }

  Widget _statCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 16),
            Text(value,
                style: AppTextStyles.heading1
                    .copyWith(color: Colors.white, fontSize: 28)),
            const SizedBox(height: 4),
            Text(label,
                style:
                    AppTextStyles.bodyGrey.copyWith(color: Colors.white38)),
          ],
        ),
      ),
    );
  }

  Widget _quickLink(String label, IconData icon, Color color,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(label,
                style: AppTextStyles.body.copyWith(color: color)),
          ],
        ),
      ),
    );
  }

  void launchSwagger() {
    // Mo Swagger UI trong tab moi
  }
}
