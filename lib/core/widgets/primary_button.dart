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

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: effectiveOnPressed,
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 20),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.brass,
          foregroundColor: AppColors.inkNavy,
          disabledBackgroundColor: AppColors.surfaceElevated,
          disabledForegroundColor: AppColors.disabledText,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
