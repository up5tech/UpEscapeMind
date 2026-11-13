import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../data/repositories/content_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/shared_preferences_progress_repository.dart';
import '../../data/repositories/shared_preferences_settings_repository.dart';
import '../../data/repositories/static_content_repository.dart';
import '../../domain/models/progress.dart';

/// SharedPreferences instance, initialized once in `main()`.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope',
  ),
);

final contentRepositoryProvider = Provider<ContentRepository>(
  (ref) => StaticContentRepository(),
);

final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) =>
      SharedPreferencesProgressRepository(ref.watch(sharedPreferencesProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) =>
      SharedPreferencesSettingsRepository(ref.watch(sharedPreferencesProvider)),
);

/// Loads the saved [GameProgress] for the default slot, or `null`.
final gameProgressProvider = FutureProvider<GameProgress?>((ref) async {
  final repo = ref.watch(progressRepositoryProvider);
  return repo.loadProgress(AppConstants.defaultSaveSlotId);
});

/// Active locale override. `null` = follow the device locale
/// (falling back to Vietnamese per `AppConstants.defaultLocaleCode`).
class AppLocale extends Notifier<Locale?> {
  AppLocale([this.initial]);

  final Locale? initial;

  @override
  Locale? build() => initial;

  void set(Locale? locale) => state = locale;
}

final appLocaleProvider = NotifierProvider<AppLocale, Locale?>(AppLocale.new);
