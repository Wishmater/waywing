import "dart:math";

import "package:config/config.dart";
import "package:config_gen/config_gen.dart";
import "package:dartx/dartx.dart";
import "package:flutter/material.dart";
import "package:flex_seed_scheme/flex_seed_scheme.dart";
import "package:material_symbols_icons/material_symbols_icons.dart";
import "package:waywing/core/config.dart";
import "package:waywing/util/config_fields.dart";
import "package:waywing/widgets/icons/text_icon.dart";
import "package:waywing/widgets/shapes/external_rounded_corners_shape.dart";
import "package:waywing/widgets/theme/button_theme.dart";
import "package:waywing/widgets/winged_widgets/winged_icon.dart";

part "theme.config.dart";

enum ConfigIconVariation {
  normal(IconVariation.outlined),
  rounded(IconVariation.rounded),
  sharp(IconVariation.sharp);

  final IconVariation variation;
  const ConfigIconVariation(this.variation);
}

@Config()
mixin ThemeConfigBase on ThemeConfigI {
  //===========================================================================
  // Mode (light / dark)
  //===========================================================================

  static const _mode = EnumField(ThemeMode.values, defaultTo: ThemeMode.system);

  //===========================================================================
  // Font
  //===========================================================================

  /// Use this to set a custom font
  static const _fontFamily = StringField(nullable: true);

  /// Set the font size
  static const _fontSize = DoubleNumberField(defaultTo: kDefaultFontSize);
  double get fontSizeScaleFactor => fontSize / kDefaultFontSize;

  static const __iconSize = DoubleNumberField(nullable: true);
  late final double iconSize = _iconSize ?? fontSize;
  late final double iconSizeScaleFactor = iconSize / kDefaultFontSize;
  late final double iconSizeAdapted = iconSize * TextIcon.fontToIconSizeRatio;

  //===========================================================================
  // Icons
  //===========================================================================

  static const _iconPriority = ListField(
    EnumField(IconType.values),
    defaultTo: [
      IconType.flutter,
      IconType.direct,
      IconType.linux,
      IconType.nerdFont,
    ],
    validator: _iconPriorityValidator,
  );
  static ValidatorResult<List<IconType>> _iconPriorityValidator(List<IconType> value, Position position) {
    if (value.isEmpty) {
      return ValidatorError(
        MyValError("At least one icon type must be specified in iconPriority list, but received an empty list", position),
      );
    }
    for (final e in value) {
      if (value.count((f) => e == f) > 1) {
        return ValidatorError(
          MyValError("The same icon type can't be repeated more than once in iconPriority list, but $e was repeated", position),
        );
      }
    }
    return ValidatorSuccess();
  }

  static const _iconFlutterVariation = EnumField(ConfigIconVariation.values, defaultTo: ConfigIconVariation.normal);

  static const _iconFlutterTwoTone = BooleanField(defaultTo: false);

  static const _iconFlutterFill = DoubleNumberField(
    defaultTo: 0,
    validator: _iconFlutterFillValidator,
  );
  static ValidatorResult<double> _iconFlutterFillValidator(double value, Position position) {
    if (value < 0 || value > 1) {
      return ValidatorError(MyValError("Icon fill value should be between 0 and 1, but was $value", position));
    }
    return ValidatorSuccess();
  }

  static const _iconFlutterWeight = DoubleNumberField(
    defaultTo: 400,
    validator: _iconFlutterWeightValidator,
  );
  static ValidatorResult<double> _iconFlutterWeightValidator(double value, Position position) {
    if (value < 100 || value > 700) {
      return ValidatorError(MyValError("Icon weight value should be between 100 and 700, but was $value", position));
    }
    return ValidatorSuccess();
  }

  //===========================================================================
  // Colors
  //===========================================================================

  static const _primaryColor = ColorField(defaultTo: MyColor(0xFF2196F3));
  static const _secondaryColor = ColorField(nullable: true);
  static const _tertiaryColor = ColorField(nullable: true);
  static const _errorColor = ColorField(nullable: true);
  static const _backgroundColor = AdaptativeColorField(nullable: true);
  static const _foregroundColor = ColorField(nullable: true);

  static const _backgroundOpacity = DoubleNumberField(
    defaultTo: 1.0,
    validator: _backgroundOpacityValidator,
  );
  static ValidatorResult<double> _backgroundOpacityValidator(double value, Position position) {
    if (value >= 0 && value <= 1) {
      return ValidatorSuccess();
    } else {
      return ValidatorError(MyValError("Background transparency should be between 0 and 1, but was $value", position));
    }
  }

  static const _shadows = DoubleNumberField(
    defaultTo: 1.0,
    validator: _shadowsValidator,
  );
  static ValidatorResult<double> _shadowsValidator(double value, Position position) {
    if (value >= 0) {
      return ValidatorSuccess();
    } else {
      return ValidatorError(MyValError("Shadows value should be greater than or equal to 0, but was $value", position));
    }
  }

  //===========================================================================
  // Rounded corners
  //===========================================================================

  static const _buttonRounding = DoubleNumberField(defaultTo: 12);
  static const _containerRounding = DoubleNumberField(defaultTo: 24);

  //===========================================================================
  // Borders
  //===========================================================================

  static const _activeBorderSize = DoubleNumberField(defaultTo: 2);

  static const __inactiveBorderSize = DoubleNumberField(nullable: true);
  double get inactiveBorderSize => _inactiveBorderSize ?? activeBorderSize;

  // border gradient colors, defaults to hyprland defaults
  static const _activeBorderColors = ListField(ColorField(), defaultTo: [MyColor(0xee33ccff), MyColor(0xee00ff99)]);
  static const _inactiveBorderColors = ListField(ColorField(), defaultTo: [MyColor(0xaa595959)]);

  // gradient angle in degrees (similar to hyprland borders)
  static const _activeBorderAngle = DoubleNumberField(defaultTo: 45);
  static const _inactiveBorderAngle = DoubleNumberField(defaultTo: 45);

  late final activeBorder = GradientBorderSide(
    colors: _fillColors(activeBorderColors, borderMaxColorCount),
    width: activeBorderSize,
    angle: activeBorderAngle,
  );

  late final inactiveBorder = GradientBorderSide(
    colors: _fillColors(inactiveBorderColors, borderMaxColorCount),
    width: inactiveBorderSize,
    angle: inactiveBorderAngle,
  );

  late final borderMaxColorCount = max(activeBorderColors.length, inactiveBorderColors.length);
  List<Color> _fillColors(List<Color> colors, int length) {
    if (length <= colors.length) return colors;
    List<Color> result = [];
    for (int i = 0; i < length; i++) {
      result.add(colors[i % colors.length]);
    }
    return result;
  }
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
    double? surfaceContainerLowestTone,
        surfaceContainerLowTone,
        surfaceContainerTone,
        surfaceContainerHighTone,
        surfaceContainerHighestTone,
        surfaceDimTone,
        surfaceBrightTone,
        surfaceTintTone,
        inverseSurfaceTone;
    Color? surfaceContainerLowest,
        surfaceContainerLow,
        surfaceContainer,
        surfaceContainerHigh,
        surfaceContainerHighest,
        surfaceDim,
        surfaceBright,
        surfaceTint,
        inverseSurface;
    if (config.backgroundColor != null) {
      final surfaceHct = Hct.fromInt(config.backgroundColor!.color(brightness).toARGB32());
      final surfaceToneMultiplier = surfaceHct.tone / tones.surfaceTone;
      final surfaceToneDiff = surfaceHct.tone - tones.surfaceTone;
      // // we use multiplier only for lowest, which is closer than surface to zero in dark mode (or max for light mode),
      // // the rest need to be addition, otherwise they can scale to be too bright in dark mode (or too dark in light mode)
      // surfaceContainerLowestTone = tones.surfaceContainerLowestTone + surfaceToneDiff;
      surfaceContainerLowestTone = tones.surfaceContainerLowestTone * surfaceToneMultiplier;
      surfaceContainerLowest = Color(Hct.from(surfaceHct.hue, surfaceHct.chroma, surfaceContainerLowestTone).toInt());
      surfaceContainerLowTone = tones.surfaceContainerLowTone + surfaceToneDiff;
      // surfaceContainerLowTone = tones.surfaceContainerLowTone * surfaceToneMultiplier;
      surfaceContainerLow = Color(Hct.from(surfaceHct.hue, surfaceHct.chroma, surfaceContainerLowTone).toInt());
      surfaceContainerTone = tones.surfaceContainerTone + surfaceToneDiff;
      // surfaceContainerTone = tones.surfaceContainerTone * surfaceToneMultiplier;
      surfaceContainer = Color(Hct.from(surfaceHct.hue, surfaceHct.chroma, surfaceContainerTone).toInt());
      surfaceContainerHighTone = tones.surfaceContainerHighTone + surfaceToneDiff;
      // surfaceContainerHighTone = tones.surfaceContainerHighTone * surfaceToneMultiplier;
      surfaceContainerHigh = Color(Hct.from(surfaceHct.hue, surfaceHct.chroma, surfaceContainerHighTone).toInt());
      surfaceContainerHighestTone = tones.surfaceContainerHighestTone + surfaceToneDiff;
      // surfaceContainerHighestTone = tones.surfaceContainerHighestTone * surfaceToneMultiplier;
      surfaceContainerHighest = Color(Hct.from(surfaceHct.hue, surfaceHct.chroma, surfaceContainerHighestTone).toInt());
      // // we don't specify a set color for these, we only set the tone so they get the default material "tint"
      surfaceDimTone = tones.surfaceDimTone + surfaceToneDiff;
      // surfaceDimTone = tones.surfaceDimTone * surfaceToneMultiplier;
      // surfaceDim = Color(Hct.from(surfaceHct.hue, surfaceHct.chroma, surfaceDimTone).toInt());
      surfaceBrightTone = tones.surfaceBrightTone + surfaceToneDiff;
      // surfaceBrightTone = tones.surfaceBrightTone * surfaceToneMultiplier;
      // surfaceBright = Color(Hct.from(surfaceHct.hue, surfaceHct.chroma, surfaceBrightTone).toInt());
      surfaceTintTone = tones.surfaceTintTone + surfaceToneDiff;
      // surfaceTintTone = tones.surfaceTintTone * surfaceToneMultiplier;
      // surfaceTint = Color(Hct.from(surfaceHct.hue, surfaceHct.chroma, surfaceTintTone).toInt());
      inverseSurfaceTone = tones.inverseSurfaceTone + surfaceToneDiff;
      // inverseSurfaceTone = tones.inverseSurfaceTone * surfaceToneMultiplier;
      // inverseSurface = Color(Hct.from(surfaceHct.hue, surfaceHct.chroma, inverseSurfaceTone).toInt());
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
      surface: config.backgroundColor?.color(brightness),
      onSurface: config.foregroundColor,
      onSurfaceVariant: config.foregroundColor,

      surfaceContainerLowest: surfaceContainerLowest,
      surfaceContainerLow: surfaceContainerLow,
      surfaceContainer: surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh,
      surfaceContainerHighest: surfaceContainerHighest,
      surfaceDim: surfaceDim,
      surfaceBright: surfaceBright,
      surfaceTint: surfaceTint,
      inverseSurface: inverseSurface,

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
        surfaceContainerLowestTone: surfaceContainerLowestTone?.round(),
        surfaceContainerLowTone: surfaceContainerLowTone?.round(),
        surfaceContainerTone: surfaceContainerTone?.round(),
        surfaceContainerHighTone: surfaceContainerHighTone?.round(),
        surfaceContainerHighestTone: surfaceContainerHighestTone?.round(),
        surfaceDimTone: surfaceDimTone?.round(),
        surfaceBrightTone: surfaceBrightTone?.round(),
        surfaceTintTone: surfaceTintTone?.round(),
        inverseSurfaceTone: inverseSurfaceTone?.round(),
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
    var result = ThemeData(
      colorScheme: colorScheme,
      fontFamily: config.fontFamily,
      splashFactory: mainConfig.animationEnable ? InkSparkle.splashFactory : NoSplash.splashFactory,
      splashColor: colorScheme.primary.withValues(alpha: 0.25),
      highlightColor: mainConfig.animationEnable ? null : Colors.transparent,
      hoverColor: colorScheme.onSurface.withValues(alpha: 0.04),
      focusColor: colorScheme.onSurface.withValues(alpha: colorScheme.brightness == Brightness.light ? 0.12 : 0.08),
      buttonTheme: ButtonThemeData(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      ),
      dividerTheme: DividerThemeData(
        color: Color.alphaBlend(colorScheme.onSurface.withValues(alpha: 0.2), colorScheme.surface),
      ),

      extensions: <ThemeExtension<dynamic>>[
        const WingedButtonTheme(boxConstraints: BoxConstraints(minWidth: 38, minHeight: 38)),
      ],
    );
    return result.copyWith(
      iconTheme: result.iconTheme.copyWith(
        color: config.foregroundColor == null
            ? result.iconTheme.color
            : Color.lerp(config.primaryColor, result.iconTheme.color, 0.5),
        fill: 0,
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
