import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/localization/app_localizations.dart';
import 'app/providers/app_providers.dart';
import 'app/router.dart';
import 'app/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'data/database/app_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  runApp(
    UpEscapeMindApp(
      prefs: prefs,
      languageOverride: prefs.getString('settings.language'),
    ),
  );
}

/// Root widget: provider scope + MaterialApp.router.
///
/// Takes [prefs] explicitly so tests can inject mock preferences.
class UpEscapeMindApp extends StatelessWidget {
  const UpEscapeMindApp({
    super.key,
    required this.prefs,
    this.languageOverride,
    this.database,
  });

  final SharedPreferences prefs;
  final String? languageOverride;

  /// Optional database override (tests inject `NativeDatabase.memory()`).
  final AppDatabase? database;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        if (database != null) appDatabaseProvider.overrideWithValue(database!),
        appLocaleProvider.overrideWith(
          () => AppLocale(
            languageOverride == null ? null : Locale(languageOverride!),
          ),
        ),
      ],
      child: const _AppShell(),
    );
  }
}

class _AppShell extends ConsumerWidget {
  const _AppShell();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = createAppRouter();
    final localeOverride = ref.watch(appLocaleProvider);

    return MaterialApp.router(
      title: 'Up Escape Mind',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: router,
      locale: localeOverride,
      supportedLocales: const [Locale('vi'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        // Vietnamese is the default for the first release; the persisted
        // language override takes precedence over everything.
        if (localeOverride != null) return localeOverride;
        return const Locale(AppConstants.defaultLocaleCode);
      },
    );
  }
}
