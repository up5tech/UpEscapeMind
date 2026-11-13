import '../models/content/prerequisites.dart';
import '../models/progress.dart';

/// Evaluates content [Prerequisite] conditions against persisted
/// [GameProgress]. An empty condition list is always satisfied.
///
/// Pure Dart — usable from validators, unlock logic, and UI gating.
bool prerequisitesMet(List<Prerequisite> conditions, GameProgress progress) {
  for (final condition in conditions) {
    final met = switch (condition.type) {
      PrerequisiteType.roomUnlocked => progress.isRoomUnlocked(
        condition.targetId,
      ),
      PrerequisiteType.puzzleSolved => progress.isPuzzleSolved(
        condition.targetId,
      ),
      PrerequisiteType.itemCollected => progress.hasItem(condition.targetId),
      PrerequisiteType.itemConsumed => progress.consumedItemIds.contains(
        condition.targetId,
      ),
      PrerequisiteType.clueDiscovered => progress.discoveredClueIds.contains(
        condition.targetId,
      ),
      PrerequisiteType.chapterCompleted =>
        progress.completedChapterIds.contains(condition.targetId),
    };
    if (!met) return false;
  }
  return true;
}
