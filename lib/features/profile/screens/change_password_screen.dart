import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/custom_header.dart';
import '../providers/profile_provider.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    final oldPassword = _oldPasswordCtrl.text.trim();
    final newPassword = _newPasswordCtrl.text.trim();
    
    final success = await ref.read(profileProvider.notifier).changePassword(
          oldPassword,
          newPassword,
        );

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đổi mật khẩu thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        // Chuyển về màn hình cài đặt
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mật khẩu cũ không chính xác hoặc có lỗi xảy ra!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      appBar: const CustomHeader(
        title: 'Đổi mật khẩu',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_reset_rounded,
                        color: AppColors.primaryLight,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Đổi mật khẩu', style: AppTextStyles.heading1),
                    const SizedBox(height: 8),
                    Text(
                      'Tạo mật khẩu mới cho tài khoản của bạn để tăng cường bảo mật.',
                      style: AppTextStyles.bodyGrey,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    AppTextField(
                      label: 'Mật khẩu cũ',
                      hint: '••••••••',
                      controller: _oldPasswordCtrl,
                      isPassword: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu cũ';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Mật khẩu mới',
                      hint: '••••••••',
                      controller: _newPasswordCtrl,
                      isPassword: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu mới';
                        if (v.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
                        if (v == _oldPasswordCtrl.text) return 'Mật khẩu mới phải khác mật khẩu cũ';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Xác nhận mật khẩu mới',
                      hint: '••••••••',
                      controller: _confirmPasswordCtrl,
                      isPassword: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Vui lòng xác nhận mật khẩu mới';
                        if (v != _newPasswordCtrl.text) return 'Mật khẩu không khớp';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'Cập nhật mật khẩu',
                      isLoading: _isLoading,
                      onPressed: _onSubmit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
