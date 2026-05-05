// Toan bo mau sac lay tu Figma PlantCare
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // === MAU CHINH (Primary) ===
  static const Color primary = Color(0xFF2E7D32);       // Xanh la dam - nut, header
  static const Color primaryLight = Color(0xFF4CAF50);  // Xanh la nhat - icon, highlight
  static const Color primaryBg = Color(0xFFF1F8E9);     // Nen xanh nhat - background

  // === MAU PHA (Accent) ===
  static const Color accentBlue = Color(0xFF3F51B5);    // Xanh duong - nut "Chuan doan benh"
  static const Color accentPurple = Color(0xFF9C27B0);  // Tim - nut "Tao bai dang"

  // === MAU VAN BAN ===
  static const Color textDark = Color(0xFF1A1A2E);      // Den dam - tieu de chinh
  static const Color textGrey = Color(0xFF757575);      // Xam - placeholder, ghi chu
  static const Color textLight = Color(0xFFBDBDBD);     // Xam nhat

  // === MAU NEN ===
  static const Color background = Color(0xFFF8FFF8);    // Nen trang xanh nhat
  static const Color surface = Color(0xFFFFFFFF);       // Card, form trang
  static const Color inputBg = Color(0xFFF5F5F5);       // Nen o nhap lieu

  // === MAU CANH BAO ===
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);

  // === MAU NUT DEN (Figma) ===
  static const Color buttonDark = Color(0xFF1A1A2E);    // Nut "Dang ky", "Dang nhap"
}
