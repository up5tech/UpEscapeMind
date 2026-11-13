/// Room identity and navigation metadata.
/// Hotspot bounds and content references are defined by bundled content
/// in Phase 2; this model carries only what routing/progress needs now.
class Room {
  const Room({
    required this.id,
    required this.chapterId,
    required this.titleKey,
  });

  final String id;
  final String chapterId;
  final String titleKey;
}
