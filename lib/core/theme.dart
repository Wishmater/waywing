import "package:config/config.dart";
import "package:config_gen/config_gen.dart";
import "package:flutter/material.dart";
import "package:flex_seed_scheme/flex_seed_scheme.dart";
import "package:waywing/util/config_fields.dart";

part "theme.config.dart";

@Config()
mixin ThemeConfigBase on ThemeConfigI {
  static const _mode = EnumField(ThemeMode.values, defaultTo: ThemeMode.system);

  static const _fontFamily = StringField(nullable: true);

  static const _primaryColor = ColorField(defaultTo: MyColor(0xFF2196F3));
  static const _secondaryColor = ColorField(nullable: true);
  static const _tertiaryColor = ColorField(nullable: true);
  static const _errorColor = ColorField(nullable: true);
  static const _backgroundColor = ColorField(nullable: true);
  static const _foregroundColor = ColorField(nullable: true);

  static const _backgroundOpacity = DoubleNumberField(
    defaultTo: 1.0,
    validator: _backgroundOpacityValidator,
  );
  static ValidatorResult<double> _backgroundOpacityValidator(value) {
    if (value >= 0 && value <= 1) {
      return ValidatorSuccess();
    } else {
      return ValidatorError(MyValError("Background transparency should be between 0 and 1 but was $value"));
    }
  }

  // TODO: 1 STYLE implement elevation settings, default 0, and use our own implementation of shadows
  // in WingedContainer always, that doesn't cast the shadow behind the container, because that will
  // cause issues on transparent backgrounds

  // TODO: 1 STYLE think well on how to expose corners theme (including rounding and "docking"(negative rounding)).
  // This should affect: buttons, popovers / tooltips, and Bar (if not overriden in the bar config)
  final double buttonRadiusX = 12;
  final double buttonRadiusY = 12;

  // TODO: 1 STYLE splash theming (maybe allow aplying color to it), and by default lower highlight color opacity.
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
    if (config.backgroundColor != null) {
      final surfaceHct = Hct.fromInt(config.backgroundColor!.toARGB32());
      surfaceToneMultiplier = surfaceHct.tone / tones.surfaceTone;
    }

    // TODO: 2 STYLE what to do with colors not being adapted to dark/light mode now?
    // this includes primary,secondary,etc. and especially background/foreground

    final scheme = SeedColorScheme.fromSeeds(
      brightness: brightness,
      respectMonochromeSeed: true,

      primaryKey: config.primaryColor,
      secondaryKey: config.secondaryColor ?? Color(secondaryKeyHct.toInt()),
      tertiaryKey: config.tertiaryColor ?? Color(tertiaryKeyHct.toInt()),
      errorKey: config.errorColor,
      surface: config.backgroundColor,
      onSurface: config.foregroundColor,
      onSurfaceVariant: config.foregroundColor,

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
        surfaceContainerTone: (tones.surfaceContainerTone * surfaceToneMultiplier).round(),
        surfaceContainerLowTone: (tones.surfaceContainerLowTone * surfaceToneMultiplier).round(),
        surfaceContainerLowestTone: (tones.surfaceContainerLowestTone * surfaceToneMultiplier).round(),
        surfaceContainerHighTone: (tones.surfaceContainerHighTone * surfaceToneMultiplier).round(),
        surfaceContainerHighestTone: (tones.surfaceContainerHighestTone * surfaceToneMultiplier).round(),
        surfaceDimTone: (tones.surfaceDimTone * surfaceToneMultiplier).round(),
        surfaceBrightTone: (tones.surfaceBrightTone * surfaceToneMultiplier).round(),
        surfaceTintTone: (tones.surfaceTintTone * surfaceToneMultiplier).round(),
        inverseSurfaceTone: (tones.inverseSurfaceTone * surfaceToneMultiplier).round(),
      ),
    );

    return scheme.copyWith(
      // add background opacity to all surfaces
      surface: scheme.surface.withValues(alpha: config.backgroundOpacity),
      surfaceContainer: scheme.surfaceContainer.withValues(alpha: config.backgroundOpacity),
      surfaceContainerLow: scheme.surfaceContainerLow.withValues(alpha: config.backgroundOpacity),
      surfaceContainerLowest: scheme.surfaceContainerLowest.withValues(alpha: config.backgroundOpacity),
      surfaceContainerHigh: scheme.surfaceContainerHigh.withValues(alpha: config.backgroundOpacity),
      surfaceContainerHighest: scheme.surfaceContainerHighest.withValues(alpha: config.backgroundOpacity),
      surfaceDim: scheme.surfaceDim.withValues(alpha: config.backgroundOpacity),
      surfaceBright: scheme.surfaceBright.withValues(alpha: config.backgroundOpacity),
      surfaceTint: scheme.surfaceTint.withValues(alpha: config.backgroundOpacity),
      inverseSurface: scheme.inverseSurface.withValues(alpha: config.backgroundOpacity),
    );
  }

  ThemeData _getTheme(ColorScheme colorScheme) {
    final result = ThemeData(
      colorScheme: colorScheme,
      fontFamily: config.fontFamily,
      splashFactory: InkSparkle.splashFactory,
      splashColor: colorScheme.primary.withValues(alpha: 0.25),
      highlightColor: Colors.transparent,
      buttonTheme: ButtonThemeData(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      ),
      dividerTheme: DividerThemeData(
        color: Color.alphaBlend(colorScheme.onSurface.withValues(alpha: 0.2), colorScheme.surface),
      ),
    );
    return result.copyWith(
      iconTheme: result.iconTheme.copyWith(
        color: config.foregroundColor == null
            ? result.iconTheme.color
            : Color.lerp(config.foregroundColor, result.iconTheme.color, 0.5),
      ),
    );
  }
}

extension ThemeColors on ThemeData {
  Color getColor(int index) {
    return switch (index % 3) {
      0 => colorScheme.primary,
      1 => colorScheme.secondary,
      2 => colorScheme.tertiary,
      _ => throw Exception(),
    };
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
