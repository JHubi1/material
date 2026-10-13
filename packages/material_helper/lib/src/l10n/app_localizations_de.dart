// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class MaterialHelperLocalizationsDe extends MaterialHelperLocalizations {
  MaterialHelperLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get copiedToClipboard => 'In Zwischenablage kopiert.';

  @override
  String get unavailableCharacter => '–';

  @override
  String setValue(String value) {
    return '$value setzen';
  }

  @override
  String get themeModeSwitcherDark => 'Dunkel';

  @override
  String get themeModeSwitcherSystem => 'System';

  @override
  String get themeModeSwitcherLight => 'Hell';

  @override
  String get promptDialogActionInvoke => 'Aktion ausführen';

  @override
  String get promptDialogActionClear => 'Leeren';

  @override
  String get promptDialogActionCopy => 'Kopieren';

  @override
  String get aboutScreenTitle => 'Über';

  @override
  String aboutScreenDescription(String appName) {
    return '$appName ist Teil von JHubi1s Material Apps, einer Sammlung einfacher Open-Source-Tools.';
  }

  @override
  String get aboutScreenReferencesHeadline => 'Referenzen';

  @override
  String get aboutScreenReferencesGitHub => 'GitHub';

  @override
  String get aboutScreenReferencesCreateIssue => 'Issue erstellen';

  @override
  String get aboutScreenReferencesCreateIssueSubtitle =>
      'Fehler melden oder Funktionen vorschlagen.';

  @override
  String get aboutScreenReferencesLicenses => 'Lizenzen';

  @override
  String get aboutScreenOtherAppsHeadline => 'Andere Apps';

  @override
  String get aboutTechnicalScreenTitle => 'Technisches';

  @override
  String get aboutTechnicalScreenPackageInfoAppName => 'App-Name';

  @override
  String get aboutTechnicalScreenPackageInfoPackageName => 'Paketname';

  @override
  String get aboutTechnicalScreenPackageInfoVersion => 'Version';

  @override
  String get aboutTechnicalScreenPackageInfoBuildNumber => 'Build-Nummer';

  @override
  String get aboutTechnicalScreenPackageInfoRunningTime => 'Laufzeit';

  @override
  String get aboutTechnicalScreenInstallationHeadline => 'Installation';

  @override
  String get aboutTechnicalScreenInstallationInstallerStore =>
      'Installiert von';

  @override
  String get aboutTechnicalScreenInstallationInstallTime =>
      'Erste Installation';

  @override
  String get aboutTechnicalScreenInstallationUpdateTime =>
      'Letzte Aktualisierung';

  @override
  String get aboutTechnicalScreenGitHeadline => 'Versionsverwaltung';

  @override
  String get aboutTechnicalScreenGitBranch => 'Branch';

  @override
  String get aboutTechnicalScreenGitBranchRevision => 'Revision';

  @override
  String get aboutTechnicalScreenGitLocalChanges => 'Lokale Änderungen';

  @override
  String get aboutTechnicalScreenGitCommit => 'Commit';

  @override
  String get aboutTechnicalScreenGitCommitMessage => 'Nachricht';

  @override
  String get aboutTechnicalScreenGitCommitTimestamp => 'Zeitstempel';

  @override
  String get licensesScreenTitle => 'Lizenzen';

  @override
  String licensesDetailsScreenTitle(String packageName) {
    return 'Lizenzen von „$packageName“';
  }

  @override
  String get settingsScreenTitle => 'Einstellungen';
}
