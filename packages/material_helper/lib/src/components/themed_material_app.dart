import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:material_graphics/material_graphics.dart'
    show ModifiedTextTheme;
import 'package:material_graphics/material_graphics.dart' as mg;
import 'package:material_ui/material_ui.dart';

import '../../material_helper.dart';

/// The theme fallback color.
Color materialAppsFallbackColor = Colors.lime;

/// Stopwatch that measures the app's run time.
final Stopwatch runningTime = Stopwatch()..start();

/// Simplified variant of [MaterialApp] that simplifies the theming.
///
/// It integrates the system color scheme automatically and adapts to the device
/// brightness, if not otherwise specified in [themeMode].
///
/// It also automatically listens to changes in [ThemePreferences] and updates
/// the theme accordingly.
class ThemedMaterialApp extends StatefulWidget {
  /// {@macro flutter.widgets.widgetsApp.home}
  final Widget? home;

  /// {@macro flutter.widgets.widgetsApp.title}
  ///
  /// This value is passed unmodified to [MaterialApp.title].
  final String? title;

  /// {@macro flutter.widgets.widgetsApp.onGenerateTitle}
  ///
  /// This value is passed unmodified to [MaterialApp.onGenerateTitle].
  final GenerateAppTitle? onGenerateTitle;

  /// Determines which theme will be used by the application if both [theme]
  /// and [darkTheme] are provided.
  ///
  /// If set to [ThemeMode.system], the choice of which theme to use will
  /// be based on the user's system preferences. If the [MediaQuery.platformBrightnessOf]
  /// is [Brightness.light], [theme] will be used. If it is [Brightness.dark],
  /// [darkTheme] will be used (unless it is null, in which case [theme]
  /// will be used.
  ///
  /// If set to [ThemeMode.light] the [theme] will always be used,
  /// regardless of the user's system preference.
  ///
  /// If set to [ThemeMode.dark] the [darkTheme] will be used
  /// regardless of the user's system preference. If [darkTheme] is null
  /// then it will fallback to using [theme].
  ///
  /// The default value is [ThemeMode.system].
  ///
  /// See also:
  ///
  ///  * [MaterialApp.theme], which is used when a light mode is selected.
  ///  * [MaterialApp.darkTheme], which is used when a dark mode is selected.
  ///  * [ThemeData.brightness], which indicates to various parts of the
  ///    system what kind of theme is being used.
  ///
  /// This value is passed unmodified to [MaterialApp.themeMode].
  final ThemeMode? themeMode;

  /// Whether the system's platform color scheme should be used.
  ///
  /// If set to true, the system's platform color scheme will be determined
  /// and automatically applied to the app. If set to false, the app will
  /// fallback to the default color scheme.
  final bool? useSystemColorScheme;

  /// {@macro flutter.widgets.widgetsApp.locale}
  final Locale? locale;

  /// {@macro flutter.widgets.widgetsApp.localizationsDelegates}
  ///
  /// Internationalized apps that require translations for one of the locales
  /// listed in [GlobalMaterialLocalizations] should specify this parameter
  /// and list the [supportedLocales] that the application can handle.
  ///
  /// ```dart
  /// // The GlobalMaterialLocalizations and GlobalWidgetsLocalizations
  /// // classes require the following import:
  /// // import 'package:flutter_localizations/flutter_localizations.dart';
  ///
  /// const MaterialApp(
  ///   localizationsDelegates: <LocalizationsDelegate<Object>>[
  ///     // ... app-specific localization delegate(s) here
  ///     GlobalMaterialLocalizations.delegate,
  ///     GlobalWidgetsLocalizations.delegate,
  ///   ],
  ///   supportedLocales: <Locale>[
  ///     Locale('en', 'US'), // English
  ///     Locale('he', 'IL'), // Hebrew
  ///     // ... other locales the app supports
  ///   ],
  ///   // ...
  /// )
  /// ```
  ///
  /// ## Adding localizations for a new locale
  ///
  /// The information that follows applies to the unusual case of an app
  /// adding translations for a language not already supported by
  /// [GlobalMaterialLocalizations].
  ///
  /// Delegates that produce [WidgetsLocalizations] and [MaterialLocalizations]
  /// are included automatically. Apps can provide their own versions of these
  /// localizations by creating implementations of
  /// [LocalizationsDelegate<WidgetsLocalizations>] or
  /// [LocalizationsDelegate<MaterialLocalizations>] whose load methods return
  /// custom versions of [WidgetsLocalizations] or [MaterialLocalizations].
  ///
  /// For example: to add support to [MaterialLocalizations] for a locale it
  /// doesn't already support, say `const Locale('foo', 'BR')`, one first
  /// creates a subclass of [MaterialLocalizations] that provides the
  /// translations:
  ///
  /// ```dart
  /// class FooLocalizations extends MaterialLocalizations {
  ///   FooLocalizations();
  ///   @override
  ///   String get okButtonLabel => 'foo';
  ///   // ...
  ///   // lots of other getters and methods to override!
  /// }
  /// ```
  ///
  /// One must then create a [LocalizationsDelegate] subclass that can provide
  /// an instance of the [MaterialLocalizations] subclass. In this case, this is
  /// essentially just a method that constructs a `FooLocalizations` object. A
  /// [SynchronousFuture] is used here because no asynchronous work takes place
  /// upon "loading" the localizations object.
  ///
  /// ```dart
  /// // continuing from previous example...
  /// class FooLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  ///   const FooLocalizationsDelegate();
  ///   @override
  ///   bool isSupported(Locale locale) {
  ///     return locale == const Locale('foo', 'BR');
  ///   }
  ///   @override
  ///   Future<FooLocalizations> load(Locale locale) {
  ///     assert(locale == const Locale('foo', 'BR'));
  ///     return SynchronousFuture<FooLocalizations>(FooLocalizations());
  ///   }
  ///   @override
  ///   bool shouldReload(FooLocalizationsDelegate old) => false;
  /// }
  /// ```
  ///
  /// Constructing a [MaterialApp] with a `FooLocalizationsDelegate` overrides
  /// the automatically included delegate for [MaterialLocalizations] because
  /// only the first delegate of each [LocalizationsDelegate.type] is used and
  /// the automatically included delegates are added to the end of the app's
  /// [localizationsDelegates] list.
  ///
  /// ```dart
  /// // continuing from previous example...
  /// const MaterialApp(
  ///   localizationsDelegates: <LocalizationsDelegate<Object>>[
  ///     FooLocalizationsDelegate(),
  ///   ],
  ///   // ...
  /// )
  /// ```
  /// See also:
  ///
  ///  * [supportedLocales], which must be specified along with
  ///    [localizationsDelegates].
  ///  * [GlobalMaterialLocalizations], a [localizationsDelegates] value
  ///    which provides material localizations for many languages.
  ///  * The Flutter Internationalization Tutorial,
  ///    <https://flutter.dev/to/internationalization/>.
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;

  /// {@macro flutter.widgets.widgetsApp.localeListResolutionCallback}
  ///
  /// This callback is passed along to the [WidgetsApp] built by this widget.
  final LocaleListResolutionCallback? localeListResolutionCallback;

  /// {@macro flutter.widgets.LocaleResolutionCallback}
  ///
  /// This callback is passed along to the [WidgetsApp] built by this widget.
  final LocaleResolutionCallback? localeResolutionCallback;

  /// {@macro flutter.widgets.widgetsApp.supportedLocales}
  ///
  /// It is passed along unmodified to the [WidgetsApp] built by this widget.
  ///
  /// See also:
  ///
  ///  * [localizationsDelegates], which must be specified for localized
  ///    applications.
  ///  * [GlobalMaterialLocalizations], a [localizationsDelegates] value
  ///    which provides material localizations for many languages.
  ///  * [MaterialHelperLocalizations], a [localizationsDelegates] value
  ///    which provides material helper localizations for many languages.
  ///  * The Flutter Internationalization Tutorial,
  ///    <https://flutter.dev/to/internationalization/>.
  final Iterable<Locale> supportedLocales;

  /// Turns on a performance overlay.
  ///
  /// See also:
  ///
  ///  * <https://flutter.dev/to/performance-overlay>
  final bool showPerformanceOverlay;

  /// Turns on an overlay that shows the accessibility information
  /// reported by the framework.
  final bool showSemanticsDebugger;

  /// {@macro flutter.widgets.widgetsApp.debugShowCheckedModeBanner}
  final bool debugShowCheckedModeBanner;

  /// {@macro flutter.widgets.widgetsApp.shortcuts}
  /// {@tool snippet}
  /// This example shows how to add a single shortcut for
  /// [LogicalKeyboardKey.select] to the default shortcuts without needing to
  /// add your own [Shortcuts] widget.
  ///
  /// Alternatively, you could insert a [Shortcuts] widget with just the mapping
  /// you want to add between the [WidgetsApp] and its child and get the same
  /// effect.
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   return WidgetsApp(
  ///     shortcuts: <ShortcutActivator, Intent>{
  ///       ... WidgetsApp.defaultShortcuts,
  ///       const SingleActivator(LogicalKeyboardKey.select): const ActivateIntent(),
  ///     },
  ///     color: const Color(0xFFFF0000),
  ///     builder: (BuildContext context, Widget? child) {
  ///       return const Placeholder();
  ///     },
  ///   );
  /// }
  /// ```
  /// {@end-tool}
  /// {@macro flutter.widgets.widgetsApp.shortcuts.seeAlso}
  final Map<ShortcutActivator, Intent>? shortcuts;

  /// {@macro flutter.widgets.widgetsApp.actions}
  /// {@tool snippet}
  /// This example shows how to add a single action handling an
  /// [ActivateAction] to the default actions without needing to
  /// add your own [Actions] widget.
  ///
  /// Alternatively, you could insert a [Actions] widget with just the mapping
  /// you want to add between the [WidgetsApp] and its child and get the same
  /// effect.
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   return WidgetsApp(
  ///     actions: <Type, Action<Intent>>{
  ///       ... WidgetsApp.defaultActions,
  ///       ActivateAction: CallbackAction<Intent>(
  ///         onInvoke: (Intent intent) {
  ///           // Do something here...
  ///           return null;
  ///         },
  ///       ),
  ///     },
  ///     color: const Color(0xFFFF0000),
  ///     builder: (BuildContext context, Widget? child) {
  ///       return const Placeholder();
  ///     },
  ///   );
  /// }
  /// ```
  /// {@end-tool}
  /// {@macro flutter.widgets.widgetsApp.actions.seeAlso}
  final Map<Type, Action<Intent>>? actions;

  const ThemedMaterialApp({
    super.key,
    this.home,
    required this.title,
    this.onGenerateTitle,
    this.themeMode,
    this.useSystemColorScheme,
    this.locale,
    this.localizationsDelegates,
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.supportedLocales = const <Locale>[Locale("en", "US")],
    this.showPerformanceOverlay = false,
    this.showSemanticsDebugger = false,
    this.debugShowCheckedModeBanner = true,
    this.shortcuts,
    this.actions,
  });

  @override
  State<ThemedMaterialApp> createState() => _ThemedMaterialAppState();
}

class _ThemedMaterialAppState extends State<ThemedMaterialApp> {
  @override
  void initState() {
    super.initState();
    ThemePreferences.instance.addListener(onUpdate);
    runningTime.start();
    mg.registerLicenses(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(const AssetImage("assets/icon/icon.png"), context);
      precacheImage(const AssetImage("assets/icon/iconDark.png"), context);
    });
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
    final themeMode = widget.themeMode ?? ThemePreferences.instance.themeMode;
    final useSystemColorScheme =
        widget.useSystemColorScheme ??
        ThemePreferences.instance.useSystemColorScheme;
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          home: widget.home,
          title: widget.title,
          onGenerateTitle: widget.onGenerateTitle,
          themeMode: themeMode,
          color: (themeMode == ThemeMode.system)
              ? (MediaQuery.platformBrightnessOf(context) == Brightness.light)
                    ? lightDynamic?.primary
                    : darkDynamic?.primary
              : (themeMode == ThemeMode.light)
              ? lightDynamic?.primary
              : darkDynamic?.primary,
          theme: _themeOverride(
            (useSystemColorScheme && lightDynamic != null)
                ? ThemeData.from(
                    colorScheme: _colorSchemeOverride(lightDynamic),
                  )
                : ThemeData.from(
                    colorScheme: _colorSchemeOverride(
                      ColorScheme.fromSeed(
                        seedColor: materialAppsFallbackColor,
                      ),
                    ),
                  ),
          ),
          darkTheme: _themeOverride(
            (useSystemColorScheme && darkDynamic != null)
                ? ThemeData.from(colorScheme: _colorSchemeOverride(darkDynamic))
                : ThemeData.from(
                    colorScheme: _colorSchemeOverride(
                      ColorScheme.fromSeed(
                        seedColor: materialAppsFallbackColor,
                        brightness: Brightness.dark,
                      ),
                    ),
                  ),
          ),
          locale: widget.locale,
          localizationsDelegates: widget.localizationsDelegates,
          localeListResolutionCallback: widget.localeListResolutionCallback,
          localeResolutionCallback: widget.localeResolutionCallback,
          supportedLocales: widget.supportedLocales,
          showPerformanceOverlay: widget.showPerformanceOverlay,
          showSemanticsDebugger: widget.showSemanticsDebugger,
        );
      },
    );
  }

  ColorScheme _colorSchemeOverride(ColorScheme scheme) {
    return scheme.copyWith(
      surface: scheme.brightness == Brightness.light
          ? scheme.surfaceContainerHigh
          // : scheme.surfaceContainerLow,
          : null,
    );
  }

  ThemeData _themeOverride(ThemeData data) {
    return data.copyWith(
      textTheme: data.textTheme.material,
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      ),
      progressIndicatorTheme: data.progressIndicatorTheme.copyWith(
        year2023: false,
      ),
      sliderTheme: data.sliderTheme.copyWith(year2023: false),
      switchTheme: data.switchTheme.copyWith(
        thumbIcon: WidgetStateMapper({
          WidgetState.selected: const Icon(Icons.check),
          WidgetState.any: const Icon(Icons.close),
        }),
      ),
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        },
      ),
    );
  }
}
