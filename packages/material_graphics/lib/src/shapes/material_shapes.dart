import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// Different collections of MaterialShapes for various use cases.
extension MaterialShapesCollections on MaterialShapes {
  static Map<String, List<RoundedPolygon>> values = Map.unmodifiable({
    "containers": MaterialShapesCollections.containers,
    "containersAll": MaterialShapesCollections.containersAll,
    "decorative": MaterialShapesCollections.decorative,
  });

  /// A collection of interesting shapes suitable for container-like usage.
  ///
  /// For a more general collection of container shapes, not preselected to be
  /// "interesting", use [MaterialShapesCollections.containersAll].
  static List<RoundedPolygon> containers = List.unmodifiable([
    MaterialShapes.slanted,
    MaterialShapes.pill,
    MaterialShapes.arrow,
    MaterialShapes.pentagon,
    MaterialShapes.gem,
    MaterialShapes.verySunny,
    MaterialShapes.cookie4Sided,
    MaterialShapes.cookie9Sided,
    MaterialShapes.softBurst,
    MaterialShapes.softBoom,
    MaterialShapes.flower,
    MaterialShapes.ghostish,
  ]);

  /// A collection of shapes suitable for container-like usage.
  static List<RoundedPolygon> containersAll = List.unmodifiable([
    MaterialShapes.circle,
    MaterialShapes.square,
    MaterialShapes.slanted,
    MaterialShapes.arch,
    MaterialShapes.pill,
    MaterialShapes.arrow,
    MaterialShapes.pentagon,
    MaterialShapes.gem,
    MaterialShapes.sunny,
    MaterialShapes.verySunny,
    MaterialShapes.cookie4Sided,
    MaterialShapes.cookie6Sided,
    MaterialShapes.cookie7Sided,
    MaterialShapes.cookie9Sided,
    MaterialShapes.cookie12Sided,
    MaterialShapes.clover4Leaf,
    MaterialShapes.clover8Leaf,
    MaterialShapes.softBurst,
    MaterialShapes.softBoom,
    MaterialShapes.flower,
    MaterialShapes.puffyDiamond,
    MaterialShapes.ghostish,
    MaterialShapes.pixelCircle,
    MaterialShapes.bun,
  ]);

  static List<RoundedPolygon> decorative = List.unmodifiable([
    MaterialShapes.semiCircle,
    MaterialShapes.oval,
    MaterialShapes.triangle,
    MaterialShapes.fan,
    MaterialShapes.diamond,
    MaterialShapes.clamShell,
    MaterialShapes.burst,
    MaterialShapes.boom,
    MaterialShapes.puffy,
    MaterialShapes.pixelTriangle,
    MaterialShapes.heart,
  ]);
}

/// Different point transformation functions for MaterialShapes.
class MaterialShapesPointTransformers {
  MaterialShapesPointTransformers._();

  static (double, double) Function(double x, double y) rotateDegrees(
    double degrees,
  ) {
    final rad = degrees * math.pi / 180.0;
    final cosA = math.cos(rad);
    final sinA = math.sin(rad);
    return (double x, double y) =>
        ((x * cosA - y * sinA).toDouble(), (x * sinA + y * cosA).toDouble());
  }

  static (double, double) Function(double x, double y) rotateDegreesCentered(
    double degrees, {
    double centerX = 0.5,
    double centerY = 0.5,
  }) {
    final rad = degrees * math.pi / 180.0;
    final cosA = math.cos(rad);
    final sinA = math.sin(rad);
    return (double x, double y) {
      final dx = x - centerX;
      final dy = y - centerY;
      return (centerX + dx * cosA - dy * sinA, centerY + dx * sinA + dy * cosA);
    };
  }

  static (double, double) Function(double x, double y) scale(
    double sx,
    double sy,
  ) =>
      (double x, double y) => ((x * sx).toDouble(), (y * sy).toDouble());

  static (double, double) Function(double x, double y) offset(
    double dx,
    double dy,
  ) =>
      (double x, double y) => ((x + dx).toDouble(), (y + dy).toDouble());
}
