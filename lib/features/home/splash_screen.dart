import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

/// Brief branded splash; hands off to the main menu.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Defer navigation until after the first frame so context is valid.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.goNamed('menu');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: AppCenteredPage(
        child: Column(
          children: [
            const SizedBox(height: 80),
            Text(
              l10n.appName,
              style: theme.textTheme.displaySmall?.copyWith(
                color: AppColors.parchmentText,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const BrassDivider(),
            const SizedBox(height: 12),
            Text(
              l10n.appTagline,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: AppColors.brass),
          ],
        ),
      ),
    );
  }
}
