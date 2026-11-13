/// Chapter metadata. Full content definitions land in Phase 2;
/// these are the stable identity fields used by routing and progress.
class Chapter {
  const Chapter({
    required this.id,
    required this.titleKey,
    required this.order,
    required this.roomIds,
    this.isLocked = false,
  });

  final String id;
  final String titleKey;
  final int order;
  final List<String> roomIds;
  final bool isLocked;

  /// Chapter 1 as defined in `design/02-chapter-1-story.md`.
  static const chapter1 = Chapter(
    id: 'chapter_01',
    titleKey: 'chapter1Title',
    order: 1,
    roomIds: [
      'room_entrance',
      'room_study',
      'room_workshop',
      'room_gallery',
      'room_observatory',
    ],
  );
}
