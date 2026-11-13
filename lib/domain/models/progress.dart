/// Durable player progress — the subset persisted by the local database.
/// Immutable; repositories return new instances on every change.
class GameProgress {
  const GameProgress({
    required this.saveSlotId,
    this.unlockedRoomIds = const [],
    this.solvedPuzzleIds = const [],
    this.collectedItemIds = const [],
    this.consumedItemIds = const [],
    this.discoveredClueIds = const [],
    this.completedChapterIds = const [],
    this.revealedHintLevels = const {},
    this.puzzleStates = const {},
    this.currentRoomId,
    this.playTimeMs = 0,
  });

  final String saveSlotId;
  final String? currentRoomId;
  final List<String> unlockedRoomIds;
  final List<String> solvedPuzzleIds;
  final List<String> collectedItemIds;

  /// Items consumed by item-use/combine actions.
  final List<String> consumedItemIds;
  final List<String> discoveredClueIds;
  final List<String> completedChapterIds;

  /// puzzleId -> highest revealed hint level (1-3).
  final Map<String, int> revealedHintLevels;

  /// puzzleId -> serialized in-progress puzzle input (per the puzzle's
  /// `resetPolicy`). Only meaningful for unfinished puzzles.
  final Map<String, String> puzzleStates;
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
    List<String>? consumedItemIds,
    List<String>? discoveredClueIds,
    List<String>? completedChapterIds,
    Map<String, int>? revealedHintLevels,
    Map<String, String>? puzzleStates,
    int? playTimeMs,
  }) {
    return GameProgress(
      saveSlotId: saveSlotId,
      currentRoomId: currentRoomId ?? this.currentRoomId,
      unlockedRoomIds: unlockedRoomIds ?? this.unlockedRoomIds,
      solvedPuzzleIds: solvedPuzzleIds ?? this.solvedPuzzleIds,
      collectedItemIds: collectedItemIds ?? this.collectedItemIds,
      consumedItemIds: consumedItemIds ?? this.consumedItemIds,
      discoveredClueIds: discoveredClueIds ?? this.discoveredClueIds,
      completedChapterIds: completedChapterIds ?? this.completedChapterIds,
      revealedHintLevels: revealedHintLevels ?? this.revealedHintLevels,
      puzzleStates: puzzleStates ?? this.puzzleStates,
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
    'consumedItemIds': consumedItemIds,
    'discoveredClueIds': discoveredClueIds,
    'completedChapterIds': completedChapterIds,
    'revealedHintLevels': revealedHintLevels,
    'puzzleStates': puzzleStates,
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
      consumedItemIds:
          (json['consumedItemIds'] as List?)?.cast<String>() ?? const [],
      discoveredClueIds:
          (json['discoveredClueIds'] as List?)?.cast<String>() ?? const [],
      completedChapterIds:
          (json['completedChapterIds'] as List?)?.cast<String>() ?? const [],
      revealedHintLevels:
          (json['revealedHintLevels'] as Map?)?.map(
            (k, v) => MapEntry(k as String, v as int),
          ) ??
          const {},
      puzzleStates:
          (json['puzzleStates'] as Map?)?.map(
            (k, v) => MapEntry(k as String, v as String),
          ) ??
          const {},
      playTimeMs: json['playTimeMs'] as int? ?? 0,
    );
  }
}
