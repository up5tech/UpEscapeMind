import '../models/content/prerequisites.dart';
import '../models/progress.dart';

/// Evaluates a single content [Prerequisite] condition against persisted
/// [GameProgress]. Used by the puzzle screen to explain *what kind* of
/// discovery is still missing (PLAN §6.3) without exposing solutions.
bool prerequisiteMet(Prerequisite condition, GameProgress progress) {
  return switch (condition.type) {
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
}

/// Evaluates content [Prerequisite] conditions against persisted
/// [GameProgress]. An empty condition list is always satisfied.
///
/// Pure Dart — usable from validators, unlock logic, and UI gating.
bool prerequisitesMet(List<Prerequisite> conditions, GameProgress progress) {
  for (final condition in conditions) {
    if (!prerequisiteMet(condition, progress)) return false;
  }
  return true;
}

/// The conditions that are NOT yet satisfied, in authored order.
List<Prerequisite> unmetPrerequisites(
  List<Prerequisite> conditions,
  GameProgress progress,
) {
  return [
    for (final condition in conditions)
      if (!prerequisiteMet(condition, progress)) condition,
  ];
}
