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
  String get chapter1Title => 'The Clockmaker\'s Archive';

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
  String get roomEntranceTitle => 'Entrance Hall';

  @override
  String get roomStudyTitle => 'Clockmaker\'s Study';

  @override
  String get roomWorkshopTitle => 'Workshop';

  @override
  String get roomGalleryTitle => 'Portrait Gallery';

  @override
  String get roomObservatoryTitle => 'Sealed Observatory';

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
}
