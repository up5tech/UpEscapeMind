import 'package:flutter/material.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../core/widgets/widgets.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    Widget section(String title, String body) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(body, style: theme.textTheme.bodyMedium),
            ],
          ),
        );

    return AppScaffold(
      title: l10n.creditsTitle,
      showBackButton: true,
      body: AppCenteredPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.appName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  section(l10n.creditsArtTitle, l10n.creditsArtBody),
                  section(l10n.creditsAudioTitle, l10n.creditsAudioBody),
                  section(l10n.creditsTechTitle, l10n.creditsTechBody),
                ],
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.gavel_outlined),
                title: Text(l10n.creditsLicensesAction),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: l10n.appName,
                  applicationVersion: '1.0.0',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
