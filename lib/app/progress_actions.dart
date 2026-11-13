import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
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

  /// Marks [puzzleId] solved and applies its [SuccessAction]s.
  /// Idempotent: re-solving grants nothing twice.
  Future<void> solvePuzzle(
    String puzzleId,
    List<SuccessAction> successActions,
  ) {
    return _mutate((p) {
      var next = p.isPuzzleSolved(puzzleId)
          ? p
          : p.copyWith(solvedPuzzleIds: [...p.solvedPuzzleIds, puzzleId]);
      for (final action in successActions) {
        next = _applySuccessAction(next, action);
      }
      return next;
    });
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
