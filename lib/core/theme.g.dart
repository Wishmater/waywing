// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin ThemeConfigurationI {
  ThemeMode get mode;
  double get backgroundTransparency;
  MyColor get primaryColorKey;
  MyColor? get secondaryColorKey;
  MyColor? get tertiaryColorKey;
  MyColor? get neutralColorKey;
  MyColor? get errorColorKey;
  String? get fontFamily;
}

class ThemeConfiguration with ThemeConfigurationI, ThemeConfigurationBase {
  final ThemeMode mode;
  final double backgroundTransparency;
  final MyColor primaryColorKey;
  final MyColor? secondaryColorKey;
  final MyColor? tertiaryColorKey;
  final MyColor? neutralColorKey;
  final MyColor? errorColorKey;
  final String? fontFamily;

  ThemeConfiguration({
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

  factory ThemeConfiguration.fromMap(Map<String, dynamic> map) {
    return ThemeConfiguration(
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
      'mode': ThemeConfigurationBase._mode,
      'backgroundTransparency': ThemeConfigurationBase._backgroundTransparency,
      'primaryColorKey': ThemeConfigurationBase._primaryColorKey,
      'secondaryColorKey': ThemeConfigurationBase._secondaryColorKey,
      'tertiaryColorKey': ThemeConfigurationBase._tertiaryColorKey,
      'neutralColorKey': ThemeConfigurationBase._neutralColorKey,
      'errorColorKey': ThemeConfigurationBase._errorColorKey,
      'fontFamily': ThemeConfigurationBase._fontFamily,
    },
  );
}
