import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFF5F8FE);
  static const Color card = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF4A90E2);
  static const Color accent = Color(0xFF50E3C2);
  static const Color textPrimary = Color(0xFF222B45);
  static const Color textSecondary = Color(0xFF8F9BB3);
  static const Color border = Color(0xFFE4E9F2);
  static const Color icon = Color(0xFFBFC9DA);
  static const Color category1 = Color(0xFF6C63FF);
  static const Color category2 = Color(0xFFFFA726);
  static const Color category3 = Color(0xFF26C6DA);
  static const Color category4 = Color(0xFF66BB6A);
}

class AppTextStyles {
  static const TextStyle headline1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  static const TextStyle headline2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );
  static const TextStyle bodySecondary = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );
  static const TextStyle cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );
}
