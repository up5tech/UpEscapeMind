import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Application theme. Dark, atmospheric, portrait-first.
abstract final class AppTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);

    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.brass,
          brightness: Brightness.dark,
        ).copyWith(
          primary: AppColors.brass,
          onPrimary: AppColors.inkNavy,
          secondary: AppColors.amber,
          onSecondary: AppColors.inkNavy,
          surface: AppColors.surface,
          onSurface: AppColors.primaryText,
          error: AppColors.clockRed,
        );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.surface,
      canvasColor: AppColors.surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primaryText,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceElevated,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.brass, width: 0.5),
        ),
      ),
      textTheme: AppTypography.applyTo(
        base.textTheme.apply(
          bodyColor: AppColors.primaryText,
          displayColor: AppColors.primaryText,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.brass,
        thickness: 0.5,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceElevated,
        contentTextStyle: const TextStyle(color: AppColors.primaryText),
        behavior: SnackBarBehavior.floating,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.brass),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.brass),
        ),
      ),
    );
  }
}
