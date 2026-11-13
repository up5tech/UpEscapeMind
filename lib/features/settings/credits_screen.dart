import 'package:flutter/material.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../core/widgets/widgets.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      title: l10n.creditsTitle,
      showBackButton: true,
      body: AppCenteredPage(
        child: SectionCard(
          child: Text(
            l10n.creditsBody,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}
