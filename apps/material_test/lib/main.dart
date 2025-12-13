import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:material_graphics/material_graphics.dart';
import 'package:material_helper/material_helper.dart';

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

    Preferences.init().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) =>
      ThemedMaterialApp(title: "Material Test", home: ScreenMain());
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

  @override
  void initState() {
    super.initState();
    _counterTimer = Timer.periodic(Duration(seconds: 1), (_) {
      _counterCounter += _counterCounterMultiplier;
      if (_counterCounter >= 10 || _counterCounter <= 0) {
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
      appBar: AppBar(title: Text("Test")),
      body: ListView(
        children: [
          ListTile(title: ThemeModeSwitcher()),
          MaterialListTile(
            title: Padding(
              padding: EdgeInsetsGeometry.symmetric(vertical: 16),
              child: TallyCounter(count: _counterCounter, size: 32),
            ),
          ),

          TextButton(
            onPressed: () {
              showAboutScreen(context);
            },
            child: Text("About"),
          ),
          TextButton(
            onPressed: () => showIconComposer(context),
            child: Text("Icon Composer"),
          ),
          TextButton(
            onPressed: () {
              int counter = 0;
              bool test = false;
              void setTest(bool value) {
                test = value;
                counter++;
              }

              String? gender;
              FavoriteColor? favoriteColor;

              SettingsConfig other() => SettingsConfig(
                title: "Others",
                sections: [
                  SettingsSection(
                    headline: "Test",
                    options: [
                      SwitchSettingsOption(
                        title: "Test Switch 2",
                        value: test,
                        onChanged: (value) => setTest(value),
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
                          title: "Test Switch",
                          value: test,
                          onChanged: (value) => setTest(value),
                        ),
                        SplitSwitchSettingsOption(
                          title: "Others $counter",
                          subtitle: "More Options",
                          value: test,
                          newScreen: other,
                          onChanged: (value) => setTest(value),
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
                          title: "Favorite Color",
                          value: favoriteColor,
                          items: FavoriteColor.values,
                          onChanged: (value) => favoriteColor = value,
                          subtitleGenerator: (item) => item.feeling,
                          iconGenerator: (item) => Container(
                            width: 24,
                            height: 24,
                            decoration: ShapeDecoration(
                              color: item.color,
                              shape:
                                  MaterialShapes.containers[(Random(
                                            item.name.hashCode,
                                          ).nextDouble() *
                                          MaterialShapes.containers.length)
                                      .floor()],
                            ),
                          ),
                          allowEmpty: true,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
            child: Text("Settings Test"),
          ),
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
