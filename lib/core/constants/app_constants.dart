/// App-wide constants.
abstract final class AppConstants {
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
