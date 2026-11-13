import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../data/content/content_strings.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/asset_content_repository.dart';
import '../../data/repositories/content_repository.dart';
import '../../data/repositories/drift_progress_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/shared_preferences_settings_repository.dart';
import '../../domain/models/content/content_catalog.dart';
import '../../domain/models/progress.dart';

/// SharedPreferences instance, initialized once in `main()`.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope',
  ),
);

final contentRepositoryProvider = Provider<ContentRepository>(
  (ref) => AssetContentRepository(),
);

/// Validated content catalog, loaded once per session.
final contentCatalogProvider = FutureProvider<ContentCatalog>((ref) {
  return ref.watch(contentRepositoryProvider).loadCatalog();
});

/// Bundled content string tables (vi default, en fallback).
final contentStringsProvider = FutureProvider<ContentStrings>((ref) {
  return ContentStrings.load();
});

/// Local SQLite database. Closed when the provider scope is disposed.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => DriftProgressRepository(ref.watch(appDatabaseProvider)),
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
