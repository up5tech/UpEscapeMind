import '../models/content/content_catalog.dart';
import '../models/content/room_definition.dart';
import '../models/progress.dart';
import 'prerequisite_evaluator.dart';

/// Whether [room] can be entered right now.
///
/// A room is accessible when it is explicitly unlocked (persisted in
/// `unlockedRoomIds`) OR when it is the entry room of a chapter whose
/// `unlockConditions` are satisfied. The second clause lets later
/// chapters open automatically for saves that completed the previous
/// chapter — including saves written before the new chapter shipped —
/// without a save migration (Phase 12).
///
/// The room's own `entryConditions` are NOT evaluated here; callers
/// check them separately, exactly as before.
bool isRoomAccessible(
  ContentCatalog catalog,
  GameProgress progress,
  RoomDefinition room,
) {
  if (progress.isRoomUnlocked(room.id)) return true;
  final chapter = catalog.chaptersById[room.chapterId];
  if (chapter == null ||
      chapter.roomIds.isEmpty ||
      chapter.roomIds.first != room.id) {
    return false;
  }
  return prerequisitesMet(chapter.unlockConditions, progress);
}
