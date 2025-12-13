// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class MaterialHelperLocalizationsEn extends MaterialHelperLocalizations {
  MaterialHelperLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get copiedToClipboard => 'Copied to clipboard.';

  @override
  String get unavailableCharacter => '–';

  @override
  String setValue(String value) {
    return 'Set $value';
  }

  @override
  String get themeModeSwitcherDark => 'Dark';

  @override
  String get themeModeSwitcherSystem => 'System';

  @override
  String get themeModeSwitcherLight => 'Light';

  @override
  String get promptDialogActionInvoke => 'Invoke action';

  @override
  String get promptDialogActionClear => 'Clear';

  @override
  String get promptDialogActionCopy => 'Copy';

  @override
  String get aboutScreenTitle => 'About';

  @override
  String aboutScreenDescription(String appName) {
    return '$appName is part of JHubi1’s Material Apps, a collection of simple, open-source tools.';
  }

  @override
  String get aboutScreenLinksHeadline => 'Links';

  @override
  String get aboutScreenLinksGitHub => 'GitHub';

  @override
  String get aboutScreenLinksCreateIssue => 'Create an Issue';

  @override
  String get aboutScreenLinksCreateIssueSubtitle =>
      'Report a bug or suggest a feature.';

  @override
  String get aboutScreenLinksLicenses => 'Licenses';

  @override
  String get aboutScreenOtherAppsHeadline => 'Other Apps';

  @override
  String get aboutTechnicalScreenTitle => 'Technical Details';

  @override
  String get aboutTechnicalScreenPackageInfoAppName => 'App Name';

  @override
  String get aboutTechnicalScreenPackageInfoPackageName => 'Package Name';

  @override
  String get aboutTechnicalScreenPackageInfoVersion => 'Version';

  @override
  String get aboutTechnicalScreenPackageInfoBuildNumber => 'Build Number';

  @override
  String get aboutTechnicalScreenPackageInfoRunningTime => 'Running Time';

  @override
  String get aboutTechnicalScreenInstallationHeadline => 'Installation';

  @override
  String get aboutTechnicalScreenInstallationInstallerStore => 'App Installer';

  @override
  String get aboutTechnicalScreenInstallationInstallTime => 'First Install';

  @override
  String get aboutTechnicalScreenInstallationUpdateTime => 'Last Update';

  @override
  String get aboutTechnicalScreenGitHeadline => 'Git';

  @override
  String get aboutTechnicalScreenGitBranch => 'Branch';

  @override
  String get aboutTechnicalScreenGitBranchRevision => 'Revision';

  @override
  String get aboutTechnicalScreenGitLocalChanges => 'Local Changes';

  @override
  String get aboutTechnicalScreenGitCommit => 'Commit';

  @override
  String get aboutTechnicalScreenGitCommitMessage => 'Message';

  @override
  String get aboutTechnicalScreenGitCommitTime => 'Time';

  @override
  String get licensesScreenTitle => 'Licenses';

  @override
  String licensesDetailsScreenTitle(String packageName) {
    return 'Licenses of \"$packageName\"';
  }

  @override
  String get settingsScreenTitle => 'Settings';
}
