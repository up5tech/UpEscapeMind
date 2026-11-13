import '../../core/errors/app_exceptions.dart';
import 'config_parsing.dart';
import 'puzzle_validator.dart';

/// One entry field of a logic-deduction puzzle (orrery rings, multi-part
/// locks).
class DeductionField {
  const DeductionField({
    required this.id,
    required this.kind,
    required this.maxLength,
    required this.labelKey,
  });

  final String id;

  /// `digits` — ASCII digits only, leading zeroes significant.
  /// `text`  — compared trimmed, whitespace-collapsed, case-insensitive.
  final String kind;

  /// 0 = unlimited.
  final int maxLength;
  final String labelKey;

  factory DeductionField.parse(Map<String, dynamic> json, String where) {
    final id = reqStringCfg(json, 'id', where);
    final kind = reqStringCfg(json, 'kind', where);
    if (kind != 'digits' && kind != 'text') {
      throw ContentValidationException(
        '$where: "kind" must be "digits" or "text", got "$kind"',
      );
    }
    final maxLength = reqIntCfg(json, 'maxLength', where, dflt: 0);
    if (maxLength < 0) {
      throw ContentValidationException('$where: "maxLength" must be >= 0');
    }
    return DeductionField(
      id: id,
      kind: kind,
      maxLength: maxLength,
      labelKey: reqStringCfg(json, 'labelKey', where),
    );
  }
}

/// `logic_deduction` family — several typed fields compared together
/// (`OrrerySequenceValidator`: `[t1,t2,t3,year]` vs the authored answer).
///
/// Config:
/// - `initialState.fields` list of `{id, kind: "digits"|"text", maxLength?,
///   labelKey}`.
/// - `solutionConfig.answer` object mapping field id → expected value.
///
/// Input: `Map<String, String>` field id → raw text. Normalization is
/// per-field ([DeductionField.kind]); leading zeroes are significant for
/// digit fields, which is the core trap of the orrery puzzle.
class LogicDeductionValidator extends PuzzleValidator {
  LogicDeductionValidator._({
    required this.fields,
    required this.answer,
  });

  factory LogicDeductionValidator.parse({
    required Map<String, dynamic> initialState,
    required Map<String, dynamic> solutionConfig,
    required String where,
  }) {
    final rawFields = initialState['fields'];
    if (rawFields is! List || rawFields.isEmpty) {
      throw ContentValidationException(
        '$where: "fields" must be a non-empty list of field objects',
      );
    }
    final fields = <DeductionField>[
      for (var i = 0; i < rawFields.length; i++)
        if (rawFields[i] is Map<String, dynamic>)
          DeductionField.parse(
            rawFields[i] as Map<String, dynamic>,
            '$where.fields[$i]',
          )
        else
          throw ContentValidationException(
            '$where: "fields[$i]" must be an object',
          ),
    ];
    final ids = fields.map((f) => f.id).toSet();
    if (ids.length != fields.length) {
      throw ContentValidationException('$where: duplicate field ids');
    }
    final answer = reqStringMapCfg(solutionConfig, 'answer', where);
    for (final f in fields) {
      final expected = answer[f.id];
      if (expected == null || expected.isEmpty) {
        throw ContentValidationException(
          '$where: "answer" is missing a non-empty value for field '
          '"${f.id}"',
        );
      }
      if (f.kind == 'digits' && !isDigitString(expected)) {
        throw ContentValidationException(
          '$where: "answer.${f.id}" must be digits only',
        );
      }
      if (f.maxLength > 0 && expected.length > f.maxLength) {
        throw ContentValidationException(
          '$where: "answer.${f.id}" is longer than the field maxLength',
        );
      }
    }
    for (final key in answer.keys) {
      if (!ids.contains(key)) {
        throw ContentValidationException(
          '$where: "answer" references unknown field "$key"',
        );
      }
    }
    return LogicDeductionValidator._(fields: fields, answer: answer);
  }

  final List<DeductionField> fields;
  final Map<String, String> answer;

  /// Applies per-field input normalization. Never locale-dependent.
  String normalize(DeductionField field, String raw) {
    if (field.kind == 'digits') {
      return raw.trim().replaceAll(' ', '');
    }
    return raw.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  bool isFieldValidInput(DeductionField field, String raw) {
    final normalized = normalize(field, raw);
    if (field.maxLength > 0 && normalized.length > field.maxLength) {
      return false;
    }
    return field.kind != 'digits' || isDigitString(normalized);
  }

  PuzzleVerdict check(Map<String, String> input) {
    var anyEmpty = false;
    for (final field in fields) {
      final raw = input[field.id] ?? '';
      if (normalize(field, raw).isEmpty) {
        anyEmpty = true;
        continue;
      }
      if (!isFieldValidInput(field, raw)) return PuzzleVerdict.incorrect;
    }
    if (anyEmpty) return PuzzleVerdict.incomplete;
    for (final field in fields) {
      final expected = normalize(field, answer[field.id]!);
      final actual = normalize(field, input[field.id]!);
      if (actual != expected) return PuzzleVerdict.incorrect;
    }
    return PuzzleVerdict.correct;
  }

  @override
  PuzzleVerdict evaluateInput(Object? input) {
    if (input is! Map<String, String>) return PuzzleVerdict.incomplete;
    return check(input);
  }
}
