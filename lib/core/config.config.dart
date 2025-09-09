// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin MainConfigI {
  int get monitor;
  List<Wing<dynamic>> get wings;
  String? get socket;
  double get animationSpeed;
  double get animationDamping;
  AnimationFitting get animationFitting;
  bool get requestKeyboardFocus;
}

class MainConfig with MainConfigI, MainConfigBase {
  static const TableSchema staticSchema = TableSchema(
    tables: MainConfigBase._staticSchemaTables,
    fields: {
      'monitor': MainConfigBase._monitor,
      'wings': MainConfigBase._wings,
      'socket': MainConfigBase._socket,
      'animationSpeed': MainConfigBase._animationSpeed,
      'animationDamping': MainConfigBase._animationDamping,
      'animationFitting': MainConfigBase._animationFitting,
      'requestKeyboardFocus': MainConfigBase._requestKeyboardFocus,
    },
  );

  static TableSchema get schema => TableSchema(
    tables: {
      ...staticSchema.tables,
      ...MainConfigBase._getDynamicSchemaTables(),
    },
    fields: staticSchema.fields,
  );

  final int monitor;
  final List<Wing<dynamic>> wings;
  final String? socket;
  final double animationSpeed;
  final double animationDamping;
  final AnimationFitting animationFitting;
  final bool requestKeyboardFocus;

  final LoggingConfig logging;
  final ThemeConfig theme;

  MainConfig({
    int? monitor,
    List<Wing<dynamic>>? wings,
    this.socket,
    double? animationSpeed,
    double? animationDamping,
    AnimationFitting? animationFitting,
    bool? requestKeyboardFocus,
    required this.logging,
    required this.theme,
  }) : monitor = monitor ?? 0,
       wings = wings ?? <Wing>[],
       animationSpeed = animationSpeed ?? 1,
       animationDamping = animationDamping ?? 1,
       animationFitting = animationFitting ?? AnimationFitting.clip,
       requestKeyboardFocus = requestKeyboardFocus ?? false;

  factory MainConfig.fromMap(Map<String, dynamic> map) {
    return MainConfig(
      monitor: map['monitor'],
      wings: map['wings'],
      socket: map['socket'],
      animationSpeed: map['animationSpeed'],
      animationDamping: map['animationDamping'],
      animationFitting: map['animationFitting'],
      requestKeyboardFocus: map['requestKeyboardFocus'],
      logging: LoggingConfig.fromMap(map['Logging']),
      theme: ThemeConfig.fromMap(map['Theme']),
    );
  }

  @override
  String toString() {
    return 'MainConfigmonitor = $monitor, wings = $wings, socket = $socket, animationSpeed = $animationSpeed, animationDamping = $animationDamping, animationFitting = $animationFitting, requestKeyboardFocus = $requestKeyboardFocus';
  }

  @override
  bool operator ==(covariant MainConfig other) {
    return monitor == other.monitor &&
        wings == other.wings &&
        socket == other.socket &&
        animationSpeed == other.animationSpeed &&
        animationDamping == other.animationDamping &&
        animationFitting == other.animationFitting &&
        requestKeyboardFocus == other.requestKeyboardFocus;
  }

  @override
  int get hashCode => Object.hashAll([
    monitor,
    wings,
    socket,
    animationSpeed,
    animationDamping,
    animationFitting,
    requestKeyboardFocus,
  ]);
}
