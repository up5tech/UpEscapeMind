/// Persists small non-critical preferences via `shared_preferences`:
/// audio toggles, haptics, language override, text scale.
abstract interface class SettingsRepository {
  Future<bool> isMusicEnabled();
  Future<bool> isSoundEffectsEnabled();
  Future<bool> isHapticsEnabled();

  /// `'vi'` or `'en'`; `null` means "follow device locale".
  Future<String?> languageOverride();

  Future<void> setMusicEnabled(bool value);
  Future<void> setSoundEffectsEnabled(bool value);
  Future<void> setHapticsEnabled(bool value);
  Future<void> setLanguageOverride(String? languageCode);
}
