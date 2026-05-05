import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/storage/secure_storage.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../../diagnosis/providers/diagnosis_history_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _pushNotification = true;
  bool _emailNotification = false;

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
            // Nut Xoa (Dang xuat) mau do
            ElevatedButton(
              onPressed: () async {
                // Thuc hien dang xuat
                await SecureStorage.clear();
                
                // Reset toan bo state cua cac provider de tranh luu cache cua user cu
                ref.invalidate(authProvider);
                ref.invalidate(profileProvider);
                ref.invalidate(diagnosisHistoryProvider);

                // Chuyen thang ve login
                if (context.mounted) {
                  context.go('/login');
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
            // Nut Huy mau trang vien xam
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF343A40), // Mau toi nhu Figma
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Cài đặt',
          style: AppTextStyles.heading3.copyWith(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === TAI KHOAN ===
            _buildSectionTitle('TÀI KHOẢN'),
            _buildSectionCard([
              _buildListTile(
                icon: Icons.person_outline,
                title: 'Hồ sơ cá nhân',
                onTap: () {},
              ),
              const Divider(height: 1, indent: 48, endIndent: 16),
              _buildListTile(
                icon: Icons.lock_outline,
                title: 'Đổi mật khẩu',
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 24),

            // === THONG BAO ===
            _buildSectionTitle('THÔNG BÁO'),
            _buildSectionCard([
              _buildSwitchTile(
                icon: Icons.notifications_none,
                title: 'Thông báo đẩy',
                subtitle: 'Nhận thông báo về hoạt động',
                value: _pushNotification,
                onChanged: (val) => setState(() => _pushNotification = val),
              ),
              const Divider(height: 1, indent: 48, endIndent: 16),
              _buildSwitchTile(
                icon: Icons.notifications_none,
                title: 'Thông báo email',
                subtitle: 'Nhận email về cập nhật',
                value: _emailNotification,
                onChanged: (val) => setState(() => _emailNotification = val),
              ),
            ]),
            const SizedBox(height: 24),

            // === THONG TIN ===
            _buildSectionTitle('THÔNG TIN'),
            _buildSectionCard([
              _buildListTile(
                icon: Icons.info_outline,
                title: 'Về ứng dụng',
                trailingText: 'v1.0.0',
                onTap: () {},
              ),
              const Divider(height: 1, indent: 48, endIndent: 16),
              _buildListTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Điều khoản dịch vụ',
                onTap: () {},
              ),
              const Divider(height: 1, indent: 48, endIndent: 16),
              _buildListTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Chính sách bảo mật',
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 32),

            // === NUT DANG XUAT ===
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showLogoutDialog,
                icon: const Icon(Icons.logout, color: Colors.white, size: 20),
                label: const Text(
                  'Đăng xuất',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: AppTextStyles.label.copyWith(
          color: AppColors.textGrey,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSectionCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? trailingText,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textDark, size: 24),
      title: Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
      trailing: trailingText != null
          ? Text(trailingText, style: AppTextStyles.bodyGrey)
          : const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppColors.textDark, size: 24),
      title: Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: AppTextStyles.bodyGrey.copyWith(fontSize: 12)),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.white,
      activeTrackColor: AppColors.textDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
