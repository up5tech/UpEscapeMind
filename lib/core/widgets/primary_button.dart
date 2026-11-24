import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Primary action button styled for the game's brass/amber palette.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = enabled ? onPressed : null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: enabled ? AppColors.goldFoil : null,
        color: enabled ? null : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: enabled
              ? AppColors.goldFoilLight
              : AppColors.brass.withValues(alpha: 0.4),
        ),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: AppColors.candleGlow.withValues(alpha: 0.22),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: FilledButton.icon(
        onPressed: effectiveOnPressed,
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 20),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: enabled
              ? AppColors.inkNavy
              : AppColors.disabledText,
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: AppColors.disabledText,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
