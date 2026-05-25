import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class AppAvatar extends StatelessWidget {
  final String? imageUrl;     // Dùng cho ảnh lấy từ Server (API)
  final String? localPath;    // Dùng cho ảnh vừa chọn từ máy (khi Edit Profile)
  final double radius;        // Tùy chỉnh kích thước to/nhỏ tùy màn hình

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.localPath,
    this.radius = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;

    // 1. Ưu tiên hiển thị ảnh chọn từ máy (Local) trước nếu có
    if (localPath != null && localPath!.isNotEmpty) {
      imageProvider = kIsWeb
          ? NetworkImage(localPath!) as ImageProvider
          : FileImage(File(localPath!));
    }
    // 2. Nếu không có ảnh máy, dùng ảnh từ Server
    else if (imageUrl != null && imageUrl!.isNotEmpty) {
      imageProvider = NetworkImage(imageUrl!);
    }

    // 3. Render giao diện
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: imageProvider,
      // Nếu imageProvider là null (không có cả 2 ảnh), thì hiện Icon người
      child: imageProvider == null
          ? Icon(
        Icons.person,
        size: radius, // Tự động scale icon theo bán kính
        color: Colors.grey.shade400,
      )
          : null,
    );
  }
}