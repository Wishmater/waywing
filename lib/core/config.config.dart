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
  bool get internalUsePainter;
  LoggingConfig get logging;
  ThemeConfig get theme;
  Map<String, List<Object>> get dynamicSchemas;
}

class MainConfig extends ConfigBaseI with MainConfigI, MainConfigBase {
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
      'internalUsePainter': MainConfigBase._internalUsePainter,
    },
  );

  static TableSchema get schema => TableSchema(
    tables: {
      ...staticSchema.tables,
      ...MainConfigBase._getDynamicSchemaTables().map(
        (k, v) => MapEntry(k, v.schema),
      ),
    },
    fields: staticSchema.fields,
    validator: staticSchema.validator,
    ignoreNotInSchema: staticSchema.ignoreNotInSchema,
    canBeMissingSchemas: <String>{
      ...staticSchema.canBeMissingSchemas,
      ...MainConfigBase._getDynamicSchemaTables().keys,
    },
  );

  @override
  final Map<String, List<Object>> dynamicSchemas;

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
  final bool internalUsePainter;

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
    bool? internalUsePainter,
    required this.logging,
    required this.theme,
    required this.dynamicSchemas,
  }) : monitor = monitor ?? 0,
       wings = wings ?? <Wing>[],
       focusGrab = focusGrab ?? kReleaseMode,
       animationEnable = animationEnable ?? true,
       animationSpeed = animationSpeed ?? 1,
       animationDamping = animationDamping ?? 1,
       animationFitting = animationFitting ?? AnimationFitting.clip,
       animationSwitching =
           animationSwitching ?? AnimationSwitching.fadeThrough,
       requestKeyboardFocus = requestKeyboardFocus ?? false,
       internalUsePainter = internalUsePainter ?? false;

  factory MainConfig.fromMap(Map<String, dynamic> map) {
    final dynamicSchemas = <String, List<Object>>{};
    final schemas = MainConfigBase._getDynamicSchemaTables();
    for (final entry in schemas.entries) {
      if (map[entry.key] == null) continue;
      for (final e in map[entry.key]) {
        if (dynamicSchemas[entry.key] == null) {
          dynamicSchemas[entry.key] = [];
        }
        dynamicSchemas[entry.key]!.add(entry.value.from(e));
      }
    }

    return MainConfig(
      dynamicSchemas: dynamicSchemas,
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
      internalUsePainter: map['internalUsePainter'],
      logging: LoggingConfig.fromMap(map['Logging'][0]),
      theme: ThemeConfig.fromMap(map['Theme'][0]),
    );
  }

  @override
  String toString() {
    return '''MainConfig(
	monitor = $monitor,
	wings = $wings,
	socket = $socket,
	focusGrab = $focusGrab,
	animationEnable = $animationEnable,
	animationSpeed = $animationSpeed,
	animationDamping = $animationDamping,
	animationFitting = $animationFitting,
	animationSwitching = $animationSwitching,
	requestKeyboardFocus = $requestKeyboardFocus,
	internalUsePainter = $internalUsePainter,
	logging = ${logging.toString().split("\n").join("\n\t")},
	theme = ${theme.toString().split("\n").join("\n\t")},
	dynamicSchemas = ${dynamicSchemas.toString().split("\n").join("\n\t")}
)''';
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
        internalUsePainter == other.internalUsePainter &&
        logging == other.logging &&
        theme == other.theme &&
        configMapEqual(dynamicSchemas, other.dynamicSchemas);
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
    internalUsePainter,
    logging,
    theme,
    dynamicSchemas,
  ]);
}
