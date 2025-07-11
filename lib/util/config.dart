import 'package:fl_linux_window_manager/models/screen_edge.dart';
import 'package:flutter/material.dart';

const config = Config();

// TODO: 2 get config from user
class Config {
  const Config(); // declared as const so it works with hot reload

  // Bar positioning / sizing
  final ScreenEdge barSide = ScreenEdge.right;
  final int barWidth = 80; // in pixels
  final double barMarginLeft = 0; // in flutter DIP, maybe also make in pixels so it's consistent
  final double barMarginRight = 0; // in flutter DIP, maybe also make in pixels so it's consistent
  final double barMarginTop = 380; // in flutter DIP, maybe also make in pixels so it's consistent
  final double barMarginBottom = 340; // in flutter DIP, maybe also make in pixels so it's consistent
  // Bar border radius
  final double barRadiusInPercCross = 0.5; // in percentage of bar cross-size
  final double barRadiusInPercMain = 0.5 * 0.67; // in percentage of bar cross-size
  final double barRadiusOutPercCross = 0.5; // in percentage of bar cross-size
  final double barRadiusOutPercMain = 0.5 * 1.5; // in percentage
  // TODO: 2 validate that you can't add margin on sides that conflict with barSide selected ??
  // TODO: 3 also support fixes pixel radius values

  // Theme / styling
  final ThemeMode themeMode = ThemeMode.light;
  final Color seedColor = Colors.deepPurple;

  // Animations
  final Duration animationDuration = const Duration(milliseconds: 250);
  final Curve animationCurve = Curves.easeOutCubic;
  // we probably want to set different animation "types" and then the user can set duration and curve for each of them
}
