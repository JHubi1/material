import 'dart:async';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../material_helper.dart';

SharedPreferencesWithCache? _prefs;
SharedPreferencesWithCache? get prefs => _prefs;

/// The helper class for shared preferences.
///
/// Should be initialized like this in the `initState` method of the state of
/// the widget that holds [ThemedMaterialApp].
///
/// ```dart
/// Preferences.init().then((_) { if (mounted) setState(() {}); });
/// ```
class Preferences {
  static final Completer isReady = Completer();
  static Future<void> init() async {
    SharedPreferencesWithCache.create(
      cacheOptions: SharedPreferencesWithCacheOptions(),
    ).then((value) {
      _prefs = value;
      isReady.complete();
    });
    await isReady.future;
  }
}

class ThemePreferences extends ChangeNotifier {
  static final ThemePreferences _instance = ThemePreferences._();
  static ThemePreferences get instance => _instance;

  ThemePreferences._() {
    if (Preferences.isReady.isCompleted) {
      final themeModeString = prefs?.getString("themeMode");
      if (themeModeString != null) {
        _themeMode = themeModeFromString(themeModeString);
      }
    }
  }

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;
  set themeMode(ThemeMode value) {
    if (value == _themeMode) return;

    _themeMode = value;
    if (Preferences.isReady.isCompleted) {
      prefs
          ?.setString("themeMode", themeModeToString(value))
          .then((_) => notifyListeners());
    } else {
      notifyListeners();
    }
  }

  bool _useSystemColorScheme = true;
  bool get useSystemColorScheme => _useSystemColorScheme;
  set useSystemColorScheme(bool value) {
    if (value == _useSystemColorScheme) return;

    _useSystemColorScheme = value;
    if (Preferences.isReady.isCompleted) {
      prefs
          ?.setBool("useSystemColorScheme", value)
          .then((_) => notifyListeners());
    } else {
      notifyListeners();
    }
  }
}
