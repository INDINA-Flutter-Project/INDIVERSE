import 'package:flutter/material.dart';

/// The complete semantic color vocabulary for INDIVERSE.
///
/// Feature widgets should use these names instead of raw color values. This
/// keeps a future rebrand or light theme isolated to the theme layer.
abstract final class AppColors {
  static const background = Color(0xFF0A0F0E);
  static const surface = Color(0xFF121A18);
  static const surfaceRaised = Color(0xFF1A2421);
  static const primary = Color(0xFF70E3B1);
  static const primaryContainer = Color(0xFF123E30);
  static const textPrimary = Color(0xFFF4F7F5);
  static const textSecondary = Color(0xFF9EABA6);
  static const border = Color(0xFF293530);
  static const success = Color(0xFF54D69B);
  static const warning = Color(0xFFF1B85B);
  static const error = Color(0xFFFF6B6B);

  const AppColors._();
}
