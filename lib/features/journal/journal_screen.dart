import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/providers/app_providers.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/content/content_strings.dart';
import '../../../domain/models/content/content_catalog.dart';
import '../../../domain/models/content/content_models.dart';
import '../../../domain/models/progress.dart';

/// Journal: discovered notes, clues, and story fragments.
/// Entries appear only after their clue IDs are persisted in progress
/// (PLAN.md §8.2.9, Phase 4 acceptance).
class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final catalogAsync = ref.watch(contentCatalogProvider);
    final stringsAsync = ref.watch(contentStringsProvider);
    final progress = ref.watch(gameProgressProvider).value;
    final locale = ref.watch(appLocaleProvider)?.languageCode ?? 'vi';

    return AppScaffold(
      title: l10n.journalTitle,
      showBackButton: true,
      body: catalogAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (catalog) => stringsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (strings) => _JournalList(
            catalog: catalog,
            strings: strings,
            progress: progress,
            locale: locale,
            l10n: l10n,
          ),
        ),
      ),
    );
  }
}

class _JournalList extends StatelessWidget {
  const _JournalList({
    required this.catalog,
    required this.strings,
    required this.progress,
    required this.locale,
    required this.l10n,
  });

  final ContentCatalog catalog;
  final ContentStrings strings;
  final GameProgress? progress;
  final String locale;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final discovered = progress?.discoveredClueIds.toSet() ?? const {};
    final entries = [
      for (final clue in catalog.clues)
        if (discovered.contains(clue.id)) clue,
    ];

    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            l10n.journalEmpty,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AppColors.secondaryText),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final clue = entries[i];
        return SectionCard(
          title: strings.forLocale(locale, clue.titleKey),
          child: Text(
            strings.forLocale(locale, clue.bodyKey),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        );
      },
    );
  }
}
