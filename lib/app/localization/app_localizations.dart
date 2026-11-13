import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Up Escape Mind'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'An escape-room mystery, fully offline.'**
  String get appTagline;

  /// No description provided for @menuContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get menuContinue;

  /// No description provided for @menuNewGame.
  ///
  /// In en, this message translates to:
  /// **'New Game'**
  String get menuNewGame;

  /// No description provided for @menuChapters.
  ///
  /// In en, this message translates to:
  /// **'Chapters'**
  String get menuChapters;

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

  /// No description provided for @menuCredits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get menuCredits;

  /// No description provided for @chaptersTitle.
  ///
  /// In en, this message translates to:
  /// **'Chapters'**
  String get chaptersTitle;

  /// No description provided for @chapterLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get chapterLocked;

  /// No description provided for @chapterAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get chapterAvailable;

  /// No description provided for @chapterInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get chapterInProgress;

  /// No description provided for @chapterCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get chapterCompleted;

  /// No description provided for @noSaveExists.
  ///
  /// In en, this message translates to:
  /// **'No save found. Start a new game to begin.'**
  String get noSaveExists;

  /// No description provided for @newGameConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Start a new game?'**
  String get newGameConfirmTitle;

  /// No description provided for @newGameConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This will replace your existing save.'**
  String get newGameConfirmBody;

  /// No description provided for @journalTitle.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get journalTitle;

  /// No description provided for @journalEmpty.
  ///
  /// In en, this message translates to:
  /// **'No discoveries yet. Clues and notes you find will appear here.'**
  String get journalEmpty;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get settingsMusic;

  /// No description provided for @settingsSoundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get settingsSoundEffects;

  /// No description provided for @settingsHaptics.
  ///
  /// In en, this message translates to:
  /// **'Haptics'**
  String get settingsHaptics;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languageSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystemDefault;

  /// No description provided for @settingsResetProgress.
  ///
  /// In en, this message translates to:
  /// **'Reset progress'**
  String get settingsResetProgress;

  /// No description provided for @resetProgressConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset all progress?'**
  String get resetProgressConfirmTitle;

  /// No description provided for @resetProgressConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your save data. This cannot be undone.'**
  String get resetProgressConfirmBody;

  /// No description provided for @resetProgressDone.
  ///
  /// In en, this message translates to:
  /// **'Progress has been reset.'**
  String get resetProgressDone;

  /// No description provided for @creditsTitle.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get creditsTitle;

  /// No description provided for @creditsBody.
  ///
  /// In en, this message translates to:
  /// **'Up Escape Mind — a single-player offline escape-room adventure.'**
  String get creditsBody;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @roomLockedMessage.
  ///
  /// In en, this message translates to:
  /// **'This area is still locked.'**
  String get roomLockedMessage;

  /// No description provided for @puzzleLockedMessage.
  ///
  /// In en, this message translates to:
  /// **'This puzzle cannot be opened yet.'**
  String get puzzleLockedMessage;

  /// No description provided for @puzzleIncorrectMessage.
  ///
  /// In en, this message translates to:
  /// **'Not quite right. Try again.'**
  String get puzzleIncorrectMessage;

  /// No description provided for @puzzleSolvedMessage.
  ///
  /// In en, this message translates to:
  /// **'Correct! The puzzle is solved.'**
  String get puzzleSolvedMessage;

  /// No description provided for @keypadClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get keypadClear;

  /// No description provided for @keypadDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get keypadDelete;

  /// No description provided for @puzzleCheck.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get puzzleCheck;

  /// No description provided for @puzzleReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get puzzleReset;

  /// No description provided for @leverUp.
  ///
  /// In en, this message translates to:
  /// **'Up'**
  String get leverUp;

  /// No description provided for @leverDown.
  ///
  /// In en, this message translates to:
  /// **'Down'**
  String get leverDown;

  /// No description provided for @observationProgress.
  ///
  /// In en, this message translates to:
  /// **'Found {found} of {total}.'**
  String observationProgress(int found, int total);

  /// No description provided for @hintsAction.
  ///
  /// In en, this message translates to:
  /// **'Hints'**
  String get hintsAction;

  /// No description provided for @hintsTitle.
  ///
  /// In en, this message translates to:
  /// **'Hints'**
  String get hintsTitle;

  /// No description provided for @hintLevelTitle.
  ///
  /// In en, this message translates to:
  /// **'Hint {level}'**
  String hintLevelTitle(int level);

  /// No description provided for @hintNextButton.
  ///
  /// In en, this message translates to:
  /// **'View next hint'**
  String get hintNextButton;

  /// No description provided for @hintWalkthroughConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Show the step-by-step walkthrough?'**
  String get hintWalkthroughConfirmTitle;

  /// No description provided for @hintWalkthroughConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Hint level 3 explains the solution step by step. Your progress is not affected either way.'**
  String get hintWalkthroughConfirmBody;

  /// No description provided for @prereqMissingPuzzle.
  ///
  /// In en, this message translates to:
  /// **'Solve another puzzle first.'**
  String get prereqMissingPuzzle;

  /// No description provided for @prereqMissingItem.
  ///
  /// In en, this message translates to:
  /// **'You still need to find an item.'**
  String get prereqMissingItem;

  /// No description provided for @prereqMissingItemUse.
  ///
  /// In en, this message translates to:
  /// **'You need to use the right item somewhere else first.'**
  String get prereqMissingItemUse;

  /// No description provided for @prereqMissingClue.
  ///
  /// In en, this message translates to:
  /// **'A clue is still missing from your Journal.'**
  String get prereqMissingClue;

  /// No description provided for @prereqMissingArea.
  ///
  /// In en, this message translates to:
  /// **'Another area is still locked.'**
  String get prereqMissingArea;

  /// No description provided for @prereqMissingChapter.
  ///
  /// In en, this message translates to:
  /// **'A chapter must be completed first.'**
  String get prereqMissingChapter;

  /// No description provided for @summaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Chapter complete!'**
  String get summaryTitle;

  /// No description provided for @summaryAreas.
  ///
  /// In en, this message translates to:
  /// **'Areas'**
  String get summaryAreas;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsTitle;

  /// No description provided for @summaryStarsLabel.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get summaryStarsLabel;

  /// No description provided for @starRuleOne.
  ///
  /// In en, this message translates to:
  /// **'Finish the chapter\'s final objective.'**
  String get starRuleOne;

  /// No description provided for @starRuleTwo.
  ///
  /// In en, this message translates to:
  /// **'Solve every puzzle, including optional ones.'**
  String get starRuleTwo;

  /// No description provided for @starRuleThree.
  ///
  /// In en, this message translates to:
  /// **'Discover every clue, note and secret, including optional ones.'**
  String get starRuleThree;

  /// No description provided for @badgeNoWalkthrough.
  ///
  /// In en, this message translates to:
  /// **'No walkthrough used'**
  String get badgeNoWalkthrough;

  /// No description provided for @viewSummary.
  ///
  /// In en, this message translates to:
  /// **'View summary'**
  String get viewSummary;

  /// No description provided for @statChaptersCompleted.
  ///
  /// In en, this message translates to:
  /// **'Chapters completed'**
  String get statChaptersCompleted;

  /// No description provided for @statAreasDiscovered.
  ///
  /// In en, this message translates to:
  /// **'Areas discovered: {found}/{total}'**
  String statAreasDiscovered(int found, int total);

  /// No description provided for @statPuzzlesSolved.
  ///
  /// In en, this message translates to:
  /// **'Puzzles solved: {found}/{total}'**
  String statPuzzlesSolved(int found, int total);

  /// No description provided for @statOptionalCluesFound.
  ///
  /// In en, this message translates to:
  /// **'Optional clues found: {found}/{total}'**
  String statOptionalCluesFound(int found, int total);

  /// No description provided for @statHintsLevel.
  ///
  /// In en, this message translates to:
  /// **'Hints opened, level {level}: {count}'**
  String statHintsLevel(int level, int count);

  /// No description provided for @itemCollectedMessage.
  ///
  /// In en, this message translates to:
  /// **'Picked up {name}.'**
  String itemCollectedMessage(String name);

  /// No description provided for @alreadyHaveItemMessage.
  ///
  /// In en, this message translates to:
  /// **'You already have {name}.'**
  String alreadyHaveItemMessage(String name);

  /// No description provided for @clueDiscoveredMessage.
  ///
  /// In en, this message translates to:
  /// **'New clue in your Journal: {title}.'**
  String clueDiscoveredMessage(String title);

  /// No description provided for @inventoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Satchel'**
  String get inventoryTitle;

  /// No description provided for @inventoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your satchel is empty. Picked-up items will appear here.'**
  String get inventoryEmpty;

  /// No description provided for @itemUseAction.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get itemUseAction;

  /// No description provided for @itemDeselectAction.
  ///
  /// In en, this message translates to:
  /// **'Deselect'**
  String get itemDeselectAction;

  /// No description provided for @itemCombineAction.
  ///
  /// In en, this message translates to:
  /// **'Combine'**
  String get itemCombineAction;

  /// No description provided for @combineExitAction.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get combineExitAction;

  /// No description provided for @combineNeedsSelection.
  ///
  /// In en, this message translates to:
  /// **'Select at least two items to combine.'**
  String get combineNeedsSelection;

  /// No description provided for @invalidItemUseMessage.
  ///
  /// In en, this message translates to:
  /// **'That doesn\'t work here.'**
  String get invalidItemUseMessage;

  /// No description provided for @invalidCombinationMessage.
  ///
  /// In en, this message translates to:
  /// **'These items can\'t be combined.'**
  String get invalidCombinationMessage;

  /// No description provided for @itemUsedMessage.
  ///
  /// In en, this message translates to:
  /// **'You use the {item}.'**
  String itemUsedMessage(String item);

  /// No description provided for @itemUsingHint.
  ///
  /// In en, this message translates to:
  /// **'Using {item} — tap something in the room.'**
  String itemUsingHint(String item);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
