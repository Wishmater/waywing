import "dart:convert";
import "dart:io";

import "package:config/config.dart";
import "package:config_gen/config_gen.dart";
import "package:dartx/dartx.dart";
import "package:fl_linux_window_manager/models/screen_edge.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:path/path.dart" as path;
import "package:tronco/tronco.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/core/theme.dart";
import "package:waywing/core/wing.dart";
import "package:waywing/util/animation_utils.dart";
import "package:waywing/util/derived_value_notifier.dart";
import "package:waywing/util/logger.dart";
import "package:waywing/util/xdg_dirs.dart";

part "config.config.dart";

final String _dataHome = dataHomeDir;
Directory? _mainDataHomeDir;
Directory get mainDataHomeDir {
  if (_mainDataHomeDir == null) {
    _mainDataHomeDir = Directory(path.join(_dataHome, "waywing"));
    _mainDataHomeDir!.createSync();
  }
  return _mainDataHomeDir!;
}

final _logger = mainLogger.clone(properties: [LogType("Config")]);

MainConfig get mainConfig => _config;
late MainConfig _config;

typedef SchemaBuilder = BlockSchema Function();
typedef ConfigBuilder<Conf> = Conf Function(BlockData map);

@Config()
mixin MainConfigBase on MainConfigI {
  // TODO: 2 each wing should declare its monitor, instead of having it here globally
  // This requires a big refactor in window_utils
  static const _monitor = IntegerNumberField(defaultTo: 0);
  static const _socket = StringField(nullable: true);
  static const _focusGrab = BooleanField(defaultTo: kReleaseMode);
  // TODO: 2 flutter focus still does some weird shit when this is set to false, needs some debugging
  static const _focusContainerOnMouseOver = BooleanField(defaultTo: true);

  // TODO: 3 validate that at least 1 wing is added (at least warn, prefer hard error)

  //===========================================================================
  // Animations
  //===========================================================================

  static const _animationEnable = BooleanField(defaultTo: true);
  static const _animationSpeed = DoubleNumberField(defaultTo: 1); // stiffness
  static const _animationDamping = DoubleNumberField(defaultTo: 1);
  // TODO: 3 validate that these () are >=0 and maybe an upper bound as well

  static const _animationFitting = EnumField(AnimationFitting.values, defaultTo: AnimationFitting.clip);
  static const _animationSwitching = EnumField(AnimationSwitching.values, defaultTo: AnimationSwitching.fadeThrough);

  late final motions = MaterialSpringMotionValues(
    // increasing damping will still speed and decreasing dambing will increase speed,
    // multiplying stiffness by damping causes damping changes to not affect speed as much.
    enableAnimations: animationEnable, // TODO: 1 This does not get affected by configuration changes. Fix it.
    stiffness: animationSpeed * animationDamping,
    damping: animationDamping,
  );

  //===========================================================================
  // Layer settings
  //===========================================================================

  static const _requestKeyboardFocus = BooleanField(defaultTo: false);

  late final ValueListenable<EdgeInsets> exclusiveSize = DerivedValueNotifier(
    dependencies: wings.map((e) => e.exclusiveSize).toList(),
    derive: () => wings.map((e) => e.exclusiveSize.value).fold(EdgeInsets.zero, (a, b) => a + b),
  );
  double? getExclusiveSizeForSide(ScreenEdge side) {
    return switch (side) {
      ScreenEdge.left => exclusiveSize.value.left,
      ScreenEdge.right => exclusiveSize.value.right,
      ScreenEdge.top => exclusiveSize.value.top,
      ScreenEdge.bottom => exclusiveSize.value.bottom,
    };
  }

  //===========================================================================
  // Add config tables defined in other files
  //===========================================================================

  @SchemaFieldAnnot()
  static const _Logging = LoggingConfig.staticSchema; // ignore: constant_identifier_names
  @SchemaFieldAnnot()
  static const _Theme = ThemeConfig.staticSchema; // ignore: constant_identifier_names

  static Map<String, ({BlockSchema schema, dynamic Function(BlockData) from})> _getDynamicSchemaTables() => {
    // TODO: 3 validate that "Wings" is only added once
    "Wings": (schema: FeathersContainer.schema, from: FeathersContainer.fromBlock),
    // TODO: 3 validate that "Defaults" is only added once
    "Defaults": (schema: FeathersContainer.schema, from: FeathersContainer.fromBlock),
    ...serviceRegistry.getSchemaTables(),
  };
  FeathersContainer? get featherDefaults =>
      dynamicSchemas.firstOrNullWhere((e) => e.$1 == "Defaults")?.$2 as FeathersContainer?;

  //===========================================================================
  // Internal experimental options
  //===========================================================================
  static const _internalDebugIcons = BooleanField(defaultTo: false);

  //===========================================================================
  // Wings
  //===========================================================================

  late final List<Wing> wings = _getWings();
  List<Wing> _getWings() {
    // TODO: 3 validate that Wings is added and that it has at least 1 wing
    final feathersContainer = dynamicSchemas.firstOrNullWhere((e) => e.$1 == "Wings")?.$2 as FeathersContainer?;
    // TODO: 3 make it so the error is prettier if a non-wing feather is added as a wing
    return feathersContainer?.getFeatherInstances<Wing>(null) ?? [];
  }
}

@Config()
mixin FeathersContainerBase on FeathersContainerI {
  static Map<String, ({BlockSchema schema, dynamic Function(BlockData) from})> _getDynamicSchemaTables() =>
      featherRegistry.getDynamicFeathersSchemas();

  List<(String, Object)> get rawFeathers => dynamicSchemas;

  List<T> getFeatherInstances<T extends Feather>(String? uniqueIdPrefix) {
    return getFeatherInstancesStatic<T>(rawFeathers, uniqueIdPrefix);
  }
}

List<T> getFeatherInstancesStatic<T extends Feather>(
  List<(String, Object)> feathers,
  String? uniqueIdPrefix,
) {
  final result = <T>[];
  final counter = <String, int>{};
  for (final e in feathers) {
    final featherName = e.$1;
    final i = (counter[featherName] ?? -1) + 1;
    counter[featherName] = i;

    final config = e.$2 as BlockData;
    final uniqueId = uniqueIdPrefix != null ? "$uniqueIdPrefix.$featherName[$i]" : "$featherName[$i]";
    final feather = featherRegistry.getFeatherInstance(featherName, uniqueId, config) as T;
    result.add(feather);
  }
  return result;
}

Future<MainConfig> reloadConfig(String content) async {
  final result = ConfigurationParser().parseFromString(
    content,
    schema: MainConfig.schema,
  );
  // TODO: 2 implement proper config error handling
  switch (result) {
    case EvaluationParseError():
      _logger.log(Level.fatal, "Read config EvaluationParseError\n${result.errors.join("\n")}");
      // TODO: 2 on config parse error, we should probably load default config and notify error
      throw UnimplementedError();
    case EvaluationValidationError():
      _logger.log(Level.fatal, "Read config EvaluationValidationError\n${result.errors.join("\n")}");
      _logger.log(Level.debug, _toPrettyJson(result.values));
      // TODO: 2 on config evaluation error: ideally, we have sane defaults on everything
      // so that result.values is still usable AND we notify errors
      throw UnimplementedError();
    case EvaluationSuccess():
      _logger.log(Level.info, "Read config EvaluationSuccess");
      _logger.log(Level.debug, _toPrettyJson(result.values));
      _config = MainConfig.fromBlock(result.values);
      updateLoggerConfig(_config.logging);
      return _config;
  }
}

late final String? customConfigPath;
String getConfigurationFilePath() {
  if (customConfigPath != null) {
    return customConfigPath!;
  } else {
    return path.joinAll([configDir, "waywing", "config"]);
  }
}

String getConfigurationDirectoryPath() {
  if (customConfigPath != null) {
    try {
      return File(customConfigPath!).parent.path;
    } catch (_) {}
  }
  return path.joinAll([configDir, "waywing"]);
}

Future<String> getConfigurationString() async {
  final file = File(getConfigurationFilePath());
  if (await file.exists()) {
    return file.readAsString();
  } else {
    return defaultConfig;
  }
}

// TODO: 2 RELEASE update the defalut config
const String defaultConfig = """
  # TODO: 2 add a sensible initial config, once config API is more stable
""";

dynamic _toPrettyJson(dynamic values) {
  const encoder = JsonEncoder.withIndent("  ");
  values = _sanitizeForJson(values);
  return encoder.convert(values);
}

dynamic _sanitizeForJson(dynamic e) {
  if (e == null) return e;
  if (e is num) return e;
  if (e is List) return e.map(_sanitizeForJson).toList();
  if (e is Map) return e.mapValues((entry) => _sanitizeForJson(entry.value));
  return e.toString();
}

// TODO: 3 why is this necessary ??
class EmptyConfig {
  const EmptyConfig();

  factory EmptyConfig.fromMap(dynamic _) {
    return EmptyConfig();
  }

  static Schema get schema => Schema();
}
