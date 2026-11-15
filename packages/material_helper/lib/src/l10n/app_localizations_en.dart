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
  String get confirmationDialogActionContinue => 'Continue';

  @override
  String get promptDialogActionInvoke => 'Invoke action';

  @override
  String get promptDialogActionClear => 'Clear';

  @override
  String get promptDialogActionCopy => 'Copy';

  @override
  String get promptDialogActionToggleObscure => 'Toggle obscure';

  @override
  String get aboutScreenTitle => 'About';

  @override
  String aboutScreenDescription(String appName) {
    return '$appName is part of JHubi1’s Material Apps, a collection of simple, open-source tools.';
  }

  @override
  String get aboutScreenReferencesHeadline => 'References';

  @override
  String get aboutScreenReferencesGitHub => 'GitHub';

  @override
  String get aboutScreenReferencesCreateIssue => 'Create an issue';

  @override
  String get aboutScreenReferencesCreateIssueSubtitle =>
      'Report a bug or suggest a feature.';

  @override
  String get aboutScreenReferencesLicenses => 'Licenses';

  @override
  String get aboutScreenOtherAppsHeadline => 'Other apps';

  @override
  String get aboutTechnicalScreenTitle => 'Technical Details';

  @override
  String get aboutTechnicalScreenPackageInfoAppName => 'App name';

  @override
  String get aboutTechnicalScreenPackageInfoPackageName => 'Package name';

  @override
  String get aboutTechnicalScreenPackageInfoVersion => 'Version';

  @override
  String get aboutTechnicalScreenPackageInfoBuildNumber => 'Build number';

  @override
  String get aboutTechnicalScreenPackageInfoRunningTime => 'Running time';

  @override
  String get aboutTechnicalScreenInstallationHeadline => 'Installation';

  @override
  String get aboutTechnicalScreenInstallationInstallerStore => 'App installer';

  @override
  String get aboutTechnicalScreenInstallationInstallTime => 'First install';

  @override
  String get aboutTechnicalScreenInstallationUpdateTime => 'Last update';

  @override
  String get aboutTechnicalScreenGitHeadline => 'Source control';

  @override
  String get aboutTechnicalScreenGitBranch => 'Branch';

  @override
  String get aboutTechnicalScreenGitBranchRevision => 'Revision';

  @override
  String get aboutTechnicalScreenGitLocalChanges => 'Local changes';

  @override
  String get aboutTechnicalScreenGitCommit => 'Commit';

  @override
  String get aboutTechnicalScreenGitCommitMessage => 'Message';

  @override
  String get aboutTechnicalScreenGitCommitTimestamp => 'Timestamp';

  @override
  String get licensesScreenTitle => 'Licenses';

  @override
  String licensesDetailsScreenTitle(String packageName) {
    return 'Licenses of “$packageName”';
  }

  @override
  String get settingsScreenTitle => 'Settings';
}
