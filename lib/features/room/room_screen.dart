import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/localization/app_localizations.dart';
import '../../app/progress_actions.dart';
import '../../app/providers/app_providers.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/widgets.dart';
import '../../data/content/content_strings.dart';
import '../../domain/models/content/content_models.dart';
import '../../domain/models/progress.dart';
import '../../domain/rules/prerequisite_evaluator.dart';
import 'room_scene.dart';

/// Room exploration screen: renders the scene, positions hotspots, and
/// dispatches interactions (inspect / navigate / clue / item / puzzle).
///
/// Locked or unknown rooms redirect to the chapter map — locked content is
/// never reachable through direct navigation.
class RoomScreen extends ConsumerStatefulWidget {
  const RoomScreen({super.key, required this.roomId});

  final String roomId;

  @override
  ConsumerState<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends ConsumerState<RoomScreen> {
  String? _enteredRoomId;

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(contentCatalogProvider);
    final stringsAsync = ref.watch(contentStringsProvider);
    final progressAsync = ref.watch(gameProgressProvider);
    final locale = ref.watch(appLocaleProvider)?.languageCode ?? 'vi';

    final catalog = catalogAsync.value;
    final strings = stringsAsync.value;

    if (catalog == null || strings == null || progressAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final progress = progressAsync.value;
    final room = catalog.roomsById[widget.roomId];

    final canEnter =
        room != null &&
        progress != null &&
        progress.isRoomUnlocked(room.id) &&
        prerequisitesMet(room.entryConditions, progress);

    if (!canEnter) {
      // Defer the redirect out of build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.goNamed('chapters');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_enteredRoomId != room.id) {
      _enteredRoomId = room.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(progressActionsProvider).enterRoom(room.id);
        }
      });
    }

    final hotspots = [
      for (final hs in room.hotspots)
        if (prerequisitesMet(hs.visibilityConditions, progress))
          RoomHotspotView(
            definition: hs,
            label: strings.forLocale(locale, hs.labelKey),
          ),
    ];

    return AppScaffold(
      title: strings.forLocale(locale, room.titleKey),
      showBackButton: true,
      body: RoomScene(
        backgroundAsset: room.backgroundAsset,
        hotspots: hotspots,
        onHotspotTap: (hotspot) =>
            _handleHotspot(context, ref, catalog, strings, progress, hotspot),
      ),
    );
  }

  Future<void> _handleHotspot(
    BuildContext context,
    WidgetRef ref,
    ContentCatalog catalog,
    ContentStrings strings,
    GameProgress progress,
    RoomHotspotView hotspot,
  ) async {
    final l10n = AppLocalizations.of(context);
    final locale = ref.read(appLocaleProvider)?.languageCode ?? 'vi';
    String s(String key) => strings.forLocale(locale, key);
    final actions = ref.read(progressActionsProvider);
    final def = hotspot.definition;

    switch (def.interactionType) {
      case HotspotInteraction.inspect:
      case HotspotInteraction.useItem:
        await _showInspection(context, hotspot, s);
      case HotspotInteraction.navigate:
        await _navigate(context, catalog, progress, def.targetId, l10n);
      case HotspotInteraction.discoverClue:
        final clueId = def.targetId;
        if (clueId == null) return;
        final isNew = !progress.discoveredClueIds.contains(clueId);
        await actions.discoverClue(clueId);
        if (isNew && context.mounted) {
          final title = catalog.cluesById[clueId] != null
              ? s(catalog.cluesById[clueId]!.titleKey)
              : clueId;
          _toast(context, l10n.clueDiscoveredMessage(title));
        }
      case HotspotInteraction.collectItem:
        final itemId = def.targetId;
        if (itemId == null) return;
        final isNew = !progress.hasItem(itemId);
        await actions.collectItem(itemId);
        if (context.mounted) {
          final name = catalog.itemsById[itemId] != null
              ? s(catalog.itemsById[itemId]!.nameKey)
              : itemId;
          _toast(
            context,
            isNew
                ? l10n.itemCollectedMessage(name)
                : l10n.alreadyHaveItemMessage(name),
          );
        }
      case HotspotInteraction.puzzle:
        await _openPuzzle(context, catalog, progress, def.targetId, l10n);
    }
  }

  Future<void> _navigate(
    BuildContext context,
    ContentCatalog catalog,
    GameProgress progress,
    String? targetRoomId,
    AppLocalizations l10n,
  ) async {
    if (targetRoomId == null) return;
    final target = catalog.roomsById[targetRoomId];
    final allowed =
        target != null &&
        progress.isRoomUnlocked(target.id) &&
        prerequisitesMet(target.entryConditions, progress);
    if (!allowed) {
      _toast(context, l10n.roomLockedMessage);
      return;
    }
    if (context.mounted) {
      await context.pushNamed('room', pathParameters: {'roomId': target.id});
    }
  }

  Future<void> _openPuzzle(
    BuildContext context,
    ContentCatalog catalog,
    GameProgress progress,
    String? puzzleId,
    AppLocalizations l10n,
  ) async {
    if (puzzleId == null) return;
    final puzzle = catalog.puzzlesById[puzzleId];
    if (puzzle == null) {
      _toast(context, l10n.errorGeneric);
      return;
    }
    if (!prerequisitesMet(puzzle.prerequisites, progress)) {
      _toast(context, l10n.puzzleLockedMessage);
      return;
    }
    if (context.mounted) {
      await context.pushNamed(
        'puzzle',
        pathParameters: {'puzzleId': puzzle.id},
      );
    }
  }

  Future<void> _showInspection(
    BuildContext context,
    RoomHotspotView hotspot,
    String Function(String) s,
  ) {
    final def = hotspot.definition;
    final description = def.descriptionKey != null
        ? s(def.descriptionKey!)
        : hotspot.label;

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryText,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  hotspot.label,
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
                if (def.inspectionAsset != null) ...[
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 280),
                    child: Image.asset(
                      def.inspectionAsset!,
                      fit: BoxFit.contain,
                      semanticLabel: hotspot.label,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  description,
                  style: Theme.of(sheetContext).textTheme.bodyMedium
                      ?.copyWith(height: 1.4),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: Text(AppLocalizations.of(sheetContext).commonClose),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
