import 'package:flutter/material.dart';

/// Color palette from `design/05-visual-style.md`.
///
/// "Dusty grandeur": muted navy/charcoal surfaces, aged paper, brass, and
/// restrained amber highlights.
abstract final class AppColors {
  static const Color inkNavy = Color(0xFF141B2E);
  static const Color charcoal = Color(0xFF23262E);
  static const Color agedPaper = Color(0xFFD8C9A3);
  static const Color brass = Color(0xFFB08D3E);
  static const Color amber = Color(0xFFE8A33D);
  static const Color clockRed = Color(0xFFA33B2E);
  static const Color parchmentText = Color(0xFFF2EAD8);

  // r2 art-direction tokens (§8.7). Existing tokens are unchanged.
  static const Color goldFoilLight = Color(0xFFE8C86A);
  static const Color goldFoilDark = Color(0xFFB08D3E);
  static const Color candleGlow = Color(0xFFFFD27A);
  static const Color fogBlue = Color(0xFF2A3A5E);
  static const Color parchmentShadow = Color(0xFF8A7648);
  static const Color successSeal = Color(0xFF3E7A4E);

  static const LinearGradient goldFoil = LinearGradient(
    colors: [goldFoilLight, goldFoilDark],
  );

  // Derived surface colors.
  static const Color surface = inkNavy;
  static const Color surfaceElevated = charcoal;
  static const Color surfaceOverlay = Color(0xCC141B2E);

  static const Color primaryText = parchmentText;
  static const Color secondaryText = Color(0xB3F2EAD8);
  static const Color disabledText = Color(0x59F2EAD8);

  static const Color accent = brass;
  static const Color highlight = amber;
  static const Color danger = clockRed;
}
