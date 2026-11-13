import '../../core/errors/app_exceptions.dart';
import 'config_parsing.dart';
import 'puzzle_validator.dart';

/// One rotatable dial: absolute target angle plus optional detent snapping.
class RotationStep {
  const RotationStep({required this.targetAngle, required this.startAngle});

  /// Absolute solution angle, normalized to `[0, 360)`.
  final double targetAngle;

  /// Angle shown when the puzzle is (re)opened; Reset returns here.
  final double startAngle;
}

/// `rotation` family — align one or more dials to target angles
/// (`RotationValidator` for the globe, `MultiRotationValidator` semantics
/// when the definition lists several `steps`).
///
/// Config:
/// - `solutionConfig.steps` non-empty list of target angles in degrees.
/// - `validationConfig.toleranceDegrees` number ≥ 0 (default 5).
/// - `validationConfig.detents` optional int > 1 — angles snap to
///   `360 / detents` increments.
/// - `initialState.startAngles` optional list of start angles (default 0
///   per step).
///
/// Input: `List<double>` current angle per step. The validator receives
/// raw angles; it normalizes to 0–359 and compares with the shortest arc.
class RotationValidator extends PuzzleValidator {
  RotationValidator._({
    required this.steps,
    required this.toleranceDegrees,
    this.detents,
  });

  factory RotationValidator.parse({
    required Map<String, dynamic> initialState,
    required Map<String, dynamic> solutionConfig,
    required Map<String, dynamic> validationConfig,
    required String where,
  }) {
    final targets = reqNumListCfg(solutionConfig, 'steps', where);
    final startsRaw = initialState['startAngles'];
    List<num> starts;
    if (startsRaw == null) {
      starts = [for (final _ in targets) 0];
    } else if (startsRaw is! List || startsRaw.length != targets.length) {
      throw ContentValidationException(
        '$where: "startAngles" must be a list with one entry per "steps" '
        'entry',
      );
    } else {
      starts = [
        for (var i = 0; i < startsRaw.length; i++)
          if (startsRaw[i] is num)
            startsRaw[i] as num
          else
            throw ContentValidationException(
              '$where: "startAngles[$i]" must be a number',
            ),
      ];
    }
    final detentsRaw = validationConfig['detents'];
    if (detentsRaw != null && (detentsRaw is! int || detentsRaw < 2)) {
      throw ContentValidationException(
        '$where: "detents" must be an int of at least 2',
      );
    }
    return RotationValidator._(
      steps: [
        for (var i = 0; i < targets.length; i++)
          RotationStep(
            targetAngle: normalizeAngle(targets[i].toDouble()),
            startAngle: normalizeAngle(starts[i].toDouble()),
          ),
      ],
      toleranceDegrees: reqDoubleCfg(
        validationConfig,
        'toleranceDegrees',
        where,
        dflt: 5,
      ),
      detents: detentsRaw as int?,
    );
  }

  final List<RotationStep> steps;
  final double toleranceDegrees;
  final int? detents;

  int get dialCount => steps.length;

  List<double> get startAngles => [for (final s in steps) s.startAngle];

  /// Snaps [degrees] to the configured detents, or normalizes it when the
  /// dial is continuous.
  double snap(double degrees) {
    final normalized = normalizeAngle(degrees);
    final d = detents;
    if (d == null) return normalized;
    final size = 360 / d;
    return normalizeAngle((normalized / size).round() * size);
  }

  PuzzleVerdict check(List<double> angles) {
    if (angles.length != steps.length) return PuzzleVerdict.incorrect;
    for (var i = 0; i < steps.length; i++) {
      if (angleError(angles[i], steps[i].targetAngle) > toleranceDegrees) {
        return PuzzleVerdict.incorrect;
      }
    }
    return PuzzleVerdict.correct;
  }

  @override
  PuzzleVerdict evaluateInput(Object? input) =>
      input is List<double> ? check(input) : PuzzleVerdict.incomplete;
}
