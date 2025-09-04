import "package:config/config.dart";
import "package:config_gen/config_gen.dart";
import "package:flutter/material.dart";
import "package:flex_seed_scheme/flex_seed_scheme.dart" as flex;
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
  // static const _surfaceColor = ColorField(nullable: true);
  // static const _errorColor = ColorField(nullable: true);

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
    final scheme = flex.SeedColorScheme.fromSeeds(
      brightness: brightness,
      primaryKey: config.primaryColorKey,
      secondaryKey: config.secondaryColorKey,
      tertiaryKey: config.tertiaryColorKey,
      neutralKey: config.neutralColorKey,
      errorKey: config.errorColorKey,
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
      // TODO: 1 remove this hardcoded value
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade400.withValues(alpha: 0.66),
      ),
    );
  }
}
