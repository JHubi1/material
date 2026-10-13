import 'dart:math' as math;
import 'dart:ui';

import 'package:material_graphics/material_graphics.dart';
import 'package:material_ui/material_ui.dart';

enum MaterialLoadingIndicatorStyle { normal, contained }

class MaterialLoadingIndicator extends StatefulWidget {
  final double size;
  final MaterialLoadingIndicatorStyle style;
  final String? semanticLabel;

  const MaterialLoadingIndicator({
    super.key,
    this.size = 48,
    this.style = MaterialLoadingIndicatorStyle.normal,
    this.semanticLabel,
  });

  @override
  State<MaterialLoadingIndicator> createState() =>
      _MaterialLoadingIndicatorState();
}

class _MaterialLoadingIndicatorState extends State<MaterialLoadingIndicator>
    with TickerProviderStateMixin {
  late final AnimationController _shapeController;
  late final AnimationController _rotateController;
  late final AnimationController _scaleController;

  final _sre = 180.0;
  var _loadingIndicatorIndex = 0;
  late final _loadingIndicatorShapes = [
    MaterialShapes.softBurst
        .transformed(MaterialShapesPointTransformers.rotateDegrees(-_sre))
        .normalized(),
    MaterialShapes.cookie9Sided
        .transformed(MaterialShapesPointTransformers.rotateDegrees(-_sre))
        .normalized(),
    MaterialShapes.pentagon
        .transformed(MaterialShapesPointTransformers.rotateDegrees(-18 - _sre))
        .normalized(),
    MaterialShapes.pill
        .transformed(MaterialShapesPointTransformers.rotateDegrees(60 - _sre))
        .normalized(),
    MaterialShapes.sunny
        .transformed(MaterialShapesPointTransformers.rotateDegrees(5 - _sre))
        .normalized(),
    MaterialShapes.cookie4Sided
        .transformed(MaterialShapesPointTransformers.rotateDegrees(-15 - _sre))
        .normalized(),
    MaterialShapes.oval
        .transformed(MaterialShapesPointTransformers.rotateDegrees(-70 - _sre))
        .normalized(),
  ];

  @override
  void initState() {
    super.initState();

    _shapeController =
        AnimationController(vsync: this, duration: Durations.long2)
          ..addStatusListener((status) async {
            if (status == AnimationStatus.completed) {
              await Future.delayed(Durations.short4);
              if (!mounted) return;

              _loadingIndicatorIndex++;

              _shapeController.reset();
              _rotateController.reset();

              _shapeController.forward();
              _rotateController.forward();

              _scheduleBounce();
            }
          });
    _rotateController = AnimationController(
      vsync: this,
      duration: Durations.extralong1,
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: Durations.short4,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _shapeController.forward();
      _rotateController.forward();
      _scheduleBounce();
    });
  }

  @override
  void dispose() {
    _shapeController.dispose();
    _rotateController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final widgetScale = widget.size / 48.0;
    return AnimatedBuilder(
      animation: Listenable.merge([
        _shapeController,
        _rotateController,
        _scaleController,
      ]),
      builder: (context, _) {
        final colorScheme = ColorScheme.of(context);

        final curved1 = CurveTween(curve: Curves.easeInOutCubicEmphasized);
        final curved2 = CurveTween(
          curve: ThreePointCubic(
            Offset(0.05, 0),
            Offset(0.133333, 0.12),
            Offset(0.166666, 0.45),
            Offset(0.208333, 0.55),
            Offset(0.25, 1),
          ),
        );
        final eased = CurveTween(
          curve: _rotateController.status == AnimationStatus.reverse
              ? Curves.easeInOut.flipped
              : Curves.easeInOut,
        );

        final shape =
            Morph(
              _loadingIndicatorShapes[_loadingIndicatorIndex %
                      _loadingIndicatorShapes.length]
                  .transformed(
                    MaterialShapesPointTransformers.rotateDegrees(_sre),
                  )
                  .normalized(),
              _loadingIndicatorShapes[(_loadingIndicatorIndex + 1) %
                  _loadingIndicatorShapes.length],
            ).toShapeDecoration(
              progress: curved1.evaluate(_shapeController),
              color: widget.style == MaterialLoadingIndicatorStyle.contained
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.primary,
            );
        final rotate = Tween<double>(
          begin: 0,
          end: _sre / 180 * math.pi,
        ).chain(curved2).evaluate(_rotateController);
        final scale = Tween<double>(
          begin: 1,
          end: 1.05,
        ).chain(eased).evaluate(_scaleController);

        Widget res = Transform.scale(
          scale: scale,
          child: Transform.rotate(
            angle: rotate,
            child: Container(
              width: 34 * widgetScale,
              height: 34 * widgetScale,
              decoration: shape,
            ),
          ),
        );

        if (widget.style == MaterialLoadingIndicatorStyle.contained) {
          res = Container(
            height: widget.size,
            width: widget.size,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            padding: EdgeInsets.all(7 * widgetScale),
            child: res,
          );
        }

        res = Semantics(
          role: SemanticsRole.progressBar,
          label: widget.semanticLabel,
          child: res,
        );

        return res;
      },
    );
  }

  void _scheduleBounce() => Future.delayed(Durations.short2).then((_) {
    if (!mounted || !_rotateController.isAnimating) return;
    _scaleController.repeat(reverse: true, count: 2);
  });
}

abstract class MaterialLoadingIndicatorSizes {
  static const double small = 24;
  static const double medium = 48;
  static const double large = 72;
  static const double extraLarge = 96;
}
