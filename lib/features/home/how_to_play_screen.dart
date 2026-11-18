import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/localization/app_localizations.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/widgets.dart';

/// How-to-play guide (PLAN §17 onboarding): shown automatically once after
/// the prologue of a new game, and replayable any time from the main menu.
///
/// When reached with a room id in `GoRouterState.extra` (the post-prologue
/// flow), the start button replaces this route with that room; from the
/// menu it simply pops back.
class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  static const String guidanceId = 'howto';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final extra = GoRouterState.of(context).extra;
    final roomId = extra is String && extra.isNotEmpty ? extra : null;

    final steps = [
      (Icons.touch_app_outlined, l10n.howToPlayExplore),
      (Icons.backpack_outlined, l10n.howToPlayItems),
      (Icons.lightbulb_outline, l10n.howToPlayHints),
      (Icons.menu_book_outlined, l10n.howToPlayJournal),
    ];

    return AppScaffold(
      title: l10n.howToPlayTitle,
      showBackButton: roomId == null,
      body: AppCenteredPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (icon, text) in steps)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: AppColors.brass, size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        text,
                        style: Theme.of(context).textTheme.bodyLarge
                            ?.copyWith(height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            const BrassDivider(),
            const SizedBox(height: 24),
            PrimaryButton(
              key: const ValueKey('how_to_play_start'),
              label: roomId != null ? l10n.howToPlayStart : l10n.commonClose,
              icon: roomId != null ? Icons.play_arrow : Icons.check,
              onPressed: () {
                if (roomId != null) {
                  context.replaceNamed(
                    'room',
                    pathParameters: {'roomId': roomId},
                  );
                } else {
                  context.pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
