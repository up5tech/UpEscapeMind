import 'package:flutter_test/flutter_test.dart';
import 'package:up_escape_mind/domain/models/content/chapter_definition.dart';
import 'package:up_escape_mind/domain/models/content/clue_definition.dart';
import 'package:up_escape_mind/domain/models/content/content_catalog.dart';
import 'package:up_escape_mind/domain/models/content/puzzle_definition.dart';
import 'package:up_escape_mind/domain/models/content/room_definition.dart';
import 'package:up_escape_mind/domain/models/progress.dart';
import 'package:up_escape_mind/domain/rules/progress_stats.dart';

ContentCatalog catalog() => ContentCatalog(
  chapters: [
    ChapterDefinition.fromJson({
      'schemaVersion': 1,
      'type': 'chapter',
      'id': 'ch1',
      'titleKey': 't',
      'order': 0,
      'roomIds': ['r1', 'r2'],
    }, 'ch'),
  ],
  rooms: [
    for (final id in ['r1', 'r2'])
      RoomDefinition.fromJson({
        'schemaVersion': 1,
        'type': 'room',
        'id': id,
        'chapterId': 'ch1',
        'titleKey': 't',
        'backgroundAsset': 'a.png',
        'hotspots': const <Map<String, dynamic>>[],
      }, 'room:$id'),
  ],
  puzzles: [
    for (final id in ['p1', 'p2'])
      PuzzleDefinition.fromJson({
        'schemaVersion': 1,
        'type': 'puzzle',
        'id': id,
        'roomId': 'r1',
        'hotspotId': 'hs',
        'puzzleType': 'keypad',
        'titleKey': 't',
        'instructionsKey': 't',
        'initialState': {'digits': 4},
        'solutionConfig': {'code': '1234'},
        'validationConfig': <String, dynamic>{},
        'hints': [
          {'level': 1, 'textKey': 'h'},
        ],
        'resetPolicy': 'keep',
      }, 'puz:$id'),
  ],
  items: const [],
  combinations: const [],
  clues: [
    for (final e in [
      ('c1', false),
      ('c2', true),
      ('c3', true),
    ])
      ClueDefinition.fromJson({
        'schemaVersion': 1,
        'type': 'clue',
        'id': e.$1,
        'titleKey': 't',
        'bodyKey': 'b',
        'sourceRoomId': 'r1',
        'optional': e.$2,
      }, 'clue:${e.$1}'),
  ],
);

ProgressStats stats(GameProgress p) =>
    computeProgressStats(catalog: catalog(), progress: p);

GameProgress make({
  List<String> unlocked = const [],
  List<String> solved = const [],
  List<String> clues = const [],
  List<String> completed = const [],
  Map<String, int> hints = const {},
}) => GameProgress(
  saveSlotId: 'slot',
  unlockedRoomIds: unlocked,
  solvedPuzzleIds: solved,
  discoveredClueIds: clues,
  completedChapterIds: completed,
  revealedHintLevels: hints,
);

void main() {
  test('empty save reports zeros with catalog totals', () {
    final s = stats(make());
    expect(s.chaptersCompleted, 0);
    expect(s.areasDiscovered, 0);
    expect(s.areasTotal, 2);
    expect(s.puzzlesSolved, 0);
    expect(s.puzzlesTotal, 2);
    expect(s.optionalCluesFound, 0);
    expect(s.optionalCluesTotal, 2);
    expect(s.hintsLevel1Opened, 0);
    expect(s.hintsUsed, isFalse);
  });

  test('areas/puzzles/chapters count catalog entries only', () {
    final s = stats(
      make(
        unlocked: ['r1', 'ghost_room'],
        solved: ['p1', 'ghost_puz'],
        completed: ['ch1'],
      ),
    );
    expect(s.areasDiscovered, 1);
    expect(s.puzzlesSolved, 1);
    expect(s.chaptersCompleted, 1);
  });

  test('optional clue discovery is tracked separately', () {
    final s = stats(make(clues: ['c1', 'c2']));
    expect(s.optionalCluesFound, 1);
    expect(s.optionalCluesTotal, 2);
  });

  test('hint opens count per level, monotonic (level 3 counts at 1..3)', () {
    final s = stats(make(hints: {'p1': 3, 'p2': 1}));
    expect(s.hintsLevel1Opened, 2);
    expect(s.hintsLevel2Opened, 1);
    expect(s.hintsLevel3Opened, 1);
    expect(s.hintsUsed, isTrue);
  });
}
