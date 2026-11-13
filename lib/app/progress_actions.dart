import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../domain/models/content/item_combination_definition.dart';
import '../domain/models/content/prerequisites.dart';
import '../domain/models/progress.dart';
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

  /// Marks [roomId] as the player's current location.
  Future<void> enterRoom(String roomId) {
    return _mutate(
      (p) => p.currentRoomId == roomId ? p : p.copyWith(currentRoomId: roomId),
    );
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
        next = _applySuccessAction(next, action);
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
      if (!recipe.inputItemIds.every(p.hasItem)) return p;
      if (p.hasItem(recipe.resultItemId)) return p;

      applied = true;
      var next = p.copyWith(
        collectedItemIds: [...p.collectedItemIds, recipe.resultItemId],
      );
      if (recipe.consumeInputItems) {
        final consumed = [...p.consumedItemIds];
        for (final input in recipe.inputItemIds) {
          if (!consumed.contains(input)) consumed.add(input);
        }
        next = next.copyWith(
          collectedItemIds: next.collectedItemIds
              .where((id) => !recipe.inputItemIds.contains(id))
              .toList(),
          consumedItemIds: consumed,
        );
      }
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
      var progress = p.isPuzzleSolved(puzzleId)
          ? p
          : p.copyWith(solvedPuzzleIds: [...p.solvedPuzzleIds, puzzleId]);
      for (final action in successActions) {
        progress = _applySuccessAction(progress, action);
      }
      return progress;
    });
    return [
      for (final id in next.completedChapterIds)
        if (!beforeCompleted.contains(id)) id,
    ];
  }

  GameProgress _applySuccessAction(GameProgress p, SuccessAction action) {
    List<String> addUnique(List<String> list, String id) =>
        list.contains(id) ? list : [...list, id];

    return switch (action.type) {
      SuccessActionType.unlockRoom => p.copyWith(
        unlockedRoomIds: addUnique(p.unlockedRoomIds, action.targetId),
      ),
      SuccessActionType.collectItem =>
        p.hasItem(action.targetId)
            ? p
            : p.copyWith(
                collectedItemIds: addUnique(
                  p.collectedItemIds,
                  action.targetId,
                ),
              ),
      SuccessActionType.consumeItem =>
        p.consumedItemIds.contains(action.targetId)
            ? p
            : p.copyWith(
                collectedItemIds: p.collectedItemIds
                    .where((id) => id != action.targetId)
                    .toList(),
                consumedItemIds: addUnique(p.consumedItemIds, action.targetId),
              ),
      SuccessActionType.discoverClue =>
        p.discoveredClueIds.contains(action.targetId)
            ? p
            : p.copyWith(
                discoveredClueIds: addUnique(
                  p.discoveredClueIds,
                  action.targetId,
                ),
              ),
      SuccessActionType.completeChapter =>
        p.completedChapterIds.contains(action.targetId)
            ? p
            : p.copyWith(
                completedChapterIds: addUnique(
                  p.completedChapterIds,
                  action.targetId,
                ),
              ),
    };
  }
}

final progressActionsProvider = Provider<ProgressActions>(
  (ref) => ProgressActions(ref),
);
