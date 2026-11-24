import 'package:flutter/material.dart';

import 'app_colors.dart';

/// r2 type scale (PLAN.md §8.7). Serif for story/title, sans for UI labels.
/// Fonts are declared as families so licensed files can be bundled later
/// without changing call sites.
abstract final class AppTypography {
  static const String displayFamily = 'Lora';
  static const String bodyFamily = 'Lora';
  static const String uiFamily = 'Inter';

  static const TextStyle display = TextStyle(
    fontFamily: displayFamily,
    fontSize: 42,
    height: 1.15,
    letterSpacing: 1.2,
    fontWeight: FontWeight.w700,
    color: AppColors.parchmentText,
  );

  static const TextStyle title = TextStyle(
    fontFamily: displayFamily,
    fontSize: 26,
    height: 1.25,
    letterSpacing: 0.6,
    fontWeight: FontWeight.w600,
    color: AppColors.parchmentText,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: displayFamily,
    fontSize: 19,
    height: 1.35,
    color: AppColors.amber,
  );

  static const TextStyle body = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 15,
    height: 1.45,
    color: AppColors.parchmentText,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: uiFamily,
    fontSize: 12,
    height: 1.4,
    color: AppColors.secondaryText,
  );

  static const TextStyle hint = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 14,
    height: 1.5,
    color: AppColors.parchmentText,
  );

  static TextTheme applyTo(TextTheme base) => base.copyWith(
    displayLarge: display,
    displayMedium: title,
    titleLarge: title,
    titleMedium: subtitle,
    bodyLarge: body,
    bodyMedium: body,
    bodySmall: hint,
    labelLarge: caption,
  );
}
