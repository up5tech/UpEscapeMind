import '../models/content/content_catalog.dart';
import '../models/progress.dart';

/// Local player statistics (PLAN §7.3) derived from durable progress and
/// the content catalog. Game-progress indicators only — never IQ/clinical
/// claims, and speed is not measured.
class ProgressStats {
  const ProgressStats({
    required this.chaptersCompleted,
    required this.areasDiscovered,
    required this.areasTotal,
    required this.puzzlesSolved,
    required this.puzzlesTotal,
    required this.optionalCluesFound,
    required this.optionalCluesTotal,
    required this.hintsLevel1Opened,
    required this.hintsLevel2Opened,
    required this.hintsLevel3Opened,
  });

  final int chaptersCompleted;
  final int areasDiscovered;
  final int areasTotal;
  final int puzzlesSolved;
  final int puzzlesTotal;
  final int optionalCluesFound;
  final int optionalCluesTotal;

  /// Hints opened per level. A puzzle whose highest revealed level is N
  /// counts once at every level 1..N (revealing is monotonic).
  final int hintsLevel1Opened;
  final int hintsLevel2Opened;
  final int hintsLevel3Opened;

  bool get hintsUsed => hintsLevel3Opened > 0;
}

ProgressStats computeProgressStats({
  required ContentCatalog catalog,
  required GameProgress progress,
}) {
  var level1 = 0, level2 = 0, level3 = 0;
  for (final maxLevel in progress.revealedHintLevels.values) {
    if (maxLevel >= 1) level1++;
    if (maxLevel >= 2) level2++;
    if (maxLevel >= 3) level3++;
  }

  final optionalClues = catalog.clues.where((c) => c.optional);

  return ProgressStats(
    chaptersCompleted: catalog.chapters
        .where((c) => progress.completedChapterIds.contains(c.id))
        .length,
    areasDiscovered: catalog.rooms
        .where((r) => progress.isRoomUnlocked(r.id))
        .length,
    areasTotal: catalog.rooms.length,
    puzzlesSolved: catalog.puzzles
        .where((p) => progress.isPuzzleSolved(p.id))
        .length,
    puzzlesTotal: catalog.puzzles.length,
    optionalCluesFound: optionalClues
        .where((c) => progress.discoveredClueIds.contains(c.id))
        .length,
    optionalCluesTotal: optionalClues.length,
    hintsLevel1Opened: level1,
    hintsLevel2Opened: level2,
    hintsLevel3Opened: level3,
  );
}
