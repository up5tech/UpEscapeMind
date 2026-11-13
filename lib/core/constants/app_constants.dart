/// App-wide constants.
abstract final class AppConstants {
  /// Entry room of the first chapter — used by the prologue's
  /// "Enter the house" action as a fallback for fresh saves.
  static const String entryRoomId = 'room_entrance';

  /// Current content schema version bundled with the app.
  /// Bump together with `assets/content/` format changes (Phase 2+).
  static const int contentSchemaVersion = 1;

  /// Current save schema version for the local database (Phase 3+).
  static const int saveSchemaVersion = 1;

  /// The single local save slot used by the MVP.
  static const String defaultSaveSlotId = 'slot_main';

  /// Supported locales. Vietnamese is the default for the first release.
  static const String defaultLocaleCode = 'vi';
}
