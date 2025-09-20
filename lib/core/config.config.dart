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
  bool get focusGrab;
  bool get animationEnable;
  double get animationSpeed;
  double get animationDamping;
  AnimationFitting get animationFitting;
  AnimationSwitching get animationSwitching;
  bool get requestKeyboardFocus;
  LoggingConfig get logging;
  ThemeConfig get theme;
}

class MainConfig with MainConfigI, MainConfigBase {
  static const TableSchema staticSchema = TableSchema(
    tables: {
      'Logging': MainConfigBase._Logging,
      'Theme': MainConfigBase._Theme,
    },
    canBeMissingSchemas: {},
    fields: {
      'monitor': MainConfigBase._monitor,
      'wings': MainConfigBase._wings,
      'socket': MainConfigBase._socket,
      'focusGrab': MainConfigBase._focusGrab,
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
    validator: staticSchema.validator,
    ignoreNotInSchema: staticSchema.ignoreNotInSchema,
    canBeMissingSchemas: staticSchema.canBeMissingSchemas,
  );

  @override
  final int monitor;
  @override
  final List<Wing<dynamic>> wings;
  @override
  final String? socket;
  @override
  final bool focusGrab;
  @override
  final bool animationEnable;
  @override
  final double animationSpeed;
  @override
  final double animationDamping;
  @override
  final AnimationFitting animationFitting;
  @override
  final AnimationSwitching animationSwitching;
  @override
  final bool requestKeyboardFocus;

  @override
  final LoggingConfig logging;
  @override
  final ThemeConfig theme;

  MainConfig({
    int? monitor,
    List<Wing<dynamic>>? wings,
    this.socket,
    bool? focusGrab,
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
       focusGrab = focusGrab ?? kReleaseMode,
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
      focusGrab: map['focusGrab'],
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
    return 'MainConfig(monitor = $monitor, wings = $wings, socket = $socket, focusGrab = $focusGrab, animationEnable = $animationEnable, animationSpeed = $animationSpeed, animationDamping = $animationDamping, animationFitting = $animationFitting, animationSwitching = $animationSwitching, requestKeyboardFocus = $requestKeyboardFocus, logging = $logging, theme = $theme)';
  }

  @override
  bool operator ==(covariant MainConfig other) {
    return monitor == other.monitor &&
        wings == other.wings &&
        socket == other.socket &&
        focusGrab == other.focusGrab &&
        animationEnable == other.animationEnable &&
        animationSpeed == other.animationSpeed &&
        animationDamping == other.animationDamping &&
        animationFitting == other.animationFitting &&
        animationSwitching == other.animationSwitching &&
        requestKeyboardFocus == other.requestKeyboardFocus &&
        logging == other.logging &&
        theme == other.theme;
  }

  @override
  int get hashCode => Object.hashAll([
    monitor,
    wings,
    socket,
    focusGrab,
    animationEnable,
    animationSpeed,
    animationDamping,
    animationFitting,
    animationSwitching,
    requestKeyboardFocus,
    logging,
    theme,
  ]);
}
