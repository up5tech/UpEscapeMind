import '../../domain/models/chapter.dart';
import '../../domain/models/room.dart';
import 'content_repository.dart';

/// Interim content repository returning the statically defined Chapter 1
/// room list from `design/03-room-progression.md`.
///
/// Phase 2 replaces this with the JSON asset loader + validator. The stable
/// IDs here match `design/README.md` so later content files bind cleanly.
class StaticContentRepository implements ContentRepository {
  static const _rooms = <Room>[
    Room(
      id: 'room_entrance',
      chapterId: 'chapter_01',
      titleKey: 'roomEntranceTitle',
    ),
    Room(id: 'room_study', chapterId: 'chapter_01', titleKey: 'roomStudyTitle'),
    Room(
      id: 'room_workshop',
      chapterId: 'chapter_01',
      titleKey: 'roomWorkshopTitle',
    ),
    Room(
      id: 'room_gallery',
      chapterId: 'chapter_01',
      titleKey: 'roomGalleryTitle',
    ),
    Room(
      id: 'room_observatory',
      chapterId: 'chapter_01',
      titleKey: 'roomObservatoryTitle',
    ),
  ];

  @override
  Future<List<Chapter>> loadChapters() async => const [Chapter.chapter1];

  @override
  Future<List<Room>> loadRoomsForChapter(String chapterId) async {
    if (chapterId != Chapter.chapter1.id) return const [];
    return _rooms;
  }

  @override
  Future<Room> loadRoom(String roomId) async {
    for (final room in _rooms) {
      if (room.id == roomId) return room;
    }
    throw StateError('Unknown room id: $roomId');
  }
}
