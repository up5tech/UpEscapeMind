import 'package:shared_preferences/shared_preferences.dart';

import 'settings_repository.dart';

/// `SharedPreferences`-backed settings store.
class SharedPreferencesSettingsRepository implements SettingsRepository {
  SharedPreferencesSettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _keyMusic = 'settings.music';
  static const _keySfx = 'settings.sfx';
  static const _keyHaptics = 'settings.haptics';
  static const _keyLanguage = 'settings.language';

  @override
  Future<bool> isMusicEnabled() async => _prefs.getBool(_keyMusic) ?? true;

  @override
  Future<bool> isSoundEffectsEnabled() async => _prefs.getBool(_keySfx) ?? true;

  @override
  Future<bool> isHapticsEnabled() async => _prefs.getBool(_keyHaptics) ?? true;

  @override
  Future<String?> languageOverride() async => _prefs.getString(_keyLanguage);

  @override
  Future<void> setMusicEnabled(bool value) => _prefs.setBool(_keyMusic, value);

  @override
  Future<void> setSoundEffectsEnabled(bool value) =>
      _prefs.setBool(_keySfx, value);

  @override
  Future<void> setHapticsEnabled(bool value) =>
      _prefs.setBool(_keyHaptics, value);

  @override
  Future<void> setLanguageOverride(String? languageCode) {
    if (languageCode == null) {
      return _prefs.remove(_keyLanguage);
    }
    return _prefs.setString(_keyLanguage, languageCode);
  }
}
