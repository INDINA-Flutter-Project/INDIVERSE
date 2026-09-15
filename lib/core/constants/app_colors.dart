import 'package:flutter/material.dart';

/// The complete semantic color vocabulary for INDIVERSE.
///
/// Feature widgets should use these names instead of raw color values. This
/// keeps a future rebrand or light theme isolated to the theme layer.
abstract final class AppColors {
  static const background = Color(0xFF000000);
  static const surface = Color(0xFF090F0D);
  static const surfaceRaised = Color(0xFF101917);
  static const glassFill = Color(0x0CFFFFFF);
  static const glassBorder = Color(0x17FFFFFF);
  static const primary = Color(0xFF22D17E);
  static const primaryDeep = Color(0xFF0E8F57);
  static const primaryContainer = Color(0xFF0A2D1F);
  static const silver = Color(0xFFE7ECEA);
  static const textPrimary = Color(0xFFF3F5F4);
  static const textSecondary = Color(0xFF8A9490);
  static const border = Color(0xFF1E2A26);
  static const success = Color(0xFF22D17E);
  static const warning = Color(0xFFF1B85B);
  static const error = Color(0xFFFF6B6B);

  const AppColors._();
}
