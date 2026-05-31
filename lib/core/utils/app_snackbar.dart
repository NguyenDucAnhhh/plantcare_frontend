import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class AppSnackbar {
  /// Hiển thị thông báo thành công (Màu xanh)
  static void showSuccess(BuildContext context, String message) {
    _showSnackbar(context, message, isError: false);
  }

  /// Hiển thị thông báo lỗi (Màu đỏ)
  static void showError(BuildContext context, String message) {
    _showSnackbar(context, message, isError: true);
  }

  static void _showSnackbar(BuildContext context, String message, {required bool isError}) {
    // Ẩn snackbar cũ (nếu có) trước khi hiện cái mới để tránh chồng chéo
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.body.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: isError ? Colors.red.shade700 : AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      duration: const Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
