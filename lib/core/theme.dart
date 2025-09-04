import "package:config/config.dart";
import "package:config_gen/config_gen.dart";
import "package:flutter/material.dart";
import "package:flex_seed_scheme/flex_seed_scheme.dart";
import "package:waywing/util/config_fields.dart";

part "theme.g.dart";

@Config()
mixin ThemeConfigBase on ThemeConfigI {
  static const _mode = EnumField(ThemeMode.values, defaultTo: ThemeMode.system);

  static const _fontFamily = StringField(nullable: true);

  static const _primaryColor = ColorField(defaultTo: MyColor(0xFF2196F3));
  static const _secondaryColor = ColorField(nullable: true);
  static const _tertiaryColor = ColorField(nullable: true);
  static const _errorColor = ColorField(nullable: true);
  static const _surfaceColor = ColorField(nullable: true);

  static const _backgroundTransparency = DoubleNumberField(
    defaultTo: 1.0,
    validator: _backgroundTransparencyValidator,
  );
  static ValidatorResult<double> _backgroundTransparencyValidator(value) {
    if (value >= 0 && value <= 1) {
      return ValidatorSuccess();
    } else {
      return ValidatorError(MyValError("Background transparency should be between 0 and 1 but was $value"));
    }
  }

  // TODO: 2 STYLE think well on how to expose button theme
  final double buttonRadiusX = 12;
  final double buttonRadiusY = 12;
}

class WaywingTheme {
  final ThemeConfig config;
  WaywingTheme(this.config);

  late final ColorScheme colorSchemeLight = _getColorScheme(Brightness.light);
  late final ColorScheme colorSchemeDark = _getColorScheme(Brightness.dark);
  late final ThemeData themeLight = _getTheme(colorSchemeLight);
  late final ThemeData themeDark = _getTheme(colorSchemeDark);

  ColorScheme _getColorScheme(Brightness brightness) {
    final tones = FlexTones.material(brightness);
    final primaryKeyHct = Hct.fromInt(config.primaryColor.toARGB32());
    const colorRotation = 60;
    final secondaryKeyHct = config.secondaryColor != null
        ? Hct.fromInt(config.secondaryColor!.toARGB32())
        : primaryKeyHct.multTone(tones.secondaryTone / tones.primaryTone).addHue(colorRotation);
    final tertiaryKeyHct = config.tertiaryColor != null
        ? Hct.fromInt(config.tertiaryColor!.toARGB32())
        : primaryKeyHct.multTone(tones.tertiaryTone / tones.primaryTone).addHue(colorRotation);
    final errorKeyHct = config.errorColor != null
        ? Hct.fromInt(config.errorColor!.toARGB32())
        : primaryKeyHct.multTone(tones.errorTone / tones.primaryTone);
    double surfaceToneMultiplier = 1;
    if (config.surfaceColor != null) {
      final surfaceHct = Hct.fromInt(config.surfaceColor!.toARGB32());
      surfaceToneMultiplier = surfaceHct.tone / tones.surfaceTone;
    }
    // TODO: 2 what to do with colors not being adapted to dark/light mode now?
    // this includes primary,secondary,etc. and especially background/foreground
    final scheme = SeedColorScheme.fromSeeds(
      brightness: brightness,
      respectMonochromeSeed: true,
      primaryKey: config.primaryColor,
      secondaryKey: config.secondaryColor ?? Color(secondaryKeyHct.toInt()),
      tertiaryKey: config.tertiaryColor ?? Color(tertiaryKeyHct.toInt()),
      errorKey: config.errorColor,
      surface: config.surfaceColor,
      tones: tones.copyWith(
        // respect declared primary, secondary, tercary and error colors exactly
        primaryTone: primaryKeyHct.tone.toInt(),
        primaryChroma: primaryKeyHct.chroma,
        primaryMinChroma: 0,
        secondaryTone: secondaryKeyHct.tone.toInt(),
        secondaryChroma: secondaryKeyHct.chroma,
        secondaryMinChroma: 0,
        tertiaryTone: tertiaryKeyHct.tone.toInt(),
        tertiaryChroma: tertiaryKeyHct.chroma,
        tertiaryMinChroma: 0,
        errorTone: errorKeyHct.tone.toInt(),
        errorChroma: errorKeyHct.chroma,
        // errorMinChroma: 0, // we DO want error to have a min chroma value

        // make all surfaces darker/lighter to match the declared surface color
        surfaceTintTone: (tones.surfaceTintTone * surfaceToneMultiplier).round(),
        surfaceContainerHighestTone: (tones.surfaceContainerHighestTone * surfaceToneMultiplier).round(),
        surfaceContainerTone: (tones.surfaceContainerTone * surfaceToneMultiplier).round(),
        surfaceContainerLowTone: (tones.surfaceContainerLowTone * surfaceToneMultiplier).round(),
        surfaceContainerHighTone: (tones.surfaceContainerHighTone * surfaceToneMultiplier).round(),
        surfaceContainerLowestTone: (tones.surfaceContainerLowestTone * surfaceToneMultiplier).round(),
        surfaceBrightTone: (tones.surfaceBrightTone * surfaceToneMultiplier).round(),
        surfaceDimTone: (tones.surfaceDimTone * surfaceToneMultiplier).round(),
        inverseSurfaceTone: (tones.inverseSurfaceTone * surfaceToneMultiplier).round(),
      ),
    );
    return scheme.copyWith(
      surface: scheme.surface.withValues(alpha: config.backgroundTransparency),
    );
  }

  ThemeData _getTheme(ColorScheme colorScheme) {
    return ThemeData(
      colorScheme: colorScheme,
      fontFamily: config.fontFamily,
      buttonTheme: ButtonThemeData(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      ),
      splashFactory: InkSparkle.splashFactory,
      dividerTheme: DividerThemeData(
        color: Color.alphaBlend(colorScheme.onSurface.withValues(alpha: 0.2), colorScheme.surface),
      ),
    );
  }
}

extension HctMultiply on Hct {
  Hct multTone(num v) {
    return Hct.from(hue, chroma, tone * v);
  }

  Hct divTone(num v) {
    return Hct.from(hue, chroma, tone / v);
  }

  Hct addHue(num v) {
    return Hct.from(_addHue(hue, v), chroma, tone);
  }

  double _addHue(double hue, num v) {
    var newHue = hue + v;
    while (newHue > 360) {
      newHue -= 360;
    }
    while (newHue < 0) {
      newHue += 360;
    }
    // // avoid overlapping with errorColor
    // const minProximityToError = 90;
    // const errorColorHue = 25; // this shouldn't be const, take it from user input if specified
    // final diffToError = newHue - errorColorHue;
    // // this doesn't account for when it wraps around 1
    // if (diffToError.isNegative) {
    //   if (diffToError > -minProximityToError) {
    //     newHue = _addHue(newHue, -minProximityToError - diffToError);
    //   }
    // } else {
    //   if (diffToError < minProximityToError) {
    //     newHue = _addHue(newHue, minProximityToError - diffToError);
    //   }
    // }
    return newHue;
  }
}
