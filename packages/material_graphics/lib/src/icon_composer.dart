import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:material_helper/material_helper.dart';
import 'package:material_ui/material_ui.dart';

import 'transitions.dart';

Color randomColor([int? seed]) =>
    Color((math.Random(seed).nextDouble() * 0xFFFFFF).toInt()).withAlpha(255);

String colorFormat(Color color, {bool includeAlpha = false}) {
  final alpha = (color.a * 255).truncate().toRadixString(16).padLeft(2, "0");
  final red = (color.r * 255).truncate().toRadixString(16).padLeft(2, "0");
  final green = (color.g * 255).truncate().toRadixString(16).padLeft(2, "0");
  final blue = (color.b * 255).truncate().toRadixString(16).padLeft(2, "0");

  final rgb = "$red$green$blue";
  return (includeAlpha ? "#$alpha$rgb" : "#$rgb").toUpperCase();
}

class _IconComposerIcon extends StatefulWidget {
  final IconData icon;
  final ColorScheme colorScheme;
  const _IconComposerIcon({required this.icon, required this.colorScheme});

  @override
  State<_IconComposerIcon> createState() => _IconComposerIconState();
}

class _IconComposerIconState extends State<_IconComposerIcon>
    with TickerProviderStateMixin {
  final GlobalKey _boxKey = GlobalKey();
  double _boxSize = 299;

  late final AnimationController _animationController;
  late final Animation<double> _animation;
  double _jumpDegree = 0;
  Completer<void> _jumpCompleter = Completer<void>();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Durations.short3,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutSine,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tmpBoxSize = _boxKey.currentContext?.size?.width ?? 0;
      if (tmpBoxSize != _boxSize) {
        _boxSize = tmpBoxSize;
        if (mounted) setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: AspectRatio(
        aspectRatio: 1 / 1,
        child: GestureDetector(
          onTapDown: (details) async {
            if (_animation.isAnimating && !_jumpCompleter.isCompleted) return;
            _jumpCompleter = Completer<void>();
            _jumpDegree =
                (math.Random().nextInt(8) + 4) *
                (details.localPosition.dx < _boxSize / 2 ? 1 : -1);
            await _animationController.forward();
            await _jumpCompleter.future;
            await _animationController.reverse();
          },
          onTapUp: (_) => _jumpCompleter.complete(),
          onTapCancel: () => _jumpCompleter.complete(),
          child: ClipOval(
            child: Container(
              key: _boxKey,
              color: widget.colorScheme.secondaryContainer,
              padding: EdgeInsetsGeometry.all(_boxSize * 0.16),
              child: FittedBox(
                fit: BoxFit.contain,
                alignment: Alignment.center,
                child: AnimatedSwitcher(
                  duration: Durations.long1,
                  reverseDuration: Durations.long4,
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeInBack,
                  transitionBuilder: Transitions.fromBottom,
                  child: AnimatedBuilder(
                    key: ValueKey(widget.icon),
                    animation: _animation,
                    builder: (context, child) {
                      return RotationTransition(
                        turns: Tween(
                          begin: 0.0,
                          end: _jumpDegree / 360,
                        ).animate(_animation),
                        child: MatrixTransition(
                          animation: _animation,
                          onTransform: (animationValue) =>
                              Matrix4.translationValues(
                                0,
                                animationValue * -2,
                                0,
                              ),
                          child: child!,
                        ),
                      );
                    },
                    child: Icon(
                      widget.icon,
                      color: widget.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> showIconComposer(
  BuildContext context, [
  String? initialAppName,
]) async {
  if (initialAppName == null || initialAppName.isEmpty) {
    final packageInfo = await PackageInfo.fromPlatform();
    initialAppName = packageInfo.appName;
  }

  String? appName = initialAppName;
  final icons = [
    Icons.celebration_rounded,
    Icons.pets_rounded,
    Icons.face_rounded,
    Icons.cake_rounded,
    Icons.local_florist_rounded,
    Icons.sports_esports_rounded,
    Icons.music_note_rounded,
    Icons.lock_rounded,
    Icons.directions_car_rounded,
    Icons.home_rounded,
    Icons.school_rounded,
    Icons.camera_alt_rounded,
    Icons.map_rounded,
    Icons.phone_rounded,
  ];
  var selectedIcon = 0;

  if (!context.mounted) return;
  showSettingsScreen(
    context,
    config: () {
      final colorScheme = ColorScheme.fromSeed(
        seedColor: randomColor(appName.hashCode),
        dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
      );
      return SettingsConfig(
        title: "Icon Composer",
        sections: [
          SettingsSection(
            options: [
              SettingsOptionBuilder(
                builder: (_, _) => _IconComposerIcon(
                  icon: icons.elementAt(selectedIcon),
                  colorScheme: colorScheme,
                ),
              ),
            ],
          ),
          SettingsSection(
            options: [
              InputSettingsOption(
                title: "App Name",
                value: appName,
                onChanged: (value) => appName = value.trim(),
                allowEmpty: true,
                capitalization: TextCapitalization.words,
                action: PromptDialogAction(
                  icon: Icons.refresh,
                  label: "Reset",
                  invoke: (event) => event.setValue(initialAppName),
                ),
              ),
              SettingsOptionBuilder(
                builder: (_, event) => Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  children: icons
                      .toList()
                      .asMap()
                      .entries
                      .map(
                        (i) => IconButton(
                          isSelected: selectedIcon == i.key,
                          onPressed: selectedIcon != i.key
                              ? () {
                                  selectedIcon = i.key;
                                  event.onChanged();
                                }
                              : null,
                          icon: Icon(i.value),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),

          SettingsSection(
            headline: "Colors",
            options: [
              CustomSettingsOption(
                title:
                    "These colors are generated from the app name above. Change it to get different colors.",
                titleStyle: MaterialListTileTitleStyle.text,
              ),
              CustomSettingsOption(
                title: "Secondary Container",
                subtitle: colorFormat(colorScheme.secondaryContainer),
                onLongPress: () => copyData(
                  context,
                  colorFormat(colorScheme.secondaryContainer),
                ),
              ),
              CustomSettingsOption(
                title: "On Secondary Container",
                subtitle: colorFormat(colorScheme.onSecondaryContainer),
                onLongPress: () => copyData(
                  context,
                  colorFormat(colorScheme.onSecondaryContainer),
                ),
              ),
            ],
          ),

          SettingsSection(
            headline: "Usage",
            options: [
              CustomSettingsOption(
                icon: SizedBox.square(
                  dimension: IconTheme.of(context).size,
                  child: Image.network(
                    "https://icon.kitchen/logo192.png",
                    errorBuilder: (_, _, _) => Icon(Icons.soup_kitchen),
                  ),
                ),
                title: "IconKitchen",
                onTap: () {
                  final data = jsonEncode({
                    "values": {
                      "fgType": "image",
                      "fgMask": true,
                      "bgColor": colorFormat(
                        colorScheme.secondaryContainer,
                      ).toLowerCase(),
                      "fgColor": colorFormat(
                        colorScheme.onSecondaryContainer,
                      ).toLowerCase(),
                      "themed": true,
                      "fgScaling": "crop",
                      "fgPadding": {
                        "top": 16,
                        "right": 16,
                        "bottom": 16,
                        "left": 16,
                      },
                    },
                    "modules": ["android"],
                  });
                  final packaged = Uri.encodeComponent(
                    base64Encode(gzip.encode(utf8.encode(data))),
                  );
                  final url = Uri.parse("https://icon.kitchen/i/$packaged");
                  copyData(context, url.toString());
                  launchUrl(url);
                },
              ),
            ],
          ),
        ],
      );
    },
  );
}
