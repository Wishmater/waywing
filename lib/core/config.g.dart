// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin MainConfigI {
  int get monitor;
  List<Wing<dynamic>> get wings;
  ThemeMode get themeMode;
  MyColor get seedColor;
  MyColor? get surfaceColor;
  double get animationSpeed;
  double get animationDamping;
  AnimationFitting get animationFitting;
  bool get requestKeyboardFocus;
}

class MainConfig with MainConfigI, MainConfigBase {
  final int monitor;
  final List<Wing<dynamic>> wings;
  final ThemeMode themeMode;
  final MyColor seedColor;
  final MyColor? surfaceColor;
  final double animationSpeed;
  final double animationDamping;
  final AnimationFitting animationFitting;
  final bool requestKeyboardFocus;

  MainConfig({
    int? monitor,
    List<Wing<dynamic>>? wings,
    ThemeMode? themeMode,
    required this.seedColor,
    this.surfaceColor,
    double? animationSpeed,
    double? animationDamping,
    AnimationFitting? animationFitting,
    bool? requestKeyboardFocus,
  }) : monitor = monitor ?? 0,
       wings = wings ?? <Wing>[],
       themeMode = themeMode ?? ThemeMode.system,
       animationSpeed = animationSpeed ?? 1,
       animationDamping = animationDamping ?? 1,
       animationFitting = animationFitting ?? AnimationFitting.clip,
       requestKeyboardFocus = requestKeyboardFocus ?? false;

  factory MainConfig.fromMap(Map<String, dynamic> map) {
    return MainConfig(
      monitor: map['monitor'],
      wings: map['wings'],
      themeMode: map['themeMode'],
      seedColor: map['seedColor'],
      surfaceColor: map['surfaceColor'],
      animationSpeed: map['animationSpeed'],
      animationDamping: map['animationDamping'],
      animationFitting: map['animationFitting'],
      requestKeyboardFocus: map['requestKeyboardFocus'],
    );
  }

  static TableSchema get schema => TableSchema(
    tables: MainConfigBase._getSchemaTables(),
    fields: {
      'monitor': MainConfigBase._monitor,
      'wings': MainConfigBase._wings,
      'themeMode': MainConfigBase._themeMode,
      'seedColor': MainConfigBase._seedColor,
      'surfaceColor': MainConfigBase._surfaceColor,
      'animationSpeed': MainConfigBase._animationSpeed,
      'animationDamping': MainConfigBase._animationDamping,
      'animationFitting': MainConfigBase._animationFitting,
      'requestKeyboardFocus': MainConfigBase._requestKeyboardFocus,
    },
  );
}
