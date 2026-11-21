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
  String get creditsArtTitle => 'Artwork';

  @override
  String get creditsArtBody =>
      'All artwork is original and created for Up Escape Mind.';

  @override
  String get creditsAudioTitle => 'Audio';

  @override
  String get creditsAudioBody =>
      'Version 1.0.0 ships without audio. Music and sound effects are planned for a future update.';

  @override
  String get creditsTechTitle => 'Technology';

  @override
  String get creditsTechBody =>
      'Built with Flutter. The game runs fully offline — no account, ads, or internet required.';

  @override
  String get creditsLicensesAction => 'Open-source licenses';

  @override
  String get commonBack => 'Back';

  @override
  String get commonClose => 'Close';

  @override
  String get commonNext => 'Next';

  @override
  String get prologueCard1 =>
      'You woke on the floor of the Meridian House. Every clock has stopped — each at a different time.';

  @override
  String get prologueCard2 =>
      '\"The archive keeps what the house forgets. — E.V.\"';

  @override
  String get prologueCard3 =>
      'Someone arranged all of this for you. Start looking.';

  @override
  String get prologueSkip => 'Skip';

  @override
  String get prologueEnter => 'Enter the house';

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
  String get puzzleCheck => 'Check';

  @override
  String get puzzleReset => 'Reset';

  @override
  String get rotationDecrease => 'Rotate counterclockwise';

  @override
  String get rotationIncrease => 'Rotate clockwise';

  @override
  String get leverUp => 'Up';

  @override
  String get leverDown => 'Down';

  @override
  String observationProgress(int found, int total) {
    return 'Found $found of $total.';
  }

  @override
  String tapRegionOption(int index) {
    return 'Target $index';
  }

  @override
  String get hintsAction => 'Hints';

  @override
  String get hintsTitle => 'Hints';

  @override
  String hintLevelTitle(int level) {
    return 'Hint $level';
  }

  @override
  String get hintNextButton => 'View next hint';

  @override
  String get hintWalkthroughConfirmTitle =>
      'Show the step-by-step walkthrough?';

  @override
  String get hintWalkthroughConfirmBody =>
      'Hint level 3 explains the solution step by step. Your progress is not affected either way.';

  @override
  String get prereqMissingPuzzle => 'Solve another puzzle first.';

  @override
  String get prereqMissingItem => 'You still need to find an item.';

  @override
  String get prereqMissingItemUse =>
      'You need to use the right item somewhere else first.';

  @override
  String get prereqMissingClue => 'A clue is still missing from your Journal.';

  @override
  String get prereqMissingArea => 'Another area is still locked.';

  @override
  String get prereqMissingChapter => 'A chapter must be completed first.';

  @override
  String get summaryTitle => 'Chapter complete!';

  @override
  String get summaryAreas => 'Areas';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get summaryStarsLabel => 'Rating';

  @override
  String get starRuleOne => 'Finish the chapter\'s final objective.';

  @override
  String get starRuleTwo => 'Solve every puzzle, including optional ones.';

  @override
  String get starRuleThree =>
      'Discover every clue, note and secret, including optional ones.';

  @override
  String get badgeNoWalkthrough => 'No walkthrough used';

  @override
  String get viewSummary => 'View summary';

  @override
  String get statChaptersCompleted => 'Chapters completed';

  @override
  String statAreasDiscovered(int found, int total) {
    return 'Areas discovered: $found/$total';
  }

  @override
  String statPuzzlesSolved(int found, int total) {
    return 'Puzzles solved: $found/$total';
  }

  @override
  String statOptionalCluesFound(int found, int total) {
    return 'Optional clues found: $found/$total';
  }

  @override
  String statHintsLevel(int level, int count) {
    return 'Hints opened, level $level: $count';
  }

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

  @override
  String get inventoryTitle => 'Satchel';

  @override
  String get inventoryEmpty =>
      'Your satchel is empty. Picked-up items will appear here.';

  @override
  String get itemUseAction => 'Use';

  @override
  String get itemDeselectAction => 'Deselect';

  @override
  String get itemCombineAction => 'Combine';

  @override
  String get combineExitAction => 'Done';

  @override
  String get combineNeedsSelection => 'Select at least two items to combine.';

  @override
  String get invalidItemUseMessage => 'That doesn\'t work here.';

  @override
  String get invalidCombinationMessage => 'These items can\'t be combined.';

  @override
  String itemUsedMessage(String item) {
    return 'You use the $item.';
  }

  @override
  String itemUsingHint(String item) {
    return 'Using $item — tap something in the room.';
  }

  @override
  String get menuHowToPlay => 'How to play';

  @override
  String get howToPlayTitle => 'How to play';

  @override
  String get howToPlayExplore =>
      'Tap the glowing spots in a room to find clues, items and puzzles.';

  @override
  String get howToPlayItems =>
      'Items live in your Satchel: choose “Use” then tap a spot in the room, or “Combine” several items.';

  @override
  String get howToPlayHints =>
      'The lightbulb in a puzzle opens 3 hint levels — hints are never required.';

  @override
  String get howToPlayJournal => 'Every clue and note is kept in your Journal.';

  @override
  String get howToPlayStart => 'Start exploring';

  @override
  String get guideRoomExplore => 'Tap the glowing spots to explore the room.';

  @override
  String get guideRoomDismiss => 'Got it';

  @override
  String get guideChaptersPick => 'Tap an area to start playing.';

  @override
  String get guidePuzzleKeypad =>
      'Tap the digits to enter the code — it checks itself when complete.';

  @override
  String get guidePuzzleSymbolMatching =>
      'Tap a slot to pick the right symbol, then press Check.';

  @override
  String get guidePuzzleSequence =>
      'Tap candidates to fill the slots in order, then press Check.';

  @override
  String get guidePuzzleRotation =>
      'Drag or tap a dial to rotate it to the right angle, then press Check.';

  @override
  String get guidePuzzleLogicDeduction =>
      'Fill in each row\'s answer, then press Check.';

  @override
  String get guidePuzzleMechanicalState =>
      'Flip the levers into position, then press Check.';

  @override
  String get guidePuzzleTapRegion =>
      'Tap the hidden spots to find every target.';

  @override
  String get roomZoomAction => 'Zoom scene';

  @override
  String get roomZoomHint => 'Pinch to zoom · drag to pan';

  @override
  String get roomLabelsShowAction => 'Show object names';

  @override
  String get roomLabelsHideAction => 'Hide object names';

  @override
  String get clueSavedToJournal => 'Saved to your Journal.';
}
