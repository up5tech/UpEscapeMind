import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exceptions.dart';
import '../../domain/models/progress.dart';
import 'progress_repository.dart';

/// Interim progress store backed by `SharedPreferences`.
///
/// Phase 3 replaces this with the Drift/SQLite implementation. The
/// [ProgressRepository] contract is identical, so callers do not change.
class SharedPreferencesProgressRepository implements ProgressRepository {
  SharedPreferencesProgressRepository(this._prefs);

  final SharedPreferences _prefs;

  String _key(String saveSlotId) => 'progress.$saveSlotId';

  @override
  Future<GameProgress?> loadProgress(String saveSlotId) async {
    final raw = _prefs.getString(_key(saveSlotId));
    if (raw == null) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('progress payload is not an object');
      }
      return GameProgress.fromJson(decoded);
    } on FormatException catch (e) {
      throw SaveDataException('Corrupt save for slot "$saveSlotId": $e');
    } on TypeError catch (e) {
      throw SaveDataException('Unsupported save schema for "$saveSlotId": $e');
    }
  }

  @override
  Future<void> saveProgress(GameProgress progress) {
    return _prefs.setString(
      _key(progress.saveSlotId),
      jsonEncode(progress.toJson()),
    );
  }

  @override
  Future<void> resetProgress(String saveSlotId) =>
      _prefs.remove(_key(saveSlotId));

  /// Convenience accessor for the MVP's single save slot.
  Future<GameProgress?> loadDefaultProgress() =>
      loadProgress(AppConstants.defaultSaveSlotId);
}
