import 'package:config/config.dart';
import 'package:fl_linux_window_manager/models/screen_edge.dart';
import 'package:flutter/material.dart';
import 'package:waywing/core/feather.dart';
import 'package:waywing/core/feather_registry.dart';
import 'package:waywing/util/config_fields.dart';

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
  static const _themeMode = EnumField(
    'themeMode',
    ThemeMode.values,
    defaultTo: ThemeMode.system,
  );

  final Color seedColor;
  static const _seedColor = ColorField(
    'seedColor',
  );

  //===========================================================================
  // Animations
  //===========================================================================

  final Duration animationDuration;
  static const _animationDuration = DurationField(
    'animationDuration',
    defaultTo: Duration(milliseconds: 250),
  );

  final Curve animationCurve;
  static const _animationCurve = CurveField(
    'animationCurve',
    defaultTo: Curves.easeOutCubic,
  );
  // TODO: 2 we probably want to set different animation "types" and then the user can set duration and curve for each of them

  //===========================================================================
  // Layer settings
  //===========================================================================

  final double? exclusiveSizeLeft;
  static const _exclusiveSizeLeft = DoubleNumberField(
    'exclusiveSizeLeft',
    nullable: true,
  );

  final double? exclusiveSizeRight;
  static const _exclusiveSizeRight = DoubleNumberField(
    'exclusiveSizeRight',
    nullable: true,
  );

  final double? exclusiveSizeTop;
  static const _exclusiveSizeTop = DoubleNumberField(
    'exclusiveSizeTop',
    nullable: true,
  );

  final double? exclusiveSizeBottom;
  static const _exclusiveSizeBottom = DoubleNumberField(
    'exclusiveSizeBottom',
    nullable: true,
  );

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

  final ScreenEdge barSide;
  static const _barSide = EnumField(
    'barSide',
    ScreenEdge.values,
  );

  final int barSize; // in pixels
  static const _barSize = IntegerNumberField(
    'barSize',
  );

  final double barMarginLeft; // in flutter DIP, maybe also make in pixels so it's consistent ??? is it the same ???
  static const _barMarginLeft = DoubleNumberField(
    'barMarginLeft',
    defaultTo: 0,
  );

  final double barMarginRight; // in flutter DIP, maybe also make in pixels so it's consistent ??? is it the same ???
  static const _barMarginRight = DoubleNumberField(
    'barMarginRight',
    defaultTo: 0,
  );

  final double barMarginTop; // in flutter DIP, maybe also make in pixels so it's consistent ??? is it the same ???
  static const _barMarginTop = DoubleNumberField(
    'barMarginTop',
    defaultTo: 0,
  );

  final double barMarginBottom; // in flutter DIP, maybe also make in pixels so it's consistent ??? is it the same ???
  static const _barMarginBottom = DoubleNumberField(
    'barMarginBottom',
    defaultTo: 0,
  );

  final double barItemSize; // in flutter DIP, maybe also make in pixels so it's consistent ??? is it the same ???
  static const _barItemSize = DoubleNumberField(
    'barItemSize',
    nullable: true, // defaults to barSize
  );

  // Derivates
  late final bool isBarVertical = config.barSide == ScreenEdge.left || config.barSide == ScreenEdge.right;
  // TODO: 3 validate that mainSize is not <=0 after deducting margins
  // TODO: 3 validate that you can't add margin on sides that conflict with barSide selected

  //===========================================================================
  // Bar border radius
  //===========================================================================

  final double barRadiusInCross; // in flutter DIP, maybe also make in pixels so it's consistent ??? is it the same ???
  static const _barRadiusInCross = DoubleNumberField(
    'barRadiusInCross',
    defaultTo: 0,
  );

  final double barRadiusInMain; // in flutter DIP, maybe also make in pixels so it's consistent ??? is it the same ???
  static const _barRadiusInMain = DoubleNumberField(
    'barRadiusInMain',
    defaultTo: 0,
  );

  final double barRadiusOutCross; // in flutter DIP, maybe also make in pixels so it's consistent ??? is it the same ???
  static const _barRadiusOutCross = DoubleNumberField(
    'barRadiusOutCross',
    defaultTo: 0,
  );

  final double barRadiusOutMain; // in flutter DIP, maybe also make in pixels so it's consistent ??? is it the same ???
  static const _barRadiusOutMain = DoubleNumberField(
    'barRadiusOutMain',
    defaultTo: 0,
  );
  // TODO: 3 validate that barRadiusOutMain <= relevantBarMargin

  //===========================================================================
  // Bar feathers (components)
  //===========================================================================

  // When implementing reading config, get the instance with Feather.getByName
  final List<Feather> barStartFeathers;
  final List<Feather> barCenterFeathers;
  final List<Feather> barEndFeathers;
  // TODO: 3 validate that passed feather names exist

  MainConfig._({
    this.themeMode = ThemeMode.system,
    required this.seedColor,
    this.animationDuration = const Duration(milliseconds: 250),
    this.animationCurve = Curves.easeOutCubic,
    double? exclusiveSizeLeft,
    double? exclusiveSizeRight,
    double? exclusiveSizeTop,
    double? exclusiveSizeBottom,
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
      fields: [
        _themeMode,
        _seedColor,
        _animationDuration,
        _animationCurve,
        _exclusiveSizeLeft,
        _exclusiveSizeRight,
        _exclusiveSizeTop,
        _exclusiveSizeBottom,
        _barSide,
        _barSize,
        _barMarginLeft,
        _barMarginRight,
        _barMarginTop,
        _barMarginBottom,
        _barItemSize,
        _barRadiusInCross,
        _barRadiusInMain,
        _barRadiusOutCross,
        _barRadiusOutMain,
      ],
    );
  }

  factory MainConfig.fromMap(Map<String, dynamic> values) {
    return MainConfig._(
      themeMode: values[_themeMode.name],
      seedColor: values[_seedColor.name],
      animationDuration: values[_animationDuration.name],
      animationCurve: values[_animationCurve.name],
      exclusiveSizeLeft: values[_exclusiveSizeLeft.name],
      exclusiveSizeRight: values[_exclusiveSizeRight.name],
      exclusiveSizeTop: values[_exclusiveSizeTop.name],
      exclusiveSizeBottom: values[_exclusiveSizeBottom.name],
      barSide: values[_barSide.name],
      barSize: values[_barSize.name],
      barMarginLeft: values[_barMarginLeft.name],
      barMarginRight: values[_barMarginRight.name],
      barMarginTop: values[_barMarginTop.name],
      barMarginBottom: values[_barMarginBottom.name],
      barItemSize: values[_barItemSize.name],
      barRadiusInCross: values[_barRadiusInCross.name],
      barRadiusInMain: values[_barRadiusInMain.name],
      barRadiusOutCross: values[_barRadiusOutCross.name],
      barRadiusOutMain: values[_barRadiusOutMain.name],
      // TODO 2 waiting for lists implementation in config.dart
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
  }
}

Future<Config> reloadConfig() async {
  final content = '''
    themeMode = "light"
    seedColor = "#0000ff"
    animationDuration = 250
    barSide = "bottom"
    barSize = 64
    barMarginTop = 380
    barMarginBottom = 340
    barMarginLeft = 48
    barMarginRight = 48
    barRadiusInCross = barSize * 0.5
    barRadiusInMain = barSize * 0.5 * 0.67
    barRadiusOutCross = barSize * 0.5
    barRadiusOutMain = barSize * 0.5 * 1.5
  ''';

  final result = ConfigurationParser().parseFromString(
    content,
    schema: MainConfig.buildSchema(),
  );
  // final configFile = File(''); // TODO: 1 get default config file path
  // if (!(await configFile.exists())) {
  //   // TODO: 1 write default config
  // }
  // final result = await ConfigurationParser().parseFromFile(configFile);
  switch (result) {
    case EvaluationParseError():
      print('EvaluationParseError');
      print(result.errors.join('\n'));
      // TODO: Handle this case.
      throw UnimplementedError();
    case EvaluationValidationError():
      print('EvaluationValidationError');
      print(result.errors.join('\n'));
      print(result.values);
      // TODO: Handle this case.
      throw UnimplementedError();
    case EvaluationSuccess():
      _config = MainConfig.fromMap(result.values);
      return _config;
  }
}
