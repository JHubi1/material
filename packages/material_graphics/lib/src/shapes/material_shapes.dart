import 'dart:math' as math;

import 'package:material_new_shapes/material_new_shapes.dart';
import 'package:material_ui/material_ui.dart'
    hide MaterialShapes, RoundedPolygon;

export 'package:material_new_shapes/material_new_shapes.dart';

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

extension on Path {
  Path resize(Size size, [double scaleFactor = 1]) {
    final scaleMatrix = Matrix4.diagonal3Values(
      size.width * scaleFactor,
      size.height * scaleFactor,
      1,
    );
    final scaledPath = transform(scaleMatrix.storage);

    final bounds = scaledPath.getBounds();
    final translation = Offset(size.width / 2, size.height / 2) - bounds.center;
    final finalPath = scaledPath.shift(translation);

    return finalPath;
  }
}

Rect _listToRect(List<double> list) {
  assert(list.length == 4, "List must have exactly 4 elements.");
  return Rect.fromLTRB(list[0], list[1], list[2], list[3]);
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

// MARK: PathClippers

extension RoundedPolygonPathClipper on RoundedPolygon {
  /// Converts the RoundedPolygon to a [PathClipper].
  ///
  /// Note: If you just want to display an icon, consider using [toShapeBorder]
  /// or [toShapeDecoration] instead. This is the preferred way to use and
  /// display shapes in the Material Apps project.
  PathClipper toPathClipper({
    int startAngle = 0,
    bool repeatPath = false,
    bool closePath = true,
    Path? path,
  }) => PathClipper(
    toPath(
      startAngle: startAngle,
      repeatPath: repeatPath,
      closePath: closePath,
    ),
  );
}

extension MorphPathClipper on Morph {
  /// Converts the Morph to a [PathClipper].
  ///
  /// Note: If you just want to display an icon, consider using [toShapeBorder]
  /// or [toShapeDecoration] instead. This is the preferred way to use and
  /// display shapes in the Material Apps project.
  PathClipper toPathClipper({
    required double progress,
    int startAngle = 0,
    bool repeatPath = false,
    bool closePath = true,
    double rotationPivotX = 0,
    double rotationPivotY = 0,
    Path? path,
  }) => PathClipper(
    toPath(
      progress: progress,
      startAngle: startAngle,
      repeatPath: repeatPath,
      closePath: closePath,
      rotationPivotX: rotationPivotX,
      rotationPivotY: rotationPivotY,
    ),
  );
}

/// A CustomClipper that clips a widget to a given Path.
///
/// The path is automatically resized to fit the size of the widget being
/// clipped. Is is rebuilt whenever the path changes.
class PathClipper extends CustomClipper<Path> {
  final Path path;
  PathClipper(this.path);

  @override
  Path getClip(Size size) => path.resize(size);

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) =>
      oldClipper != this;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PathClipper && other.path == path;
  }

  @override
  int get hashCode => path.hashCode;
}

// MARK: PathShape

extension RoundedPolygonShapeBorder on RoundedPolygon {
  /// Converts the RoundedPolygon to a [ShapeBorder].
  ///
  /// The returned value is mostly used to be passed to a [ShapeDecoration] in
  /// the [toShapeDecoration] method.
  ShapeBorder toShapeBorder() => RoundedPolygonBorder(polygon: this);

  /// Converts the RoundedPolygon to a [ShapeDecoration].
  ///
  /// The returned value can be directly used in a [Container] or other widgets
  /// that accept a [Decoration].
  ///
  /// The path is first converted to a [ShapeBorder] using the [toShapeBorder]
  /// method, and then wrapped in a [ShapeDecoration].
  ///
  /// The [color] parameter defines the fill color of the shape.
  ///
  /// This is the preferred way to use and display shapes in the Material Apps
  /// project.
  ShapeDecoration toShapeDecoration({Color color = Colors.white}) =>
      ShapeDecoration(color: color, shape: toShapeBorder());
}

extension MorphShapeBorder on Morph {
  /// Converts the Morph to a [ShapeBorder].
  ///
  /// The returned value is mostly used to be passed to a [ShapeDecoration] in
  /// the [toShapeDecoration] method.
  ShapeBorder toShapeBorder({required double progress}) {
    final path = toPath(progress: progress);

    // calculating max bounds manually is necessary because [Morph.getBounds]
    // does not calculate them correctly

    final bounds = path.getBounds();
    final centerX = bounds.center.dx;
    final centerY = bounds.center.dy;

    var maxDistSquared = 0.0;
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      final length = metric.length;
      const sampleCount = 32;
      for (var i = 0; i <= sampleCount; i++) {
        final tangent = metric.getTangentForOffset(length * i / sampleCount);
        if (tangent != null) {
          final dx = tangent.position.dx - centerX;
          final dy = tangent.position.dy - centerY;
          maxDistSquared = math.max(maxDistSquared, dx * dx + dy * dy);
        }
      }
    }

    final distance = math.sqrt(maxDistSquared);
    return RoundedPolygonBorder(
      path: path,
      bounds: _listToRect([
        centerX - distance,
        centerY - distance,
        centerX + distance,
        centerY + distance,
      ]),
    );
  }

  /// Converts the Morph to a [ShapeDecoration].
  ///
  /// The returned value can be directly used in a [Container] or other widgets
  /// that accept a [Decoration].
  ///
  /// The path is first converted to a [ShapeBorder] using the [toShapeBorder]
  /// method, and then wrapped in a [ShapeDecoration].
  ///
  /// The [progress] parameter controls the interpolation between the two shapes
  /// defined in the Morph. It may be evaluated from an animation controller to
  /// create animated transitions between shapes.
  ///
  /// The [color] parameter defines the fill color of the shape.
  ///
  /// This is the preferred way to use and display shapes in the Material Apps
  /// project.
  ShapeDecoration toShapeDecoration({
    required double progress,
    Color color = Colors.white,
  }) {
    return ShapeDecoration(
      color: color,
      shape: toShapeBorder(progress: progress),
    );
  }
}

/// A ShapeBorder that uses a given Path for its shape.
class RoundedPolygonBorder extends ShapeBorder {
  final RoundedPolygon? polygon;
  final Path? path;
  final Rect? bounds;

  const RoundedPolygonBorder({this.polygon, this.path, this.bounds})
    : assert(
        polygon != null || (path != null && bounds != null),
        "Either polygon or both path and bounds must be provided.",
      );

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  ShapeBorder scale(double t) {
    assert(
      polygon != null,
      "Scaling is only supported when a polygon is provided.",
    );
    return RoundedPolygonBorder(
      polygon: polygon!.transformed(
        MaterialShapesPointTransformers.scale(t, t),
      ),
    );
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      _buildPathFitted(rect);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      _buildPathFitted(rect);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder lerpFrom(ShapeBorder? a, double t) {
    if (a is RoundedPolygonBorder) {
      assert(
        polygon != null && a.polygon != null,
        "Lerping is only supported when both borders have polygons provided.",
      );

      if (t <= 0.0) return a;
      if (t >= 1.0) return this;

      final p = Morph(a.polygon!, polygon!);
      return RoundedPolygonBorder(
        path: p.toPath(progress: t),
        bounds: _listToRect(p.calculateMaxBounds()),
      );
    }
    return this;
  }

  @override
  ShapeBorder lerpTo(ShapeBorder? b, double t) {
    if (b is RoundedPolygonBorder) {
      assert(
        polygon != null && b.polygon != null,
        "Lerping is only supported when both borders have polygons provided.",
      );

      if (t <= 0.0) return this;
      if (t >= 1.0) return b;

      final p = Morph(polygon!, b.polygon!);
      return RoundedPolygonBorder(
        path: p.toPath(progress: t),
        bounds: _listToRect(p.calculateMaxBounds()),
      );
    }
    return this;
  }

  Path _buildPathFitted(Rect rect) {
    final effectivePath = path ?? polygon!.toPath();
    final effectiveBounds =
        bounds ?? _listToRect(polygon!.calculateMaxBounds());

    final polyWidth = effectiveBounds.width == 0 ? 1.0 : effectiveBounds.width;
    final polyHeight = effectiveBounds.height == 0
        ? 1.0
        : effectiveBounds.height;
    final scale = math.min(rect.width / polyWidth, rect.height / polyHeight);

    final srcCenter = Offset(
      effectiveBounds.left + effectiveBounds.width / 2,
      effectiveBounds.top + effectiveBounds.height / 2,
    );
    final dx = rect.center.dx - srcCenter.dx * scale;
    final dy = rect.center.dy - srcCenter.dy * scale;

    final m4 = Matrix4.identity()
      ..translateByDouble(dx, dy, 0, 1)
      ..scaleByDouble(scale, scale, scale, 1);
    return effectivePath.transform(m4.storage);
  }

  RoundedPolygonBorder copy(RoundedPolygon Function(RoundedPolygon p) modify) {
    assert(
      polygon != null,
      "Copying is only supported when a polygon is provided.",
    );
    return RoundedPolygonBorder(polygon: modify(polygon!));
  }
}
