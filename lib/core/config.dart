import 'package:fl_linux_window_manager/models/screen_edge.dart';
import 'package:flutter/material.dart';
import 'package:waywing/core/feather.dart';
import 'package:waywing/core/feather_registry.dart';

Config get config => _config;
late Config _config;

@immutable
class Config {
  Config._();

  // Theme / styling
  final ThemeMode themeMode = ThemeMode.light;
  final Color seedColor = Colors.deepPurple;

  // Animations
  final Duration animationDuration = const Duration(milliseconds: 250);
  final Curve animationCurve = Curves.easeOutCubic;
  // TODO: 2 we probably want to set different animation "types" and then the user can set duration and curve for each of them

  // Bar positioning / sizing
  final ScreenEdge barSide = ScreenEdge.right;
  final int barWidth = 64; // in pixels
  final double barMarginLeft = 0; // in flutter DIP, maybe also make in pixels so it's consistent
  final double barMarginRight = 0; // in flutter DIP, maybe also make in pixels so it's consistent
  final double barMarginTop = 380; // in flutter DIP, maybe also make in pixels so it's consistent
  final double barMarginBottom = 340; // in flutter DIP, maybe also make in pixels so it's consistent
  final double barItemSize = 64; // in flutter DIP, maybe also make in pixels so it's consistent
  // Derivates
  late final bool isBarVertical = config.barSide == ScreenEdge.left || config.barSide == ScreenEdge.right;
  // TODO: 3 validate that mainSize is not <=0 after deducting margins
  // TODO: 3 validate that you can't add margin on sides that conflict with barSide selected

  // Bar border radius
  final double barRadiusInPercCross = 0.5; // in percentage of bar cross-size
  final double barRadiusInPercMain = 0.5 * 0.67; // in percentage of bar cross-size
  final double barRadiusOutPercCross = 0.5; // in percentage of bar cross-size
  final double barRadiusOutPercMain = 0.5 * 1.5; // in percentage
  // TODO: 2 also support fixed pixel radius values

  // Bar feathers (components)
  // When implementing reading config, get the instance with Feather.getByName
  final List<Feather> barStartFeathers = List.unmodifiable([]);
  final List<Feather> barCenterFeathers = List.unmodifiable([]);
  final List<Feather> barEndFeathers = List.unmodifiable([
    featherRegistry.getFeatherByName('Clock'),
  ]);
  // TODO: 3 validate that passed feather names exist
}

Future<Config> reloadConfig() async {
  // TODO: 2 get config from user file
  _config = Config._();
  return _config;
}
