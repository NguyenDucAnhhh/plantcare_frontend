import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;
  final String otp;

  const ResetPasswordScreen({super.key, required this.email, required this.otp});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final newPassword = _passwordCtrl.text.trim();
    final success = await ref.read(authProvider.notifier).resetPassword(
          widget.email,
          widget.otp,
          newPassword,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đặt lại mật khẩu thành công! Vui lòng đăng nhập lại.'),
          backgroundColor: Colors.green,
        ),
      );
      // Chuyển về màn hình đăng nhập
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => context.pop(),
        ),
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
                      decoration: BoxDecoration(
                        color: AppColors.primaryBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.password_rounded,
                        color: AppColors.primaryLight,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Mật khẩu mới', style: AppTextStyles.heading1),
                    const SizedBox(height: 8),
                    Text(
                      'Tạo mật khẩu mới cho tài khoản của bạn.',
                      style: AppTextStyles.bodyGrey,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    AppTextField(
                      label: 'Mật khẩu mới',
                      hint: '••••••••',
                      controller: _passwordCtrl,
                      isPassword: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu';
                        if (v.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Xác nhận mật khẩu',
                      hint: '••••••••',
                      controller: _confirmPasswordCtrl,
                      isPassword: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Vui lòng xác nhận mật khẩu';
                        if (v != _passwordCtrl.text) return 'Mật khẩu không khớp';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    if (authState.errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.error.withOpacity(0.3)),
                        ),
                        child: Text(
                          authState.errorMessage!,
                          style: AppTextStyles.body.copyWith(color: AppColors.error),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    AppButton(
                      label: 'Xác nhận',
                      isLoading: authState.isLoading,
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
