/// Core rounded polygon shapes, borders, geometry utils, and transforms.
///
/// Split out from `material_shapes.dart` so that `MaterialShapes` only contains
/// the catalog of shapes while this file contains the implementation details.
library;

import 'dart:math' as math;
import 'dart:ui' as ui show PathMetric;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' show Vector2;

typedef PointTransformer = Vector2 Function(Vector2 p);

// MARK: Public API types

class CornerRounding {
  final double radius;
  final double smoothing;

  const CornerRounding([this.radius = 0, this.smoothing = 0])
    : assert(
        0 <= smoothing && smoothing <= 1.0,
        "Smoothing must be in range 0..1",
      );

  static const CornerRounding unrounded = CornerRounding();
}

// Simple pair of a point and its rounding, for convenience in polygon construction.
class PointNRound {
  final Offset o; // point
  final CornerRounding r; // rounding for this point
  const PointNRound(this.o, [this.r = CornerRounding.unrounded]);
}

class RoundedPolygonBorder extends ShapeBorder {
  final RoundedPolygon polygon;
  final bool useMaxBounds;

  const RoundedPolygonBorder({required this.polygon, this.useMaxBounds = true});

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  ShapeBorder scale(double t) => RoundedPolygonBorder(
    polygon: polygon.scaled(t),
    useMaxBounds: useMaxBounds,
  );

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return _buildPathFitted(rect, useMaxBounds: useMaxBounds);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return _buildPathFitted(rect, useMaxBounds: useMaxBounds);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder lerpFrom(ShapeBorder? a, double t) {
    if (a is RoundedPolygonBorder) {
      if (t <= 0.0) return a;
      if (t >= 1.0) return this;
      return _LerpedRoundedPolygonBorder(begin: a, end: this, t: t);
    }
    return this;
  }

  @override
  ShapeBorder lerpTo(ShapeBorder? b, double t) {
    if (b is RoundedPolygonBorder) {
      if (t <= 0.0) return this;
      if (t >= 1.0) return b;
      return _LerpedRoundedPolygonBorder(begin: this, end: b, t: t);
    }
    return this;
  }

  Path _buildPathFitted(Rect rect, {required bool useMaxBounds}) {
    final path = polygon.toPath();
    final bounds = useMaxBounds
        ? polygon.calculateMaxBounds()
        : polygon.calculateBounds();
    final polyWidth = bounds.width == 0 ? 1.0 : bounds.width;
    final polyHeight = bounds.height == 0 ? 1.0 : bounds.height;
    final scale = math.min(rect.width / polyWidth, rect.height / polyHeight);

    final srcCenter = Offset(
      bounds.left + bounds.width / 2,
      bounds.top + bounds.height / 2,
    );
    final dx = rect.center.dx - srcCenter.dx * scale;
    final dy = rect.center.dy - srcCenter.dy * scale;

    final m4 = Matrix4.identity()
      ..translateByDouble(dx, dy, 0, 1)
      ..scaleByDouble(scale, scale, scale, 1);
    return path.transform(m4.storage);
  }

  RoundedPolygonBorder copy(RoundedPolygon Function(RoundedPolygon p) modify) =>
      RoundedPolygonBorder(
        polygon: modify(polygon),
        useMaxBounds: useMaxBounds,
      );
}

/// A ShapeBorder that represents a linear interpolation between two
/// RoundedPolygonBorder shapes. It morphs their fitted paths by sampling
/// equidistant points and linearly interpolating between them.
class _LerpedRoundedPolygonBorder extends ShapeBorder {
  final RoundedPolygonBorder begin;
  final RoundedPolygonBorder end;
  final double t;

  static const int _defaultSamples = 128; //64;

  const _LerpedRoundedPolygonBorder({
    required this.begin,
    required this.end,
    required this.t,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  ShapeBorder scale(double s) => _LerpedRoundedPolygonBorder(
    begin: begin.scale(s) as RoundedPolygonBorder,
    end: end.scale(s) as RoundedPolygonBorder,
    t: t,
  );

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    if (t <= 0.0) return begin.getOuterPath(rect, textDirection: textDirection);
    if (t >= 1.0) return end.getOuterPath(rect, textDirection: textDirection);

    final pa = begin.getOuterPath(rect, textDirection: textDirection);
    final pb = end.getOuterPath(rect, textDirection: textDirection);
    final morphed = _morphPaths(pa, pb, t, _defaultSamples);
    return morphed;
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    // Same as outer for this border type
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder lerpFrom(ShapeBorder? a, double t) => this;

  @override
  ShapeBorder lerpTo(ShapeBorder? b, double t) => this;

  static Path _morphPaths(Path a, Path b, double t, int samples) {
    // Handle degenerate cases: empty paths
    if (a.computeMetrics().isEmpty) return b;
    if (b.computeMetrics().isEmpty) return a;

    var ptsA = _samplePath(a, samples);
    var ptsB = _samplePath(b, samples);

    if (ptsA.isEmpty || ptsB.isEmpty) {
      // Fallback: choose either path based on t
      return t < 0.5 ? a : b;
    }

    // Ensure same winding direction (CW/CCW)
    final areaA = _signedArea(ptsA);
    final areaB = _signedArea(ptsB);
    if ((areaA >= 0 && areaB < 0) || (areaA < 0 && areaB >= 0)) {
      ptsB = ptsB.reversed.toList(growable: false);
    }

    // Find optimal circular shift to minimize distance between samples
    final shift = _bestShift(ptsA, ptsB);
    if (shift != 0) {
      ptsB = _shiftPoints(ptsB, shift);
    }

    // Interpolate point-by-point
    final path = Path();
    final first = Offset.lerp(ptsA.first, ptsB.first, t)!;
    path.moveTo(first.dx, first.dy);
    for (var i = 1; i < samples; i++) {
      final p = Offset.lerp(ptsA[i], ptsB[i], t)!;
      path.lineTo(p.dx, p.dy);
    }
    path.close();
    return path;
  }

  static List<Offset> _samplePath(Path p, int samples) {
    final metrics = p.computeMetrics(forceClosed: true).toList(growable: false);
    if (metrics.isEmpty || samples <= 1) return const <Offset>[];

    final lengths = metrics.map((m) => m.length).toList(growable: false);
    final totalLen = lengths.fold<double>(0.0, (a, b) => a + b);
    if (totalLen <= 0) {
      final b = p.getBounds();
      final c = b.center;
      return List<Offset>.filled(samples, c);
    }

    final points = <Offset>[];
    for (var i = 0; i < samples; i++) {
      final target = totalLen * (i / samples);
      var acc = 0.0;
      ui.PathMetric? chosen;
      var local = 0.0;
      for (var mi = 0; mi < metrics.length; mi++) {
        final len = lengths[mi];
        if (target <= acc + len || mi == metrics.length - 1) {
          chosen = metrics[mi];
          local = target - acc;
          if (local < 0) local = 0;
          if (local > len) local = len;
          break;
        }
        acc += len;
      }
      final tangent = chosen!.getTangentForOffset(local);
      points.add(tangent?.position ?? Offset.zero);
    }
    return points;
  }

  // Compute polygon signed area (positive for CCW, negative for CW)
  static double _signedArea(List<Offset> pts) {
    double a = 0.0;
    for (var i = 0; i < pts.length; i++) {
      final j = (i + 1) % pts.length;
      a += pts[i].dx * pts[j].dy - pts[j].dx * pts[i].dy;
    }
    return 0.5 * a;
  }

  // Find circular shift of b that minimizes sum of squared distances to a
  static int _bestShift(List<Offset> a, List<Offset> b) {
    final n = math.min(a.length, b.length);
    if (n == 0) return 0;
    var bestShift = 0;
    var bestScore = double.infinity;

    // Evaluate all shifts. For performance you could sample a subset,
    // but with n<=256 this O(n^2) loop is fine.
    for (var s = 0; s < n; s++) {
      var score = 0.0;
      for (var i = 0; i < n; i++) {
        final j = (i + s) % n;
        final dx = a[i].dx - b[j].dx;
        final dy = a[i].dy - b[j].dy;
        score += dx * dx + dy * dy;
      }
      if (score < bestScore) {
        bestScore = score;
        bestShift = s;
      }
    }
    return bestShift;
  }

  static List<Offset> _shiftPoints(List<Offset> pts, int shift) {
    final n = pts.length;
    if (n == 0) return pts;
    final s = ((shift % n) + n) % n;
    if (s == 0) return pts;
    final out = List<Offset>.filled(n, Offset.zero);
    for (var i = 0; i < n; i++) {
      out[i] = pts[(i + s) % n];
    }
    return out;
  }
}

class RoundedPolygon {
  final List<_Feature> _features; // Corners and edges
  final Offset _center;

  RoundedPolygon._(this._features, this._center);

  factory RoundedPolygon.circle({
    int numVertices = 8,
    double radius = 1.0,
    double centerX = 0.0,
    double centerY = 0.0,
  }) {
    assert(numVertices > 3, "numSegments must be > 3");
    return RoundedPolygon.fromNumVertices(
      numVertices: numVertices,
      rounding: CornerRounding(radius),
      radius: radius / math.cos(math.pi / numVertices),
      centerX: centerX,
      centerY: centerY,
    );
  }

  factory RoundedPolygon.rectangle({
    double width = 2.0,
    double height = 2.0,
    CornerRounding rounding = CornerRounding.unrounded,
    List<CornerRounding>? perVertexRounding,
    double centerX = 0.0,
    double centerY = 0.0,
  }) {
    final left = centerX - width / 2;
    final top = centerY - height / 2;
    final right = centerX + width / 2;
    final bottom = centerY + height / 2;

    return RoundedPolygon.fromVertices(
      vertices: [right, bottom, left, bottom, left, top, right, top],
      rounding: rounding,
      perVertexRounding: perVertexRounding,
      centerX: centerX,
      centerY: centerY,
    );
  }

  factory RoundedPolygon.star({
    required int numVerticesPerRadius,
    double radius = 1,
    double innerRadius = 0.5,
    CornerRounding rounding = CornerRounding.unrounded,
    CornerRounding? innerRounding,
    List<CornerRounding>? perVertexRounding,
    double centerX = 0,
    double centerY = 0,
  }) {
    if (radius <= 0) {
      throw ArgumentError.value(
        radius,
        "radius",
        "Star radii must both be greater than 0",
      );
    } else if (innerRadius <= 0) {
      throw ArgumentError.value(
        innerRadius,
        "innerRadius",
        "Star radii must both be greater than 0",
      );
    }
    if (innerRadius >= radius) {
      throw ArgumentError("innerRadius must be less than radius");
    }

    var effectivePerVertexRounding = perVertexRounding;
    if (effectivePerVertexRounding == null && innerRounding != null) {
      effectivePerVertexRounding = List<CornerRounding>.generate(
        numVerticesPerRadius * 2,
        (i) => i.isEven ? rounding : innerRounding,
        growable: false,
      );
    }

    Vector2 radialToCartesian(
      double radius,
      double angleRadians, [
      Vector2? center,
    ]) =>
        Vector2(math.cos(angleRadians), math.sin(angleRadians)) * radius +
        (center ?? Vector2.zero());
    List<double> starVerticesFromNumVertices(
      int numVerticesPerRadius,
      double radius,
      double innerRadius,
      double centerX,
      double centerY,
    ) {
      final result = List<double>.filled(numVerticesPerRadius * 4, 0);
      var arrayIndex = 0;
      for (var i = 0; i < numVerticesPerRadius; i++) {
        var vertex = radialToCartesian(
          radius,
          (math.pi / numVerticesPerRadius * 2 * i),
        );
        result[arrayIndex++] = vertex.x + centerX;
        result[arrayIndex++] = vertex.y + centerY;
        vertex = radialToCartesian(
          innerRadius,
          (math.pi / numVerticesPerRadius * (2 * i + 1)),
        );
        result[arrayIndex++] = vertex.x + centerX;
        result[arrayIndex++] = vertex.y + centerY;
      }
      return result;
    }

    return RoundedPolygon.fromVertices(
      vertices: starVerticesFromNumVertices(
        numVerticesPerRadius,
        radius,
        innerRadius,
        centerX,
        centerY,
      ),
      rounding: rounding,
      perVertexRounding: effectivePerVertexRounding,
      centerX: centerX,
      centerY: centerY,
    );
  }

  factory RoundedPolygon.fromNumVertices({
    required int numVertices,
    double radius = 1.0,
    double centerX = 0.0,
    double centerY = 0.0,
    CornerRounding rounding = CornerRounding.unrounded,
    List<CornerRounding>? perVertexRounding,
  }) {
    assert(numVertices >= 3, "Polygons must have at least 3 vertices");
    final vertices = _verticesFromNumVertices(
      numVertices,
      radius,
      centerX,
      centerY,
    );
    return RoundedPolygon.fromVertices(
      vertices: vertices,
      rounding: rounding,
      perVertexRounding: perVertexRounding,
      centerX: centerX,
      centerY: centerY,
    );
  }

  factory RoundedPolygon.fromVertices({
    required List<double> vertices, // [x0,y0, x1,y1, ...]
    CornerRounding rounding = CornerRounding.unrounded,
    List<CornerRounding>? perVertexRounding,
    double? centerX,
    double? centerY,
  }) {
    if (vertices.length < 6) {
      throw ArgumentError.value(
        vertices.length ~/ 2,
        "vertices",
        "Polygons must have at least 3 vertices",
      );
    }
    if (vertices.length.isOdd) {
      throw ArgumentError.value(
        vertices.length,
        "vertices",
        "The vertices array should have even size",
      );
    }
    if (perVertexRounding != null &&
        perVertexRounding.length * 2 != vertices.length) {
      throw ArgumentError.value(
        perVertexRounding.length,
        "perVertexRounding",
        "perVertexRounding must match number of vertices",
      );
    }

    final n = vertices.length ~/ 2;
    final roundedCorners = <_RoundedCorner>[];
    for (var i = 0; i < n; i++) {
      final vtxR = perVertexRounding != null ? perVertexRounding[i] : rounding;
      final prevIx = ((i + n - 1) % n) * 2;
      final nextIx = ((i + 1) % n) * 2;
      roundedCorners.add(
        _RoundedCorner(
          Vector2(vertices[prevIx], vertices[prevIx + 1]),
          Vector2(vertices[i * 2], vertices[i * 2 + 1]),
          Vector2(vertices[nextIx], vertices[nextIx + 1]),
          vtxR,
        ),
      );
    }

    // Determine allowed cuts per side
    final cutAdjusts = List<_Pair>.generate(n, (ix) {
      final expectedRoundCut =
          roundedCorners[ix].expectedRoundCut +
          roundedCorners[(ix + 1) % n].expectedRoundCut;
      final expectedCut =
          roundedCorners[ix].expectedCut +
          roundedCorners[(ix + 1) % n].expectedCut;
      final vtxX = vertices[ix * 2];
      final vtxY = vertices[ix * 2 + 1];
      final nextVtxX = vertices[((ix + 1) % n) * 2];
      final nextVtxY = vertices[((ix + 1) % n) * 2 + 1];
      final sideSize = _distance(vtxX - nextVtxX, vtxY - nextVtxY);
      if (expectedRoundCut > sideSize) {
        return _Pair(
          sideSize / (expectedRoundCut == 0 ? 1 : expectedRoundCut),
          0.0,
        );
      } else if (expectedCut > sideSize) {
        final denom = (expectedCut - expectedRoundCut);
        return _Pair(
          1.0,
          denom == 0 ? 0.0 : (sideSize - expectedRoundCut) / denom,
        );
      } else {
        return const _Pair(1.0, 1.0);
      }
    });

    final cornersCubics = <List<_Cubic>>[];
    for (var i = 0; i < n; i++) {
      final allowedCuts = List<double>.filled(2, 0.0);
      for (var delta = 0; delta <= 1; delta++) {
        final pair = cutAdjusts[(i + n - 1 + delta) % n];
        final adj =
            roundedCorners[i].expectedRoundCut * pair.first +
            (roundedCorners[i].expectedCut -
                    roundedCorners[i].expectedRoundCut) *
                pair.second;
        allowedCuts[delta] = adj;
      }
      cornersCubics.add(
        roundedCorners[i].getCubics(allowedCuts[0], allowedCuts[1]),
      );
    }

    // Build features (Corner + Edge)
    final features = <_Feature>[];
    for (var i = 0; i < n; i++) {
      final prevVtxIndex = (i + n - 1) % n;
      final nextVtxIndex = (i + 1) % n;
      final currVertex = Vector2(vertices[i * 2], vertices[i * 2 + 1]);
      final prevVertex = Vector2(
        vertices[prevVtxIndex * 2],
        vertices[prevVtxIndex * 2 + 1],
      );
      final nextVertex = Vector2(
        vertices[nextVtxIndex * 2],
        vertices[nextVtxIndex * 2 + 1],
      );
      final isConvex = _convex(prevVertex, currVertex, nextVertex);
      features.add(_Feature.corner(cornersCubics[i], isConvex));
      features.add(
        _Feature.edge([
          _Cubic.straightLine(
            cornersCubics[i].last.anchor1X,
            cornersCubics[i].last.anchor1Y,
            cornersCubics[(i + 1) % n].first.anchor0X,
            cornersCubics[(i + 1) % n].first.anchor0Y,
          ),
        ]),
      );
    }

    // Center
    final cxcy = (centerX == null || centerY == null)
        ? _calculateCenter(vertices)
        : Vector2(centerX, centerY);
    return RoundedPolygon._(features, Offset(cxcy.x, cxcy.y));
  }

  RoundedPolygon transformed(PointTransformer f) {
    final transformedFeatures = _features
        .map((feat) => feat.transformed(f))
        .toList(growable: false);
    final center = f(Vector2(_center.dx, _center.dy));
    return RoundedPolygon._(transformedFeatures, Offset(center.x, center.y));
  }

  RoundedPolygon scaled(double s) {
    return transformed((p) => Vector2(p.x * s, p.y * s));
  }

  List<_Cubic> get cubics {
    final out = <_Cubic>[];
    _Cubic? firstCubic;
    _Cubic? lastCubic;
    List<_Cubic>? firstFeatureSplitStart;
    List<_Cubic>? firstFeatureSplitEnd;

    if (_features.isNotEmpty && _features[0].cubics.length == 3) {
      final centerCubic = _features[0].cubics[1];
      final split = centerCubic.split(0.5);
      firstFeatureSplitStart = [_features[0].cubics[0], split.first];
      firstFeatureSplitEnd = [split.second, _features[0].cubics[2]];
    }
    for (var i = 0; i <= _features.length; i++) {
      final featureCubics = (i == 0 && firstFeatureSplitEnd != null)
          ? firstFeatureSplitEnd
          : (i == _features.length)
          ? (firstFeatureSplitStart ?? const <_Cubic>[])
          : _features[i].cubics;
      if (featureCubics.isEmpty) continue;
      for (final cubic in featureCubics) {
        if (!cubic.zeroLength()) {
          if (lastCubic != null) out.add(lastCubic);
          lastCubic = cubic;
          firstCubic ??= cubic;
        } else {
          if (lastCubic != null) {
            lastCubic = _Cubic(
              lastCubic.anchor0X,
              lastCubic.anchor0Y,
              lastCubic.control0X,
              lastCubic.control0Y,
              lastCubic.control1X,
              lastCubic.control1Y,
              cubic.anchor1X,
              cubic.anchor1Y,
            );
          }
        }
      }
    }
    if (lastCubic != null && firstCubic != null) {
      out.add(
        _Cubic(
          lastCubic.anchor0X,
          lastCubic.anchor0Y,
          lastCubic.control0X,
          lastCubic.control0Y,
          lastCubic.control1X,
          lastCubic.control1Y,
          firstCubic.anchor0X,
          firstCubic.anchor0Y,
        ),
      );
    } else {
      out.add(_Cubic.empty(_center.dx, _center.dy));
    }
    return out;
  }

  Path toPath() {
    final cs = cubics;
    final path = Path();
    if (cs.isEmpty) return path;
    final first = cs.first;
    path.moveTo(first.anchor0X, first.anchor0Y);
    for (final c in cs) {
      path.cubicTo(
        c.control0X,
        c.control0Y,
        c.control1X,
        c.control1Y,
        c.anchor1X,
        c.anchor1Y,
      );
    }
    path.close();
    return path;
  }

  Rect calculateBounds({bool approximate = true}) {
    double minX = double.infinity,
        minY = double.infinity,
        maxX = -double.infinity,
        maxY = -double.infinity;
    final tmp = List<double>.filled(4, 0);
    for (final c in cubics) {
      c.calculateBounds(tmp, approximate: approximate);
      minX = math.min(minX, tmp[0]);
      minY = math.min(minY, tmp[1]);
      maxX = math.max(maxX, tmp[2]);
      maxY = math.max(maxY, tmp[3]);
    }
    if (!minX.isFinite) {
      return Rect.fromLTWH(_center.dx, _center.dy, 0, 0);
    }
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  Rect calculateMaxBounds() {
    var maxDist2 = 0.0;
    for (final c in cubics) {
      final ax = c.anchor0X - _center.dx;
      final ay = c.anchor0Y - _center.dy;
      final anchorD2 = _distanceSquared(ax, ay);
      final m = c.pointOnCurve(0.5);
      final mx = m.dx - _center.dx;
      final my = m.dy - _center.dy;
      final middleD2 = _distanceSquared(mx, my);
      maxDist2 = math.max(maxDist2, math.max(anchorD2, middleD2));
    }
    final d = math.sqrt(maxDist2);
    return Rect.fromLTRB(
      _center.dx - d,
      _center.dy - d,
      _center.dx + d,
      _center.dy + d,
    );
  }
}

abstract class MaterialTransforms {
  static PointTransformer rotateDegrees(double degrees) {
    final rad = degrees * math.pi / 180.0;
    final cosA = math.cos(rad);
    final sinA = math.sin(rad);
    return (p) => Vector2(
      (p.x * cosA - p.y * sinA).toDouble(),
      (p.x * sinA + p.y * cosA).toDouble(),
    );
  }

  static PointTransformer scale(double sx, double sy) =>
      (p) => Vector2((p.x * sx).toDouble(), (p.y * sy).toDouble());
}

// MARK: helpers and internals

const double _distanceEpsilon = 1e-6;

double _distance(double dx, double dy) => math.sqrt(dx * dx + dy * dy);
double _distanceSquared(double dx, double dy) => dx * dx + dy * dy;
double _square(double v) => v * v;

// Vector helpers extension to replace _Pt and globals
extension on Vector2 {
  Vector2 rotated90() => Vector2(-y, x);
  double dotXY(double dx, double dy) => x * dx + y * dy;
  Vector2 normalizedOrZero([double eps = _distanceEpsilon]) {
    final len = length;
    if (len < eps) return Vector2.zero();
    return this * (1.0 / len);
  }

  Vector2 lerpTo(Vector2 other, double t) =>
      Vector2(x + (other.x - x) * t, y + (other.y - y) * t);
}

bool _convex(Vector2 prev, Vector2 curr, Vector2 next) {
  final v0 = prev - curr;
  final v1 = next - curr;
  final cross = v0.x * v1.y - v0.y * v1.x;
  return cross < 0;
}

class _Cubic {
  final double anchor0X,
      anchor0Y,
      control0X,
      control0Y,
      control1X,
      control1Y,
      anchor1X,
      anchor1Y;
  const _Cubic(
    this.anchor0X,
    this.anchor0Y,
    this.control0X,
    this.control0Y,
    this.control1X,
    this.control1Y,
    this.anchor1X,
    this.anchor1Y,
  );

  factory _Cubic.fromPts(Vector2 a0, Vector2 c0, Vector2 c1, Vector2 a1) =>
      _Cubic(a0.x, a0.y, c0.x, c0.y, c1.x, c1.y, a1.x, a1.y);

  static _Cubic straightLine(double x0, double y0, double x1, double y1) {
    return _Cubic(
      x0,
      y0,
      _interpolate(x0, x1, 1 / 3),
      _interpolate(y0, y1, 1 / 3),
      _interpolate(x0, x1, 2 / 3),
      _interpolate(y0, y1, 2 / 3),
      x1,
      y1,
    );
  }

  static _Cubic circularArc(
    double centerX,
    double centerY,
    double x0,
    double y0,
    double x1,
    double y1,
  ) {
    final p0d = Vector2(x0 - centerX, y0 - centerY).normalizedOrZero();
    final p1d = Vector2(x1 - centerX, y1 - centerY).normalizedOrZero();
    final rotatedP0 = p0d.rotated90();
    final rotatedP1 = p1d.rotated90();
    final clockwise = rotatedP0.dotXY(x1 - centerX, y1 - centerY) >= 0;
    final cosa = p0d.dot(p1d);
    if (cosa > 0.999) return straightLine(x0, y0, x1, y1);
    final k =
        _distance(x0 - centerX, y0 - centerY) *
        4.0 /
        3.0 *
        (math.sqrt(2 * (1 - cosa)) - math.sqrt(1 - cosa * cosa)) /
        (1 - cosa) *
        (clockwise ? 1.0 : -1.0);
    return _Cubic(
      x0,
      y0,
      x0 + rotatedP0.x * k,
      y0 + rotatedP0.y * k,
      x1 - rotatedP1.x * k,
      y1 - rotatedP1.y * k,
      x1,
      y1,
    );
  }

  bool zeroLength() =>
      (anchor0X - anchor1X).abs() < _distanceEpsilon &&
      (anchor0Y - anchor1Y).abs() < _distanceEpsilon;

  _Cubic reverse() => _Cubic(
    anchor1X,
    anchor1Y,
    control1X,
    control1Y,
    control0X,
    control0Y,
    anchor0X,
    anchor0Y,
  );

  _PairCubic split(double t) {
    final u = 1 - t;
    final px =
        anchor0X * (u * u * u) +
        control0X * (3 * t * u * u) +
        control1X * (3 * t * t * u) +
        anchor1X * (t * t * t);
    final py =
        anchor0Y * (u * u * u) +
        control0Y * (3 * t * u * u) +
        control1Y * (3 * t * t * u) +
        anchor1Y * (t * t * t);
    final p = Vector2(px, py);
    final left = _Cubic(
      anchor0X,
      anchor0Y,
      anchor0X * u + control0X * t,
      anchor0Y * u + control0Y * t,
      anchor0X * (u * u) + control0X * (2 * u * t) + control1X * (t * t),
      anchor0Y * (u * u) + control0Y * (2 * u * t) + control1Y * (t * t),
      p.x,
      p.y,
    );
    final right = _Cubic(
      p.x,
      p.y,
      control0X * (u * u) + control1X * (2 * u * t) + anchor1X * (t * t),
      control0Y * (u * u) + control1Y * (2 * u * t) + anchor1Y * (t * t),
      control1X * u + anchor1X * t,
      control1Y * u + anchor1Y * t,
      anchor1X,
      anchor1Y,
    );
    return _PairCubic(left, right);
  }

  void calculateBounds(List<double> out, {bool approximate = false}) {
    if (zeroLength()) {
      out[0] = anchor0X;
      out[1] = anchor0Y;
      out[2] = anchor0X;
      out[3] = anchor0Y;
      return;
    }
    double minX = math.min(anchor0X, anchor1X),
        minY = math.min(anchor0Y, anchor1Y);
    double maxX = math.max(anchor0X, anchor1X),
        maxY = math.max(anchor0Y, anchor1Y);
    if (approximate) {
      minX = math.min(minX, math.min(control0X, control1X));
      minY = math.min(minY, math.min(control0Y, control1Y));
      maxX = math.max(maxX, math.max(control0X, control1X));
      maxY = math.max(maxY, math.max(control0Y, control1Y));
      out[0] = minX;
      out[1] = minY;
      out[2] = maxX;
      out[3] = maxY;
      return;
    }

    double xa = -anchor0X + 3 * control0X - 3 * control1X + anchor1X;
    double xb = 2 * anchor0X - 4 * control0X + 2 * control1X;
    double xc = -anchor0X + control0X;
    void updateX(double t) {
      if (t >= 0 && t <= 1) {
        final u = 1 - t;
        final x =
            anchor0X * (u * u * u) +
            control0X * (3 * t * u * u) +
            control1X * (3 * t * t * u) +
            anchor1X * (t * t * t);
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
      }
    }

    if (xa.abs() < _distanceEpsilon) {
      if (xb != 0) updateX(2 * xc / (-2 * xb));
    } else {
      final xs = xb * xb - 4 * xa * xc;
      if (xs >= 0) {
        final sxs = math.sqrt(xs);
        updateX((-xb + sxs) / (2 * xa));
        updateX((-xb - sxs) / (2 * xa));
      }
    }

    double ya = -anchor0Y + 3 * control0Y - 3 * control1Y + anchor1Y;
    double yb = 2 * anchor0Y - 4 * control0Y + 2 * control1Y;
    double yc = -anchor0Y + control0Y;
    void updateY(double t) {
      if (t >= 0 && t <= 1) {
        final u = 1 - t;
        final y =
            anchor0Y * (u * u * u) +
            control0Y * (3 * t * u * u) +
            control1Y * (3 * t * t * u) +
            anchor1Y * (t * t * t);
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }

    if (ya.abs() < _distanceEpsilon) {
      if (yb != 0) updateY(2 * yc / (-2 * yb));
    } else {
      final ys = yb * yb - 4 * ya * yc;
      if (ys >= 0) {
        final sys = math.sqrt(ys);
        updateY((-yb + sys) / (2 * ya));
        updateY((-yb - sys) / (2 * ya));
      }
    }

    out[0] = minX;
    out[1] = minY;
    out[2] = maxX;
    out[3] = maxY;
  }

  Offset pointOnCurve(double t) {
    final u = 1 - t;
    return Offset(
      anchor0X * (u * u * u) +
          control0X * (3 * t * u * u) +
          control1X * (3 * t * t * u) +
          anchor1X * (t * t * t),
      anchor0Y * (u * u * u) +
          control0Y * (3 * t * u * u) +
          control1Y * (3 * t * t * u) +
          anchor1Y * (t * t * t),
    );
  }

  _Cubic transformed(PointTransformer f) {
    Vector2 tr(double x, double y) => f(Vector2(x, y));
    final a0 = tr(anchor0X, anchor0Y);
    final c0 = tr(control0X, control0Y);
    final c1 = tr(control1X, control1Y);
    final a1 = tr(anchor1X, anchor1Y);
    return _Cubic(a0.x, a0.y, c0.x, c0.y, c1.x, c1.y, a1.x, a1.y);
  }

  static _Cubic empty(double x0, double y0) =>
      _Cubic(x0, y0, x0, y0, x0, y0, x0, y0);
}

class _PairCubic {
  final _Cubic first;
  final _Cubic second;
  _PairCubic(this.first, this.second);
}

double _interpolate(double a, double b, double t) => a + (b - a) * t;

class _Feature {
  final List<_Cubic> cubics;
  final bool convex; // only meaningful for Corner
  const _Feature._(this.cubics, this.convex);

  factory _Feature.corner(List<_Cubic> cubics, bool convex) =>
      _Feature._(cubics, convex);
  factory _Feature.edge(List<_Cubic> cubics) => _Feature._(cubics, true);

  _Feature transformed(PointTransformer f) =>
      _Feature._(cubics.map((c) => c.transformed(f)).toList(), convex);
}

class _RoundedCorner {
  final Vector2 p0; // previous vertex
  final Vector2 p1; // corner vertex
  final Vector2 p2; // next vertex
  final CornerRounding? rounding;

  late final Vector2 d1;
  late final Vector2 d2;
  late final double cornerRadius;
  late final double smoothing;
  late final double cosAngle;
  late final double sinAngle;
  late final double expectedRoundCut;
  late Vector2 center;

  _RoundedCorner(this.p0, this.p1, this.p2, this.rounding) {
    final v01 = p0 - p1;
    final v21 = p2 - p1;
    final d01 = v01.length;
    final d21 = v21.length;
    if (d01 > 0 && d21 > 0) {
      d1 = v01 * (1.0 / d01);
      d2 = v21 * (1.0 / d21);
      cornerRadius = (rounding?.radius ?? 0).toDouble();
      smoothing = (rounding?.smoothing ?? 0).toDouble();
      cosAngle = d1.dot(d2);
      sinAngle = math.sqrt(math.max(0.0, 1 - _square(cosAngle)));
      expectedRoundCut = sinAngle > 1e-3
          ? cornerRadius * (cosAngle + 1) / sinAngle
          : 0.0;
    } else {
      d1 = Vector2.zero();
      d2 = Vector2.zero();
      cornerRadius = 0;
      smoothing = 0;
      cosAngle = 0;
      sinAngle = 0;
      expectedRoundCut = 0;
    }
    center = Vector2.zero();
  }

  double get expectedCut => (1 + smoothing) * expectedRoundCut;

  List<_Cubic> getCubics(double allowedCut0, [double? allowedCut1]) {
    final cut1 = allowedCut1 ?? allowedCut0;
    final allowedCut = math.min(allowedCut0, cut1);
    if (expectedRoundCut < _distanceEpsilon ||
        allowedCut < _distanceEpsilon ||
        cornerRadius < _distanceEpsilon) {
      center = p1;
      return [_Cubic.straightLine(p1.x, p1.y, p1.x, p1.y)];
    }
    final actualRoundCut = math.min(allowedCut, expectedRoundCut);
    double calcActualSmoothing(double allowedCut) {
      if (allowedCut > expectedCut) return smoothing;
      if (allowedCut > expectedRoundCut) {
        final denom = (expectedCut - expectedRoundCut);
        return denom == 0
            ? 0
            : smoothing * (allowedCut - expectedRoundCut) / denom;
      }
      return 0;
    }

    final actualSmoothing0 = calcActualSmoothing(allowedCut0);
    final actualSmoothing1 = calcActualSmoothing(cut1);
    final actualR =
        cornerRadius *
        (expectedRoundCut == 0 ? 0 : (actualRoundCut / expectedRoundCut));
    final centerDistance = math.sqrt(
      _square(actualR) + _square(actualRoundCut),
    );
    center = p1 + ((d1 + d2) * 0.5).normalizedOrZero() * centerDistance;
    final circleIntersection0 = p1 + d1 * actualRoundCut;
    final circleIntersection2 = p1 + d2 * actualRoundCut;

    _Cubic computeFlankingCurve(
      double actualRoundCut,
      double actualSmoothing,
      Vector2 corner,
      Vector2 sideStart,
      Vector2 circleSegmentIntersection,
      Vector2 otherCircleSegmentIntersection,
      Vector2 circleCenter,
      double actualR,
    ) {
      final sideDirection = (sideStart - corner).normalizedOrZero();
      final curveStart =
          corner + sideDirection * actualRoundCut * (1 + actualSmoothing);
      final mid =
          (circleSegmentIntersection + otherCircleSegmentIntersection) * 0.5;
      final p = circleSegmentIntersection.lerpTo(mid, actualSmoothing);
      final curveEnd =
          circleCenter + (p - circleCenter).normalizedOrZero() * actualR;
      final circleTangent = (curveEnd - circleCenter).rotated90();
      final anchorEnd =
          _lineIntersection(
            sideStart,
            sideDirection,
            curveEnd,
            circleTangent,
          ) ??
          circleSegmentIntersection;
      final anchorStart = (curveStart + anchorEnd * 2.0) * (1.0 / 3.0);
      return _Cubic.fromPts(curveStart, anchorStart, anchorEnd, curveEnd);
    }

    final flanking0 = computeFlankingCurve(
      actualRoundCut,
      actualSmoothing0,
      p1,
      p0,
      circleIntersection0,
      circleIntersection2,
      center,
      actualR,
    );
    final flanking2 = computeFlankingCurve(
      actualRoundCut,
      actualSmoothing1,
      p1,
      p2,
      circleIntersection2,
      circleIntersection0,
      center,
      actualR,
    ).reverse();

    return [
      flanking0,
      _Cubic.circularArc(
        center.x,
        center.y,
        flanking0.anchor1X,
        flanking0.anchor1Y,
        flanking2.anchor0X,
        flanking2.anchor0Y,
      ),
      flanking2,
    ];
  }

  Vector2? _lineIntersection(Vector2 p0, Vector2 d0, Vector2 p1, Vector2 d1) {
    final rotatedD1 = d1.rotated90();
    final den = d0.dot(rotatedD1);
    if (den.abs() < _distanceEpsilon) return null;
    final num = (p1 - p0).dot(rotatedD1);
    if (den.abs() < _distanceEpsilon * num.abs()) return null;
    final k = num / den;
    return p0 + d0 * k;
  }
}

class _Pair {
  final double first;
  final double second;
  const _Pair(this.first, this.second);
}

List<double> _verticesFromNumVertices(
  int numVertices,
  double radius,
  double centerX,
  double centerY,
) {
  final result = List<double>.filled(numVertices * 2, 0);
  var ai = 0;
  for (var i = 0; i < numVertices; i++) {
    final angle = (math.pi / numVertices * 2 * i);
    final vertex =
        Vector2(radius * math.cos(angle), radius * math.sin(angle)) +
        Vector2(centerX, centerY);
    result[ai++] = vertex.x;
    result[ai++] = vertex.y;
  }
  return result;
}

Vector2 _calculateCenter(List<double> vertices) {
  var sumX = 0.0, sumY = 0.0;
  for (var i = 0; i < vertices.length; i += 2) {
    sumX += vertices[i];
    sumY += vertices[i + 1];
  }
  final n = vertices.length / 2;
  return Vector2(sumX / n, sumY / n);
}

// MARK: Builders

/// Utilities to build complex RoundedPolygons.
abstract class RoundedPolygonBuilder {
  /// Builds a polygon by repeating, rotating, and optionally mirroring a set of
  /// seed points around a center.
  static RoundedPolygon customPolygon(
    List<PointNRound> pnr,
    int reps, {
    Offset center = const Offset(0.5, 0.5),
    bool mirroring = false,
  }) {
    if (pnr.isEmpty) {
      throw ArgumentError.value(
        pnr.length,
        "pnr",
        "Must provide at least one point",
      );
    }
    if (reps < 1) {
      throw ArgumentError.value(reps, "reps", "Repetition count must be >= 1");
    }

    List<PointNRound> doRepeat(
      List<PointNRound> points,
      int reps,
      Offset center,
      bool mirroring,
    ) {
      if (mirroring) {
        final angles = points
            .map((e) => math.atan2(e.o.dy - center.dy, e.o.dx - center.dx))
            .toList(growable: false);
        final distances = points
            .map((e) {
              final dx = e.o.dx - center.dx;
              final dy = e.o.dy - center.dy;
              return math.sqrt(dx * dx + dy * dy);
            })
            .toList(growable: false);
        final actualReps = reps * 2;
        final sectionAngle = 2 * math.pi / actualReps;

        final out = <PointNRound>[];
        for (var it = 0; it < actualReps; it++) {
          for (var index = 0; index < points.length; index++) {
            final i = (it % 2 == 0) ? index : (points.length - 1 - index);
            if (i > 0 || it % 2 == 0) {
              final double a = (it % 2 == 0)
                  ? (sectionAngle * it + angles[i])
                  : (sectionAngle * it +
                        sectionAngle -
                        angles[i] +
                        2 * angles[0]);
              final dir = Offset(math.cos(a), math.sin(a));
              final finalPoint = dir * distances[i] + center;
              out.add(PointNRound(finalPoint, points[i].r));
            }
          }
        }
        return out;
      } else {
        final np = points.length;
        final out = <PointNRound>[];
        for (var t = 0; t < np * reps; t++) {
          final idx = t % np;
          final turn = t ~/ np;
          final angle = turn * (2 * math.pi / reps);
          final cosA = math.cos(angle);
          final sinA = math.sin(angle);
          final dx = points[idx].o.dx - center.dx;
          final dy = points[idx].o.dy - center.dy;
          final rx = dx * cosA - dy * sinA;
          final ry = dx * sinA + dy * cosA;
          final rotated = Offset(center.dx + rx, center.dy + ry);
          out.add(PointNRound(rotated, points[idx].r));
        }
        return out;
      }
    }

    final actualPoints = (reps == 1 && !mirroring)
        ? List<PointNRound>.from(pnr)
        : doRepeat(pnr, reps, center, mirroring);

    final vertices = List<double>.filled(actualPoints.length * 2, 0);
    for (var ix = 0; ix < actualPoints.length * 2; ix++) {
      final pt = actualPoints[ix ~/ 2].o;
      vertices[ix] = (ix % 2 == 0) ? pt.dx : pt.dy;
    }
    final perVertexRounding = <CornerRounding>[
      for (final p in actualPoints) p.r,
    ];
    return RoundedPolygon.fromVertices(
      vertices: vertices,
      perVertexRounding: perVertexRounding,
      centerX: center.dx,
      centerY: center.dy,
    );
  }
}
