import 'package:fl_linux_window_manager/models/screen_edge.dart';
import 'package:flutter/material.dart';

final config = Config();

// TODO 2 get config from user
class Config {
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
  final double barRadiusOutPercMain = 0.5 * 1.5; // in percentage of bar cross-size
  // TODO 2 validate that you can't add margin on sides that conflict with barSide selected ??
  // TODO 3 also support fixes pixel radius values

  // Theme / styling
  final ThemeMode themeMode = ThemeMode.light;
  final Color seedColor = Colors.deepPurple;

  // Animations
  final Duration animationDuration = Duration(milliseconds: 250);
}
