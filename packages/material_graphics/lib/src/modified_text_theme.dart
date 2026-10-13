import 'package:material_ui/material_ui.dart';

extension ModifiedTextTheme on TextTheme {
  TextTheme get material {
    final base = apply(
      fontFamily: "GoogleSansFlex",
      package: "material_graphics",
    );

    // the following values are extracted from the official Material 3
    // documentation. read more here:
    // https://m3.material.io/styles/typography/type-scale-tokens

    return base.copyWith(
      labelSmall: base.labelSmall!.copyWith(
        fontSize: 11,
        letterSpacing: 0.1,
        fontFeatures: _features,
        fontVariations: _variations(weight: 500, opticalSize: 11),
      ),
      labelMedium: base.labelMedium!.copyWith(
        fontSize: 12,
        letterSpacing: 0.1,
        fontFeatures: _features,
        fontVariations: _variations(weight: 500, opticalSize: 12),
      ),
      labelLarge: base.labelLarge!.copyWith(
        fontSize: 14,
        letterSpacing: 0,
        fontFeatures: _features,
        fontVariations: _variations(weight: 500, opticalSize: 14),
      ),
      bodySmall: base.bodySmall!.copyWith(
        fontSize: 12,
        letterSpacing: 0.1,
        fontFeatures: _features,
        fontVariations: _variations(opticalSize: 12),
      ),
      bodyMedium: base.bodyMedium!.copyWith(
        fontSize: 14,
        letterSpacing: 0,
        fontFeatures: _features,
        fontVariations: _variations(opticalSize: 14),
      ),
      bodyLarge: base.bodyLarge!.copyWith(
        fontSize: 16,
        letterSpacing: 0,
        fontFeatures: _features,
        fontVariations: _variations(opticalSize: 16),
      ),
      displaySmall: base.displaySmall!.copyWith(
        fontSize: 36,
        letterSpacing: 0,
        fontFeatures: _features,
        fontVariations: _variations(opticalSize: 36),
      ),
      displayMedium: base.displayMedium!.copyWith(
        fontSize: 45,
        letterSpacing: 0,
        fontFeatures: _features,
        fontVariations: _variations(opticalSize: 45),
      ),
      displayLarge: base.displayLarge!.copyWith(
        fontSize: 57,
        letterSpacing: 0,
        fontFeatures: _features,
        fontVariations: _variations(opticalSize: 57),
      ),
      headlineSmall: base.headlineSmall!.copyWith(
        fontSize: 24,
        letterSpacing: 0,
        fontFeatures: _features,
        fontVariations: _variations(opticalSize: 24),
      ),
      headlineMedium: base.headlineMedium!.copyWith(
        fontSize: 28,
        letterSpacing: 0,
        fontFeatures: _features,
        fontVariations: _variations(opticalSize: 28),
      ),
      headlineLarge: base.headlineLarge!.copyWith(
        fontSize: 32,
        letterSpacing: 0,
        fontFeatures: _features,
        fontVariations: _variations(opticalSize: 32),
      ),
      titleSmall: base.titleSmall!.copyWith(
        fontSize: 14,
        letterSpacing: 0,
        fontFeatures: _features,
        fontVariations: _variations(
          weight: 500,
          roundness: 100,
          opticalSize: 14,
        ),
      ),
      titleMedium: base.titleMedium!.copyWith(
        fontSize: 16,
        letterSpacing: 0,
        fontFeatures: _features,
        fontVariations: _variations(
          weight: 500,
          roundness: 100,
          opticalSize: 16,
        ),
      ),
      titleLarge: base.titleLarge!.copyWith(
        fontSize: 22,
        letterSpacing: 0,
        fontFeatures: _features,
        fontVariations: _variations(
          weight: 500,
          roundness: 100,
          opticalSize: 22,
        ),
      ),
    );
  }
}

final _features = [FontFeature.enable("ss01"), FontFeature.disable("calt")];
List<FontVariation> _variations({
  double weight = 400,
  double roundness = 0,
  double opticalSize = 14,
}) => [
  FontVariation("wght", weight),
  FontVariation("ROND", roundness),
  FontVariation("opsz", opticalSize),
];
