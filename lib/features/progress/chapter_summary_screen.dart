import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/localization/app_localizations.dart';
import '../../app/providers/app_providers.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/widgets.dart';
import '../../domain/models/progress.dart';
import '../../domain/rules/chapter_rating.dart';
import '../../domain/rules/progress_stats.dart';

/// Chapter completion summary (Phase 8 task 7).
///
/// Reachable only for chapters already completed (route guard): right
/// after the chapter's final objective fires, and from the chapters
/// screen via "View summary". Shows the transparent star rules, the
/// "no walkthrough" badge, per-room progress, and local statistics
/// (PLAN §7.2–7.3). Previously unlocked content stays reachable.
class ChapterSummaryScreen extends ConsumerStatefulWidget {
  const ChapterSummaryScreen({super.key, required this.chapterId});

  final String chapterId;

  @override
  ConsumerState<ChapterSummaryScreen> createState() =>
      _ChapterSummaryScreenState();
}

class _ChapterSummaryScreenState extends ConsumerState<ChapterSummaryScreen> {
  @override
  void initState() {
    super.initState();
    // Direct-route safety: unfinished chapters must not show a summary.
    WidgetsBinding.instance.addPostFrameCallback((_) => _guard());
  }

  Future<void> _guard() async {
    GameProgress? progress;
    try {
      progress = await ref.read(gameProgressProvider.future);
    } on Object {
      return; // container torn down
    }
    if (progress == null) return;
    if (!progress.completedChapterIds.contains(widget.chapterId)) {
      if (mounted) context.goNamed('chapters');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final catalogAsync = ref.watch(contentCatalogProvider);
    final stringsAsync = ref.watch(contentStringsProvider);
    final progressAsync = ref.watch(gameProgressProvider);
    final locale = ref.watch(appLocaleProvider)?.languageCode ?? 'vi';

    final catalog = catalogAsync.value;
    final strings = stringsAsync.value;
    final progress = progressAsync.value;
    if (catalog == null || strings == null || progress == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final chapter = catalog.chaptersById[widget.chapterId];
    if (chapter == null ||
        !progress.completedChapterIds.contains(chapter.id)) {
      // Route guard fallback (state read synchronously above may lag).
      return AppScaffold(
        title: l10n.chapterLocked,
        showBackButton: true,
        body: Center(child: Text(l10n.chapterLocked)),
      );
    }

    String s(String key) => strings.forLocale(locale, key);
    final rating = rateChapter(
      chapter: chapter,
      catalog: catalog,
      progress: progress,
    );
    final stats = computeProgressStats(catalog: catalog, progress: progress);
    final theme = Theme.of(context);

    return AppScaffold(
      title: s(chapter.titleKey),
      showBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.summaryTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.brass,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _StarsRow(rating: rating, l10n: l10n),
            if (rating.noWalkthroughBadge)
              Padding(
                key: const ValueKey('summary_no_walkthrough_badge'),
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.verified_outlined,
                      size: 18,
                      color: AppColors.brass,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.badgeNoWalkthrough,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.brass,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            SectionCard(
              title: l10n.summaryStarsLabel,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RuleLine(
                    earned: rating.stars >= 1,
                    text: l10n.starRuleOne,
                  ),
                  _RuleLine(
                    earned: rating.stars >= 2,
                    text: l10n.starRuleTwo,
                    trailing: '${rating.puzzlesSolved}/'
                        '${rating.puzzlesTotal}',
                  ),
                  _RuleLine(
                    earned: rating.stars >= 3,
                    text: l10n.starRuleThree,
                    trailing: '${rating.cluesFound}/${rating.cluesTotal}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: l10n.summaryAreas,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final room in rating.rooms)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(
                            room.isComplete
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            size: 18,
                            color: room.isComplete
                                ? AppColors.brass
                                : AppColors.disabledText,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              catalog.roomsById[room.roomId] == null
                                  ? room.roomId
                                  : s(catalog.roomsById[room.roomId]!.titleKey),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.parchmentText,
                              ),
                            ),
                          ),
                          Text(
                            '${room.puzzlesSolved}/${room.puzzlesTotal}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  TextButton(
                    key: const ValueKey('summary_open_journal'),
                    onPressed: () => context.pushNamed('journal'),
                    child: Text(l10n.journalTitle),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: l10n.statsTitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatLine(
                    label: l10n.statChaptersCompleted,
                    value: '${stats.chaptersCompleted}',
                  ),
                  _StatLine(
                    label: l10n.statAreasDiscovered(
                      stats.areasDiscovered,
                      stats.areasTotal,
                    ),
                  ),
                  _StatLine(
                    label: l10n.statPuzzlesSolved(
                      stats.puzzlesSolved,
                      stats.puzzlesTotal,
                    ),
                  ),
                  _StatLine(
                    label: l10n.statOptionalCluesFound(
                      stats.optionalCluesFound,
                      stats.optionalCluesTotal,
                    ),
                  ),
                  _StatLine(
                    label: l10n.statHintsLevel(1, stats.hintsLevel1Opened),
                  ),
                  _StatLine(
                    label: l10n.statHintsLevel(2, stats.hintsLevel2Opened),
                  ),
                  _StatLine(
                    label: l10n.statHintsLevel(3, stats.hintsLevel3Opened),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              key: const ValueKey('summary_continue'),
              label: l10n.menuContinue,
              onPressed: () => context.goNamed('chapters'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StarsRow extends StatelessWidget {
  const _StarsRow({required this.rating, required this.l10n});

  final ChapterRating rating;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${l10n.summaryStarsLabel}: ${rating.stars}/3',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 1; i <= 3; i++)
            Icon(
              key: ValueKey('summary_star_$i'),
              i <= rating.stars ? Icons.star : Icons.star_border,
              size: 40,
              color: AppColors.brass,
            ),
        ],
      ),
    );
  }
}

class _RuleLine extends StatelessWidget {
  const _RuleLine({
    required this.earned,
    required this.text,
    this.trailing,
  });

  final bool earned;
  final String text;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            earned ? Icons.check : Icons.radio_button_unchecked,
            size: 18,
            color: earned ? AppColors.brass : AppColors.disabledText,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: earned
                    ? AppColors.parchmentText
                    : AppColors.secondaryText,
              ),
            ),
          ),
          if (trailing != null)
            Text(
              trailing!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
        ],
      ),
    );
  }
}

class _StatLine extends StatelessWidget {
  const _StatLine({required this.label, this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.parchmentText,
              ),
            ),
          ),
          if (value != null)
            Text(
              value!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.brass,
              ),
            ),
        ],
      ),
    );
  }
}
