import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/app_localizations_en.dart';
import 'preferences.dart';

/// A switcher for the theme mode.
///
/// Normally, both [themeMode] and [onChanged] do not need to be provided, as
/// the switcher will then use the values from [ThemePreferences].
class ThemeModeSwitcher extends StatefulWidget {
  /// The current theme mode.
  final ThemeMode? themeMode;

  /// Called when the user selects a theme mode.
  final ValueChanged<ThemeMode>? onChanged;

  const ThemeModeSwitcher({super.key, this.themeMode, this.onChanged});

  @override
  State<ThemeModeSwitcher> createState() => _ThemeModeSwitcherState();
}

class _ThemeModeSwitcherState extends State<ThemeModeSwitcher> {
  @override
  void initState() {
    super.initState();
    ThemePreferences.instance.addListener(onUpdate);
  }

  @override
  void dispose() {
    ThemePreferences.instance.removeListener(onUpdate);
    super.dispose();
  }

  void onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final localizations =
        MaterialHelperLocalizations.of(context) ??
        MaterialHelperLocalizationsEn();
    return SegmentedButton(
      segments: [
        ButtonSegment(
          value: "dark",
          icon: Icon(Icons.dark_mode_rounded),
          label: Text(
            localizations.themeModeSwitcherDark,
            maxLines: 1,
            overflow: TextOverflow.fade,
          ),
        ),
        ButtonSegment(
          value: "system",
          icon: Icon(Icons.smartphone_rounded),
          label: Text(
            localizations.themeModeSwitcherSystem,
            maxLines: 1,
            overflow: TextOverflow.fade,
          ),
        ),
        ButtonSegment(
          value: "light",
          icon: Icon(Icons.light_mode_rounded),
          label: Text(
            localizations.themeModeSwitcherLight,
            maxLines: 1,
            overflow: TextOverflow.fade,
          ),
        ),
      ],
      selected: {
        (widget.themeMode ?? ThemePreferences.instance.themeMode).name,
      },
      onSelectionChanged: (value) {
        var themeMode = themeModeFromString(value.first);
        if (widget.onChanged != null) {
          widget.onChanged!.call(themeMode);
        } else {
          ThemePreferences.instance.themeMode = themeMode;
        }
      },
    );
  }
}

ThemeMode themeModeFromString(String? value) {
  return switch (value) {
    "dark" => ThemeMode.dark,
    "system" => ThemeMode.system,
    "light" => ThemeMode.light,
    _ => ThemeMode.system,
  };
}

String themeModeToString(ThemeMode value) {
  return switch (value) {
    ThemeMode.dark => "dark",
    ThemeMode.system => "system",
    ThemeMode.light => "light",
  };
}
