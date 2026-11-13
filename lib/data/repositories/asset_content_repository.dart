import '../../core/errors/app_exceptions.dart';
import '../../domain/models/chapter.dart';
import '../../domain/models/content/content_catalog.dart';
import '../../domain/models/room.dart';
import '../content/content_loader.dart';
import 'content_repository.dart';

/// [ContentRepository] backed by bundled JSON assets via [ContentLoader].
/// The catalog is loaded once and cached for the session.
class AssetContentRepository implements ContentRepository {
  AssetContentRepository({ContentLoader? loader})
    : _loader = loader ?? const ContentLoader();

  final ContentLoader _loader;
  ContentCatalog? _catalog;

  @override
  Future<ContentCatalog> loadCatalog() async {
    return _catalog ??= await _loader.load();
  }

  @override
  Future<List<Chapter>> loadChapters() async {
    final catalog = await loadCatalog();
    return [
      for (final c in catalog.chapters)
        Chapter(
          id: c.id,
          titleKey: c.titleKey,
          order: c.order,
          roomIds: c.roomIds,
        ),
    ];
  }

  @override
  Future<List<Room>> loadRoomsForChapter(String chapterId) async {
    final catalog = await loadCatalog();
    return [
      for (final r in catalog.rooms)
        if (r.chapterId == chapterId)
          Room(id: r.id, chapterId: r.chapterId, titleKey: r.titleKey),
    ];
  }

  @override
  Future<Room> loadRoom(String roomId) async {
    final catalog = await loadCatalog();
    final def = catalog.roomsById[roomId];
    if (def == null) {
      throw ContentNotFoundException('room "$roomId"');
    }
    return Room(id: def.id, chapterId: def.chapterId, titleKey: def.titleKey);
  }
}
