import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../core/logging/app_log.dart';

/// Runtime lookup for player-facing content strings.
///
/// Content definitions reference localization keys (e.g. `titleKey`); those
/// keys resolve through the bundled tables in
/// `assets/content/localization/strings_<locale>.json`. Vietnamese is the
/// default; English is the fallback, then the key itself (so a missing
/// translation degrades visibly in debug rather than crashing).
class ContentStrings {
  ContentStrings._(this._tables);

  final Map<String, Map<String, String>> _tables;

  String forLocale(String localeCode, String key) {
    final primary = _tables[localeCode]?[key];
    if (primary != null) return primary;
    final fallback = _tables['en']?[key];
    if (fallback != null) return fallback;
    AppLog.warning('missing content string "$key" for locale "$localeCode"');
    return key;
  }

  static Future<ContentStrings> load() async {
    final tables = <String, Map<String, String>>{};
    for (final locale in ['vi', 'en']) {
      final raw = await rootBundle.loadString(
        'assets/content/localization/strings_$locale.json',
      );
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw FormatException('strings_$locale.json is not an object');
      }
      tables[locale] = {
        for (final e in decoded.entries)
          if (e.value is String) e.key: e.value as String,
      };
    }
    return ContentStrings._(tables);
  }
}
