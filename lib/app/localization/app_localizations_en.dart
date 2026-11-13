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
  String get chapterSampleTitle => 'Sample Chapter (dev fixture)';

  @override
  String get roomSampleTitle => 'Sample Room';

  @override
  String get roomSampleDescription =>
      'A minimal room used to validate the content pipeline.';

  @override
  String get roomSampleExitTitle => 'Sample Room — Exit';

  @override
  String get hotspotSampleNote => 'A note';

  @override
  String get hotspotSampleNoteDesc => 'A folded note lies on the desk.';

  @override
  String get hotspotSamplePlaque => 'A plaque';

  @override
  String get hotspotSampleKeyDrawer => 'Key drawer';

  @override
  String get hotspotSampleGearDrawer => 'Gear drawer';

  @override
  String get hotspotSampleDoorLock => 'Door lock';

  @override
  String get hotspotSampleExitDoor => 'Side door';

  @override
  String get hotspotSampleExitBack => 'Way back';

  @override
  String get exitSampleForward => 'Proceed';

  @override
  String get exitSampleBack => 'Return';

  @override
  String get puzzleSampleLockTitle => 'Sample Lock';

  @override
  String get puzzleSampleLockInstructions => 'Enter the four-digit code.';

  @override
  String get puzzleSampleLockHint1 => 'Look around the room for digits.';

  @override
  String get puzzleSampleLockHint2 =>
      'The plaque by the door shows the first two digits.';

  @override
  String get puzzleSampleLockHint3 => 'Code: 4 - 2 - 7 - 1.';

  @override
  String get itemSampleKeyName => 'Small Key';

  @override
  String get itemSampleKeyDesc => 'A small brass key, still warm.';

  @override
  String get itemSampleGearName => 'Brass Gear';

  @override
  String get itemSampleGearDesc => 'A single gear from an old mechanism.';

  @override
  String get itemSampleHookName => 'Hook & Key';

  @override
  String get itemSampleHookDesc => 'A combined tool: key mounted on a gear.';

  @override
  String get combinationSampleHookMessage =>
      'You fit the gear onto the key, making a hooked tool.';

  @override
  String get clueSampleNoteTitle => 'Margin Note';

  @override
  String get clueSampleNoteBody =>
      'The clockmaker wrote: \'Time is a lock, not a river.\'';

  @override
  String get clueSampleLockOpenedTitle => 'The Lock Opens';

  @override
  String get clueSampleLockOpenedBody =>
      'Inside the panel: a second, smaller lock.';

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
}
