import "dart:convert";
import "dart:io";

import "package:config/config.dart";
import "package:config_gen/config_gen.dart";
import "package:dartx/dartx.dart";
import "package:fl_linux_window_manager/models/screen_edge.dart";
import "package:flutter/material.dart";
import "package:path/path.dart" as path;
import "package:tronco/tronco.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/util/animation_utils.dart";
import "package:waywing/util/config_fields.dart";
import "package:waywing/util/logger.dart";

part "config.g.dart";

final _logger = mainLogger.clone(properties: [LogType("Config")]);

MainConfig get mainConfig => _config;
late MainConfig _config;

Map<String, dynamic> get rawMainConfig => _rawMainConfig;
late Map<String, dynamic> _rawMainConfig;

typedef SchemaBuilder = TableSchema Function();
typedef ConfigBuilder<Conf> = Conf Function(Map<String, dynamic> map);

@Config()
mixin MainConfigBase on MainConfigI {
  //===========================================================================
  // Theme / styling
  //===========================================================================

  static const _themeMode = EnumField(ThemeMode.values, defaultTo: ThemeMode.system);
  static const _seedColor = ColorField();
  static const _surfaceColor = ColorField(nullable: true);

  //===========================================================================
  // Animations
  //===========================================================================

  static const _animationSpeed = DoubleNumberField(defaultTo: 1); // stiffness
  static const _animationDamping = DoubleNumberField(defaultTo: 1);
  static const _animationFitting = EnumField(AnimationFitting.values, defaultTo: AnimationFitting.clip);
  // TODO: 3 validate that these are >=0 and maybe an upper bound as well

  late final motions = MaterialSpringMotionValues(
    // increasing damping will still speed and decreasing dambing will increase speed,
    // multiplying stiffness by damping causes damping changes to not affect speed as much.
    stiffness: animationSpeed * animationDamping,
    damping: animationDamping,
  );

  //===========================================================================
  // Layer settings
  //===========================================================================

  static const _requestKeyboardFocus = BooleanField(defaultTo: false);

  static const __exclusiveSizeLeft = DoubleNumberField(nullable: true);
  double get exclusiveSizeLeft => _exclusiveSizeLeft ?? (barSide == ScreenEdge.left ? barSize.toDouble() : 0);
  static const __exclusiveSizeRight = DoubleNumberField(nullable: true);
  double get exclusiveSizeRight => _exclusiveSizeRight ?? (barSide == ScreenEdge.right ? barSize.toDouble() : 0);
  static const __exclusiveSizeTop = DoubleNumberField(nullable: true);
  double get exclusiveSizeTop => _exclusiveSizeTop ?? (barSide == ScreenEdge.top ? barSize.toDouble() : 0);
  static const __exclusiveSizeBottom = DoubleNumberField(nullable: true);
  double get exclusiveSizeBottom => _exclusiveSizeBottom ?? (barSide == ScreenEdge.bottom ? barSize.toDouble() : 0);

  // Note (add to readme when it exists): explicitly set exclusiveSice will have priority over Bar size.
  // Set exclusiveSize to zero on same side bar is on to remove autoExclusiveSize on Bar.
  double? getExclusiveSizeForSide(ScreenEdge side) {
    return switch (side) {
      ScreenEdge.left => exclusiveSizeLeft,
      ScreenEdge.right => exclusiveSizeRight,
      ScreenEdge.top => exclusiveSizeTop,
      ScreenEdge.bottom => exclusiveSizeBottom,
    };
  }

  //===========================================================================
  // Bar positioning / sizing
  //===========================================================================

  static const _barMonitor = IntegerNumberField(defaultTo: 0);
  static const _barSide = EnumField(ScreenEdge.values);
  static const _barSize = IntegerNumberField(); // in pixels
  // in flutter DIP, maybe also make in pixels so it's consistent ??? is it the same ???
  static const _barMarginLeft = DoubleNumberField(defaultTo: 0);
  static const _barMarginRight = DoubleNumberField(defaultTo: 0);
  static const _barMarginTop = DoubleNumberField(defaultTo: 0);
  static const _barMarginBottom = DoubleNumberField(defaultTo: 0);
  static const __barIndicatorMinSize = DoubleNumberField(nullable: true); // defaults to barSize
  double get barIndicatorMinSize => _barIndicatorMinSize ?? barSize.toDouble();
  static const __barIndicatorPadding = DoubleNumberField(nullable: true); // defaults to a fraction of barSize
  double get barIndicatorPadding => _barIndicatorPadding ?? barSize.toDouble();

  // Derived
  late final bool isBarVertical = mainConfig.barSide == ScreenEdge.left || mainConfig.barSide == ScreenEdge.right;
  // TODO: 3 validate that mainSize is not <=0 after deducting margins
  // TODO: 3 validate that you can't add margin on sides that conflict with barSide selected

  //===========================================================================
  // Bar border radius
  //===========================================================================

  // in flutter DIP, maybe also make in pixels so it's consistent ??? is it the same ???
  static const _barRadiusInCross = DoubleNumberField(defaultTo: 0);
  static const _barRadiusInMain = DoubleNumberField(defaultTo: 0);
  static const _barRadiusOutCross = DoubleNumberField(defaultTo: 0);
  static const _barRadiusOutMain = DoubleNumberField(defaultTo: 0);
  // TODO: 3 validate that barRadiusOutMain <= relevantBarMargin

  // Derived
  late final double buttonRadiusX = 0.5 * (isBarVertical ? barRadiusInCross : barRadiusInMain);
  late final double buttonRadiusY = 0.5 * (isBarVertical ? barRadiusInMain : barRadiusInCross);

  //===========================================================================
  // Bar feathers (components)
  //===========================================================================

  static const _barStartFeathers = ListField(FeatherField(), defaultTo: <Feather>[]);
  static const _barCenterFeathers = ListField(FeatherField(), defaultTo: <Feather>[]);
  static const _barEndFeathers = ListField(FeatherField(), defaultTo: <Feather>[]);

  //===========================================================================
  // Add config tables defined in other files
  //===========================================================================

  static Map<String, TableSchema> _getSchemaTables() => {
    "Logging": LoggingConfig.schema,
    ...featherRegistry.getSchemaTables(),
    ...serviceRegistry.getSchemaTables(),
  };
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
      _rawMainConfig = Map.unmodifiable(result.values);
      _config = MainConfig.fromMap(result.values);
      updateLoggerConfig(LoggingConfig.fromMap(result.values["Logging"]));
      return _config;
  }
}

late final String? customConfigPath;
String getConfigurationFilePath() {
  if (customConfigPath != null) {
    return customConfigPath!;
  } else {
    final configDir = Platform.environment["XDG_CONFIG_HOME"] ?? expandEnvironmentVariables(r"$HOME/.config");
    return path.joinAll([configDir, "waywing", "config"]);
  }
}

String getConfigurationDirectoryPath() {
  if (customConfigPath != null) {
    try {
      return File(customConfigPath!).parent.path;
    } catch (_) {}
  }
  final configDir = Platform.environment["XDG_CONFIG_HOME"] ?? expandEnvironmentVariables(r"$HOME/.config");
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

const String defaultConfig = '''
  seedColor = "#0000ff"
  animationDuration = 250ms
  barSide = "top"
  barSize = 64
  barMarginLeft = barSize
  barMarginRight = barSize
  barRadiusInCross = barSize * 0.5
  barRadiusInMain = barSize * 0.5 * 0.67
  barRadiusOutCross = barSize * 0.5
  barRadiusOutMain = barSize * 0.5 * 1.5
  barStartFeathers = [  ]
  barEndFeathers = [ "Volume", "NetworkManager", "SystemTray", "Clock" ]
''';

// Only if the dollar sign does not have a backslash before it.
final _unescapedVariables = RegExp(r"(?<!\\)\$([a-zA-Z_]+[a-zA-Z0-9_]*)");

/// Resolves environment variables. Replaces all $VARS with their value.
String expandEnvironmentVariables(String path) {
  return path.replaceAllMapped(_unescapedVariables, (Match match) {
    String env = match[1]!;
    return Platform.environment[env] ?? "";
  });
}

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
