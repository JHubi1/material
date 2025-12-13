import 'dart:math' as math;
import 'package:flutter/material.dart';

class TallyCounter extends StatelessWidget {
  final int count;
  final int? maxCount;
  final bool scrollable;
  final double? size;
  final double width;

  const TallyCounter({
    super.key,
    required this.count,
    this.maxCount = 100,
    this.scrollable = false,
    this.size,
    this.width = 1,
  });

  @override
  Widget build(BuildContext context) {
    var effectiveCount = math.max(count, 0);
    if (maxCount != null) effectiveCount = math.min(effectiveCount, maxCount!);

    var effectiveSize =
        size ?? DefaultTextStyle.of(context).style.fontSize ?? kDefaultFontSize;

    final fullRounds = effectiveCount ~/ 5;
    final remainder = effectiveCount % 5;
    final roundCount = fullRounds + (remainder > 0 ? 1 : 0);

    final containerSize = Size(effectiveSize * 3, effectiveSize * 2);
    final color = ColorScheme.of(context).primary;
    final items = List<Widget>.generate(roundCount, (index) {
      if (index < fullRounds) {
        return CustomPaint(
          size: containerSize,
          painter: _TallyCounterPainter(5, color, width),
        );
      } else {
        return CustomPaint(
          size: containerSize,
          painter: _TallyCounterPainter(remainder, color, width),
        );
      }
    });
    if (items.isEmpty) {
      items.add(
        SizedBox(width: containerSize.width, height: containerSize.height),
      );
    }

    // index == items.length * 2 - 3
    //   ? SizedBox()
    //   :
    Widget widget = Row(key: ValueKey(effectiveCount), children: items);
    // widget = AnimatedSwitcher(
    //   duration: Durations.short4,
    //   transitionBuilder: (child, animation) =>
    //       FadeTransition(opacity: animation, child: child),
    //   child: widget,
    // );

    if (scrollable) {
      widget = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: widget,
      );
    }
    return widget;
  }
}

class _TallyCounterPainter extends CustomPainter {
  final int count;
  final Color color;
  final double width;
  _TallyCounterPainter(this.count, this.color, this.width)
    : assert(count >= 0 && count <= 5);

  @override
  void paint(Canvas canvas, Size size) {
    final strokeCount = count == 5 ? 4 : count;
    final lineThrough = count == 5;

    final spacing = size.width / 9;
    final paint = Paint()
      ..color = color
      ..strokeWidth = spacing * width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < strokeCount; i++) {
      final x = spacing * 1.5 + spacing * i * 2;
      canvas.drawLine(
        Offset(x, size.height - spacing / 2),
        Offset(x, spacing / 2),
        paint,
      );
    }
    if (lineThrough) {
      final path = Path()
        ..moveTo(spacing / 2, size.height - spacing * 2)
        ..lineTo(size.width - spacing / 2, spacing * 2);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_TallyCounterPainter oldDelegate) =>
      count != oldDelegate.count || color != oldDelegate.color;
}
