import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Illustrated chrome shared by menus, cards, sheets, and puzzle panels
/// (PLAN.md §8.7). Screens compose these widgets instead of restyling
/// Material defaults locally.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 14,
    this.borderColor = AppColors.brass,
    this.opacity = 0.82,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color borderColor;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.inkNavy.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor.withValues(alpha: 0.75), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.inkNavy.withValues(alpha: 0.55),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.parchmentText.withValues(alpha: 0.05),
            Colors.transparent,
          ],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: child,
      ),
    );
  }
}

class FoilDivider extends StatelessWidget {
  const FoilDivider({super.key, this.height = 1, this.margin = const EdgeInsets.symmetric(vertical: 10)});

  final double height;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      height: height,
      decoration: const BoxDecoration(gradient: AppColors.goldFoil),
    );
  }
}

/// Brass-rimmed inventory slot with a soft inner glow.
class BrassSlot extends StatelessWidget {
  const BrassSlot({
    super.key,
    required this.child,
    this.size = 72,
    this.highlight = false,
    this.onTap,
  });

  final Widget child;
  final double size;
  final bool highlight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final slot = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight ? AppColors.goldFoilLight : AppColors.brass,
          width: highlight ? 2 : 1,
        ),
        boxShadow: highlight
            ? [
                BoxShadow(
                  color: AppColors.candleGlow.withValues(alpha: 0.35),
                  blurRadius: 16,
                ),
              ]
            : null,
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(11), child: child),
    );
    if (onTap == null) return slot;
    return Semantics(button: true, child: InkWell(onTap: onTap, child: slot));
  }
}

/// Wax-seal badge used for journal marks and chapter completion.
class WaxSeal extends StatelessWidget {
  const WaxSeal({super.key, required this.child, this.size = 56});

  final Widget child;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.clockRed,
        border: Border.all(color: AppColors.goldFoilLight, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DefaultTextStyle(
        style: const TextStyle(color: AppColors.parchmentText, fontSize: 13),
        child: child,
      ),
    );
  }
}
