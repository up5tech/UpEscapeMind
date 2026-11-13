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
import '../inventory/inventory_panel.dart';
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

  /// Transient UI state: item currently "in hand" and combine mode.
  /// Durable state lives in `GameProgress`.
  String? _selectedItemId;
  bool _combineMode = false;
  final Set<String> _combineSelection = {};

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

    final l10n = AppLocalizations.of(context);
    final items = [
      for (final id in progress.collectedItemIds)
        if (catalog.itemsById[id] != null) catalog.itemsById[id]!,
    ];

    return AppScaffold(
      title: strings.forLocale(locale, room.titleKey),
      showBackButton: true,
      body: Column(
        children: [
          Expanded(
            child: RoomScene(
              backgroundAsset: room.backgroundAsset,
              hotspots: hotspots,
              onHotspotTap: (hotspot) => _handleHotspot(
                context,
                ref,
                catalog,
                strings,
                progress,
                hotspot,
              ),
            ),
          ),
          InventoryBar(
            items: items,
            strings: strings,
            locale: locale,
            l10n: l10n,
            selectedItemId: _selectedItemId,
            combineMode: _combineMode,
            combineSelection: _combineSelection,
            onItemTap: _onCombineItemTap,
            onCombine: _tryCombine,
            onExitCombine: () => setState(() {
              _combineMode = false;
              _combineSelection.clear();
            }),
            onDeselect: () => setState(() => _selectedItemId = null),
            onOpenSheet: (item) => _openItemSheet(context, ref, strings, item),
          ),
        ],
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

    // While an item is "in hand", every hotspot tap is a use attempt.
    // Only `use_item` hotspots can succeed; anything else is invalid
    // feedback and the selection is kept.
    if (_selectedItemId != null &&
        def.interactionType != HotspotInteraction.useItem) {
      _toast(context, l10n.invalidItemUseMessage);
      return;
    }

    switch (def.interactionType) {
      case HotspotInteraction.inspect:
        await _showInspection(context, hotspot, s);
      case HotspotInteraction.useItem:
        if (_selectedItemId == null) {
          await _showInspection(context, hotspot, s);
        } else {
          await _tryUseItem(catalog, strings, progress, hotspot);
        }
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

  /// Item-in-hand use attempt on a `use_item` hotspot. Succeeds only when
  /// the hotspot's `acceptedItemIds` lists the selected item; success
  /// applies the hotspot's `successActions` and optionally consumes the
  /// item. Invalid attempts never consume anything.
  Future<void> _tryUseItem(
    ContentCatalog catalog,
    ContentStrings strings,
    GameProgress progress,
    RoomHotspotView hotspot,
  ) async {
    final l10n = AppLocalizations.of(context);
    final locale = ref.read(appLocaleProvider)?.languageCode ?? 'vi';
    final itemId = _selectedItemId!;
    final item = catalog.itemsById[itemId];
    final def = hotspot.definition;

    final accepted =
        item != null &&
        progress.hasItem(itemId) &&
        def.acceptedItemIds.contains(itemId);
    if (!accepted) {
      _toast(context, l10n.invalidItemUseMessage);
      return;
    }

    final actions = ref.read(progressActionsProvider);
    await actions.applySuccessActions(def.successActions);
    if (def.consumeItemOnUse) {
      await actions.consumeItem(itemId);
    }
    if (!mounted) return;
    setState(() => _selectedItemId = null);
    _toast(
      context,
      l10n.itemUsedMessage(strings.forLocale(locale, item.nameKey)),
    );
  }

  void _onCombineItemTap(ItemDefinition item) {
    setState(() {
      if (!_combineSelection.remove(item.id)) {
        _combineSelection.add(item.id);
      }
    });
  }

  /// Attempts an explicitly defined combination recipe matching the
  /// current combine selection. Invalid selections change nothing.
  Future<void> _tryCombine() async {
    final l10n = AppLocalizations.of(context);
    if (_combineSelection.length < 2) {
      _toast(context, l10n.combineNeedsSelection);
      return;
    }
    final catalog = ref.read(contentCatalogProvider).value;
    if (catalog == null) return;
    final recipe = catalog.combinations
        .where(
          (c) =>
              c.inputItemIds.length == _combineSelection.length &&
              c.inputItemIds.every(_combineSelection.contains),
        )
        .firstOrNull;
    if (recipe == null) {
      _toast(context, l10n.invalidCombinationMessage);
      return;
    }
    final ok = await ref.read(progressActionsProvider).combineItems(recipe);
    if (!mounted) return;
    if (ok) {
      setState(() {
        _combineMode = false;
        _combineSelection.clear();
      });
      final strings = ref.read(contentStringsProvider).value;
      final locale = ref.read(appLocaleProvider)?.languageCode ?? 'vi';
      if (strings != null) {
        _toast(context, strings.forLocale(locale, recipe.resultMessageKey));
      }
    } else {
      _toast(context, l10n.invalidCombinationMessage);
    }
  }

  void _openItemSheet(
    BuildContext context,
    WidgetRef ref,
    ContentStrings strings,
    ItemDefinition item,
  ) {
    final locale = ref.read(appLocaleProvider)?.languageCode ?? 'vi';
    final isSelected = _selectedItemId == item.id;
    showItemDetailSheet(
      context: context,
      item: item,
      strings: strings,
      locale: locale,
      l10n: AppLocalizations.of(context),
      isSelected: isSelected,
      onUse: () =>
          setState(() => _selectedItemId = isSelected ? null : item.id),
      onCombineStart: () => setState(() {
        _selectedItemId = null;
        _combineMode = true;
        _combineSelection
          ..clear()
          ..add(item.id);
      }),
    );
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
