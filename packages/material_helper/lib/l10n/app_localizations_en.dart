// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get themeModeSwitcherDark => 'Dark';

  @override
  String get themeModeSwitcherSystem => 'System';

  @override
  String get themeModeSwitcherLight => 'Light';

  @override
  String get promptDialogActionInvoke => 'Invoke action';

  @override
  String get aboutScreenTitle => 'About';

  @override
  String get aboutScreenDescription =>
      'This app is part of JHubi1\'s Material App collection of simple, ad-free, and open-source gadget apps.';

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
}
