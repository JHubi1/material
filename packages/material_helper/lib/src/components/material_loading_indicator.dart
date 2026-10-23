import 'dart:math' as math;
import 'dart:ui';

import 'package:material_graphics/material_graphics.dart';
import 'package:material_ui/material_ui.dart';
// material_ui doesn't expose transformed function publicly
// ignore: implementation_imports
import 'package:material_ui/src/shapes/rounded_polygon.dart';

enum MaterialLoadingIndicatorStyle { normal, contained }

class MaterialLoadingIndicator extends StatefulWidget {
  final double size;
  final MaterialLoadingIndicatorStyle style;
  final String? semanticLabel;

  const MaterialLoadingIndicator({
    super.key,
    this.size = MaterialLoadingIndicatorSizes.medium,
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
    MaterialShapes.softBurst.transformed(
      MaterialShapesPointTransformers.rotateDegreesCentered(-_sre),
    ),
    MaterialShapes.cookie9Sided.transformed(
      MaterialShapesPointTransformers.rotateDegreesCentered(-_sre),
    ),
    MaterialShapes.pentagon.transformed(
      MaterialShapesPointTransformers.rotateDegreesCentered(-18 - _sre),
    ),
    MaterialShapes.pill.transformed(
      MaterialShapesPointTransformers.rotateDegreesCentered(60 - _sre),
    ),
    MaterialShapes.sunny.transformed(
      MaterialShapesPointTransformers.rotateDegreesCentered(5 - _sre),
    ),
    MaterialShapes.cookie4Sided.transformed(
      MaterialShapesPointTransformers.rotateDegreesCentered(-15 - _sre),
    ),
    MaterialShapes.oval.transformed(
      MaterialShapesPointTransformers.rotateDegreesCentered(-70 - _sre),
    ),
  ];

  late final _shapeScale = _loadingIndicatorShapes
      .map((shape) => 1 / shape.calculateMaxBounds().width)
      .reduce(math.min)
      .clamp(0.0, 1.0);

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

        final shape = ShapeDecoration(
          color: widget.style == MaterialLoadingIndicatorStyle.contained
              ? colorScheme.onPrimaryContainer
              : colorScheme.primary,
          shape: ShapeBorderTween(
            begin: MaterialShapeBorder(
              shape:
                  _loadingIndicatorShapes[_loadingIndicatorIndex %
                          _loadingIndicatorShapes.length]
                      .transformed(
                        MaterialShapesPointTransformers.rotateDegreesCentered(
                          _sre,
                        ),
                      ),
            ),
            end: MaterialShapeBorder(
              shape:
                  _loadingIndicatorShapes[(_loadingIndicatorIndex + 1) %
                      _loadingIndicatorShapes.length],
            ),
          ).evaluate(curved1.animate(_shapeController))!,
        );
        final rotate = Tween<double>(
          begin: 0,
          end: _sre / 180 * math.pi,
        ).chain(curved2).evaluate(_rotateController);
        final scale = Tween<double>(
          begin: 1,
          end: 1.05,
        ).chain(eased).evaluate(_scaleController);

        Widget res = SizedBox(
          width: 38 * widgetScale,
          height: 38 * widgetScale,
          child: Transform.scale(
            scale: scale * _shapeScale,
            child: Transform.rotate(
              angle: rotate,
              child: DecoratedBox(decoration: shape),
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
            padding: EdgeInsets.all(5 * widgetScale),
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
