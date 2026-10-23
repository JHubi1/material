import 'package:material_helper/material_helper.dart';
import 'package:material_ui/material_ui.dart' hide MaterialShapes;

import 'material_shapes.dart';

Future<void> showShapeDemoDialog(BuildContext context) {
  return showDialog(
    context: context,
    fullscreenDialog: true,
    barrierColor: Colors.transparent,
    builder: (context) => Dialog.fullscreen(child: ShapeDemoDialog()),
  );
}

class ShapeDemoDialog extends StatefulWidget {
  const ShapeDemoDialog({super.key});

  @override
  State<ShapeDemoDialog> createState() => _ShapeDemoDialogState();
}

class _ShapeDemoDialogState extends State<ShapeDemoDialog>
    with TickerProviderStateMixin {
  late final AnimationController controller;
  String? highlightedCollection;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: Durations.long4);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final values = MaterialShapes.all;
    final animation = CurveTween(
      curve: Curves.easeInOutCubic,
    ).animate(controller);
    return Scaffold(
      appBar: AppBar(title: Text("Shape Demo")),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: double.infinity),
              Wrap(
                alignment: WrapAlignment.spaceEvenly,
                children: List.generate(values.length, (index) {
                  final highlight = highlightedCollection != null
                      ? MaterialShapesCollections
                            .values[highlightedCollection!]!
                      : [];
                  final shape = values[index];
                  final next = index + 1 < values.length
                      ? values[index + 1]
                      : values[0];
                  return Container(
                    decoration: Morph(shape, next).toShapeDecoration(
                      progress: animation.value,
                      color: ColorTween(
                        begin: highlight.contains(shape)
                            ? ColorScheme.of(context).primary
                            : ColorScheme.of(context).primaryContainer,
                        end: highlight.contains(next)
                            ? ColorScheme.of(context).primary
                            : ColorScheme.of(context).primaryContainer,
                      ).evaluate(animation)!,
                    ),
                    margin: EdgeInsets.all(8),
                    child: SizedBox.square(dimension: 64),
                  );
                }),
              ),
              FilledButton.icon(
                onPressed: () {
                  if (controller.isAnimating) {
                    controller.reset();
                  } else {
                    controller.repeat(reverse: true);
                  }
                },
                icon: Icon(
                  controller.isAnimating ? Icons.stop : Icons.play_arrow,
                ),
                label: Text(
                  controller.isAnimating ? "Stop Animation" : "Start Animation",
                ),
              ),
              AnimatedSwitcher(
                duration: Durations.medium1,
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeInBack.flipped,
                transitionBuilder: (child, animation) => SizeTransition(
                  sizeFactor: animation,
                  alignment: Alignment.bottomCenter,
                  child: child,
                ),
                child: !controller.isAnimating
                    ? MaterialListTile(
                        title: Slider(
                          value: controller.value,
                          onChanged: (value) => controller.value = value,
                          padding: EdgeInsets.symmetric(horizontal: 4),
                        ),
                      )
                    : null,
              ),
              ...MaterialListTile.group(
                headline: MaterialListTileHeadline(Text("Collections")),
                MaterialShapesCollections.values.entries
                    .map(
                      (e) => MaterialListTile(
                        leading: e.key == highlightedCollection
                            ? Icon(Icons.check_circle)
                            : Icon(Icons.circle_outlined),
                        title: Text(e.key),
                        trailing: e.key == highlightedCollection
                            ? IconButton(
                                onPressed: () => copyData(
                                  context,
                                  "MaterialShapesCollections.${e.key}",
                                ),
                                icon: Icon(Icons.copy),
                              )
                            : null,

                        selected: e.key == highlightedCollection,
                        onTap: () {
                          highlightedCollection == e.key
                              ? highlightedCollection = null
                              : highlightedCollection = e.key;
                          if (mounted) setState(() {});
                        },
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
