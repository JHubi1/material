/// Material Graphics Library
library;

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

export 'package:simple_icons/simple_icons.dart';

export 'src/curves.dart';
export 'src/icon_composer.dart';
export 'src/modified_text_style.dart';
export 'src/modified_text_theme.dart';
export 'src/shapes/material_shapes.dart';

/// Font licenses used by the Material Graphics library.
///
/// Key contains the font names, value the header of their OFL license file. If
/// null, no header is added.
final _fontLicenses = <String, String?>{
  "Bagel Fat One":
      "Copyright 2022 The Bagel Fat Project Authors (https://github.com/JAMO-TYPEFACE/BagelFat)",
  "Google Sans Code":
      "Copyright 2025 The Google Sans Code Project Authors (github.com/googlefonts/googlesans-code)",
  "Google Sans Flex": null,
};

/// Registers font licenses for the Material Graphics library.
Future<void> registerLicenses(BuildContext context) async {
  final ofl = await DefaultAssetBundle.of(
    context,
  ).loadString("packages/material_graphics/assets/fonts/OFL.txt");
  for (final entry in _fontLicenses.entries) {
    LicenseRegistry.addLicense(() async* {
      yield LicenseEntryWithLineBreaks([
        entry.key,
      ], entry.value != null ? "${entry.value}\n\n$ofl" : ofl);
    });
  }
}
