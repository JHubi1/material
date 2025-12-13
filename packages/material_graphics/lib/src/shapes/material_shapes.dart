/// A Flutter port of AndroidX MaterialShapes and everything around them.
///
/// Licensed under Apache-2.0:
/// https://android.googlesource.com/platform/frameworks/support/%2B/androidx-master-dev/LICENSE.txt
///
/// References:
/// - https://cs.android.com/androidx/platform/frameworks/support/+/androidx-main:compose/material3/material3/src/commonMain/kotlin/androidx/compose/material3/MaterialShapes.kt
/// - https://cs.android.com/androidx/platform/frameworks/support/+/androidx-main:graphics/graphics-shapes/src/commonMain/kotlin/androidx/graphics/shapes/RoundedPolygon.kt
/// - https://cs.android.com/androidx/platform/frameworks/support/+/androidx-main:graphics/graphics-shapes/src/commonMain/kotlin/androidx/graphics/shapes/Shapes.kt
library;

// TODO: Add an image to all MaterialShapes documentation.
// Crop from: https://m3.material.io/styles/shape/overview-principles#579dd4ba-39f3-4e60-bd9b-1d97ed6ef1bf

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' show Vector2;
import 'rounded_polygon.dart';

const CornerRounding _cornerRound15 = CornerRounding(0.15);
const CornerRounding _cornerRound20 = CornerRounding(0.2);
const CornerRounding _cornerRound30 = CornerRounding(0.3);
const CornerRounding _cornerRound50 = CornerRounding(0.5);
const CornerRounding _cornerRound100 = CornerRounding(1.0);

final PointTransformer _rotateNeg45 = MaterialTransforms.rotateDegrees(-45);
final PointTransformer _rotateNeg90 = MaterialTransforms.rotateDegrees(-90);
final PointTransformer _rotateNeg135 = MaterialTransforms.rotateDegrees(-135);

abstract class MaterialShapes {
  /// The Material Shape called "Circle".
  static ShapeBorder circle = RoundedPolygonBorder(
    polygon: RoundedPolygon.circle(numVertices: 10),
  );

  /// The Material Shape called "Square".
  static ShapeBorder square = RoundedPolygonBorder(
    polygon: RoundedPolygon.rectangle(
      width: 1,
      height: 1,
      rounding: _cornerRound30,
    ),
  );

  /// The Material Shape called "Slanted".
  static ShapeBorder slanted = RoundedPolygonBorder(
    polygon: RoundedPolygonBuilder.customPolygon([
      PointNRound(Offset(0.926, 0.970), CornerRounding(0.189, 0.811)),
      PointNRound(Offset(-0.021, 0.967), CornerRounding(0.187, 0.057)),
    ], 2),
  );

  /// The Material Shape called "Arch".
  static ShapeBorder arch = RoundedPolygonBorder(
    polygon: RoundedPolygon.fromNumVertices(
      numVertices: 4,
      perVertexRounding: [
        _cornerRound100,
        _cornerRound100,
        _cornerRound20,
        _cornerRound20,
      ],
    ).transformed(_rotateNeg135),
  );

  /// The Material Shape called "Fan".
  static ShapeBorder fan = RoundedPolygonBorder(
    polygon: RoundedPolygonBuilder.customPolygon([
      PointNRound(Offset(1.004, 1.000), CornerRounding(0.148, 0.417)),
      PointNRound(Offset(0.000, 1.000), CornerRounding(0.151)),
      PointNRound(Offset(0.000, -0.003), CornerRounding(0.148)),
      PointNRound(Offset(0.978, 0.020), CornerRounding(0.803)),
    ], 1),
  );

  /// The Material Shape called "Arrow".
  static ShapeBorder arrow = RoundedPolygonBorder(
    polygon: RoundedPolygonBuilder.customPolygon([
      PointNRound(Offset(0.500, 0.892), CornerRounding(0.313)),
      PointNRound(Offset(-0.216, 1.050), CornerRounding(0.207)),
      PointNRound(Offset(0.499, -0.160), CornerRounding(0.215, 1.000)),
      PointNRound(Offset(1.225, 1.060), CornerRounding(0.211)),
    ], 1),
  );

  /// The Material Shape called "Semi Circle".
  static ShapeBorder semiCircle = RoundedPolygonBorder(
    polygon: RoundedPolygon.rectangle(
      width: 1.6,
      height: 1,
      perVertexRounding: [
        _cornerRound20,
        _cornerRound20,
        _cornerRound100,
        _cornerRound100,
      ],
    ),
  );

  /// The Material Shape called "Oval".
  static ShapeBorder oval = RoundedPolygonBorder(
    polygon: RoundedPolygon.circle()
        .transformed(MaterialTransforms.scale(1, 0.64))
        .transformed(_rotateNeg45),
  );

  /// The Material Shape called "Pill".
  static ShapeBorder pill = RoundedPolygonBorder(
    polygon: RoundedPolygonBuilder.customPolygon(
      [
        PointNRound(Offset(0.961, 0.039), CornerRounding(0.426)),
        PointNRound(Offset(1.001, 0.428)),
        PointNRound(Offset(1.000, 0.609), CornerRounding(1.000)),
      ],
      2,
      mirroring: true,
    ),
  );

  /// The Material Shape called "Triangle".
  static ShapeBorder triangle = RoundedPolygonBorder(
    polygon: RoundedPolygon.fromNumVertices(
      numVertices: 3,
      rounding: _cornerRound20,
    ).transformed(_rotateNeg90),
  );

  /// The Material Shape called "Diamond".
  static ShapeBorder diamond = RoundedPolygonBorder(
    polygon: RoundedPolygonBuilder.customPolygon([
      PointNRound(Offset(0.500, 1.096), CornerRounding(0.151, 0.524)),
      PointNRound(Offset(0.040, 0.500), CornerRounding(0.159)),
    ], 2),
  );

  /// The Material Shape called "Clam Shell".
  static ShapeBorder clamShell = RoundedPolygonBorder(
    polygon: RoundedPolygonBuilder.customPolygon([
      PointNRound(Offset(0.171, 0.841), CornerRounding(0.159)),
      PointNRound(Offset(-0.020, 0.500), CornerRounding(0.140)),
      PointNRound(Offset(0.17, 0.159), CornerRounding(0.159)),
    ], 2),
  );

  /// The Material Shape called "Pentagon".
  static ShapeBorder pentagon = RoundedPolygonBorder(
    polygon: RoundedPolygonBuilder.customPolygon(
      [
        PointNRound(Offset(0.500, -0.009), CornerRounding(0.172)),
        PointNRound(Offset(1.030, 0.365), CornerRounding(0.164)),
        PointNRound(Offset(0.828, 0.970), CornerRounding(0.169)),
      ],
      1,
      mirroring: true,
    ),
  );

  /// The Material Shape called "Gem".
  static ShapeBorder gem = RoundedPolygonBorder(
    polygon: RoundedPolygonBuilder.customPolygon(
      [
        PointNRound(Offset(0.499, 1.023), CornerRounding(0.241, 0.778)),
        PointNRound(Offset(-0.005, 0.792), CornerRounding(0.208)),
        PointNRound(Offset(0.073, 0.258), CornerRounding(0.228)),
        PointNRound(Offset(0.433, -0.000), CornerRounding(0.491)),
      ],
      1,
      mirroring: true,
    ),
  );

  /// The Material Shape called "Sunny".
  static ShapeBorder sunny = RoundedPolygonBorder(
    polygon: RoundedPolygon.star(
      numVerticesPerRadius: 8,
      innerRadius: 0.800,
      rounding: _cornerRound15,
    ),
  );

  /// The Material Shape called "Very Sunny".
  static ShapeBorder verySunny = RoundedPolygonBorder(
    polygon: RoundedPolygonBuilder.customPolygon([
      PointNRound(Offset(0.500, 1.08), CornerRounding(0.085)),
      PointNRound(Offset(0.358, 0.843), CornerRounding(0.085)),
    ], 8),
  );

  /// The Material Shape called "4-Sided Cookie".
  static ShapeBorder cookie4Sided = RoundedPolygonBorder(
    polygon: RoundedPolygonBuilder.customPolygon([
      PointNRound(Offset(1.237, 1.236), CornerRounding(0.258)),
      PointNRound(Offset(0.500, 0.918), CornerRounding(0.233)),
    ], 4),
  );

  /// The Material Shape called "6-Sided Cookie".
  static ShapeBorder cookie6Sided = RoundedPolygonBorder(
    polygon: RoundedPolygonBuilder.customPolygon([
      PointNRound(Offset(0.723, 0.884), CornerRounding(0.394)),
      PointNRound(Offset(0.500, 1.099), CornerRounding(0.398)),
    ], 6),
  );

  /// The Material Shape called "7-Sided Cookie".
  static ShapeBorder cookie7Sided = RoundedPolygonBorder(
    polygon: RoundedPolygon.star(
      numVerticesPerRadius: 7,
      innerRadius: 0.750,
      rounding: _cornerRound50,
    ).transformed(_rotateNeg90),
  );

  /// The Material Shape called "9-Sided Cookie".
  static ShapeBorder cookie9Sided = RoundedPolygonBorder(
    polygon: RoundedPolygon.star(
      numVerticesPerRadius: 9,
      innerRadius: 0.800,
      rounding: _cornerRound50,
    ).transformed(_rotateNeg90),
  );

  /// The Material Shape called "12-Sided Cookie".
  static ShapeBorder cookie12Sided = RoundedPolygonBorder(
    polygon: RoundedPolygon.star(
      numVerticesPerRadius: 12,
      innerRadius: 0.800,
      rounding: _cornerRound50,
    ).transformed(_rotateNeg90),
  );

  /// The Material Shape called "Ghostish".
  static ShapeBorder ghostish = RoundedPolygonBorder(
    polygon: RoundedPolygonBuilder.customPolygon(
      [
        PointNRound(Offset(0.500, 0.000), CornerRounding(1.000)),
        PointNRound(Offset(1.000, 0.000), CornerRounding(1.000)),
        PointNRound(Offset(1.000, 1.140), CornerRounding(0.254, 0.106)),
        PointNRound(Offset(0.575, 0.906), CornerRounding(0.253)),
      ],
      1,
      mirroring: true,
    ),
  );

  /// The Material Shape called "4-Leaf Clover".
  static ShapeBorder clover4Leaf = RoundedPolygonBorder(
    polygon: RoundedPolygonBuilder.customPolygon(
      [
        PointNRound(Offset(0.500, 0.074)),
        PointNRound(Offset(0.725, -0.099), CornerRounding(0.476)),
      ],
      4,
      mirroring: true,
    ),
  );

  /// The Material Shape called "8-Leaf Clover".
  static ShapeBorder clover8Leaf = RoundedPolygonBorder(
    polygon: RoundedPolygonBuilder.customPolygon([
      PointNRound(Offset(0.500, 0.036)),
      PointNRound(Offset(0.758, -0.101), CornerRounding(0.209)),
    ], 8),
  );

  /// The Material Shape called "Burst".
  ///
  /// **WARNING:** This shape does not work well with
  /// [RoundedPolygonBorder.lerpTo] or [RoundedPolygonBorder.lerpFrom]! Do not
  /// use if that is the intended purpose!
  static ShapeBorder burst = RoundedPolygonBorder(
    polygon: RoundedPolygonBuilder.customPolygon([
      PointNRound(Offset(0.500, -0.006), CornerRounding(0.006)),
      PointNRound(Offset(0.592, 0.158), CornerRounding(0.006)),
    ], 12),
  );

  /// The Material Shape called "Soft Burst".
  ///
  /// **WARNING:** This shape does not work well with
  /// [RoundedPolygonBorder.lerpTo] or [RoundedPolygonBorder.lerpFrom]! Do not
  /// use if that is the intended purpose!
  static ShapeBorder softBurst = RoundedPolygonBorder(
    polygon: RoundedPolygonBuilder.customPolygon([
      PointNRound(Offset(0.193, 0.277), CornerRounding(0.053)),
      PointNRound(Offset(0.176, 0.055), CornerRounding(0.053)),
    ], 10),
  );

  /// The Material Shape called "Boom".
  static ShapeBorder boom = RoundedPolygonBorder(
    polygon: RoundedPolygonBuilder.customPolygon([
      PointNRound(Offset(0.457, 0.296), CornerRounding(0.007)),
      PointNRound(Offset(0.500, -0.051), CornerRounding(0.007)),
    ], 15),
  );

  /// The Material Shape called "Soft Boom".
  static ShapeBorder softBoom = RoundedPolygonBorder(
    polygon: RoundedPolygonBuilder.customPolygon(
      [
        PointNRound(Offset(0.733, 0.454)),
        PointNRound(Offset(0.839, 0.437), CornerRounding(0.532)),
        PointNRound(Offset(0.949, 0.449), CornerRounding(0.439, 1.000)),
        PointNRound(Offset(0.998, 0.478), CornerRounding(0.174)),
      ],
      16,
      mirroring: true,
    ),
  );

  /// The Material Shape called "Flower".
  static ShapeBorder flower = RoundedPolygonBorder(
    polygon: RoundedPolygonBuilder.customPolygon(
      [
        PointNRound(Offset(0.370, 0.187)),
        PointNRound(Offset(0.416, 0.049), CornerRounding(0.381)),
        PointNRound(Offset(0.479, 0.001), CornerRounding(0.095)),
      ],
      8,
      mirroring: true,
    ),
  );

  /// The Material Shape called "Puffy".
  static ShapeBorder puffy = RoundedPolygonBorder(
    polygon: RoundedPolygonBuilder.customPolygon(
      [
        PointNRound(Offset(0.500, 0.053)),
        PointNRound(Offset(0.545, -0.040), CornerRounding(0.405)),
        PointNRound(Offset(0.670, -0.035), CornerRounding(0.426)),
        PointNRound(Offset(0.717, 0.066), CornerRounding(0.574)),
        PointNRound(Offset(0.722, 0.128)),
        PointNRound(Offset(0.777, 0.002), CornerRounding(0.360)),
        PointNRound(Offset(0.914, 0.149), CornerRounding(0.660)),
        PointNRound(Offset(0.926, 0.289), CornerRounding(0.660)),
        PointNRound(Offset(0.881, 0.346)),
        PointNRound(Offset(0.940, 0.344), CornerRounding(0.126)),
        PointNRound(Offset(1.003, 0.437), CornerRounding(0.255)),
      ],
      2,
      mirroring: true,
    ).transformed((p) => Vector2(p.x, p.y * 0.742)),
  );

  /// The Material Shape called "Puffy Diamond".
  static ShapeBorder puffyDiamond = RoundedPolygonBorder(
    polygon: RoundedPolygonBuilder.customPolygon(
      [
        PointNRound(Offset(0.870, 0.130), CornerRounding(0.146)),
        PointNRound(Offset(0.818, 0.357)),
        PointNRound(Offset(1.000, 0.332), CornerRounding(0.853)),
      ],
      4,
      mirroring: true,
    ),
  );

  /// The Material Shape called "Pixel Circle".
  static ShapeBorder pixelCircle = RoundedPolygonBorder(
    polygon: RoundedPolygonBuilder.customPolygon(
      [
        PointNRound(Offset(0.500, 0.000)),
        PointNRound(Offset(0.704, 0.000)),
        PointNRound(Offset(0.704, 0.065)),
        PointNRound(Offset(0.843, 0.065)),
        PointNRound(Offset(0.843, 0.148)),
        PointNRound(Offset(0.926, 0.148)),
        PointNRound(Offset(0.926, 0.296)),
        PointNRound(Offset(1.000, 0.296)),
      ],
      2,
      mirroring: true,
    ),
  );

  /// The Material Shape called "Pixel Triangle".
  static ShapeBorder pixelTriangle = RoundedPolygonBorder(
    polygon: RoundedPolygonBuilder.customPolygon(
      [
        PointNRound(Offset(0.110, 0.500)),
        PointNRound(Offset(0.113, 0.000)),
        PointNRound(Offset(0.287, 0.000)),
        PointNRound(Offset(0.287, 0.087)),
        PointNRound(Offset(0.421, 0.087)),
        PointNRound(Offset(0.421, 0.170)),
        PointNRound(Offset(0.560, 0.170)),
        PointNRound(Offset(0.560, 0.265)),
        PointNRound(Offset(0.674, 0.265)),
        PointNRound(Offset(0.675, 0.344)),
        PointNRound(Offset(0.789, 0.344)),
        PointNRound(Offset(0.789, 0.439)),
        PointNRound(Offset(0.888, 0.439)),
      ],
      1,
      mirroring: true,
    ),
  );

  /// The Material Shape called "Bun".
  static ShapeBorder bun = RoundedPolygonBorder(
    polygon: RoundedPolygonBuilder.customPolygon(
      [
        PointNRound(Offset(0.796, 0.500)),
        PointNRound(Offset(0.853, 0.518), CornerRounding(1.000)),
        PointNRound(Offset(0.992, 0.631), CornerRounding(1.000)),
        PointNRound(Offset(0.968, 1.000), CornerRounding(1.000)),
      ],
      2,
      mirroring: true,
    ),
  );

  /// The Material Shape called "Heart".
  static ShapeBorder heart = RoundedPolygonBorder(
    polygon: RoundedPolygonBuilder.customPolygon(
      [
        PointNRound(Offset(0.500, 0.268), CornerRounding(0.016)),
        PointNRound(Offset(0.792, -0.066), CornerRounding(0.958)),
        PointNRound(Offset(1.064, 0.276), CornerRounding(1.000)),
        PointNRound(Offset(0.501, 0.946), CornerRounding(0.129)),
      ],
      1,
      mirroring: true,
    ),
  );

  /// A list of all Material Shapes defined in this class.
  static List<ShapeBorder> values = List.unmodifiable([
    circle,
    square,
    slanted,
    arch,
    fan,
    arrow,
    semiCircle,
    oval,
    pill,
    triangle,
    diamond,
    clamShell,
    pentagon,
    gem,
    sunny,
    verySunny,
    cookie4Sided,
    cookie6Sided,
    cookie7Sided,
    cookie9Sided,
    cookie12Sided,
    ghostish,
    clover4Leaf,
    clover8Leaf,
    burst,
    softBurst,
    boom,
    softBoom,
    flower,
    puffy,
    puffyDiamond,
    pixelCircle,
    pixelTriangle,
    bun,
    heart,
  ]);

  /// A list of Material Shapes suitable for containers.
  ///
  /// This may not include all shapes needed to get the job done, but this can
  /// be useful for simple access to common container shapes.
  static List<ShapeBorder> containers = List.unmodifiable([
    slanted,
    pill,
    pentagon,
    gem,
    sunny,
    verySunny,
    cookie4Sided,
    cookie6Sided,
    cookie7Sided,
    cookie9Sided,
    cookie12Sided,
    ghostish,
    clover4Leaf,
    clover8Leaf,
    softBurst,
    flower,
  ]);
}
