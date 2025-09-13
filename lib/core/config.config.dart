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
  bool get animationEnable;
  double get animationSpeed;
  double get animationDamping;
  AnimationFitting get animationFitting;
  AnimationSwitching get animationSwitching;
  bool get requestKeyboardFocus;
}

class MainConfig with MainConfigI, MainConfigBase {
  static const TableSchema staticSchema = TableSchema(
    tables: MainConfigBase._staticSchemaTables,
    fields: {
      'monitor': MainConfigBase._monitor,
      'wings': MainConfigBase._wings,
      'socket': MainConfigBase._socket,
      'animationEnable': MainConfigBase._animationEnable,
      'animationSpeed': MainConfigBase._animationSpeed,
      'animationDamping': MainConfigBase._animationDamping,
      'animationFitting': MainConfigBase._animationFitting,
      'animationSwitching': MainConfigBase._animationSwitching,
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
  final bool animationEnable;
  final double animationSpeed;
  final double animationDamping;
  final AnimationFitting animationFitting;
  final AnimationSwitching animationSwitching;
  final bool requestKeyboardFocus;

  final LoggingConfig logging;
  final ThemeConfig theme;

  MainConfig({
    int? monitor,
    List<Wing<dynamic>>? wings,
    this.socket,
    bool? animationEnable,
    double? animationSpeed,
    double? animationDamping,
    AnimationFitting? animationFitting,
    AnimationSwitching? animationSwitching,
    bool? requestKeyboardFocus,
    required this.logging,
    required this.theme,
  }) : monitor = monitor ?? 0,
       wings = wings ?? <Wing>[],
       animationEnable = animationEnable ?? true,
       animationSpeed = animationSpeed ?? 1,
       animationDamping = animationDamping ?? 1,
       animationFitting = animationFitting ?? AnimationFitting.clip,
       animationSwitching =
           animationSwitching ?? AnimationSwitching.fadeThrough,
       requestKeyboardFocus = requestKeyboardFocus ?? false;

  factory MainConfig.fromMap(Map<String, dynamic> map) {
    return MainConfig(
      monitor: map['monitor'],
      wings: map['wings'],
      socket: map['socket'],
      animationEnable: map['animationEnable'],
      animationSpeed: map['animationSpeed'],
      animationDamping: map['animationDamping'],
      animationFitting: map['animationFitting'],
      animationSwitching: map['animationSwitching'],
      requestKeyboardFocus: map['requestKeyboardFocus'],
      logging: LoggingConfig.fromMap(map['Logging']),
      theme: ThemeConfig.fromMap(map['Theme']),
    );
  }

  @override
  String toString() {
    return 'MainConfigmonitor = $monitor, wings = $wings, socket = $socket, animationEnable = $animationEnable, animationSpeed = $animationSpeed, animationDamping = $animationDamping, animationFitting = $animationFitting, animationSwitching = $animationSwitching, requestKeyboardFocus = $requestKeyboardFocus';
  }

  @override
  bool operator ==(covariant MainConfig other) {
    return monitor == other.monitor &&
        wings == other.wings &&
        socket == other.socket &&
        animationEnable == other.animationEnable &&
        animationSpeed == other.animationSpeed &&
        animationDamping == other.animationDamping &&
        animationFitting == other.animationFitting &&
        animationSwitching == other.animationSwitching &&
        requestKeyboardFocus == other.requestKeyboardFocus;
  }

  @override
  int get hashCode => Object.hashAll([
    monitor,
    wings,
    socket,
    animationEnable,
    animationSpeed,
    animationDamping,
    animationFitting,
    animationSwitching,
    requestKeyboardFocus,
  ]);
}
