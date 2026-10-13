import 'package:material_ui/material_ui.dart';

extension ModifiedTextStyle on TextStyle {
  TextStyle get rounded => copyWith(
    fontVariations: [...?fontVariations, FontVariation("ROND", 100)],
  );

  TextStyle get bagelFatOne =>
      copyWith(fontFamily: "BagelFatOne", package: "material_graphics");
  TextStyle get googleSansCode =>
      copyWith(fontFamily: "GoogleSansCode", package: "material_graphics");
  TextStyle get googleSansFlex =>
      copyWith(fontFamily: "GoogleSansFlex", package: "material_graphics");
}
