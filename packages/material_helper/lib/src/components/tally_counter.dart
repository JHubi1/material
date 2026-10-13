import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:material_graphics/material_graphics.dart';
import 'package:material_ui/material_ui.dart';

extension NumberLeadingZeros on num {
  String withLeadingZeros(int totalLength) {
    final str = toString();
    if (str.length >= totalLength) return str;
    return "0" * (totalLength - str.length) + str;
  }
}

class TallyCounter extends StatefulWidget {
  final int count;
  final int? maxCount;
  final bool scrollable;
  final double? size;
  final double width;

  const TallyCounter({
    super.key,
    required this.count,
    this.maxCount = 100,
    this.scrollable = true,
    this.size,
    this.width = 1,
  });

  @override
  State<TallyCounter> createState() => _TallyCounterState();
}

class _TallyCounterState extends State<TallyCounter>
    with TickerProviderStateMixin {
  final Map<int, AnimationController> _controllers = {};

  @override
  void didUpdateWidget(TallyCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count > oldWidget.count) {
      for (var i = oldWidget.count; i < widget.count; i++) {
        _controllers[i]?.dispose();
        final controller = AnimationController(
          vsync: this,
          duration: Durations.medium1,
        )..addListener(() => setState(() {}));
        _controllers[i] = controller;
        controller.forward().then((_) {
          if (mounted && _controllers[i] == controller) {
            _controllers.remove(i);
            controller.dispose();
          }
        });
      }
    } else if (widget.count < oldWidget.count) {
      for (var i = widget.count; i < oldWidget.count; i++) {
        _controllers[i]?.dispose();
        final controller = AnimationController(
          vsync: this,
          duration: ExpressiveCurves.expressiveEffects.slowDuration,
          value: 1.0,
        )..addListener(() => setState(() {}));
        _controllers[i] = controller;
        controller.reverse().then((_) {
          if (mounted && _controllers[i] == controller) {
            setState(() {
              _controllers.remove(i);
              controller.dispose();
            });
          }
        });
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var effectiveCount = math.max(widget.count, 0);
    if (_controllers.isNotEmpty) {
      final maxIndex = _controllers.keys.reduce(math.max);
      effectiveCount = math.max(effectiveCount, maxIndex + 1);
    }
    if (widget.maxCount != null) {
      effectiveCount = math.min(effectiveCount, widget.maxCount!);
    }

    final effectiveSize =
        widget.size ??
        DefaultTextStyle.of(context).style.fontSize ??
        kDefaultFontSize;

    final fullRounds = effectiveCount ~/ 5;
    final remainder = effectiveCount % 5;
    final roundCount = fullRounds + (remainder > 0 ? 1 : 0);

    final containerSize = Size(effectiveSize * 3, effectiveSize * 2);
    final color = ColorScheme.of(context).primary;
    final items = List<Widget>.generate(roundCount, (index) {
      return CustomPaint(
        size: containerSize,
        painter: _TallyCounterPainter(
          index < fullRounds ? 5 : remainder,
          color,
          widget.width,
          List.generate(5, (i) {
            final realIndex = index * 5 + i;
            return _controllers.containsKey(realIndex)
                ? CurvedAnimation(
                    parent: _controllers[realIndex]!,
                    curve: ExpressiveCurves.expressiveEffects.slow,
                    reverseCurve:
                        ExpressiveCurves.expressiveEffects.slow.flipped,
                  ).value
                : 1.0;
          }),
        ),
      );
    });
    if (items.isEmpty) {
      items.add(
        SizedBox(width: containerSize.width, height: containerSize.height),
      );
    }

    Widget tally = Row(key: ValueKey(effectiveCount), children: items);
    if (widget.scrollable) {
      tally = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: AnimatedSize(
          duration: ExpressiveCurves.expressiveSpatial.slowDuration,
          curve: ExpressiveCurves.expressiveSpatial.slow,
          alignment: Alignment.centerLeft,
          clipBehavior: Clip.none,
          child: tally,
        ),
      );
    }
    return tally;
  }
}

class _TallyCounterPainter extends CustomPainter {
  final int count;
  final Color color;
  final double width;
  final List<double> opacities;
  _TallyCounterPainter(this.count, this.color, this.width, this.opacities)
    : assert(
        count >= 0 && count <= 5,
        "Count must be between 0 and 5 inclusive.",
      ),
      assert(
        opacities.length == 5,
        "Opacities list must have exactly 5 elements.",
      );

  @override
  void paint(Canvas canvas, Size size) {
    final strokeCount = count == 5 ? 4 : count;
    final lineThrough = count == 5;

    final spacing = size.width / 9;
    paint(int index) => Paint()
      ..color = color.withValues(alpha: opacities[index])
      ..strokeWidth = spacing * width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..filterQuality = FilterQuality.medium
      ..isAntiAlias = true;

    for (var i = 0; i < strokeCount; i++) {
      final x = spacing * 1.5 + spacing * i * 2;
      canvas.drawLine(
        Offset(x, size.height - spacing / 2),
        Offset(x, spacing / 2),
        paint(i),
      );
    }
    if (lineThrough) {
      final path = Path()
        ..moveTo(spacing / 2, size.height - spacing * 2)
        ..lineTo(size.width - spacing / 2, spacing * 2);
      canvas.drawPath(path, paint(4));
    }
  }

  @override
  bool shouldRepaint(_TallyCounterPainter oldDelegate) =>
      count != oldDelegate.count ||
      color != oldDelegate.color ||
      width != oldDelegate.width ||
      !listEquals(opacities, oldDelegate.opacities);
}
