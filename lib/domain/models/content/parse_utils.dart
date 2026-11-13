import '../../../core/errors/app_exceptions.dart';

/// Shared strict-JSON helpers for content parsing. Every failure message
/// includes the source file path and the offending field.
String reqString(
  Map<String, dynamic> json,
  String key,
  String filePath, {
  String fieldPrefix = '',
}) {
  final field = fieldPrefix.isEmpty ? key : '$fieldPrefix.$key';
  final value = json[key];
  if (value is! String || value.isEmpty) {
    throw ContentValidationException(
      '$filePath: "$field" must be a non-empty string',
    );
  }
  return value;
}

String? optString(
  Map<String, dynamic> json,
  String key,
  String filePath, {
  String fieldPrefix = '',
}) {
  final field = fieldPrefix.isEmpty ? key : '$fieldPrefix.$key';
  final value = json[key];
  if (value == null) return null;
  if (value is! String) {
    throw ContentValidationException('$filePath: "$field" must be a string');
  }
  return value;
}

bool reqBool(
  Map<String, dynamic> json,
  String key,
  String filePath, {
  bool mandatory = true,
  String fieldPrefix = '',
}) {
  final field = fieldPrefix.isEmpty ? key : '$fieldPrefix.$key';
  final value = json[key];
  if (value == null && !mandatory) return false;
  if (value is! bool) {
    throw ContentValidationException('$filePath: "$field" must be a bool');
  }
  return value;
}

int reqInt(
  Map<String, dynamic> json,
  String key,
  String filePath, {
  String fieldPrefix = '',
}) {
  final field = fieldPrefix.isEmpty ? key : '$fieldPrefix.$key';
  final value = json[key];
  if (value is! int) {
    throw ContentValidationException('$filePath: "$field" must be an int');
  }
  return value;
}

Map<String, dynamic> reqMap(
  Map<String, dynamic> json,
  String key,
  String filePath, {
  String fieldPrefix = '',
}) {
  final field = fieldPrefix.isEmpty ? key : '$fieldPrefix.$key';
  final value = json[key];
  if (value is! Map<String, dynamic>) {
    throw ContentValidationException('$filePath: "$field" must be an object');
  }
  return value;
}

Map<String, dynamic>? optMap(
  Map<String, dynamic> json,
  String key,
  String filePath, {
  String fieldPrefix = '',
}) {
  final field = fieldPrefix.isEmpty ? key : '$fieldPrefix.$key';
  final value = json[key];
  if (value == null) return null;
  if (value is! Map<String, dynamic>) {
    throw ContentValidationException('$filePath: "$field" must be an object');
  }
  return value;
}

List<dynamic> reqList(
  Map<String, dynamic> json,
  String key,
  String filePath, {
  String fieldPrefix = '',
}) {
  final field = fieldPrefix.isEmpty ? key : '$fieldPrefix.$key';
  final value = json[key];
  if (value is! List) {
    throw ContentValidationException('$filePath: "$field" must be a list');
  }
  return value;
}

List<String> reqStringList(
  Map<String, dynamic> json,
  String key,
  String filePath, {
  String fieldPrefix = '',
}) {
  final field = fieldPrefix.isEmpty ? key : '$fieldPrefix.$key';
  final list = reqList(json, key, filePath, fieldPrefix: fieldPrefix);
  return [
    for (var i = 0; i < list.length; i++)
      if (list[i] is String && (list[i] as String).isNotEmpty)
        list[i] as String
      else
        throw ContentValidationException(
          '$filePath: "$field[$i]" must be a non-empty string',
        ),
  ];
}

List<Map<String, dynamic>> reqMapList(
  Map<String, dynamic> json,
  String key,
  String filePath, {
  String fieldPrefix = '',
}) {
  final field = fieldPrefix.isEmpty ? key : '$fieldPrefix.$key';
  final list = reqList(json, key, filePath, fieldPrefix: fieldPrefix);
  return [
    for (var i = 0; i < list.length; i++)
      if (list[i] is Map<String, dynamic>)
        list[i] as Map<String, dynamic>
      else
        throw ContentValidationException(
          '$filePath: "$field[$i]" must be an object',
        ),
  ];
}

/// Parses the `schemaVersion` field shared by every content file.
int reqSchemaVersion(Map<String, dynamic> json, String filePath) {
  final value = json['schemaVersion'];
  if (value is! int) {
    throw ContentValidationException(
      '$filePath: "schemaVersion" must be an int',
    );
  }
  return value;
}
