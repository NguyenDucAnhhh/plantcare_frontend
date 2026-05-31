import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../providers/admin_stats_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [


        // === STAT CARDS ===
        statsAsync.when(
          data: (stats) => Row(
            children: [
              _statCard('Người dùng', stats['totalUsers']?.toString() ?? '0', Icons.people_outline,
                  AppColors.accentBlue),
              const SizedBox(width: 16),
              _statCard('Bài đăng', stats['totalPosts']?.toString() ?? '0', Icons.article_outlined,
                  AppColors.accentPurple),
              const SizedBox(width: 16),
              _statCard('Tố cáo', stats['totalReports']?.toString() ?? '0', Icons.report_outlined,
                  Colors.orange),
              const SizedBox(width: 16),
              _statCard('Mẹo chăm sóc', stats['totalTips']?.toString() ?? '0', Icons.lightbulb_outline,
                  AppColors.primaryLight),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Text('Lỗi tải dữ liệu: $e', style: const TextStyle(color: Colors.red)),
        ),
      ],
      ),
    );
  }

  Widget _statCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 16),
            Text(value,
                style: AppTextStyles.heading1
                    .copyWith(color: AppColors.textDark, fontSize: 28)),
            const SizedBox(height: 4),
            Text(label,
                style:
                    AppTextStyles.bodyGrey),
          ],
        ),
      ),
    );
  }
}
