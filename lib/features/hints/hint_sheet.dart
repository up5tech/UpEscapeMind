import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/localization/app_localizations.dart';
import '../../app/progress_actions.dart';
import '../../app/providers/app_providers.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/widgets.dart';
import '../../domain/models/content/content_models.dart';

/// Three-level hint sheet (PLAN §6).
///
/// Levels are authored per puzzle in content JSON and revealed one at a
/// time; revealed levels persist immediately and survive close/reopen.
/// The level-3 walkthrough asks an explicit confirmation first (PLAN
/// §6.1). Hints cost nothing and never gate progression (§6.2/§7.2).
Future<void> showHintSheet(BuildContext context, PuzzleDefinition puzzle) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.charcoal,
    builder: (_) => HintSheet(puzzle: puzzle),
  );
}

class HintSheet extends ConsumerWidget {
  const HintSheet({super.key, required this.puzzle});

  final PuzzleDefinition puzzle;

  /// Sorted authored hint levels (content may author fewer than three).
  List<int> get _levels {
    final levels = puzzle.hints.map((h) => h.level).toList()..sort();
    return levels;
  }

  Future<void> _revealNext(BuildContext context, WidgetRef ref, int nextLevel) async {
    if (nextLevel >= 3) {
      final l10n = AppLocalizations.of(context);
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: AppColors.charcoal,
          title: Text(l10n.hintWalkthroughConfirmTitle),
          content: Text(
            l10n.hintWalkthroughConfirmBody,
            style: const TextStyle(color: AppColors.parchmentText),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              key: const ValueKey('hint_walkthrough_confirm'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.commonConfirm),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;
    }
    await ref.read(progressActionsProvider).revealHint(puzzle.id, nextLevel);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final progress = ref.watch(gameProgressProvider).value;
    final strings = ref.watch(contentStringsProvider).value;
    if (progress == null || strings == null) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final locale = ref.watch(appLocaleProvider)?.languageCode ?? 'vi';
    String s(String key) => strings.forLocale(locale, key);

    final revealed = progress.hintLevelFor(puzzle.id);
    final next = _levels.firstWhere((level) => level > revealed, orElse: () => 0);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.brass,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.hintsTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.parchmentText,
                    ),
                  ),
                ],
              ),
              Text(
                s(puzzle.titleKey),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 16),
              for (final hint in puzzle.hints)
                if (hint.level <= revealed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SectionCard(
                      title: l10n.hintLevelTitle(hint.level),
                      child: Text(
                        s(hint.textKey),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.parchmentText,
                        ),
                      ),
                    ),
                  ),
              if (next > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: PrimaryButton(
                    key: const ValueKey('hint_reveal_next'),
                    label: l10n.hintNextButton,
                    onPressed: () => _revealNext(context, ref, next),
                  ),
                )
              else if (revealed > 0 && _levels.isNotEmpty)
                Text(
                  l10n.hintLevelTitle(_levels.last),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.disabledText,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
