import '../models/content/chapter_definition.dart';
import '../models/content/content_catalog.dart';
import '../models/progress.dart';

/// Completion state of one room inside a chapter (Phase 8 task 5).
class RoomProgress {
  const RoomProgress({
    required this.roomId,
    required this.puzzlesSolved,
    required this.puzzlesTotal,
  });

  final String roomId;
  final int puzzlesSolved;
  final int puzzlesTotal;

  /// A room with no puzzles is trivially complete (pure transition areas).
  bool get isComplete => puzzlesSolved >= puzzlesTotal;
}

/// Deterministic, transparent chapter rating (PLAN §7.1–7.2).
///
/// Star rules — exactly the criteria the UI shows, never speed, never a
/// gate on story progression:
/// - 1★: the chapter's final objective is fulfilled (`completeChapter`).
/// - 2★: additionally, every puzzle authored in the chapter is solved
///   (optional puzzles included — this is why 2★ can stay unlit).
/// - 3★: additionally, every clue authored in the chapter (optional notes
///   and secrets included) is discovered.
///
/// Opening the level-3 walkthrough is recorded as `walkthroughUsed` and
/// shown as a separate "no walkthrough" badge; it never removes a star.
class ChapterRating {
  const ChapterRating({
    required this.isCompleted,
    required this.stars,
    required this.puzzlesSolved,
    required this.puzzlesTotal,
    required this.cluesFound,
    required this.cluesTotal,
    required this.walkthroughUsed,
    required this.rooms,
  });

  final bool isCompleted;
  final int stars;
  final int puzzlesSolved;
  final int puzzlesTotal;
  final int cluesFound;
  final int cluesTotal;
  final bool walkthroughUsed;
  final List<RoomProgress> rooms;

  /// Badge earned only when the chapter was finished without opening any
  /// level-3 walkthrough hint.
  bool get noWalkthroughBadge => isCompleted && !walkthroughUsed;
}

/// Computes the rating of [chapter] from durable [progress] and the
/// validated content catalog. Pure Dart — fully unit-testable.
ChapterRating rateChapter({
  required ChapterDefinition chapter,
  required ContentCatalog catalog,
  required GameProgress progress,
}) {
  final roomIds = chapter.roomIds.toSet();

  final puzzles = [
    for (final p in catalog.puzzles)
      if (roomIds.contains(p.roomId)) p,
  ];
  final solvedPuzzles = puzzles.where((p) => progress.isPuzzleSolved(p.id));

  final clues = [
    for (final c in catalog.clues)
      if (roomIds.contains(c.sourceRoomId)) c,
  ];
  final foundClues = clues.where((c) => progress.discoveredClueIds.contains(c.id));

  final walkthroughUsed = puzzles.any(
    (p) => progress.hintLevelFor(p.id) >= 3,
  );

  final rooms = [
    for (final roomId in chapter.roomIds)
      () {
        final roomPuzzles = puzzles.where((p) => p.roomId == roomId).toList();
        return RoomProgress(
          roomId: roomId,
          puzzlesSolved: roomPuzzles
              .where((p) => progress.isPuzzleSolved(p.id))
              .length,
          puzzlesTotal: roomPuzzles.length,
        );
      }(),
  ];

  final isCompleted = progress.completedChapterIds.contains(chapter.id);
  var stars = 0;
  if (isCompleted) {
    // Tiered, not additive: star N always means rules 1..N are met, so
    // the rendered checkmarks can never mislabel which rule earned a star.
    stars = 1;
    if (solvedPuzzles.length == puzzles.length) {
      stars = 2;
      if (foundClues.length == clues.length) stars = 3;
    }
  }

  return ChapterRating(
    isCompleted: isCompleted,
    stars: stars,
    puzzlesSolved: solvedPuzzles.length,
    puzzlesTotal: puzzles.length,
    cluesFound: foundClues.length,
    cluesTotal: clues.length,
    walkthroughUsed: walkthroughUsed,
    rooms: rooms,
  );
}
