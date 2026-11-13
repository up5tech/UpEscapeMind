import '../../domain/models/progress.dart';

/// Persists durable game progress (unlocks, solved puzzles, inventory,
/// discovered clues, revealed hints) in the local database.
///
/// All mutating operations must be atomic and idempotent: repeating a
/// completed action must not grant duplicate rewards.
/// Drift implementation lands in Phase 3.
abstract interface class ProgressRepository {
  /// Loads progress for [saveSlotId], or `null` when no save exists.
  Future<GameProgress?> loadProgress(String saveSlotId);

  /// Persists [progress] for its save slot.
  Future<void> saveProgress(GameProgress progress);

  /// Deletes the save for [saveSlotId]. Caller must confirm with the user.
  Future<void> resetProgress(String saveSlotId);
}
