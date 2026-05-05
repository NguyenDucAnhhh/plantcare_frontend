import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      // Khi an lai vao tab hien tai, no se quay ve man hinh root cua tab do
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Trang chủ',
                  isActive: navigationShell.currentIndex == 0,
                  onTap: () => _goBranch(0),
                ),
                _navItem(
                  icon: Icons.article_outlined,
                  activeIcon: Icons.article,
                  label: 'Bài đăng',
                  isActive: navigationShell.currentIndex == 1,
                  onTap: () => _goBranch(1),
                ),
                // Nut trung tam: Chan doan
                GestureDetector(
                  onTap: () => _goBranch(2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: navigationShell.currentIndex == 2 ? Colors.white : AppColors.primary,
                          shape: BoxShape.circle,
                          border: navigationShell.currentIndex == 2 
                            ? Border.all(color: AppColors.primary, width: 2) 
                            : null,
                        ),
                        child: Icon(
                          Icons.document_scanner_outlined, 
                          color: navigationShell.currentIndex == 2 ? AppColors.primary : Colors.white, 
                          size: 26
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Chẩn đoán',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 11, 
                          color: navigationShell.currentIndex == 2 ? AppColors.primary : AppColors.textGrey,
                          fontWeight: navigationShell.currentIndex == 2 ? FontWeight.bold : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                _navItem(
                  icon: Icons.local_florist_outlined,
                  activeIcon: Icons.local_florist,
                  label: 'Vườn cây',
                  isActive: navigationShell.currentIndex == 3,
                  onTap: () => _goBranch(3),
                ),
                _navItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Hồ sơ',
                  isActive: navigationShell.currentIndex == 4,
                  onTap: () => _goBranch(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final color = isActive ? AppColors.primary : AppColors.textGrey;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isActive ? activeIcon : icon, color: color, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              fontSize: 11,
              color: color,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
