import 'dart:async';
import 'dart:math';

import 'package:material_graphics/material_graphics.dart';
// Intended usage
// ignore: implementation_imports
import 'package:material_graphics/src/shapes/demo.dart' as shapes_demo;
import 'package:material_helper/material_helper.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  runApp(const AppMain());
}

class AppMain extends StatefulWidget {
  const AppMain({super.key});

  @override
  State<AppMain> createState() => _AppMainState();
}

class _AppMainState extends State<AppMain> {
  @override
  void initState() {
    super.initState();

    materialAppsFallbackColor = Colors.cyanAccent;
    Preferences.init().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) => ThemedMaterialApp(
    title: "Material Test",
    // useSystemColorScheme: false,
    localizationsDelegates: [
      MaterialHelperLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    supportedLocales: [Locale("de"), Locale("en")],
    home: ScreenMain(),
  );
}

class ScreenMain extends StatefulWidget {
  const ScreenMain({super.key});

  @override
  State<ScreenMain> createState() => _ScreenMainState();
}

class _ScreenMainState extends State<ScreenMain> with TickerProviderStateMixin {
  late final Timer _counterTimer;
  int _counterCounter = 0;
  int _counterCounterMultiplier = 1;

  bool buttonToggled = false;

  bool loadingIsLoading = false;
  Future<void> loadingFuture = Future.value();

  @override
  void initState() {
    super.initState();
    _counterTimer = Timer.periodic(Duration(milliseconds: 500), (_) {
      _counterCounter += _counterCounterMultiplier;
      if (_counterCounter >= 55 || _counterCounter <= 0) {
        _counterCounterMultiplier *= -1;
      }
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _counterTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Material Test")),
      body: ListView(
        children: [
          ...MaterialListTile.group([
            MaterialListTile(title: TickTock()),
            MaterialListTile(title: ThemeModeSwitcher()),
            MaterialListTile(
              title: Padding(
                padding: EdgeInsetsGeometry.symmetric(vertical: 16),
                child: TallyCounter(count: _counterCounter),
              ),
            ),
          ]),
          MaterialListTile(
            title: Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MaterialLoadingIndicator(),
                  MaterialLoadingIndicator(
                    style: MaterialLoadingIndicatorStyle.contained,
                  ),
                ],
              ),
            ),
          ),

          ...MaterialListTile.group(
            headline: MaterialListTileHeadline(Text("Demonstration options")),
            [
              MaterialListTile(
                leading: Icon(Icons.info_outline),
                title: Text("About screen"),
                onTap: () => showAboutScreen(context),
              ),
              MaterialListTile(
                leading: Icon(Icons.palette_outlined),
                title: Text("Icon composer"),
                onTap: () => showIconComposer(context),
              ),
              MaterialListTile(
                leading: Icon(Icons.text_snippet_outlined),
                title: Text("Text dialog test"),
                onTap: () {
                  showInfoDialog(
                    context: context,
                    title: "Test information",
                    content: Text(
                      ("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec a diam lectus. Sed sit amet ipsum mauris. Maecenas congue ligula ac quam viverra nec consectetur ante hendrerit. Donec et mollis dolor. Praesent et diam eget libero egestas mattis sit amet vitae augue.\n" *
                              20)
                          .trim(),
                    ),
                  );
                },
              ),
              MaterialListTile(
                leading: Icon(Icons.list_outlined),
                title: Text("List tile in dialog test"),
                onTap: () {
                  showInfoDialog(
                    context: context,
                    title: "Test information",
                    contentPadding: EdgeInsets.zero,
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        40,
                        (i) => MaterialListTile(
                          leading: Text(
                            (i + 1).withLeadingZeros(2),
                            style: TextTheme.of(
                              context,
                            ).labelLarge!.bagelFatOne.copyWith(fontSize: 24),
                          ),
                          title: Text("This is item #${i + 1}"),
                          subtitle: Text("Isn’t the number beautiful?"),
                          backgroundStyle:
                              MaterialListTileBackgroundStyle.lightened,
                        ),
                      ),
                    ),
                  );
                },
              ),
              MaterialListTile(
                leading: Icon(Icons.settings_outlined),
                title: Text("Settings test"),
                onTap: () {
                  var counter = 0;
                  var test = false;
                  void setTest(bool value) {
                    test = value;
                    counter++;
                  }

                  String? gender;
                  FavoriteColor? favoriteColor;
                  final favoriteColors = <FavoriteActivity>[];

                  SettingsConfig other() => SettingsConfig(
                    title: "Others",
                    sections: [
                      SettingsSection(
                        headline: "Test",
                        options: [
                          SwitchSettingsOption(
                            title: "Test switch 2",
                            value: test,
                            onChanged: setTest,
                          ),
                        ],
                      ),
                    ],
                  );
                  showSettingsScreen(
                    context,
                    config: () => SettingsConfig(
                      description: "Hello World!",
                      sections: [
                        SettingsSection(
                          headline: "Test",
                          options: [
                            SwitchSettingsOption(
                              title: "Test switch",
                              value: test,
                              onChanged: setTest,
                            ),
                            SplitSwitchSettingsOption(
                              title: "Others $counter",
                              subtitle: "More Options",
                              value: test,
                              newScreen: other,
                              onChanged: setTest,
                            ),
                          ],
                        ),
                        SettingsSection(
                          options: [
                            NavigationSettingsOption(
                              title: "Another other",
                              newScreen: other,
                            ),
                          ],
                        ),
                        SettingsSection(
                          options: [
                            InputSettingsOption(
                              title: "Gender",
                              dialogTitle: "Set Gender",
                              value: gender,
                              onChanged: (value) => gender = value,
                            ),
                            NumInputSettingsOption<int>(
                              title: "Counter",
                              dialogTitle: "Change Counter",
                              value: counter,
                              onChanged: (value) => counter = value,
                            ),
                          ],
                        ),

                        SettingsSection(
                          headline: "",
                          options: [
                            CustomSettingsOption(
                              title: "Spaced away section",
                              titleStyle: MaterialListTileTitleStyle.text,
                            ),
                            RadioSettingsOption(
                              title: "Favorite color",
                              dialogSubtitle: "Choose your favorite color",
                              value: favoriteColor,
                              items: FavoriteColor.values,
                              onChanged: (value) => favoriteColor = value,
                              subtitleGenerator: (item) => item.feeling,
                              iconGenerator: (item) => Container(
                                width: 24,
                                height: 24,
                                decoration: ShapeDecoration(
                                  color: item.color,
                                  shape: MaterialShapesCollections
                                      .containers[(Random(
                                                item.name.hashCode,
                                              ).nextDouble() *
                                              MaterialShapesCollections
                                                  .containers
                                                  .length)
                                          .floor()]
                                      .toShapeBorder(),
                                ),
                              ),
                              allowEmpty: true,
                            ),
                            CheckSettingsOption<FavoriteActivity>(
                              title: "Favorite activities",
                              dialogSubtitle: "Choose your favorite activities",
                              value: favoriteColors,
                              items: FavoriteActivity.values,
                              onChanged: (value) => favoriteColors
                                ..clear()
                                ..addAll(value),
                              subtitleGenerator: (item) => item.description,
                              iconGenerator: (item) => Icon(item.icon),
                              allowEmpty: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              MaterialListTile(
                leading: Icon(Icons.keyboard_outlined),
                title: Text("GBoard settings test"),
                onTap: () {
                  showSettingsScreen(
                    context,
                    config: () => SettingsConfig(
                      title: "Einstellungen",
                      expandAppBar: true,
                      sections: [
                        SettingsSection(
                          options: [
                            CheckSettingsOption(
                              icon: Icon(Icons.language_outlined),
                              title: "Sprachen",
                              value: [
                                "Deutsch (Deutschland) (Deutsch)",
                                "Deutsch (Deutschland) (Handschrift)",
                                "English (US) …",
                              ],
                              items: [
                                "Deutsch (Deutschland) (Deutsch)",
                                "Deutsch (Deutschland) (Handschrift)",
                                "English (US) …",
                              ],
                              onChanged: (_) {},
                            ),
                            NavigationSettingsOption(
                              icon: Icon(Icons.tune_rounded),
                              title: "Einstellungen",
                              newScreen: SettingsConfig.new,
                            ),
                            NavigationSettingsOption(
                              icon: Icon(Icons.palette_rounded),
                              title: "Design",
                              newScreen: SettingsConfig.new,
                            ),
                          ],
                        ),
                        SettingsSection(
                          headline: "",
                          options: [
                            NavigationSettingsOption(
                              icon: Icon(Icons.spellcheck_rounded),
                              title: "Korrekturen & Vorschläge",
                              newScreen: SettingsConfig.new,
                            ),
                            NavigationSettingsOption(
                              icon: Icon(Icons.gesture_rounded),
                              title: "Glide Typing",
                              newScreen: SettingsConfig.new,
                            ),
                            NavigationSettingsOption(
                              icon: Icon(Icons.mic_rounded),
                              title: "Spracheingabe",
                              newScreen: SettingsConfig.new,
                            ),
                            NavigationSettingsOption(
                              icon: Icon(Icons.emoji_emotions_outlined),
                              title: "Emojis, Sticker & GIFs",
                              newScreen: SettingsConfig.new,
                            ),
                          ],
                        ),
                        SettingsSection(
                          headline: "",
                          options: [
                            NavigationSettingsOption(
                              icon: Icon(Icons.assignment_rounded),
                              title: "Zwischenablage",
                              newScreen: SettingsConfig.new,
                            ),
                            NavigationSettingsOption(
                              icon: Icon(Icons.menu_book_outlined),
                              title: "Wörterbuch",
                              newScreen: SettingsConfig.new,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              MaterialListTile(
                leading: Icon(Icons.refresh),
                title: Text("Loading widget test"),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => StatefulBuilder(
                      builder: (context, setState) {
                        Future<void> delayedFuture() =>
                            Future.delayed(Durations.extralong4).then((_) {
                              loadingIsLoading = false;
                              if (context.mounted) setState(() {});
                            });
                        return Scaffold(
                          appBar: AppBar(title: Text("Downloads")),
                          body: MaterialFutureLoadedWidget(
                            future: loadingFuture,
                            builder: (context, value) => Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset("assets/tile.png", width: 128),
                                  SizedBox(height: 8),
                                  Text(
                                    "Fertig",
                                    style: TextTheme.of(context).bodyLarge,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "All deine Apps sind auf dem aktuellen Stand",
                                    style: TextTheme.of(context).bodySmall,
                                  ),
                                  SizedBox(height: 32),
                                  FilledButton(
                                    onPressed: () {
                                      if (loadingIsLoading) return;
                                      loadingIsLoading = true;
                                      loadingFuture = delayedFuture();
                                      setState(() {});
                                    },
                                    child: Text("Nach Updates suchen"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              MaterialListTile(
                leading: Icon(Icons.shape_line_outlined),
                title: Text("MaterialShapes"),
                onTap: () => shapes_demo.showShapeDemoDialog(context),
              ),
            ],
          ),
          MaterialListTileBottomSpacer(),
        ],
      ),
    );
  }
}

enum FavoriteColor {
  red(Colors.red, "Fiery and determined"),
  green(Colors.green, "Calm and full of growth"),
  blue(Colors.blue, "Serene and trustworthy"),
  pink(Colors.pink, "Playful and affectionate"),
  purple(Colors.purple, "Mysterious and regal"),
  yellow(Colors.yellow, "Sunny and optimistic"),
  silver(Colors.grey, "Sleek, modern neutrality"),
  beige(Colors.brown, "Warm, understated comfort"),
  urgh(Colors.teal, "Quirky and refreshingly odd"),
  wow(Colors.amber, "Bright energy with golden warmth"),
  newton(Colors.indigo, "Deep, thoughtful clarity"),
  believer(Colors.cyan, "Hopeful and uplifting"),
  coral(Colors.deepOrange, "Warm coral — lively and inviting"),
  mint(Colors.lightGreen, "Fresh, cool, and rejuvenating"),
  lavender(Colors.purpleAccent, "Soft, dreamy, and calming"),
  charcoal(Colors.blueGrey, "Solid, modern, and dependable"),
  olive(Colors.lime, "Earthy with a hint of vitality"),
  maroon(Colors.deepPurple, "Rich, thoughtful and grounded"),
  lime(Colors.limeAccent, "Zesty, energetic and bright"),
  sky(Colors.lightBlue, "Open, airy, and uplifting"),
  peach(Colors.orangeAccent, "Gentle warmth with soft sweetness"),
  slate(Colors.grey, "Neutral, balanced, and composed"),
  pearl(Colors.white70, "Clean, pure, and understated"),
  obsidian(Colors.black87, "Bold, strong, and elegant");

  final Color color;
  final String feeling;
  const FavoriteColor(this.color, this.feeling);
}

enum FavoriteActivity {
  reading(Icons.book, "Getting lost in stories and knowledge"),
  gaming(Icons.videogame_asset, "Immersing in virtual worlds and challenges"),
  cooking(Icons.restaurant, "Eating and creating delicious taste experiences"),
  hiking(Icons.terrain, "Exploring nature and enjoying the outdoors"),
  painting(Icons.brush, "Expressing creativity through colors and strokes"),
  music(Icons.music_note, "Listening to and creating melodies"),
  photography(Icons.camera_alt, "Capturing moments and memories"),
  swimming(Icons.pool, "Gliding through water with freedom"),
  cycling(Icons.directions_bike, "Pedaling through scenic routes"),
  yoga(Icons.self_improvement, "Finding inner peace and balance"),
  gardening(Icons.local_florist, "Nurturing plants and watching them grow"),
  writing(Icons.edit, "Putting thoughts and stories into words"),
  dancing(Icons.nightlife, "Moving to the rhythm and expressing joy"),
  traveling(Icons.flight, "Discovering new places and cultures"),
  movies(Icons.movie, "Enjoying cinematic stories and experiences"),
  crafting(Icons.handyman, "Building and creating with your hands"),
  running(Icons.directions_run, "Feeling the wind while staying fit"),
  meditation(Icons.spa, "Clearing the mind and finding calm"),
  coding(Icons.code, "Building digital solutions and apps"),
  astronomy(Icons.star, "Gazing at stars and exploring the cosmos"),
  baking(Icons.cake, "Creating sweet treats and desserts"),
  fishing(Icons.phishing, "Patiently waiting for the perfect catch"),
  sketching(Icons.draw, "Quick artistic expressions on paper"),
  podcasts(Icons.podcasts, "Learning and entertaining through audio");

  final IconData icon;
  final String description;
  const FavoriteActivity(this.icon, this.description);
}

class TickTock extends StatefulWidget {
  const TickTock({super.key});

  @override
  State<TickTock> createState() => _TickTockState();
}

class _TickTockState extends State<TickTock> with TickerProviderStateMixin {
  DateTime? _dateTime;

  late final Timer _timer;
  late final AnimationController _controllerSeconds;
  late final AnimationController _controllerMinutes;
  late final AnimationController _controllerHours;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(milliseconds: 10), (_) => onTick());
    _controllerSeconds = AnimationController(
      vsync: this,
      duration: Durations.short3,
    );
    _controllerMinutes = AnimationController(
      vsync: this,
      duration: Durations.short3,
    );
    _controllerHours = AnimationController(
      vsync: this,
      duration: Durations.short3,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  void onTick() {
    final dateTime = DateTime.now();
    if (dateTime.second != _dateTime?.second) {
      _controllerSeconds
          .forward(from: 0)
          .then((_) => _controllerSeconds.reverse());
      if (dateTime.minute != _dateTime?.minute) {
        _controllerMinutes
            .forward(from: 0)
            .then((_) => _controllerMinutes.reverse());
      }
      if (dateTime.hour != _dateTime?.hour) {
        _controllerHours
            .forward(from: 0)
            .then((_) => _controllerHours.reverse());
      }
      _dateTime = dateTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final animationHours = CurvedAnimation(
      parent: _controllerHours,
      curve: Curves.easeInOutCubic,
    );
    final animationMinutes = CurvedAnimation(
      parent: _controllerMinutes,
      curve: Curves.easeInOutCubic,
    );
    final animationSeconds = CurvedAnimation(
      parent: _controllerSeconds,
      curve: Curves.easeInOutCubic,
    );

    return AnimatedBuilder(
      animation: Listenable.merge([
        _controllerSeconds,
        _controllerMinutes,
        _controllerHours,
      ]),
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 67.9,
            child: Text(
              _dateTime?.hour.withLeadingZeros(2) ?? "–",
              textAlign: TextAlign.center,
              style: textTheme.displayLarge!
                  .copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: -3,
                    fontVariations: [
                      ...textTheme.displayLarge!.fontVariations!,
                      FontVariation("wght", 500),
                      FontVariation(
                        "GRAD",
                        Tween<double>(
                          begin: -1000,
                          end: 1000,
                        ).evaluate(animationHours),
                      ),
                      FontVariation(
                        "wdth",
                        Tween<double>(
                          begin: 100,
                          end: 90,
                        ).evaluate(animationHours),
                      ),
                    ],
                    fontFeatures: [FontFeature.tabularFigures()],
                  )
                  .rounded,
            ),
          ),
          Transform.translate(
            offset: Offset(1, -4),
            child: Text(
              " : ",
              style: textTheme.displayLarge!
                  .copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: -6,
                  )
                  .rounded,
            ),
          ),
          SizedBox(
            width: 67.9,
            child: Text(
              _dateTime?.minute.withLeadingZeros(2) ?? "–",
              textAlign: TextAlign.center,
              style: textTheme.displayLarge!
                  .copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: -3,
                    fontVariations: [
                      ...textTheme.displayLarge!.fontVariations!,
                      FontVariation("wght", 500),
                      FontVariation(
                        "GRAD",
                        Tween<double>(
                          begin: -1000,
                          end: 1000,
                        ).evaluate(animationMinutes),
                      ),
                      FontVariation(
                        "wdth",
                        Tween<double>(
                          begin: 100,
                          end: 90,
                        ).evaluate(animationMinutes),
                      ),
                    ],
                    fontFeatures: [FontFeature.tabularFigures()],
                  )
                  .rounded,
            ),
          ),
          Transform.translate(
            offset: Offset(1, -4),
            child: Text(
              " : ",
              style: textTheme.displayLarge!
                  .copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: -6,
                  )
                  .rounded,
            ),
          ),
          SizedBox(
            width: 67.9,
            child: Text(
              _dateTime?.second.withLeadingZeros(2) ?? "–",
              textAlign: TextAlign.center,
              style: textTheme.displayLarge!
                  .copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: -3,
                    fontVariations: [
                      ...textTheme.displayLarge!.fontVariations!,
                      FontVariation("wght", 500),
                      FontVariation(
                        "GRAD",
                        Tween<double>(
                          begin: -1000,
                          end: 1000,
                        ).evaluate(animationSeconds),
                      ),
                      FontVariation(
                        "wdth",
                        Tween<double>(
                          begin: 100,
                          end: 90,
                        ).evaluate(animationSeconds),
                      ),
                    ],
                    fontFeatures: [FontFeature.tabularFigures()],
                  )
                  .rounded,
            ),
          ),
        ],
      ),
    );
  }
}
