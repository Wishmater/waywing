// ignore_for_file: unused_element_parameter  TODO: 2 remove this once reading user config is implemented, which will use all params

import 'package:fl_linux_window_manager/models/screen_edge.dart';
import 'package:flutter/material.dart';
import 'package:waywing/core/feather.dart';
import 'package:waywing/core/feather_registry.dart';

Config get config => _config;
late Config _config;

@immutable
class Config {
  // Theme / styling
  final ThemeMode themeMode;
  final Color seedColor;

  // Animations
  final Duration animationDuration;
  final Curve animationCurve;
  // TODO: 2 we probably want to set different animation "types" and then the user can set duration and curve for each of them

  // Layer settings
  final double? exclusiveSizeLeft;
  final double? exclusiveSizeRight;
  final double? exclusiveSizeTop;
  final double? exclusiveSizeBottom;
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

  // Bar positioning / sizing
  final ScreenEdge barSide;
  final int barWidth; // in pixels
  final double barMarginLeft; // in flutter DIP, maybe also make in pixels so it's consistent
  final double barMarginRight; // in flutter DIP, maybe also make in pixels so it's consistent
  final double barMarginTop; // in flutter DIP, maybe also make in pixels so it's consistent
  final double barMarginBottom; // in flutter DIP, maybe also make in pixels so it's consistent
  final double barItemSize; // in flutter DIP, maybe also make in pixels so it's consistent
  // Derivates
  late final bool isBarVertical = config.barSide == ScreenEdge.left || config.barSide == ScreenEdge.right;
  // TODO: 3 validate that mainSize is not <=0 after deducting margins
  // TODO: 3 validate that you can't add margin on sides that conflict with barSide selected

  // Bar border radius
  final double barRadiusInPercCross; // in percentage of bar cross-size
  final double barRadiusInPercMain; // in percentage of bar cross-size
  final double barRadiusOutPercCross; // in percentage of bar cross-size
  final double barRadiusOutPercMain; // in percentage
  // TODO: 2 also support fixed pixel radius values
  // TODO: 3 validate that barRadiusOutMain <= relevantBarMargin

  // Bar feathers (components)
  // When implementing reading config, get the instance with Feather.getByName
  final List<Feather> barStartFeathers;
  final List<Feather> barCenterFeathers;
  final List<Feather> barEndFeathers;
  // TODO: 3 validate that passed feather names exist

  Config._({
    this.themeMode = ThemeMode.system,
    required this.seedColor,
    this.animationDuration = const Duration(milliseconds: 250),
    this.animationCurve = Curves.easeOutCubic,
    double? exclusiveSizeLeft,
    double? exclusiveSizeRight,
    double? exclusiveSizeTop,
    double? exclusiveSizeBottom,
    required this.barSide,
    required this.barWidth,
    double? barItemSize,
    this.barMarginLeft = 0,
    this.barMarginRight = 0,
    this.barMarginTop = 0,
    this.barMarginBottom = 0,
    this.barRadiusInPercCross = 0,
    this.barRadiusInPercMain = 0,
    this.barRadiusOutPercCross = 0,
    this.barRadiusOutPercMain = 0,
    this.barStartFeathers = const [],
    this.barCenterFeathers = const [],
    this.barEndFeathers = const [],
  }) : exclusiveSizeLeft = exclusiveSizeLeft ?? (barSide == ScreenEdge.left ? barWidth.toDouble() : null),
       exclusiveSizeRight = exclusiveSizeRight ?? (barSide == ScreenEdge.right ? barWidth.toDouble() : null),
       exclusiveSizeTop = exclusiveSizeTop ?? (barSide == ScreenEdge.top ? barWidth.toDouble() : null),
       exclusiveSizeBottom = exclusiveSizeBottom ?? (barSide == ScreenEdge.bottom ? barWidth.toDouble() : null),
       barItemSize = barItemSize ?? barWidth.toDouble();
}

Future<Config> reloadConfig() async {
  // TODO: 2 get config from user file
  _config = Config._(
    themeMode: ThemeMode.light,
    seedColor: Colors.blue,
    animationDuration: Duration(milliseconds: 250),
    barSide: ScreenEdge.right,
    barWidth: 64,
    barMarginTop: 380,
    barMarginBottom: 340,
    barMarginLeft: 48,
    barMarginRight: 48,
    barRadiusInPercCross: 0.5,
    barRadiusInPercMain: 0.5 * 0.67,
    barRadiusOutPercCross: 0.5,
    barRadiusOutPercMain: 0.5 * 1.5,
    barStartFeathers: List.unmodifiable([
      featherRegistry.getFeatherByName('Clock'),
      featherRegistry.getFeatherByName('Clock'),
      featherRegistry.getFeatherByName('Clock'),
    ]),
    barCenterFeathers: List.unmodifiable([
      featherRegistry.getFeatherByName('Clock'),
      featherRegistry.getFeatherByName('Clock'),
    ]),
    barEndFeathers: List.unmodifiable([
      featherRegistry.getFeatherByName('Clock'),
      featherRegistry.getFeatherByName('Clock'),
      featherRegistry.getFeatherByName('Clock'),
      featherRegistry.getFeatherByName('Clock'),
    ]),
  );
  return _config;
}
