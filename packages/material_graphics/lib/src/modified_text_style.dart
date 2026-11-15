import 'package:material_ui/material_ui.dart';

extension ModifiedTextStyle on TextStyle {
  TextStyle get rounded => copyWith(
    fontVariations: [...?fontVariations, FontVariation("ROND", 100)],
  );

  TextStyle get bagelFatOne =>
      copyWith(fontFamily: "BagelFatOne", package: "material_graphics");
  TextStyle get googleSansCode =>
      copyWith(fontFamily: "GoogleSansCode", package: "material_graphics");
  TextStyle get googleSansFlex => copyWith(
    fontFamily: "GoogleSansFlex",
    package: "material_graphics",
    fontFeatures: [FontFeature.enable("ss01"), FontFeature.disable("calt")],
    fontVariations: [
      ...?fontVariations,
      if (fontSize != null) FontVariation("opsz", fontSize!),
    ],
  );

  TextStyle googleSansFlexExt({
    double? weight,
    double? roundness,
    double? opticalSize,
  }) {
    final weightTmp =
        weight ??
        fontVariations?.firstWhereOrNull((v) => v.axis == "wght")?.value;
    final roundnessTmp =
        roundness ??
        fontVariations?.firstWhereOrNull((v) => v.axis == "ROND")?.value;
    final opticalSizeTmp =
        opticalSize ??
        fontVariations?.firstWhereOrNull((v) => v.axis == "opsz")?.value;
    return googleSansFlex.copyWith(
      fontVariations: [
        ...List.from(fontVariations ?? [])
          ..removeWhere((v) => ["wght", "ROND", "opsz"].contains(v.axis)),
        if (weightTmp != null) FontVariation("wght", weightTmp),
        if (roundnessTmp != null) FontVariation("ROND", roundnessTmp),
        if (opticalSizeTmp != null) FontVariation("opsz", opticalSizeTmp),
      ],
    );
  }
}

extension _ListExtension<E> on List<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
