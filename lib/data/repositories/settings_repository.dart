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

  /// One-time guidance overlays (how-to-play, per-room intro) are tracked
  /// by stable id so each is shown once and can be replayed from the menu.
  Future<bool> hasSeenGuidance(String guidanceId);
  Future<void> markGuidanceSeen(String guidanceId);
}
