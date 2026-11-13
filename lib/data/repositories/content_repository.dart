import '../../domain/models/chapter.dart';
import '../../domain/models/room.dart';

/// Loads bundled, versioned content definitions (chapters, rooms,
/// hotspots, items, puzzles, hints).
///
/// Implementations read only local assets — never the network.
/// Full JSON parsing and validation land in Phase 2.
abstract interface class ContentRepository {
  /// All chapters known to the bundled content, in display order.
  Future<List<Chapter>> loadChapters();

  /// All rooms belonging to [chapterId].
  Future<List<Room>> loadRoomsForChapter(String chapterId);

  /// Single room by stable ID. Throws [ContentNotFoundException] if absent.
  Future<Room> loadRoom(String roomId);
}
