import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Transient puzzle input, keyed by puzzle id.
///
/// This is UI-session state only — never persisted. It exists so a puzzle
/// with `resetPolicy: "keep"` restores the player's partial input when the
/// puzzle screen is reopened within the app session (PLAN §4.5), while
/// `reset_on_exit` puzzles are cleared by [PuzzleScreen] on dispose.
class PuzzleSessions extends Notifier<Map<String, Object?>> {
  @override
  Map<String, Object?> build() => const {};

  Object? inputFor(String puzzleId) => state[puzzleId];

  void setInput(String puzzleId, Object? input) {
    if (input == null) {
      clearInput(puzzleId);
      return;
    }
    state = {...state, puzzleId: input};
  }

  void clearInput(String puzzleId) {
    if (!state.containsKey(puzzleId)) return;
    final next = Map<String, Object?>.of(state)..remove(puzzleId);
    state = next;
  }
}

final puzzleSessionsProvider =
    NotifierProvider<PuzzleSessions, Map<String, Object?>>(
      PuzzleSessions.new,
    );
