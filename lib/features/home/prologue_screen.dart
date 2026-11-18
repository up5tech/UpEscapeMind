import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/localization/app_localizations.dart';
import '../../app/providers/app_providers.dart';
import '../../app/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/widgets.dart';
import 'how_to_play_screen.dart';

/// Prologue (PLAN §2.1 MVP content; design/02 §7): three skippable text
/// cards shown after New Game, before entering the Entrance Hall.
/// Localized, skippable, never blocks input.
class PrologueScreen extends ConsumerStatefulWidget {
  const PrologueScreen({super.key});

  @override
  ConsumerState<PrologueScreen> createState() => _PrologueScreenState();
}

class _PrologueScreenState extends ConsumerState<PrologueScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _cardCount = 3;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next(AppLocalizations l10n) {
    if (_page < _cardCount - 1) {
      final reduceMotion = MediaQuery.disableAnimationsOf(context);
      if (reduceMotion) {
        _controller.jumpToPage(_page + 1);
      } else {
        _controller.animateToPage(
          _page + 1,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
        );
      }
    } else {
      unawaited(_enterHouse());
    }
  }

  Future<void> _enterHouse() async {
    final roomId =
        ref.read(gameProgressProvider).value?.currentRoomId ??
        AppConstants.entryRoomId;
    // First playthrough shows the how-to-play guide once (persisted in
    // settings), then continues to the first room. Replace — never `go`,
    // which would clear the menu from the stack and break system-back.
    final settings = ref.read(settingsRepositoryProvider);
    if (await settings.hasSeenGuidance(HowToPlayScreen.guidanceId)) {
      if (mounted) {
        context.replaceNamed('room', pathParameters: {'roomId': roomId});
      }
      return;
    }
    await settings.markGuidanceSeen(HowToPlayScreen.guidanceId);
    if (mounted) {
      context.replaceNamed('howToPlay', extra: roomId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cards = [l10n.prologueCard1, l10n.prologueCard2, l10n.prologueCard3];
    final isLast = _page == _cardCount - 1;

    return AppScaffold(
      body: Column(
        children: [
          Align(
            alignment: AlignmentDirectional.topEnd,
            child: TextButton(
              key: const ValueKey('prologue_skip'),
              onPressed: _enterHouse,
              child: Text(l10n.prologueSkip),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _cardCount,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 36,
                  vertical: 24,
                ),
                child: Center(
                  child: Text(
                    cards[i],
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(color: AppColors.parchmentText),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: PrimaryButton(
              key: const ValueKey('prologue_next'),
              label: isLast ? l10n.prologueEnter : l10n.commonNext,
              onPressed: () => _next(l10n),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
