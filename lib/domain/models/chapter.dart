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
}
