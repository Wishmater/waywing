// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin MainConfigI {
  ThemeMode get themeMode;
  MyColor get seedColor;
  MyColor? get surfaceColor;
  Duration get animationDuration;
  Curve get animationCurve;
  double? get _exclusiveSizeLeft;
  double? get _exclusiveSizeRight;
  double? get _exclusiveSizeTop;
  double? get _exclusiveSizeBottom;
  int get barMonitor;
  ScreenEdge get barSide;
  int get barSize;
  double get barMarginLeft;
  double get barMarginRight;
  double get barMarginTop;
  double get barMarginBottom;
  double? get _barItemSize;
  double get barRadiusInCross;
  double get barRadiusInMain;
  double get barRadiusOutCross;
  double get barRadiusOutMain;
  List<Feather<dynamic>> get barStartFeathers;
  List<Feather<dynamic>> get barCenterFeathers;
  List<Feather<dynamic>> get barEndFeathers;
}

class MainConfig with MainConfigI, MainConfigBase {
  final ThemeMode themeMode;
  final MyColor seedColor;
  final MyColor? surfaceColor;
  final Duration animationDuration;
  final Curve animationCurve;
  final double? _exclusiveSizeLeft;
  final double? _exclusiveSizeRight;
  final double? _exclusiveSizeTop;
  final double? _exclusiveSizeBottom;
  final int barMonitor;
  final ScreenEdge barSide;
  final int barSize;
  final double barMarginLeft;
  final double barMarginRight;
  final double barMarginTop;
  final double barMarginBottom;
  final double? _barItemSize;
  final double barRadiusInCross;
  final double barRadiusInMain;
  final double barRadiusOutCross;
  final double barRadiusOutMain;
  final List<Feather<dynamic>> barStartFeathers;
  final List<Feather<dynamic>> barCenterFeathers;
  final List<Feather<dynamic>> barEndFeathers;

  MainConfig({
    ThemeMode? themeMode,
    required this.seedColor,
    this.surfaceColor,
    Duration? animationDuration,
    Curve? animationCurve,
    double? exclusiveSizeLeft,
    double? exclusiveSizeRight,
    double? exclusiveSizeTop,
    double? exclusiveSizeBottom,
    int? barMonitor,
    required this.barSide,
    required this.barSize,
    double? barMarginLeft,
    double? barMarginRight,
    double? barMarginTop,
    double? barMarginBottom,
    double? barItemSize,
    double? barRadiusInCross,
    double? barRadiusInMain,
    double? barRadiusOutCross,
    double? barRadiusOutMain,
    List<Feather<dynamic>>? barStartFeathers,
    List<Feather<dynamic>>? barCenterFeathers,
    List<Feather<dynamic>>? barEndFeathers,
  }) : themeMode = themeMode ?? ThemeMode.system,
       animationDuration = animationDuration ?? Duration(milliseconds: 250),
       animationCurve = animationCurve ?? Curves.easeOutCubic,
       _exclusiveSizeLeft = exclusiveSizeLeft,
       _exclusiveSizeRight = exclusiveSizeRight,
       _exclusiveSizeTop = exclusiveSizeTop,
       _exclusiveSizeBottom = exclusiveSizeBottom,
       barMonitor = barMonitor ?? 0,
       barMarginLeft = barMarginLeft ?? 0,
       barMarginRight = barMarginRight ?? 0,
       barMarginTop = barMarginTop ?? 0,
       barMarginBottom = barMarginBottom ?? 0,
       _barItemSize = barItemSize,
       barRadiusInCross = barRadiusInCross ?? 0,
       barRadiusInMain = barRadiusInMain ?? 0,
       barRadiusOutCross = barRadiusOutCross ?? 0,
       barRadiusOutMain = barRadiusOutMain ?? 0,
       barStartFeathers = barStartFeathers ?? <Feather>[],
       barCenterFeathers = barCenterFeathers ?? <Feather>[],
       barEndFeathers = barEndFeathers ?? <Feather>[];

  factory MainConfig.fromMap(Map<String, dynamic> map) {
    return MainConfig(
      themeMode: map['themeMode'],
      seedColor: map['seedColor'],
      surfaceColor: map['surfaceColor'],
      animationDuration: map['animationDuration'],
      animationCurve: map['animationCurve'],
      exclusiveSizeLeft: map['exclusiveSizeLeft'],
      exclusiveSizeRight: map['exclusiveSizeRight'],
      exclusiveSizeTop: map['exclusiveSizeTop'],
      exclusiveSizeBottom: map['exclusiveSizeBottom'],
      barMonitor: map['barMonitor'],
      barSide: map['barSide'],
      barSize: map['barSize'],
      barMarginLeft: map['barMarginLeft'],
      barMarginRight: map['barMarginRight'],
      barMarginTop: map['barMarginTop'],
      barMarginBottom: map['barMarginBottom'],
      barItemSize: map['barItemSize'],
      barRadiusInCross: map['barRadiusInCross'],
      barRadiusInMain: map['barRadiusInMain'],
      barRadiusOutCross: map['barRadiusOutCross'],
      barRadiusOutMain: map['barRadiusOutMain'],
      barStartFeathers: map['barStartFeathers'],
      barCenterFeathers: map['barCenterFeathers'],
      barEndFeathers: map['barEndFeathers'],
    );
  }

  static TableSchema get schema => TableSchema(
    tables: MainConfigBase._getSchemaTables(),
    fields: {
      'themeMode': MainConfigBase._themeMode,
      'seedColor': MainConfigBase._seedColor,
      'surfaceColor': MainConfigBase._surfaceColor,
      'animationDuration': MainConfigBase._animationDuration,
      'animationCurve': MainConfigBase._animationCurve,
      'exclusiveSizeLeft': MainConfigBase.__exclusiveSizeLeft,
      'exclusiveSizeRight': MainConfigBase.__exclusiveSizeRight,
      'exclusiveSizeTop': MainConfigBase.__exclusiveSizeTop,
      'exclusiveSizeBottom': MainConfigBase.__exclusiveSizeBottom,
      'barMonitor': MainConfigBase._barMonitor,
      'barSide': MainConfigBase._barSide,
      'barSize': MainConfigBase._barSize,
      'barMarginLeft': MainConfigBase._barMarginLeft,
      'barMarginRight': MainConfigBase._barMarginRight,
      'barMarginTop': MainConfigBase._barMarginTop,
      'barMarginBottom': MainConfigBase._barMarginBottom,
      'barItemSize': MainConfigBase.__barItemSize,
      'barRadiusInCross': MainConfigBase._barRadiusInCross,
      'barRadiusInMain': MainConfigBase._barRadiusInMain,
      'barRadiusOutCross': MainConfigBase._barRadiusOutCross,
      'barRadiusOutMain': MainConfigBase._barRadiusOutMain,
      'barStartFeathers': MainConfigBase._barStartFeathers,
      'barCenterFeathers': MainConfigBase._barCenterFeathers,
      'barEndFeathers': MainConfigBase._barEndFeathers,
    },
  );
}
