import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).register(
          _nameCtrl.text.trim(),
          _emailCtrl.text.trim(),
          _passwordCtrl.text.trim(),
        );

    if (success && mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
                    // === ICON LA CAY (Figma) ===
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.eco_rounded,
                        color: AppColors.primaryLight,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // === TIEU DE: "Dang ky" ===
                    Text('Đăng ký', style: AppTextStyles.heading1),
                    const SizedBox(height: 8),
                    Text(
                      'Tạo tài khoản mới để bắt đầu',
                      style: AppTextStyles.bodyGrey,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // === HO VA TEN ===
                    AppTextField(
                      label: 'Họ và tên',
                      hint: 'Nguyễn Văn A',
                      controller: _nameCtrl,
                      keyboardType: TextInputType.name,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Vui lòng nhập họ tên';
                        if (v.trim().length < 2) return 'Họ tên quá ngắn';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // === EMAIL ===
                    AppTextField(
                      label: 'Email',
                      hint: 'your@email.com',
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Vui lòng nhập email';
                        if (!v.contains('@')) return 'Email không hợp lệ';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // === MAT KHAU ===
                    AppTextField(
                      label: 'Mật khẩu',
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

                    // === XAC NHAN MAT KHAU ===
                    AppTextField(
                      label: 'Xác nhận mật khẩu',
                      hint: '••••••••',
                      controller: _confirmCtrl,
                      isPassword: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Vui lòng xác nhận mật khẩu';
                        if (v != _passwordCtrl.text) return 'Mật khẩu không khớp';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // === HIEN THI LOI TU SERVER ===
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

                    // === NUT DANG KY (Figma: nut den) ===
                    AppButton(
                      label: 'Đăng ký',
                      isLoading: authState.isLoading,
                      onPressed: _onRegister,
                    ),
                    const SizedBox(height: 20),

                    // === DA CO TAI KHOAN? DANG NHAP ===
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Đã có tài khoản?  ', style: AppTextStyles.bodyGrey),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: Text('Đăng nhập', style: AppTextStyles.link),
                        ),
                      ],
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
