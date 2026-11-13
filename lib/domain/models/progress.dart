/// Durable player progress — the subset persisted by the local database.
/// Immutable; repositories return new instances on every change.
class GameProgress {
  const GameProgress({
    required this.saveSlotId,
    this.unlockedRoomIds = const [],
    this.solvedPuzzleIds = const [],
    this.collectedItemIds = const [],
    this.discoveredClueIds = const [],
    this.revealedHintLevels = const {},
    this.currentRoomId,
    this.playTimeMs = 0,
  });

  final String saveSlotId;
  final String? currentRoomId;
  final List<String> unlockedRoomIds;
  final List<String> solvedPuzzleIds;
  final List<String> collectedItemIds;
  final List<String> discoveredClueIds;

  /// puzzleId -> highest revealed hint level (1-3).
  final Map<String, int> revealedHintLevels;
  final int playTimeMs;

  bool get hasSave => unlockedRoomIds.isNotEmpty;

  bool isRoomUnlocked(String roomId) => unlockedRoomIds.contains(roomId);
  bool isPuzzleSolved(String puzzleId) => solvedPuzzleIds.contains(puzzleId);
  bool hasItem(String itemId) => collectedItemIds.contains(itemId);
  int hintLevelFor(String puzzleId) => revealedHintLevels[puzzleId] ?? 0;

  GameProgress copyWith({
    String? currentRoomId,
    List<String>? unlockedRoomIds,
    List<String>? solvedPuzzleIds,
    List<String>? collectedItemIds,
    List<String>? discoveredClueIds,
    Map<String, int>? revealedHintLevels,
    int? playTimeMs,
  }) {
    return GameProgress(
      saveSlotId: saveSlotId,
      currentRoomId: currentRoomId ?? this.currentRoomId,
      unlockedRoomIds: unlockedRoomIds ?? this.unlockedRoomIds,
      solvedPuzzleIds: solvedPuzzleIds ?? this.solvedPuzzleIds,
      collectedItemIds: collectedItemIds ?? this.collectedItemIds,
      discoveredClueIds: discoveredClueIds ?? this.discoveredClueIds,
      revealedHintLevels: revealedHintLevels ?? this.revealedHintLevels,
      playTimeMs: playTimeMs ?? this.playTimeMs,
    );
  }

  /// Fresh progress for a new game: only the chapter's entry room unlocked.
  factory GameProgress.newGame(String saveSlotId, String entryRoomId) {
    return GameProgress(
      saveSlotId: saveSlotId,
      currentRoomId: entryRoomId,
      unlockedRoomIds: [entryRoomId],
    );
  }

  Map<String, dynamic> toJson() => {
    'saveSlotId': saveSlotId,
    'currentRoomId': currentRoomId,
    'unlockedRoomIds': unlockedRoomIds,
    'solvedPuzzleIds': solvedPuzzleIds,
    'collectedItemIds': collectedItemIds,
    'discoveredClueIds': discoveredClueIds,
    'revealedHintLevels': revealedHintLevels,
    'playTimeMs': playTimeMs,
  };

  factory GameProgress.fromJson(Map<String, dynamic> json) {
    return GameProgress(
      saveSlotId: json['saveSlotId'] as String,
      currentRoomId: json['currentRoomId'] as String?,
      unlockedRoomIds:
          (json['unlockedRoomIds'] as List?)?.cast<String>() ?? const [],
      solvedPuzzleIds:
          (json['solvedPuzzleIds'] as List?)?.cast<String>() ?? const [],
      collectedItemIds:
          (json['collectedItemIds'] as List?)?.cast<String>() ?? const [],
      discoveredClueIds:
          (json['discoveredClueIds'] as List?)?.cast<String>() ?? const [],
      revealedHintLevels:
          (json['revealedHintLevels'] as Map?)?.map(
            (k, v) => MapEntry(k as String, v as int),
          ) ??
          const {},
      playTimeMs: json['playTimeMs'] as int? ?? 0,
    );
  }
}
