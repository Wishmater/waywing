// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin ThemeConfigI {
  ThemeMode get mode;
  String? get fontFamily;
  MyColor get primaryColor;
  MyColor? get secondaryColor;
  MyColor? get tertiaryColor;
  MyColor? get errorColor;
  MyColor? get surfaceColor;
  double get backgroundTransparency;
}

class ThemeConfig with ThemeConfigI, ThemeConfigBase {
  final ThemeMode mode;
  final String? fontFamily;
  final MyColor primaryColor;
  final MyColor? secondaryColor;
  final MyColor? tertiaryColor;
  final MyColor? errorColor;
  final MyColor? surfaceColor;
  final double backgroundTransparency;

  ThemeConfig({
    ThemeMode? mode,
    this.fontFamily,
    MyColor? primaryColor,
    this.secondaryColor,
    this.tertiaryColor,
    this.errorColor,
    this.surfaceColor,
    double? backgroundTransparency,
  }) : mode = mode ?? ThemeMode.system,
       primaryColor = primaryColor ?? MyColor(0xFF2196F3),
       backgroundTransparency = backgroundTransparency ?? 1.0;

  factory ThemeConfig.fromMap(Map<String, dynamic> map) {
    return ThemeConfig(
      mode: map['mode'],
      fontFamily: map['fontFamily'],
      primaryColor: map['primaryColor'],
      secondaryColor: map['secondaryColor'],
      tertiaryColor: map['tertiaryColor'],
      errorColor: map['errorColor'],
      surfaceColor: map['surfaceColor'],
      backgroundTransparency: map['backgroundTransparency'],
    );
  }

  static TableSchema get schema => TableSchema(
    fields: {
      'mode': ThemeConfigBase._mode,
      'fontFamily': ThemeConfigBase._fontFamily,
      'primaryColor': ThemeConfigBase._primaryColor,
      'secondaryColor': ThemeConfigBase._secondaryColor,
      'tertiaryColor': ThemeConfigBase._tertiaryColor,
      'errorColor': ThemeConfigBase._errorColor,
      'surfaceColor': ThemeConfigBase._surfaceColor,
      'backgroundTransparency': ThemeConfigBase._backgroundTransparency,
    },
  );

  @override
  String toString() {
    return 'ThemeConfigmode = $mode, backgroundTransparency = $backgroundTransparency, primaryColorKey = $primaryColorKey, secondaryColorKey = $secondaryColorKey, tertiaryColorKey = $tertiaryColorKey, neutralColorKey = $neutralColorKey, errorColorKey = $errorColorKey, fontFamily = $fontFamily';
  }

  @override
  bool operator ==(covariant ThemeConfig other) {
    return mode == other.mode &&
        backgroundTransparency == other.backgroundTransparency &&
        primaryColorKey == other.primaryColorKey &&
        secondaryColorKey == other.secondaryColorKey &&
        tertiaryColorKey == other.tertiaryColorKey &&
        neutralColorKey == other.neutralColorKey &&
        errorColorKey == other.errorColorKey &&
        fontFamily == other.fontFamily;
  }

  @override
  int get hashCode => Object.hashAll([
    mode,
    backgroundTransparency,
    primaryColorKey,
    secondaryColorKey,
    tertiaryColorKey,
    neutralColorKey,
    errorColorKey,
    fontFamily,
  ]);
}
