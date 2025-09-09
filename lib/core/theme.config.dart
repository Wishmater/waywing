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
  MyColor? get backgroundColor;
  MyColor? get foregroundColor;
  double get backgroundOpacity;
  double get shadows;
}

class ThemeConfig with ThemeConfigI, ThemeConfigBase {
  final ThemeMode mode;
  final String? fontFamily;
  final MyColor primaryColor;
  final MyColor? secondaryColor;
  final MyColor? tertiaryColor;
  final MyColor? errorColor;
  final MyColor? backgroundColor;
  final MyColor? foregroundColor;
  final double backgroundOpacity;
  final double shadows;

  ThemeConfig({
    ThemeMode? mode,
    this.fontFamily,
    MyColor? primaryColor,
    this.secondaryColor,
    this.tertiaryColor,
    this.errorColor,
    this.backgroundColor,
    this.foregroundColor,
    double? backgroundOpacity,
    double? shadows,
  }) : mode = mode ?? ThemeMode.system,
       primaryColor = primaryColor ?? MyColor(0xFF2196F3),
       backgroundOpacity = backgroundOpacity ?? 1.0,
       shadows = shadows ?? 1.0;

  factory ThemeConfig.fromMap(Map<String, dynamic> map) {
    return ThemeConfig(
      mode: map['mode'],
      fontFamily: map['fontFamily'],
      primaryColor: map['primaryColor'],
      secondaryColor: map['secondaryColor'],
      tertiaryColor: map['tertiaryColor'],
      errorColor: map['errorColor'],
      backgroundColor: map['backgroundColor'],
      foregroundColor: map['foregroundColor'],
      backgroundOpacity: map['backgroundOpacity'],
      shadows: map['shadows'],
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
      'backgroundColor': ThemeConfigBase._backgroundColor,
      'foregroundColor': ThemeConfigBase._foregroundColor,
      'backgroundOpacity': ThemeConfigBase._backgroundOpacity,
      'shadows': ThemeConfigBase._shadows,
    },
  );

  @override
  String toString() {
    return 'ThemeConfigmode = $mode, fontFamily = $fontFamily, primaryColor = $primaryColor, secondaryColor = $secondaryColor, tertiaryColor = $tertiaryColor, errorColor = $errorColor, backgroundColor = $backgroundColor, foregroundColor = $foregroundColor, backgroundOpacity = $backgroundOpacity, shadows = $shadows';
  }

  @override
  bool operator ==(covariant ThemeConfig other) {
    return mode == other.mode &&
        fontFamily == other.fontFamily &&
        primaryColor == other.primaryColor &&
        secondaryColor == other.secondaryColor &&
        tertiaryColor == other.tertiaryColor &&
        errorColor == other.errorColor &&
        backgroundColor == other.backgroundColor &&
        foregroundColor == other.foregroundColor &&
        backgroundOpacity == other.backgroundOpacity &&
        shadows == other.shadows;
  }

  @override
  int get hashCode => Object.hashAll([
    mode,
    fontFamily,
    primaryColor,
    secondaryColor,
    tertiaryColor,
    errorColor,
    backgroundColor,
    foregroundColor,
    backgroundOpacity,
    shadows,
  ]);
}
