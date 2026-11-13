import '../../core/errors/app_exceptions.dart';

/// Strict typed accessors for a puzzle's opaque `initialState` /
/// `solutionConfig` / `validationConfig` maps. Every failure message
/// includes the owning puzzle (via [where]) and the offending key.
///
/// Content JSON must never contain executable code — only these scalar,
/// list, and map shapes.
int reqIntCfg(Map<String, dynamic> cfg, String key, String where, {int? dflt}) {
  final value = cfg[key];
  if (value == null) {
    if (dflt != null) return dflt;
    throw ContentValidationException('$where: "$key" must be an int');
  }
  if (value is! int) {
    throw ContentValidationException('$where: "$key" must be an int');
  }
  return value;
}

double reqDoubleCfg(
  Map<String, dynamic> cfg,
  String key,
  String where, {
  double? dflt,
}) {
  final value = cfg[key];
  if (value == null) {
    if (dflt != null) return dflt;
    throw ContentValidationException('$where: "$key" must be a number');
  }
  if (value is! num) {
    throw ContentValidationException('$where: "$key" must be a number');
  }
  return value.toDouble();
}

bool reqBoolCfg(Map<String, dynamic> cfg, String key, String where,
    {bool dflt = false}) {
  final value = cfg[key];
  if (value == null) return dflt;
  if (value is! bool) {
    throw ContentValidationException('$where: "$key" must be a bool');
  }
  return value;
}

String reqStringCfg(Map<String, dynamic> cfg, String key, String where) {
  final value = cfg[key];
  if (value is! String || value.isEmpty) {
    throw ContentValidationException(
      '$where: "$key" must be a non-empty string',
    );
  }
  return value;
}

List<String> reqStringListCfg(
  Map<String, dynamic> cfg,
  String key,
  String where, {
  bool allowDuplicates = false,
}) {
  final value = cfg[key];
  if (value is! List || value.isEmpty) {
    throw ContentValidationException(
      '$where: "$key" must be a non-empty list of strings',
    );
  }
  final list = <String>[
    for (var i = 0; i < value.length; i++)
      if (value[i] is String && (value[i] as String).isNotEmpty)
        value[i] as String
      else
        throw ContentValidationException(
          '$where: "$key[$i]" must be a non-empty string',
        ),
  ];
  if (!allowDuplicates && list.toSet().length != list.length) {
    throw ContentValidationException('$where: "$key" contains duplicates');
  }
  return list;
}

List<num> reqNumListCfg(Map<String, dynamic> cfg, String key, String where) {
  final value = cfg[key];
  if (value is! List || value.isEmpty) {
    throw ContentValidationException(
      '$where: "$key" must be a non-empty list of numbers',
    );
  }
  return [
    for (var i = 0; i < value.length; i++)
      if (value[i] is num)
        value[i] as num
      else
        throw ContentValidationException('$where: "$key[$i]" must be a number'),
  ];
}

List<bool> reqBoolListCfg(Map<String, dynamic> cfg, String key, String where) {
  final value = cfg[key];
  if (value is! List || value.isEmpty) {
    throw ContentValidationException(
      '$where: "$key" must be a non-empty list of bools',
    );
  }
  return [
    for (var i = 0; i < value.length; i++)
      if (value[i] is bool)
        value[i] as bool
      else
        throw ContentValidationException('$where: "$key[$i]" must be a bool'),
  ];
}

Map<String, dynamic> reqObjectCfg(
  Map<String, dynamic> cfg,
  String key,
  String where,
) {
  final value = cfg[key];
  if (value is! Map<String, dynamic>) {
    throw ContentValidationException('$where: "$key" must be an object');
  }
  return value;
}

Map<String, String> reqStringMapCfg(
  Map<String, dynamic> cfg,
  String key,
  String where,
) {
  final value = reqObjectCfg(cfg, key, where);
  final out = <String, String>{};
  for (final e in value.entries) {
    if (e.value is! String) {
      throw ContentValidationException(
        '$where: "$key.${e.key}" must be a string',
      );
    }
    out[e.key] = e.value as String;
  }
  return out;
}
