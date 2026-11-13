/// Base type for expected, recoverable application errors.
///
/// Unexpected errors should be allowed to propagate or be logged; use these
/// types for states the UI knows how to present (missing content, locked
/// content, invalid input, unsupported save version, ...).
sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Referenced content (room, puzzle, item, clue, ...) does not exist.
final class ContentNotFoundException extends AppException {
  const ContentNotFoundException(super.message);
}

/// Referenced content exists but fails validation.
final class ContentValidationException extends AppException {
  const ContentValidationException(super.message);
}

/// Player attempted to access locked or not-yet-unlocked content.
final class LockedContentException extends AppException {
  const LockedContentException(super.message);
}

/// Player input failed puzzle/item validation. Never corrupts state.
final class InvalidPlayerInputException extends AppException {
  const InvalidPlayerInputException(super.message);
}

/// Local save data is missing, corrupt, or from an unsupported version.
final class SaveDataException extends AppException {
  const SaveDataException(super.message);
}
