import "dart:convert";

import "package:config/config.dart";
import "package:dartx/dartx.dart";
import "package:fl_linux_window_manager/models/screen_edge.dart";
import "package:flutter/material.dart";
import "package:tronco/tronco.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/util/config_fields.dart";
import "package:waywing/util/logger.dart";

final _logger = mainLogger.clone(properties: [LogType("Config")]);

MainConfig get config => _config;
late MainConfig _config;

@immutable
abstract class Config {}

@immutable
class MainConfig extends Config {
  //===========================================================================
  // Theme / styling
  //===========================================================================

  final ThemeMode themeMode;
  static const _themeModeName = "themeMode";
  static const _themeMode = EnumField(
    ThemeMode.values,
    defaultTo: ThemeMode.system,
  );

  final Color seedColor;
  static const _seedColorName = "seedColor";
  static const _seedColor = ColorField();

  final Color? surfaceColor;
  static const _surfaceColorName = "surfaceColor";
  static const _surfaceColor = ColorField(
    nullable: true,
  );

  //===========================================================================
  // Animations
  //===========================================================================

  final Duration animationDuration;
  static const _animationDurationName = "animationDuration";
  static const _animationDuration = DurationField(
    defaultTo: Duration(milliseconds: 250),
  );

  final Curve animationCurve;
  static const _animationCurveName = "animationCurve";
  static const _animationCurve = CurveField(
    defaultTo: Curves.easeOutCubic,
  );
  // TODO: 2 we probably want to set different animation "types" and then the user can set duration and curve for each of them

  //===========================================================================
  // Layer settings
  //===========================================================================

  final double? exclusiveSizeLeft;
  static const _exclusiveSizeLeftName = "exclusiveSizeLeft";
  static const _exclusiveSizeLeft = DoubleNumberField(nullable: true);

  final double? exclusiveSizeRight;
  static const _exclusiveSizeRightName = "exclusiveSizeRight";
  static const _exclusiveSizeRight = DoubleNumberField(nullable: true);

  final double? exclusiveSizeTop;
  static const _exclusiveSizeTopName = "exclusiveSizeTop";
  static const _exclusiveSizeTop = DoubleNumberField(nullable: true);

  final double? exclusiveSizeBottom;
  static const _exclusiveSizeBottomName = "exclusiveSizeBottom";
  static const _exclusiveSizeBottom = DoubleNumberField(nullable: true);

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

  final int barMonitor;
  static const _barMonitorName = "barMonitor";
  static const _barMonitor = IntegerNumberField(defaultTo: 0);

  final ScreenEdge barSide;
  static const _barSideName = "barSide";
  static const _barSide = EnumField(ScreenEdge.values);

  final int barSize; // in pixels
  static const _barSizeName = "barSize";
  static const _barSize = IntegerNumberField();

  final double barMarginLeft; // in flutter DIP, maybe also make in pixels so it's consistent ??? is it the same ???
  static const _barMarginLeftName = "barMarginLeft";
  static const _barMarginLeft = DoubleNumberField(defaultTo: 0);

  final double barMarginRight; // in flutter DIP, maybe also make in pixels so it's consistent ??? is it the same ???
  static const _barMarginRightName = "barMarginRight";
  static const _barMarginRight = DoubleNumberField(defaultTo: 0);

  final double barMarginTop; // in flutter DIP, maybe also make in pixels so it's consistent ??? is it the same ???
  static const _barMarginTopName = "barMarginTop";
  static const _barMarginTop = DoubleNumberField(defaultTo: 0);

  final double barMarginBottom; // in flutter DIP, maybe also make in pixels so it's consistent ??? is it the same ???
  static const _barMarginBottomName = "barMarginBottom";
  static const _barMarginBottom = DoubleNumberField(defaultTo: 0);

  final double barItemSize; // in flutter DIP, maybe also make in pixels so it's consistent ??? is it the same ???
  static const _barItemSizeName = "barItemSize";
  static const _barItemSize = DoubleNumberField(
    nullable: true, // defaults to barSize
  );

  // Derived
  late final bool isBarVertical = config.barSide == ScreenEdge.left || config.barSide == ScreenEdge.right;
  // TODO: 3 validate that mainSize is not <=0 after deducting margins
  // TODO: 3 validate that you can't add margin on sides that conflict with barSide selected

  //===========================================================================
  // Bar border radius
  //===========================================================================

  final double barRadiusInCross; // in flutter DIP, maybe also make in pixels so it's consistent ??? is it the same ???
  static const _barRadiusInCrossName = "barRadiusInCross";
  static const _barRadiusInCross = DoubleNumberField(defaultTo: 0);

  final double barRadiusInMain; // in flutter DIP, maybe also make in pixels so it's consistent ??? is it the same ???
  static const _barRadiusInMainName = "barRadiusInMain";
  static const _barRadiusInMain = DoubleNumberField(defaultTo: 0);

  final double barRadiusOutCross; // in flutter DIP, maybe also make in pixels so it's consistent ??? is it the same ???
  static const _barRadiusOutCrossName = "barRadiusOutCross";
  static const _barRadiusOutCross = DoubleNumberField(defaultTo: 0);

  final double barRadiusOutMain; // in flutter DIP, maybe also make in pixels so it's consistent ??? is it the same ???
  static const _barRadiusOutMainName = "barRadiusOutMain";
  static const _barRadiusOutMain = DoubleNumberField(defaultTo: 0);
  // TODO: 3 validate that barRadiusOutMain <= relevantBarMargin

  // Derived
  late final double buttonRadiusX = 0.5 * (isBarVertical ? barRadiusInCross : barRadiusInMain);
  late final double buttonRadiusY = 0.5 * (isBarVertical ? barRadiusInMain : barRadiusInCross);

  //===========================================================================
  // Bar feathers (components)
  //===========================================================================

  // When implementing reading config, get the instance with Feather.getByName
  final List<Feather> barStartFeathers;
  static const _barStartFeathersName = "barStartFeathers";
  static const _barStartFeathers = ListField(
    FeatherField(),
    defaultTo: <Feather>[],
  );

  final List<Feather> barCenterFeathers;
  static const _barCenterFeathersName = "barCenterFeathers";
  static const _barCenterFeathers = ListField(
    FeatherField(),
    defaultTo: <Feather>[],
  );

  final List<Feather> barEndFeathers;
  static const _barEndFeathersName = "barEndFeathers";
  static const _barEndFeathers = ListField(
    FeatherField(),
    defaultTo: <Feather>[],
  );

  MainConfig._({
    this.themeMode = ThemeMode.system,
    required this.seedColor,
    this.surfaceColor,
    this.animationDuration = const Duration(milliseconds: 250),
    this.animationCurve = Curves.easeOutCubic,
    double? exclusiveSizeLeft,
    double? exclusiveSizeRight,
    double? exclusiveSizeTop,
    double? exclusiveSizeBottom,
    this.barMonitor = 0,
    required this.barSide,
    required this.barSize,
    double? barItemSize,
    this.barMarginLeft = 0,
    this.barMarginRight = 0,
    this.barMarginTop = 0,
    this.barMarginBottom = 0,
    this.barRadiusInCross = 0,
    this.barRadiusInMain = 0,
    this.barRadiusOutCross = 0,
    this.barRadiusOutMain = 0,
    this.barStartFeathers = const [],
    this.barCenterFeathers = const [],
    this.barEndFeathers = const [],
  }) : exclusiveSizeLeft = exclusiveSizeLeft ?? (barSide == ScreenEdge.left ? barSize.toDouble() : null),
       exclusiveSizeRight = exclusiveSizeRight ?? (barSide == ScreenEdge.right ? barSize.toDouble() : null),
       exclusiveSizeTop = exclusiveSizeTop ?? (barSide == ScreenEdge.top ? barSize.toDouble() : null),
       exclusiveSizeBottom = exclusiveSizeBottom ?? (barSide == ScreenEdge.bottom ? barSize.toDouble() : null),
       barItemSize = barItemSize ?? barSize.toDouble();

  static Schema buildSchema() {
    return Schema(
      fields: {
        _themeModeName: _themeMode,
        _seedColorName: _seedColor,
        _surfaceColorName: _surfaceColor,
        _animationDurationName: _animationDuration,
        _animationCurveName: _animationCurve,
        _exclusiveSizeLeftName: _exclusiveSizeLeft,
        _exclusiveSizeRightName: _exclusiveSizeRight,
        _exclusiveSizeTopName: _exclusiveSizeTop,
        _exclusiveSizeBottomName: _exclusiveSizeBottom,
        _barMonitorName: _barMonitor,
        _barSideName: _barSide,
        _barSizeName: _barSize,
        _barMarginLeftName: _barMarginLeft,
        _barMarginRightName: _barMarginRight,
        _barMarginTopName: _barMarginTop,
        _barMarginBottomName: _barMarginBottom,
        _barItemSizeName: _barItemSize,
        _barRadiusInCrossName: _barRadiusInCross,
        _barRadiusInMainName: _barRadiusInMain,
        _barRadiusOutCrossName: _barRadiusOutCross,
        _barRadiusOutMainName: _barRadiusOutMain,
        _barStartFeathersName: _barStartFeathers,
        _barCenterFeathersName: _barCenterFeathers,
        _barEndFeathersName: _barEndFeathers,
      },
      tables: {
        "Bar": Schema(
          fields: {
            "size": IntegerNumberField(nullable: true),
          },
        ),
      },
    );
  }

  factory MainConfig.fromMap(Map<String, dynamic> values) {
    return MainConfig._(
      themeMode: values[_themeModeName],
      seedColor: values[_seedColorName],
      surfaceColor: values[_surfaceColorName],
      animationDuration: values[_animationDurationName],
      animationCurve: values[_animationCurveName],
      exclusiveSizeLeft: values[_exclusiveSizeLeftName],
      exclusiveSizeRight: values[_exclusiveSizeRightName],
      exclusiveSizeTop: values[_exclusiveSizeTopName],
      exclusiveSizeBottom: values[_exclusiveSizeBottomName],
      barMonitor: values[_barMonitorName],
      barSide: values[_barSideName],
      barSize: values[_barSizeName],
      barMarginLeft: values[_barMarginLeftName],
      barMarginRight: values[_barMarginRightName],
      barMarginTop: values[_barMarginTopName],
      barMarginBottom: values[_barMarginBottomName],
      barItemSize: values[_barItemSizeName],
      barRadiusInCross: values[_barRadiusInCrossName],
      barRadiusInMain: values[_barRadiusInMainName],
      barRadiusOutCross: values[_barRadiusOutCrossName],
      barRadiusOutMain: values[_barRadiusOutMainName],
      barStartFeathers: values[_barStartFeathersName],
      barCenterFeathers: values[_barCenterFeathersName],
      barEndFeathers: values[_barEndFeathersName],
    );
  }
}

Future<Config> reloadConfig(String content) async {
  final result = ConfigurationParser().parseFromString(
    content,
    schema: MainConfig.buildSchema(),
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
      _config = MainConfig.fromMap(result.values);
      return _config;
  }
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
