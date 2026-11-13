import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/providers/app_providers.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/models/chapter.dart';
import '../../../domain/models/progress.dart';

/// Main menu: Continue, New Game, Chapters, Settings, Credits.
class MainMenuScreen extends ConsumerWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final progressAsync = ref.watch(gameProgressProvider);

    return AppScaffold(
      body: AppCenteredPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Text(
              l10n.appName,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: AppColors.parchmentText,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.appTagline,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            const BrassDivider(),
            const SizedBox(height: 32),
            progressAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => Text(
                '$error',
                style: const TextStyle(color: AppColors.danger),
                textAlign: TextAlign.center,
              ),
              data: (progress) {
                final hasSave = progress?.hasSave ?? false;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PrimaryButton(
                      label: l10n.menuContinue,
                      icon: Icons.play_arrow,
                      enabled: hasSave,
                      onPressed: hasSave
                          ? () => _onContinue(context, progress!)
                          : null,
                    ),
                    if (!hasSave)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          l10n.noSaveExists,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.secondaryText,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      label: l10n.menuNewGame,
                      icon: Icons.fiber_new,
                      onPressed: () => _onNewGame(context, ref),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            _MenuTile(
              icon: Icons.map_outlined,
              label: l10n.menuChapters,
              onTap: () => context.pushNamed('chapters'),
            ),
            _MenuTile(
              icon: Icons.settings_outlined,
              label: l10n.menuSettings,
              onTap: () => context.pushNamed('settings'),
            ),
            _MenuTile(
              icon: Icons.info_outline,
              label: l10n.menuCredits,
              onTap: () => context.pushNamed('credits'),
            ),
          ],
        ),
      ),
    );
  }

  void _onContinue(BuildContext context, GameProgress progress) {
    // Room route lands in Phase 5; until then return to the chapter map.
    final target = progress.currentRoomId ?? Chapter.chapter1.roomIds.first;
    context.pushNamed('chapters', extra: {'focusRoomId': target});
  }

  Future<void> _onNewGame(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(progressRepositoryProvider);
    final existing = await repo.loadProgress(AppConstants.defaultSaveSlotId);
    if (existing != null && existing.hasSave && context.mounted) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppLocalizations.of(ctx).newGameConfirmTitle),
          content: Text(AppLocalizations.of(ctx).newGameConfirmBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(AppLocalizations.of(ctx).commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(AppLocalizations.of(ctx).commonConfirm),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    final progress = GameProgress.newGame(
      AppConstants.defaultSaveSlotId,
      Chapter.chapter1.roomIds.first,
    );
    await repo.saveProgress(progress);
    ref.invalidate(gameProgressProvider);
    if (context.mounted) {
      unawaited(context.pushNamed('chapters'));
    }
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: AppColors.brass),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right, color: AppColors.brass),
        onTap: onTap,
      ),
    );
  }
}
