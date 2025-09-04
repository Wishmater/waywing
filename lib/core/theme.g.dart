// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin ThemeConfigI {
  ThemeMode get mode;
  double get backgroundTransparency;
  MyColor get primaryColorKey;
  MyColor? get secondaryColorKey;
  MyColor? get tertiaryColorKey;
  MyColor? get neutralColorKey;
  MyColor? get errorColorKey;
  String? get fontFamily;
}

class ThemeConfig with ThemeConfigI, ThemeConfigBase {
  final ThemeMode mode;
  final double backgroundTransparency;
  final MyColor primaryColorKey;
  final MyColor? secondaryColorKey;
  final MyColor? tertiaryColorKey;
  final MyColor? neutralColorKey;
  final MyColor? errorColorKey;
  final String? fontFamily;

  ThemeConfig({
    ThemeMode? mode,
    double? backgroundTransparency,
    MyColor? primaryColorKey,
    this.secondaryColorKey,
    this.tertiaryColorKey,
    this.neutralColorKey,
    this.errorColorKey,
    this.fontFamily,
  }) : mode = mode ?? ThemeMode.system,
       backgroundTransparency = backgroundTransparency ?? 1.0,
       primaryColorKey = primaryColorKey ?? MyColor(0xFF2196F3);

  factory ThemeConfig.fromMap(Map<String, dynamic> map) {
    return ThemeConfig(
      mode: map['mode'],
      backgroundTransparency: map['backgroundTransparency'],
      primaryColorKey: map['primaryColorKey'],
      secondaryColorKey: map['secondaryColorKey'],
      tertiaryColorKey: map['tertiaryColorKey'],
      neutralColorKey: map['neutralColorKey'],
      errorColorKey: map['errorColorKey'],
      fontFamily: map['fontFamily'],
    );
  }

  static TableSchema get schema => TableSchema(
    fields: {
      'mode': ThemeConfigBase._mode,
      'backgroundTransparency': ThemeConfigBase._backgroundTransparency,
      'primaryColorKey': ThemeConfigBase._primaryColorKey,
      'secondaryColorKey': ThemeConfigBase._secondaryColorKey,
      'tertiaryColorKey': ThemeConfigBase._tertiaryColorKey,
      'neutralColorKey': ThemeConfigBase._neutralColorKey,
      'errorColorKey': ThemeConfigBase._errorColorKey,
      'fontFamily': ThemeConfigBase._fontFamily,
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
