import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  static const display = TextStyle(
    fontSize: 34,
    height: 1.08,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.2,
  );
  static const pageTitle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    letterSpacing: -.8,
  );
  static const sectionTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );
  static const body = TextStyle(
    fontSize: 16,
    height: 1.5,
    color: AppColors.textPrimary,
  );
  static const bodyMuted = TextStyle(
    fontSize: 14,
    height: 1.45,
    color: AppColors.textSecondary,
  );
  static const label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 1,
  );

  const AppTextStyles._();
}
