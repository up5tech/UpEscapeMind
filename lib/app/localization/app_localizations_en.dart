// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Up Escape Mind';

  @override
  String get appTagline => 'An escape-room mystery, fully offline.';

  @override
  String get menuContinue => 'Continue';

  @override
  String get menuNewGame => 'New Game';

  @override
  String get menuChapters => 'Chapters';

  @override
  String get menuSettings => 'Settings';

  @override
  String get menuCredits => 'Credits';

  @override
  String get chaptersTitle => 'Chapters';

  @override
  String get chapterLocked => 'Locked';

  @override
  String get chapterAvailable => 'Available';

  @override
  String get chapterInProgress => 'In Progress';

  @override
  String get chapterCompleted => 'Completed';

  @override
  String get noSaveExists => 'No save found. Start a new game to begin.';

  @override
  String get newGameConfirmTitle => 'Start a new game?';

  @override
  String get newGameConfirmBody => 'This will replace your existing save.';

  @override
  String get journalTitle => 'Journal';

  @override
  String get journalEmpty =>
      'No discoveries yet. Clues and notes you find will appear here.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsMusic => 'Music';

  @override
  String get settingsSoundEffects => 'Sound effects';

  @override
  String get settingsHaptics => 'Haptics';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystemDefault => 'System default';

  @override
  String get settingsResetProgress => 'Reset progress';

  @override
  String get resetProgressConfirmTitle => 'Reset all progress?';

  @override
  String get resetProgressConfirmBody =>
      'This permanently deletes your save data. This cannot be undone.';

  @override
  String get resetProgressDone => 'Progress has been reset.';

  @override
  String get creditsTitle => 'Credits';

  @override
  String get creditsBody =>
      'Up Escape Mind — a single-player offline escape-room adventure.';

  @override
  String get commonBack => 'Back';

  @override
  String get commonClose => 'Close';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get roomLockedMessage => 'This area is still locked.';

  @override
  String get puzzleLockedMessage => 'This puzzle cannot be opened yet.';

  @override
  String get puzzleIncorrectMessage => 'Not quite right. Try again.';

  @override
  String get puzzleSolvedMessage => 'Correct! The puzzle is solved.';

  @override
  String get keypadClear => 'Clear';

  @override
  String get keypadDelete => 'Delete';

  @override
  String itemCollectedMessage(String name) {
    return 'Picked up $name.';
  }

  @override
  String alreadyHaveItemMessage(String name) {
    return 'You already have $name.';
  }

  @override
  String clueDiscoveredMessage(String title) {
    return 'New clue in your Journal: $title.';
  }
}
