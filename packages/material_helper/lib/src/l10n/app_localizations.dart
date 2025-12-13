import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of MaterialHelperLocalizations
/// returned by `MaterialHelperLocalizations.of(context)`.
///
/// Applications need to include `MaterialHelperLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: MaterialHelperLocalizations.localizationsDelegates,
///   supportedLocales: MaterialHelperLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the MaterialHelperLocalizations.supportedLocales
/// property.
abstract class MaterialHelperLocalizations {
  MaterialHelperLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static MaterialHelperLocalizations? of(BuildContext context) {
    return Localizations.of<MaterialHelperLocalizations>(
      context,
      MaterialHelperLocalizations,
    );
  }

  static const LocalizationsDelegate<MaterialHelperLocalizations> delegate =
      _MaterialHelperLocalizationsDelegate();

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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// Snackbar message shown when something has been copied to the clipboard
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard.'**
  String get copiedToClipboard;

  /// Character used to indicate that a value is unavailable. Should be unchanged if not totally necessary.
  ///
  /// In en, this message translates to:
  /// **'–'**
  String get unavailableCharacter;

  /// Generic title or label for a set action. This string is in MLA title case
  ///
  /// In en, this message translates to:
  /// **'Set {value}'**
  String setValue(String value);

  /// Description of the dark theme mode switcher
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeModeSwitcherDark;

  /// Description of the system theme mode switcher
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeModeSwitcherSystem;

  /// Description of the light theme mode switcher
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeModeSwitcherLight;

  /// Default label for the action button in a prompt dialog
  ///
  /// In en, this message translates to:
  /// **'Invoke action'**
  String get promptDialogActionInvoke;

  /// Label for the clear action in a prompt dialog
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get promptDialogActionClear;

  /// Label for the copy action in a prompt dialog
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get promptDialogActionCopy;

  /// Title of the about screen. This string is in MLA title case
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutScreenTitle;

  /// Description of the about screen
  ///
  /// In en, this message translates to:
  /// **'{appName} is part of JHubi1’s Material Apps, a collection of simple, open-source tools.'**
  String aboutScreenDescription(String appName);

  /// Headline for the links section in the about screen. This string is in MLA title case
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get aboutScreenLinksHeadline;

  /// Label for the GitHub link in the about screen. This string is in MLA title case
  ///
  /// In en, this message translates to:
  /// **'GitHub'**
  String get aboutScreenLinksGitHub;

  /// Label for the report issue link in the about screen. This string is in MLA title case
  ///
  /// In en, this message translates to:
  /// **'Create an Issue'**
  String get aboutScreenLinksCreateIssue;

  /// Description for the report issue link in the about screen
  ///
  /// In en, this message translates to:
  /// **'Report a bug or suggest a feature.'**
  String get aboutScreenLinksCreateIssueSubtitle;

  /// Label for the licenses link in the about screen. This string is in MLA title case
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get aboutScreenLinksLicenses;

  /// Headline for the other apps section in the about screen. This string is in MLA title case
  ///
  /// In en, this message translates to:
  /// **'Other Apps'**
  String get aboutScreenOtherAppsHeadline;

  /// Title of the technical details screen. This string is in MLA title case
  ///
  /// In en, this message translates to:
  /// **'Technical Details'**
  String get aboutTechnicalScreenTitle;

  /// Label for the app name in the technical details screen. This string is in MLA title case
  ///
  /// In en, this message translates to:
  /// **'App Name'**
  String get aboutTechnicalScreenPackageInfoAppName;

  /// Label for the package name in the technical details screen. This string is in MLA title case
  ///
  /// In en, this message translates to:
  /// **'Package Name'**
  String get aboutTechnicalScreenPackageInfoPackageName;

  /// Label for the version in the technical details screen. This string is in MLA title case
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutTechnicalScreenPackageInfoVersion;

  /// Label for the build number in the technical details screen. This string is in MLA title case
  ///
  /// In en, this message translates to:
  /// **'Build Number'**
  String get aboutTechnicalScreenPackageInfoBuildNumber;

  /// Label for the run time in the technical details screen. This string is in MLA title case
  ///
  /// In en, this message translates to:
  /// **'Running Time'**
  String get aboutTechnicalScreenPackageInfoRunningTime;

  /// Headline for the installation section in the technical details screen. This string is in MLA title case
  ///
  /// In en, this message translates to:
  /// **'Installation'**
  String get aboutTechnicalScreenInstallationHeadline;

  /// Label for the installer store in the technical details screen. This string is in MLA title case
  ///
  /// In en, this message translates to:
  /// **'App Installer'**
  String get aboutTechnicalScreenInstallationInstallerStore;

  /// Label for the install time in the technical details screen. This string is in MLA title case
  ///
  /// In en, this message translates to:
  /// **'First Install'**
  String get aboutTechnicalScreenInstallationInstallTime;

  /// Label for the update time in the technical details screen. This string is in MLA title case
  ///
  /// In en, this message translates to:
  /// **'Last Update'**
  String get aboutTechnicalScreenInstallationUpdateTime;

  /// Headline for the git section in the technical details screen. This string is in MLA title case
  ///
  /// In en, this message translates to:
  /// **'Git'**
  String get aboutTechnicalScreenGitHeadline;

  /// Label for the git branch in the technical details screen. This string is in MLA title case
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get aboutTechnicalScreenGitBranch;

  /// Label for the git branch revision in the technical details screen. This string is in MLA title case
  ///
  /// In en, this message translates to:
  /// **'Revision'**
  String get aboutTechnicalScreenGitBranchRevision;

  /// Label for the local changes in the technical details screen. This string is in MLA title case
  ///
  /// In en, this message translates to:
  /// **'Local Changes'**
  String get aboutTechnicalScreenGitLocalChanges;

  /// Label for the git commit in the technical details screen. This string is in MLA title case
  ///
  /// In en, this message translates to:
  /// **'Commit'**
  String get aboutTechnicalScreenGitCommit;

  /// Label for the git commit message in the technical details screen. This string is in MLA title case
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get aboutTechnicalScreenGitCommitMessage;

  /// Label for the git commit time in the technical details screen. This string is in MLA title case
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get aboutTechnicalScreenGitCommitTime;

  /// Title of the licenses screen. This string is in MLA title case
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licensesScreenTitle;

  /// Title of the license details screen for a specific package. This string is in MLA title case
  ///
  /// In en, this message translates to:
  /// **'Licenses of \"{packageName}\"'**
  String licensesDetailsScreenTitle(String packageName);

  /// Default title of the settings screen. This string is in MLA title case
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsScreenTitle;
}

class _MaterialHelperLocalizationsDelegate
    extends LocalizationsDelegate<MaterialHelperLocalizations> {
  const _MaterialHelperLocalizationsDelegate();

  @override
  Future<MaterialHelperLocalizations> load(Locale locale) {
    return SynchronousFuture<MaterialHelperLocalizations>(
      lookupMaterialHelperLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_MaterialHelperLocalizationsDelegate old) => false;
}

MaterialHelperLocalizations lookupMaterialHelperLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return MaterialHelperLocalizationsEn();
  }

  throw FlutterError(
    'MaterialHelperLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
