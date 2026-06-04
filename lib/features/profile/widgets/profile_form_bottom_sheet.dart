import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/custom_bottom_sheet_form.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/utils/error_mapper.dart';
import '../providers/profile_provider.dart';

class ProfileFormBottomSheet extends ConsumerStatefulWidget {
  const ProfileFormBottomSheet({super.key});

  @override
  ConsumerState<ProfileFormBottomSheet> createState() => _ProfileFormBottomSheetState();
}

class _ProfileFormBottomSheetState extends ConsumerState<ProfileFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _bioCtrl;
  bool _isLoading = false;
  String? _localAvatarPath;
  String? _currentAvatarUrl;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider).profile;
    _nameCtrl = TextEditingController(text: profile?['fullName'] ?? '');
    _bioCtrl = TextEditingController(text: profile?['bio'] ?? '');
    _currentAvatarUrl = profile?['avatarUrl'];
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(profileRepositoryProvider);
      
      if (_localAvatarPath != null && !kIsWeb) {
        await repo.uploadAvatar(_localAvatarPath!);
      }

      await ref.read(profileProvider.notifier).updateProfile({
        'fullName': _nameCtrl.text.trim(),
        'bio': _bioCtrl.text.trim(),
      });
      if (mounted) {
        Navigator.pop(context);
        AppSnackbar.showSuccess(context, 'Đã cập nhật hồ sơ');
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, ErrorMapper.parseError(e));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheetForm(
      title: 'Chỉnh sửa hồ sơ',
      actionLabel: 'Lưu thay đổi',
      onActionPressed: _submit,
      isActionLoading: _isLoading,
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ảnh đại diện', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: [
                AppAvatar(
                  imageUrl: _currentAvatarUrl,
                  localPath: _localAvatarPath,
                  radius: 40,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picker = ImagePicker();
                        final image = await picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          setState(() {
                            _localAvatarPath = image.path;
                          });
                        }
                      },
                      icon: const Icon(Icons.camera_alt_outlined, size: 18, color: AppColors.textDark),
                      label: const Text('Chọn ảnh', style: TextStyle(color: AppColors.textDark)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('Tối đa 5MB', style: AppTextStyles.bodyGrey.copyWith(fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Tên hiển thị', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameCtrl,
              decoration: _buildInputDecoration('Họ và tên'),
              validator: (v) => v!.isEmpty ? 'Vui lòng nhập họ và tên' : null,
            ),
            const SizedBox(height: 16),
            Text('Giới thiệu', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _bioCtrl,
              decoration: _buildInputDecoration('Tiểu sử (Tuỳ chọn)'),
              maxLines: 4,
              maxLength: 150,
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyGrey,
      filled: true,
      fillColor: AppColors.inputBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
