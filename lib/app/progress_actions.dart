import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../domain/models/content/item_combination_definition.dart';
import '../domain/models/content/prerequisites.dart';
import '../domain/models/progress.dart';
import '../domain/use_cases/progress_reducer.dart';
import 'providers/app_providers.dart';

/// Durable game-state mutations. Every method loads the latest progress,
/// applies an idempotent update, saves immediately, and invalidates
/// [gameProgressProvider] so watchers rebuild.
class ProgressActions {
  const ProgressActions(this._ref);

  final Ref _ref;

  Future<GameProgress> _mutate(
    GameProgress Function(GameProgress progress) update,
  ) async {
    final repo = _ref.read(progressRepositoryProvider);
    final current =
        await repo.loadProgress(AppConstants.defaultSaveSlotId) ??
        GameProgress(saveSlotId: AppConstants.defaultSaveSlotId);
    final next = update(current);
    await repo.saveProgress(next);
    _ref.invalidate(gameProgressProvider);
    return next;
  }

  /// Marks [roomId] as the player's current location. Entering a room
  /// also records it as unlocked so chapter-gated entry rooms (Phase 12)
  /// persist as discovered without a save migration.
  Future<void> enterRoom(String roomId) {
    return _mutate((p) {
      if (p.currentRoomId == roomId && p.isRoomUnlocked(roomId)) {
        return p;
      }
      return p.copyWith(
        currentRoomId: roomId,
        unlockedRoomIds: p.isRoomUnlocked(roomId)
            ? p.unlockedRoomIds
            : [...p.unlockedRoomIds, roomId],
      );
    });
  }

  /// Adds [itemId] to the inventory. No-op if already collected.
  Future<void> collectItem(String itemId) {
    return _mutate((p) {
      if (p.hasItem(itemId)) return p;
      return p.copyWith(collectedItemIds: [...p.collectedItemIds, itemId]);
    });
  }

  /// Records [clueId] as discovered. No-op if already known.
  Future<void> discoverClue(String clueId) {
    return _mutate((p) {
      if (p.discoveredClueIds.contains(clueId)) return p;
      return p.copyWith(discoveredClueIds: [...p.discoveredClueIds, clueId]);
    });
  }

  /// Consumes [itemId]: removes it from the inventory and records it in
  /// `consumedItemIds`. No-op if the item is not held.
  Future<void> consumeItem(String itemId) {
    return _mutate((p) {
      if (!p.hasItem(itemId)) return p;
      return p.copyWith(
        collectedItemIds: p.collectedItemIds
            .where((id) => id != itemId)
            .toList(),
        consumedItemIds: [...p.consumedItemIds, itemId],
      );
    });
  }

  /// Applies [actions] (e.g. a `use_item` hotspot's success effects).
  /// Idempotent per action target.
  Future<void> applySuccessActions(List<SuccessAction> actions) {
    return _mutate((p) {
      var next = p;
      for (final action in actions) {
        next = applySuccessAction(next, action);
      }
      return next;
    });
  }

  /// Attempts a defined item [recipe]. Returns `true` when the recipe
  /// matched the current inventory and was applied.
  ///
  /// Fails (returns `false`, state untouched) when any input is missing or
  /// the result item is already owned — invalid combinations never destroy
  /// items.
  Future<bool> combineItems(ItemCombinationDefinition recipe) async {
    var applied = false;
    await _mutate((p) {
      final next = applyCombination(
        p: p,
        inputItemIds: recipe.inputItemIds,
        resultItemId: recipe.resultItemId,
        consumeInputItems: recipe.consumeInputItems,
      );
      applied = !identical(next, p);
      return next;
    });
    return applied;
  }

  /// Records hint level [level] (1–3) as revealed for [puzzleId].
  /// Monotonic: revealing a lower level never un-reveals a higher one.
  /// Saved immediately (PLAN §6.2 — revealed levels persist across
  /// sessions and reopenings).
  Future<void> revealHint(String puzzleId, int level) {
    return _mutate((p) {
      if (level < 1 || level > 3) return p;
      if (p.hintLevelFor(puzzleId) >= level) return p;
      return p.copyWith(
        revealedHintLevels: {...p.revealedHintLevels, puzzleId: level},
      );
    });
  }

  /// Marks [puzzleId] solved and applies its [SuccessAction]s.
  /// Idempotent: re-solving grants nothing twice.
  ///
  /// Returns the chapter ids that became completed by THIS call (empty
  /// when no chapter finished or when the completion already existed),
  /// so the UI can open the chapter summary exactly once.
  Future<List<String>> solvePuzzle(
    String puzzleId,
    List<SuccessAction> successActions,
  ) async {
    List<String> beforeCompleted = const [];
    final next = await _mutate((p) {
      beforeCompleted = p.completedChapterIds;
      return applyPuzzleSolve(p, puzzleId, successActions);
    });
    return [
      for (final id in next.completedChapterIds)
        if (!beforeCompleted.contains(id)) id,
    ];
  }

}

final progressActionsProvider = Provider<ProgressActions>(
  (ref) => ProgressActions(ref),
);
