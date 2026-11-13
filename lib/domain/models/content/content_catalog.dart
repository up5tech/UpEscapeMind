import '../../../core/errors/app_exceptions.dart';
import 'chapter_definition.dart';
import 'clue_definition.dart';
import 'item_combination_definition.dart';
import 'item_definition.dart';
import 'puzzle_definition.dart';
import 'room_definition.dart';

/// In-memory index of all bundled content definitions.
/// Built once per session by the content loader; treated as immutable.
class ContentCatalog {
  ContentCatalog({
    required this.chapters,
    required this.rooms,
    required this.puzzles,
    required this.items,
    required this.combinations,
    required this.clues,
  }) : chaptersById = {for (final c in chapters) c.id: c},
       roomsById = {for (final r in rooms) r.id: r},
       puzzlesById = {for (final p in puzzles) p.id: p},
       itemsById = {for (final i in items) i.id: i},
       combinationsById = {for (final c in combinations) c.id: c},
       cluesById = {for (final c in clues) c.id: c};

  final List<ChapterDefinition> chapters;
  final List<RoomDefinition> rooms;
  final List<PuzzleDefinition> puzzles;
  final List<ItemDefinition> items;
  final List<ItemCombinationDefinition> combinations;
  final List<ClueDefinition> clues;

  final Map<String, ChapterDefinition> chaptersById;
  final Map<String, RoomDefinition> roomsById;
  final Map<String, PuzzleDefinition> puzzlesById;
  final Map<String, ItemDefinition> itemsById;
  final Map<String, ItemCombinationDefinition> combinationsById;
  final Map<String, ClueDefinition> cluesById;

  ChapterDefinition chapter(String id) =>
      chaptersById[id] ?? (throw ContentNotFoundException('chapter "$id"'));

  RoomDefinition room(String id) =>
      roomsById[id] ?? (throw ContentNotFoundException('room "$id"'));

  PuzzleDefinition puzzle(String id) =>
      puzzlesById[id] ?? (throw ContentNotFoundException('puzzle "$id"'));

  ItemDefinition item(String id) =>
      itemsById[id] ?? (throw ContentNotFoundException('item "$id"'));

  ClueDefinition clue(String id) =>
      cluesById[id] ?? (throw ContentNotFoundException('clue "$id"'));
}
