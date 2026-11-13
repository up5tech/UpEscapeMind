import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Standard scaffold for full-screen feature pages: themed background,
/// optional app bar, safe-area aware body.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.showBackButton = false,
    this.actions,
  });

  final Widget body;
  final String? title;
  final bool showBackButton;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title == null
          ? null
          : AppBar(
              title: Text(title!),
              automaticallyImplyLeading: showBackButton,
              actions: actions,
            ),
      body: SafeArea(child: body),
    );
  }
}

/// Full-page centered layout used by splash/menu-style screens.
class AppCenteredPage extends StatelessWidget {
  const AppCenteredPage({
    super.key,
    required this.child,
    this.scrollable = true,
  });

  final Widget child;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: child,
    );

    return scrollable ? SingleChildScrollView(child: content) : content;
  }
}

/// Brass-accented horizontal rule used as a decorative divider.
class BrassDivider extends StatelessWidget {
  const BrassDivider({super.key, this.thickness = 1});

  final double thickness;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: thickness,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, AppColors.brass, Colors.transparent],
        ),
      ),
    );
  }
}
