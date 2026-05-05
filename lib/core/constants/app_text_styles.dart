import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // === TIEU DE LON (Figma: "Dang ky", "Chao mung tro lai") ===
  static TextStyle heading1 = GoogleFonts.nunito(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
  );

  // === TIEU DE VUA ===
  static TextStyle heading2 = GoogleFonts.nunito(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  // === TIEU DE NHO (Figma: "Thao tac nhanh", label o nhap lieu) ===
  static TextStyle heading3 = GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  // === VAN BAN THUONG ===
  static TextStyle body = GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
  );

  // === MO TA NHO (Figma: "Tao tai khoan moi de bat dau") ===
  static TextStyle bodyGrey = GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textGrey,
  );

  // === NUT BAN (Figma: "Dang ky", "Dang nhap") ===
  static TextStyle button = GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  // === LINK (Figma: "Dang nhap", "Dang ky ngay") ===
  static TextStyle link = GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryLight,
  );

  // === LABEL O NHAP LIEU ===
  static TextStyle label = GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );
}
