import 'package:flutter/material.dart';
import 'material_shapes.dart';

Future<void> showShapeDemoDialog(
  BuildContext context, {
  required TickerProvider vsync,
}) {
  final values = MaterialShapes.values;
  final controller = AnimationController(
    vsync: vsync,
    duration: Durations.long4,
  );
  return showDialog(
    context: context,
    builder: (context) => Dialog.fullscreen(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceEvenly,
                children: List.generate(
                  values.length,
                  (index) => Container(
                    decoration: ShapeDecoration(
                      shape: ShapeBorder.lerp(
                        values[index],
                        index + 1 < values.length
                            ? values[index + 1]
                            : values[0],
                        CurveTween(
                          curve: controller.status == AnimationStatus.reverse
                              ? Curves.easeInOutCubicEmphasized.flipped
                              : Curves.easeInOutCubicEmphasized,
                        ).evaluate(controller),
                      )!,
                      color: MaterialShapes.containers.contains(values[index])
                          ? ColorScheme.of(context).primary
                          : ColorScheme.of(context).primaryContainer,
                    ),
                    margin: EdgeInsets.all(8),
                    child: SizedBox.square(dimension: 64),
                  ),
                ),
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
              ClipRRect(
                child: AnimatedSwitcher(
                  duration: Durations.medium1,
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeInBack.flipped,
                  transitionBuilder: (child, animation) => SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(0, -1),
                      end: Offset(0, 0),
                    ).animate(animation),
                    child: child,
                  ),
                  child: !controller.isAnimating
                      ? Slider(
                          value: controller.value,
                          onChanged: (value) => controller.value = value,
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    fullscreenDialog: true,
  );
}
