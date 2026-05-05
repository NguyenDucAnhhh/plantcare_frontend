import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/storage/secure_storage.dart';
import '../providers/weather_provider.dart';
import '../data/weather_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider);

    return Scaffold(
      backgroundColor: AppColors.background,

      // === BODY ===
      body: CustomScrollView(
        slivers: [
          // === PHAN HEADER XANH + WEATHER (Figma) ===
          SliverToBoxAdapter(
            child: _buildHeader(context, ref, weatherAsync),
          ),

          // === PHAN NOIDUNG CUON ===
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildQuickActions(context),
                const SizedBox(height: 24),
                // Cho phep mo rong them cac section moi sau nay
              ]),
            ),
          ),
        ],
      ),

    );
  }

  // ============================================================
  //  HEADER: Logo + Notification + Weather Card
  // ============================================================
  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<WeatherModel> weatherAsync,
  ) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            children: [
              // === DONG 1: Logo + Icons ===
              Row(
                children: [
                  // Logo la cay + Ten app
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.eco_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'PlantCare',
                    style: AppTextStyles.heading2.copyWith(color: Colors.white),
                  ),
                  const Spacer(),

                  // Icon chuong thong bao (co cham do)
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 26),
                        onPressed: () {},
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Icon cai dat
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 26),
                    onPressed: () => context.push('/settings'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // === DONG 2: WEATHER CARD ===
              weatherAsync.when(
                loading: () => _buildWeatherCard(WeatherModel.mock(), isLoading: true),
                error: (_, __) => _buildWeatherCard(WeatherModel.mock()),
                data: (weather) => _buildWeatherCard(weather),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherCard(WeatherModel weather, {bool isLoading = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: isLoading
          ? const Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              ),
            )
          : Row(
              children: [
                // Nhiet do + Vi tri
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.cloud_outlined, color: Colors.white70, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            weather.temperatureDisplay,
                            style: AppTextStyles.heading2.copyWith(
                              color: Colors.white,
                              fontSize: 26,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        weather.locationDisplay,
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),

                // Do am + May
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      weather.cloudDisplay,
                      style: AppTextStyles.body.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      weather.humidityDisplay,
                      style: AppTextStyles.body.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  // ============================================================
  //  THAO TAC NHANH (Quick Actions) - Figma: 2x2 grid
  // ============================================================
  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Thao tác nhanh', style: AppTextStyles.heading3),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            // Nut xanh duong: Chuan doan benh
            _buildActionCard(
              label: 'Chuẩn đoán bệnh',
              icon: Icons.search_rounded,
              backgroundColor: AppColors.accentBlue,
              iconColor: Colors.white,
              labelColor: Colors.white,
              onTap: () => context.go('/diagnosis'),
            ),

            // Nut tim: Tao bai dang
            _buildActionCard(
              label: 'Tạo bài đăng',
              icon: Icons.edit_rounded,
              backgroundColor: AppColors.accentPurple,
              iconColor: Colors.white,
              labelColor: Colors.white,
              onTap: () => context.go('/posts'),
            ),

            // Nut trang: Quan ly vuon
            _buildActionCard(
              label: 'Quản lý vườn',
              icon: Icons.local_florist_outlined,
              backgroundColor: AppColors.surface,
              iconColor: AppColors.primary,
              labelColor: AppColors.textDark,
              onTap: () => context.go('/garden'),
              hasBorder: true,
            ),

            // Nut trang: Xem meo hay
            _buildActionCard(
              label: 'Xem mẹo hay',
              icon: Icons.lightbulb_outline_rounded,
              backgroundColor: AppColors.surface,
              iconColor: AppColors.warning,
              labelColor: AppColors.textDark,
              onTap: () => context.go('/tips'),
              hasBorder: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    required Color labelColor,
    required VoidCallback onTap,
    bool hasBorder = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: hasBorder
              ? Border.all(color: AppColors.inputBg, width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.label.copyWith(color: labelColor, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

}
