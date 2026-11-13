import 'package:flutter_test/flutter_test.dart';
import 'package:up_escape_mind/domain/models/content/chapter_definition.dart';
import 'package:up_escape_mind/domain/models/content/clue_definition.dart';
import 'package:up_escape_mind/domain/models/content/content_catalog.dart';
import 'package:up_escape_mind/domain/models/content/puzzle_definition.dart';
import 'package:up_escape_mind/domain/models/content/room_definition.dart';
import 'package:up_escape_mind/domain/models/progress.dart';
import 'package:up_escape_mind/domain/rules/chapter_rating.dart';

const base = <String, dynamic>{
  'schemaVersion': 1,
  'type': 'chapter',
  'id': 'ch1',
  'titleKey': 't',
  'order': 0,
  'roomIds': ['r1', 'r2'],
  'unlockConditions': <String>[],
};

ChapterDefinition chapter() => ChapterDefinition.fromJson(base, 'ch');

RoomDefinition room(String id) => RoomDefinition.fromJson({
  'schemaVersion': 1,
  'type': 'room',
  'id': id,
  'chapterId': 'ch1',
  'titleKey': 't',
  'backgroundAsset': 'a.png',
  'hotspots': const <Map<String, dynamic>>[],
}, 'room:$id');

PuzzleDefinition puzzle(String id, String roomId) =>
    PuzzleDefinition.fromJson({
      'schemaVersion': 1,
      'type': 'puzzle',
      'id': id,
      'roomId': roomId,
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
    }, 'puz:$id');

ClueDefinition clue(String id, String roomId, {bool optional = false}) =>
    ClueDefinition.fromJson({
      'schemaVersion': 1,
      'type': 'clue',
      'id': id,
      'titleKey': 't',
      'bodyKey': 'b',
      'sourceRoomId': roomId,
      'optional': optional,
    }, 'clue:$id');

ContentCatalog catalog() => ContentCatalog(
  chapters: [chapter()],
  rooms: [room('r1'), room('r2')],
  puzzles: [puzzle('p1', 'r1'), puzzle('p2', 'r2'), puzzle('p3', 'r2')],
  items: const [],
  combinations: const [],
  clues: [
    clue('c1', 'r1'),
    clue('c2', 'r2', optional: true),
    // Outside the chapter — must never count.
    clue('c3', 'rX'),
  ],
);

GameProgress progress({
  List<String> solved = const [],
  List<String> clues = const [],
  List<String> completed = const [],
  Map<String, int> hints = const {},
}) => GameProgress(
  saveSlotId: 'slot',
  completedChapterIds: completed,
  solvedPuzzleIds: solved,
  discoveredClueIds: clues,
  revealedHintLevels: hints,
);

void main() {
  group('rateChapter', () {
    test('not completed → 0 stars, no badge', () {
      final r = rateChapter(
        chapter: chapter(),
        catalog: catalog(),
        progress: progress(solved: ['p1', 'p2', 'p3'], clues: ['c1', 'c2']),
      );
      expect(r.stars, 0);
      expect(r.isCompleted, isFalse);
      expect(r.noWalkthroughBadge, isFalse);
    });

    test('1★: completed only', () {
      final r = rateChapter(
        chapter: chapter(),
        catalog: catalog(),
        progress: progress(completed: ['ch1']),
      );
      expect(r.stars, 1);
      expect(r.puzzlesSolved, 0);
      expect(r.puzzlesTotal, 3);
      expect(r.cluesFound, 0);
      // Chapter-scoped clue c3 (sourceRoomId rX) excluded.
      expect(r.cluesTotal, 2);
    });

    test('2★: every chapter puzzle solved', () {
      final r = rateChapter(
        chapter: chapter(),
        catalog: catalog(),
        progress: progress(completed: ['ch1'], solved: ['p1', 'p2', 'p3']),
      );
      expect(r.stars, 2);
    });

    test('clues alone never raise the star above 1 (tiered rules)', () {
      final r = rateChapter(
        chapter: chapter(),
        catalog: catalog(),
        progress: progress(completed: ['ch1'], clues: ['c1', 'c2']),
      );
      expect(r.stars, 1);
    });

    test('3★: additionally every chapter clue discovered', () {
      final r = rateChapter(
        chapter: chapter(),
        catalog: catalog(),
        progress: progress(
          completed: ['ch1'],
          solved: ['p1', 'p2', 'p3'],
          clues: ['c1', 'c2', 'c3'],
        ),
      );
      expect(r.stars, 3);
      expect(r.noWalkthroughBadge, isTrue);
    });

    test('walkthrough used removes only the badge, never a star', () {
      final r = rateChapter(
        chapter: chapter(),
        catalog: catalog(),
        progress: progress(
          completed: ['ch1'],
          solved: ['p1', 'p2', 'p3'],
          clues: ['c1', 'c2'],
          hints: {'p1': 3},
        ),
      );
      expect(r.stars, 3);
      expect(r.walkthroughUsed, isTrue);
      expect(r.noWalkthroughBadge, isFalse);
    });

    test('hints below level 3 do not count as walkthrough', () {
      final r = rateChapter(
        chapter: chapter(),
        catalog: catalog(),
        progress: progress(
          completed: ['ch1'],
          solved: ['p1', 'p2', 'p3'],
          clues: ['c1', 'c2'],
          hints: {'p1': 2, 'p2': 1},
        ),
      );
      expect(r.walkthroughUsed, isFalse);
    });

    test('per-room progress', () {
      final r = rateChapter(
        chapter: chapter(),
        catalog: catalog(),
        progress: progress(completed: ['ch1'], solved: ['p1', 'p2']),
      );
      expect(r.rooms.length, 2);
      final r1 = r.rooms.firstWhere((x) => x.roomId == 'r1');
      final r2 = r.rooms.firstWhere((x) => x.roomId == 'r2');
      expect(r1.puzzlesSolved, 1);
      expect(r1.puzzlesTotal, 1);
      expect(r1.isComplete, isTrue);
      expect(r2.isComplete, isFalse);
      expect(r2.puzzlesSolved, 1);
      expect(r2.puzzlesTotal, 2);
    });
  });
}
