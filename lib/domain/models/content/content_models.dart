/// Typed content models parsed from bundled JSON under `assets/content/`.
///
/// All parsing is strict: missing required fields, wrong types, and unknown
/// enum values throw `ContentValidationException` with the source file path
/// and field name. No code is ever executed from content JSON.
library;

export 'chapter_definition.dart';
export 'clue_definition.dart';
export 'content_catalog.dart';
export 'hotspot_definition.dart';
export 'item_combination_definition.dart';
export 'item_definition.dart';
export 'prerequisites.dart';
export 'puzzle_definition.dart';
export 'room_definition.dart';
