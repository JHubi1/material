import 'package:flutter/animation.dart';

class CurveGroup {
  final String name;

  final Curve fast;
  final Duration fastDuration;
  final Curve normal;
  final Duration normalDuration;
  final Curve slow;
  final Duration slowDuration;

  const CurveGroup._({
    required this.name,
    required this.fast,
    required this.fastDuration,
    required this.normal,
    required this.normalDuration,
    required this.slow,
    required this.slowDuration,
  });

  @override
  String toString() =>
      "CurveGroup(name: $name, "
      "fast: $fast, "
      "fastDuration: $fastDuration, "
      "normal: $normal, "
      "normalDuration: $normalDuration, "
      "slow: $slow, "
      "slowDuration: $slowDuration)";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurveGroup &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          fast == other.fast &&
          fastDuration == other.fastDuration &&
          normal == other.normal &&
          normalDuration == other.normalDuration &&
          slow == other.slow &&
          slowDuration == other.slowDuration;
  @override
  int get hashCode => Object.hash(
    name,
    fast,
    fastDuration,
    normal,
    normalDuration,
    slow,
    slowDuration,
  );
}

final class ExpressiveCurves {
  ExpressiveCurves._();

  static const CurveGroup expressiveSpatial = CurveGroup._(
    name: "expressiveSpatial",
    fast: Cubic(0.42, 1.67, 0.21, 0.90),
    fastDuration: Duration(milliseconds: 350),
    normal: Cubic(0.38, 1.21, 0.22, 1.00),
    normalDuration: Duration(milliseconds: 500),
    slow: Cubic(0.39, 1.29, 0.35, 0.98),
    slowDuration: Duration(milliseconds: 650),
  );

  static const CurveGroup expressiveEffects = CurveGroup._(
    name: "expressiveEffects",
    fast: Cubic(0.31, 0.94, 0.34, 1.00),
    fastDuration: Duration(milliseconds: 150),
    normal: Cubic(0.34, 0.80, 0.34, 1.00),
    normalDuration: Duration(milliseconds: 200),
    slow: Cubic(0.34, 0.88, 0.34, 1.00),
    slowDuration: Duration(milliseconds: 300),
  );

  static const CurveGroup standardSpatial = CurveGroup._(
    name: "standardSpatial",
    fast: Cubic(0.27, 1.06, 0.18, 1.00),
    fastDuration: Duration(milliseconds: 350),
    normal: Cubic(0.27, 1.06, 0.18, 1.00),
    normalDuration: Duration(milliseconds: 500),
    slow: Cubic(0.27, 1.06, 0.18, 1.00),
    slowDuration: Duration(milliseconds: 750),
  );

  static const CurveGroup standardEffects = CurveGroup._(
    name: "standardEffects",
    fast: Cubic(0.31, 0.94, 0.34, 1.00),
    fastDuration: Duration(milliseconds: 150),
    normal: Cubic(0.34, 0.80, 0.34, 1.00),
    normalDuration: Duration(milliseconds: 200),
    slow: Cubic(0.34, 0.88, 0.34, 1.00),
    slowDuration: Duration(milliseconds: 300),
  );
}
