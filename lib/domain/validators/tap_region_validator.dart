import '../../core/errors/app_exceptions.dart';
import 'config_parsing.dart';
import 'puzzle_validator.dart';

/// A normalized tap target on a scene image. Bounds follow the hotspot
/// convention: (x, y) is the top-left corner, width/height the size, all
/// in 0.0–1.0 relative to the image.
class TapRegion {
  const TapRegion({
    required this.id,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final String id;
  final double x;
  final double y;
  final double width;
  final double height;

  factory TapRegion.parse(Map<String, dynamic> json, String where) {
    final width = reqDoubleCfg(json, 'width', where);
    final height = reqDoubleCfg(json, 'height', where);
    if (width <= 0 || height <= 0) {
      throw ContentValidationException(
        '$where: "width" and "height" must be > 0',
      );
    }
    final x = reqDoubleCfg(json, 'x', where);
    final y = reqDoubleCfg(json, 'y', where);
    if (x < 0 || y < 0 || x + width > 1 || y + height > 1) {
      throw ContentValidationException(
        '$where: region must stay within normalized bounds 0.0–1.0',
      );
    }
    return TapRegion(
      id: reqStringCfg(json, 'id', where),
      x: x,
      y: y,
      width: width,
      height: height,
    );
  }

  /// Hit test with [padding] grown on every side (hit areas must be
  /// larger than the object — AGENTS hotspot rule).
  bool contains(TapPoint point, double padding) =>
      point.x >= x - padding &&
      point.x <= x + width + padding &&
      point.y >= y - padding &&
      point.y <= y + height + padding;
}

/// `hidden_object` and `observation` families — taps on normalized regions
/// of a scene image (`HotspotHitValidator` / `ConstellationOrderValidator`).
///
/// Config:
/// - `solutionConfig.regions` non-empty list of `{id, x, y, width, height}`.
/// - `validationConfig.hitPadding` number 0–0.5 (default 0.04).
/// - hidden_object: `solutionConfig.targetId` — the single region to find.
///   Input: `TapPoint`.
/// - observation: `solutionConfig.targets` — ordered region ids to tap in
///   sequence. Input: `List<String>` of tapped ids; any tap that breaks
///   the expected prefix is incorrect.
class TapRegionValidator extends PuzzleValidator {
  TapRegionValidator._({
    required this.regions,
    required this.hitPadding,
    this.targetId,
    this.targets,
  });

  factory TapRegionValidator.parse({
    required Map<String, dynamic> solutionConfig,
    required Map<String, dynamic> validationConfig,
    required String where,
    bool ordered = false,
  }) {
    final raw = solutionConfig['regions'];
    if (raw is! List || raw.isEmpty) {
      throw ContentValidationException(
        '$where: "regions" must be a non-empty list of region objects',
      );
    }
    final regions = <TapRegion>[
      for (var i = 0; i < raw.length; i++)
        if (raw[i] is Map<String, dynamic>)
          TapRegion.parse(raw[i] as Map<String, dynamic>, '$where.regions[$i]')
        else
          throw ContentValidationException(
            '$where: "regions[$i]" must be an object',
          ),
    ];
    final ids = regions.map((r) => r.id).toSet();
    if (ids.length != regions.length) {
      throw ContentValidationException('$where: duplicate region ids');
    }
    final padding = reqDoubleCfg(
      validationConfig,
      'hitPadding',
      where,
      dflt: 0.04,
    );
    if (padding < 0 || padding > 0.5) {
      throw ContentValidationException(
        '$where: "hitPadding" must be between 0 and 0.5',
      );
    }
    String? targetId;
    List<String>? targets;
    if (ordered) {
      targets = reqStringListCfg(solutionConfig, 'targets', where);
      for (final t in targets) {
        if (!ids.contains(t)) {
          throw ContentValidationException(
            '$where: "targets" references unknown region "$t"',
          );
        }
      }
    } else {
      targetId = reqStringCfg(solutionConfig, 'targetId', where);
      if (!ids.contains(targetId)) {
        throw ContentValidationException(
          '$where: "targetId" references unknown region "$targetId"',
        );
      }
    }
    return TapRegionValidator._(
      regions: regions,
      hitPadding: padding,
      targetId: targetId,
      targets: targets,
    );
  }

  final List<TapRegion> regions;
  final double hitPadding;

  /// Single-target mode (hidden_object).
  final String? targetId;

  /// Ordered-sequence mode (observation).
  final List<String>? targets;

  bool get isOrdered => targets != null;

  /// Region hit by [point], or null. Later (drawn-on-top) regions win.
  String? hitRegionId(TapPoint point) {
    for (final region in regions.reversed) {
      if (region.contains(point, hitPadding)) return region.id;
    }
    return null;
  }

  PuzzleVerdict checkTap(TapPoint point) {
    final id = hitRegionId(point);
    return id != null && id == targetId
        ? PuzzleVerdict.correct
        : PuzzleVerdict.incorrect;
  }

  PuzzleVerdict checkSequence(List<String> taps) {
    final expected = targets;
    if (expected == null) return PuzzleVerdict.incorrect;
    if (taps.length > expected.length) return PuzzleVerdict.incorrect;
    for (var i = 0; i < taps.length; i++) {
      if (taps[i] != expected[i]) return PuzzleVerdict.incorrect;
    }
    return taps.length == expected.length
        ? PuzzleVerdict.correct
        : PuzzleVerdict.incomplete;
  }

  @override
  PuzzleVerdict evaluateInput(Object? input) {
    if (input is TapPoint && !isOrdered) return checkTap(input);
    if (input is List<String> && isOrdered) return checkSequence(input);
    return PuzzleVerdict.incomplete;
  }
}
