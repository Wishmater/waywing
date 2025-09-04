import "package:config/config.dart";
import "package:config_gen/config_gen.dart";
import "package:flutter/material.dart";
import "package:flex_seed_scheme/flex_seed_scheme.dart";
import "package:waywing/util/config_fields.dart";

part "theme.g.dart";

@Config()
mixin ThemeConfigBase on ThemeConfigI {
  static const _mode = EnumField(ThemeMode.values, defaultTo: ThemeMode.system);

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

  static const _primaryColorKey = ColorField(defaultTo: MyColor(0xFF2196F3));
  static const _secondaryColorKey = ColorField(nullable: true);
  static const _tertiaryColorKey = ColorField(nullable: true);
  static const _neutralColorKey = ColorField(nullable: true);
  static const _errorColorKey = ColorField(nullable: true);
  static const _fontFamily = StringField(nullable: true);

  // Here we could expose the actual colors like this
  // The problem with this is that may produce color inconsitence and that
  // there is a lot of color variations like primary, primaryContainer,
  // primaryFixed and primaryFixedDim
  // static const _primaryColor = ColorField(nullable: true);
  // static const _secondaryColor = ColorField(nullable: true);
  // static const _tertiaryColor = ColorField(nullable: true);
  // static const _errorColor = ColorField(nullable: true);
  // static const _surfaceColor = ColorField(nullable: true);

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
    final primaryKeyHct = Hct.fromInt(config.primaryColorKey.toARGB32());
    const colorRotation = 60;
    final secondaryKeyHct = config.secondaryColorKey != null
        ? Hct.fromInt(config.secondaryColorKey!.toARGB32())
        : primaryKeyHct.multTone(tones.secondaryTone / tones.primaryTone).addHue(colorRotation);
    final tertiaryKeyHct = config.tertiaryColorKey != null
        ? Hct.fromInt(config.tertiaryColorKey!.toARGB32())
        : primaryKeyHct.multTone(tones.tertiaryTone / tones.primaryTone).addHue(colorRotation);
    final errorKeyHct = config.errorColorKey != null
        ? Hct.fromInt(config.errorColorKey!.toARGB32())
        : primaryKeyHct.multTone(tones.errorTone / tones.primaryTone);
    // TODO: 1 what to do with surface
    // TODO: 1 what to do with colors not being adapted to dark/light mode now
    final scheme = SeedColorScheme.fromSeeds(
      // primary: config.primaryColorKey,
      brightness: brightness,
      respectMonochromeSeed: true,
      primaryKey: config.primaryColorKey,
      secondaryKey: config.secondaryColorKey ?? Color(secondaryKeyHct.toInt()),
      tertiaryKey: config.tertiaryColorKey ?? Color(tertiaryKeyHct.toInt()),
      neutralKey: config.neutralColorKey,
      errorKey: config.errorColorKey,
      tones: tones.copyWith(
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
      ),
    );
    print("------------------------");
    print(Hct.fromInt(scheme.primary.value));
    print(Hct.fromInt(scheme.secondary.value));
    print(Hct.fromInt(scheme.tertiary.value));
    print(Hct.fromInt(scheme.surface.value));
    print(Hct.fromInt(scheme.error.value));
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
      // TODO: 1 remove this hardcoded value
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade400.withValues(alpha: 0.66),
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
