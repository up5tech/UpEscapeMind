import '../models/content/prerequisites.dart';
import '../models/progress.dart';

/// Pure reducer: applies one durable [SuccessAction] to progress,
/// idempotently per action target. Shared by [ProgressActions] (runtime)
/// and the Chapter 1 solvability simulation (tests) so both use exactly
/// the same semantics — no fake logic anywhere.
GameProgress applySuccessAction(GameProgress p, SuccessAction action) {
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

/// Marks [puzzleId] solved and applies [actions] atomically (same order
/// as the runtime path).
GameProgress applyPuzzleSolve(
  GameProgress p,
  String puzzleId,
  List<SuccessAction> actions,
) {
  var next = p.isPuzzleSolved(puzzleId)
      ? p
      : p.copyWith(solvedPuzzleIds: [...p.solvedPuzzleIds, puzzleId]);
  for (final action in actions) {
    next = applySuccessAction(next, action);
  }
  return next;
}

/// Item combination semantics (mirror of the runtime recipe application),
/// kept pure for the solvability simulation.
GameProgress applyCombination({
  required GameProgress p,
  required List<String> inputItemIds,
  required String resultItemId,
  required bool consumeInputItems,
}) {
  if (!inputItemIds.every(p.hasItem)) return p;
  if (p.hasItem(resultItemId)) return p;
  var next = p.copyWith(
    collectedItemIds: [...p.collectedItemIds, resultItemId],
  );
  if (consumeInputItems) {
    next = next.copyWith(
      collectedItemIds: next.collectedItemIds
          .where((id) => !inputItemIds.contains(id))
          .toList(),
      consumedItemIds: [
        ...next.consumedItemIds,
        for (final id in inputItemIds)
          if (!next.consumedItemIds.contains(id)) id,
      ],
    );
  }
  return next;
}
