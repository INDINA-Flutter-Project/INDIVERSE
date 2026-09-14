import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  static const titleFontFamily = 'Michroma';
  static const detailsFontFamily = 'Tomorrow';
  static const interfaceFontFamily = 'Sora';

  /// Michroma is used only for titles, including page, section, and game names.
  static const title = TextStyle(fontFamily: titleFontFamily);

  /// Tomorrow is used for game information and other supporting details.
  static const details = TextStyle(fontFamily: detailsFontFamily);

  /// Regular Sora is used for buttons, navigation, inputs, and general UI copy.
  static const interface = TextStyle(
    fontFamily: interfaceFontFamily,
    fontWeight: FontWeight.w400,
  );

  /// Bold Sora is reserved for titles shown during onboarding.
  static const onboardingTitle = TextStyle(
    fontFamily: interfaceFontFamily,
    fontWeight: FontWeight.w700,
  );

  /// Regular Sora is used for onboarding descriptions and controls.
  static const onboardingDetails = TextStyle(
    fontFamily: interfaceFontFamily,
    fontWeight: FontWeight.w400,
  );

  static const display = TextStyle(
    fontFamily: titleFontFamily,
    fontSize: 34,
    height: 1.08,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.2,
  );
  static const pageTitle = TextStyle(
    fontFamily: titleFontFamily,
    fontSize: 30,
    fontWeight: FontWeight.w800,
    letterSpacing: -.8,
  );
  static const sectionTitle = TextStyle(
    fontFamily: titleFontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );
  static const body = TextStyle(
    fontFamily: detailsFontFamily,
    fontSize: 16,
    height: 1.5,
    color: AppColors.textPrimary,
  );
  static const bodyMuted = TextStyle(
    fontFamily: detailsFontFamily,
    fontSize: 14,
    height: 1.45,
    color: AppColors.textSecondary,
  );
  static const label = TextStyle(
    fontFamily: detailsFontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 1,
  );

  const AppTextStyles._();
}
