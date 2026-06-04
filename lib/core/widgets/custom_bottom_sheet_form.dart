import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class CustomBottomSheetForm extends StatelessWidget {
  final String title;
  final Widget content;
  final String actionLabel;
  final VoidCallback onActionPressed;
  final bool isActionLoading;
  final bool isActionDisabled;
  final double contentPadding;

  const CustomBottomSheetForm({
    super.key,
    required this.title,
    required this.content,
    required this.actionLabel,
    required this.onActionPressed,
    this.isActionLoading = false,
    this.isActionDisabled = false,
    this.contentPadding = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    // Keyboard padding
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 8,
        left: contentPadding,
        right: contentPadding,
        bottom: bottomInset > 0 ? bottomInset + 24 : 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Drag Handle
          Center(
            child: Container(
              width: 48,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // 2. Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.heading2),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: AppColors.textGrey),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 3. Scrollable Content
          Flexible(
            child: SingleChildScrollView(
              child: content,
            ),
          ),

          // 4. Action Button (To ở dưới cùng)
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: (isActionLoading || isActionDisabled) ? null : onActionPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: isActionLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    actionLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
