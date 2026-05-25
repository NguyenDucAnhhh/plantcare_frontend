import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_avatar.dart';

class ProfileHeader extends StatelessWidget {
  final String? avatarUrl;
  final String? localPath;
  final String fullName;
  final int followersCount;
  final int followingCount;
  final String? bio;
  final Widget actionRow;
  final List<Widget>? rightActions;
  final VoidCallback? onBack;

  const ProfileHeader({
    super.key,
    this.avatarUrl,
    this.localPath,
    required this.fullName,
    required this.followersCount,
    required this.followingCount,
    this.bio,
    required this.actionRow,
    this.rightActions,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 10, 24),
          child: Column(
            children: [
              // Hàng Icon phía trên (Back & Settings)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (onBack != null)
                    IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: onBack)
                  else
                    const SizedBox.shrink(),

                  if (rightActions != null) Row(children: rightActions!),
                ],
              ),

              // Thông tin chính (Avatar, Tên, Stats)
              Row(
                children: [
                  AppAvatar(
                    radius: 40,
                    imageUrl: avatarUrl,
                    localPath: localPath,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(fullName, style: AppTextStyles.heading2.copyWith(color: Colors.white, fontSize: 20)),
                        const SizedBox(height: 8),
                        _buildStats(),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Bio (Nếu có)
              if (bio != null && bio!.isNotEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(bio!, style: AppTextStyles.body.copyWith(color: Colors.white)),
                ),
              const SizedBox(height: 20),

              // Hàng nút hành động (Sửa hồ sơ / Theo dõi)
              actionRow,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        _statColumn(followersCount, 'Người theo dõi'),
        const SizedBox(width: 24),
        _statColumn(followingCount, 'Đang theo dõi'),
      ],
    );
  }

  Widget _statColumn(int count, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$count', style: AppTextStyles.heading3.copyWith(color: Colors.white)),
        Text(label, style: AppTextStyles.body.copyWith(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
