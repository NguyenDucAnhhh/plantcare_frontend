import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton; // Cho phép bật/tắt mũi tên quay lại
  final List<Widget>? actions; // Cho phép truyền vào các nút bấm khác nhau ở bên phải

  const CustomHeader({
    super.key,
    required this.title,
    this.showBackButton = false, // Mặc định là không có mũi tên quay lại
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      
      // Xử lý mũi tên quay lại
      automaticallyImplyLeading: false, // Tắt mũi tên mặc định của Flutter để tự control
      leading: showBackButton 
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
          
      // Xử lý tiêu đề
      title: Text(
        title,
        style: AppTextStyles.heading2.copyWith(color: Colors.white),
      ),
      
      // Các nút bấm bên phải (actions)
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
