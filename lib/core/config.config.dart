// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin MainConfigI {
  int get monitor;
  String? get socket;
  bool get focusGrab;
  bool get focusContainerOnMouseOver;
  bool get animationEnable;
  double get animationSpeed;
  double get animationDamping;
  AnimationFitting get animationFitting;
  AnimationSwitching get animationSwitching;
  bool get requestKeyboardFocus;
  bool get internalUsePainter;
  LoggingConfig get logging;
  ThemeConfig get theme;
  List<(String, Object)> get dynamicSchemas;
}

class MainConfig extends ConfigBaseI with MainConfigI, MainConfigBase {
  static const BlockSchema staticSchema = BlockSchema(
    blocks: {
      'Logging': MainConfigBase._Logging,
      'Theme': MainConfigBase._Theme,
    },
    canBeMissingSchemas: {},
    fields: {
      'monitor': MainConfigBase._monitor,
      'socket': MainConfigBase._socket,
      'focusGrab': MainConfigBase._focusGrab,
      'focusContainerOnMouseOver': MainConfigBase._focusContainerOnMouseOver,
      'animationEnable': MainConfigBase._animationEnable,
      'animationSpeed': MainConfigBase._animationSpeed,
      'animationDamping': MainConfigBase._animationDamping,
      'animationFitting': MainConfigBase._animationFitting,
      'animationSwitching': MainConfigBase._animationSwitching,
      'requestKeyboardFocus': MainConfigBase._requestKeyboardFocus,
      'internalUsePainter': MainConfigBase._internalUsePainter,
    },
  );

  static BlockSchema get schema => BlockSchema(
    blocks: {
      ...staticSchema.blocks,
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
  final List<(String, Object)> dynamicSchemas;

  @override
  final int monitor;
  @override
  final String? socket;
  @override
  final bool focusGrab;
  @override
  final bool focusContainerOnMouseOver;
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
    this.socket,
    bool? focusGrab,
    bool? focusContainerOnMouseOver,
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
       focusGrab = focusGrab ?? kReleaseMode,
       focusContainerOnMouseOver = focusContainerOnMouseOver ?? true,
       animationEnable = animationEnable ?? true,
       animationSpeed = animationSpeed ?? 1,
       animationDamping = animationDamping ?? 1,
       animationFitting = animationFitting ?? AnimationFitting.clip,
       animationSwitching =
           animationSwitching ?? AnimationSwitching.fadeThrough,
       requestKeyboardFocus = requestKeyboardFocus ?? false,
       internalUsePainter = internalUsePainter ?? false;

  factory MainConfig.fromBlock(BlockData data) {
    Map<String, dynamic> fields = data.fields;

    final dynamicSchemas = <(String, Object)>[];
    final schemas = MainConfigBase._getDynamicSchemaTables();

    for (final block in data.blocks) {
      final key = block.$1;
      if (!schemas.containsKey(key)) {
        continue;
      }
      dynamicSchemas.add((key, schemas[key]!.from(block.$2)));
    }

    return MainConfig(
      dynamicSchemas: dynamicSchemas,
      monitor: fields['monitor'],
      socket: fields['socket'],
      focusGrab: fields['focusGrab'],
      focusContainerOnMouseOver: fields['focusContainerOnMouseOver'],
      animationEnable: fields['animationEnable'],
      animationSpeed: fields['animationSpeed'],
      animationDamping: fields['animationDamping'],
      animationFitting: fields['animationFitting'],
      animationSwitching: fields['animationSwitching'],
      requestKeyboardFocus: fields['requestKeyboardFocus'],
      internalUsePainter: fields['internalUsePainter'],
      logging: LoggingConfig.fromBlock(data.firstBlockWith('Logging')!),
      theme: ThemeConfig.fromBlock(data.firstBlockWith('Theme')!),
    );
  }

  @override
  String toString() {
    return '''MainConfig(
	monitor = $monitor,
	socket = $socket,
	focusGrab = $focusGrab,
	focusContainerOnMouseOver = $focusContainerOnMouseOver,
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
        socket == other.socket &&
        focusGrab == other.focusGrab &&
        focusContainerOnMouseOver == other.focusContainerOnMouseOver &&
        animationEnable == other.animationEnable &&
        animationSpeed == other.animationSpeed &&
        animationDamping == other.animationDamping &&
        animationFitting == other.animationFitting &&
        animationSwitching == other.animationSwitching &&
        requestKeyboardFocus == other.requestKeyboardFocus &&
        internalUsePainter == other.internalUsePainter &&
        logging == other.logging &&
        theme == other.theme &&
        configListEqual(dynamicSchemas, other.dynamicSchemas);
  }

  @override
  int get hashCode => Object.hashAll([
    monitor,
    socket,
    focusGrab,
    focusContainerOnMouseOver,
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

mixin FeathersContainerI {
  List<(String, Object)> get dynamicSchemas;
}

class FeathersContainer extends ConfigBaseI
    with FeathersContainerI, FeathersContainerBase {
  static const BlockSchema staticSchema = BlockSchema(fields: {});

  static BlockSchema get schema => BlockSchema(
    blocks: {
      ...staticSchema.blocks,
      ...FeathersContainerBase._getDynamicSchemaTables().map(
        (k, v) => MapEntry(k, v.schema),
      ),
    },
    fields: staticSchema.fields,
    validator: staticSchema.validator,
    ignoreNotInSchema: staticSchema.ignoreNotInSchema,
    canBeMissingSchemas: <String>{
      ...staticSchema.canBeMissingSchemas,
      ...FeathersContainerBase._getDynamicSchemaTables().keys,
    },
  );

  @override
  final List<(String, Object)> dynamicSchemas;

  FeathersContainer({required this.dynamicSchemas});

  factory FeathersContainer.fromBlock(BlockData data) {
    Map<String, dynamic> fields = data.fields;

    final dynamicSchemas = <(String, Object)>[];
    final schemas = FeathersContainerBase._getDynamicSchemaTables();

    for (final block in data.blocks) {
      final key = block.$1;
      if (!schemas.containsKey(key)) {
        continue;
      }
      dynamicSchemas.add((key, schemas[key]!.from(block.$2)));
    }

    return FeathersContainer(dynamicSchemas: dynamicSchemas);
  }

  @override
  String toString() {
    return '''FeathersContainer(
	dynamicSchemas = ${dynamicSchemas.toString().split("\n").join("\n\t")}
)''';
  }

  @override
  bool operator ==(covariant FeathersContainer other) {
    return configListEqual(dynamicSchemas, other.dynamicSchemas);
  }

  @override
  int get hashCode => Object.hashAll([dynamicSchemas]);
}
