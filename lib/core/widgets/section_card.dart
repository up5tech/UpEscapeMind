import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import 'app_chrome.dart';

/// Titled content card used on menu, chapter select, and settings screens.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.title,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final String? title;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassPanel(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.amber,
                fontWeight: FontWeight.w600,
              ),
            ),
            const FoilDivider(),
          ],
          child,
        ],
      ),
    );
  }
}
