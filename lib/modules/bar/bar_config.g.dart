// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bar_config.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin BarConfigI {
  ScreenEdge get side;
  int get size;
  double get marginLeft;
  double get marginRight;
  double get marginTop;
  double get marginBottom;
  double? get _exclusiveSizeLeft;
  double? get _exclusiveSizeRight;
  double? get _exclusiveSizeTop;
  double? get _exclusiveSizeBottom;
  double get radiusInCross;
  double get radiusInMain;
  double get radiusOutCross;
  double get radiusOutMain;
  double? get _indicatorMinSize;
  double? get _indicatorPadding;
  List<Feather<dynamic>> get startFeathers;
  List<Feather<dynamic>> get centerFeathers;
  List<Feather<dynamic>> get endFeathers;
}

class BarConfig with BarConfigI, BarConfigBase {
  final ScreenEdge side;
  final int size;
  final double marginLeft;
  final double marginRight;
  final double marginTop;
  final double marginBottom;
  final double? _exclusiveSizeLeft;
  final double? _exclusiveSizeRight;
  final double? _exclusiveSizeTop;
  final double? _exclusiveSizeBottom;
  final double radiusInCross;
  final double radiusInMain;
  final double radiusOutCross;
  final double radiusOutMain;
  final double? _indicatorMinSize;
  final double? _indicatorPadding;
  final List<Feather<dynamic>> startFeathers;
  final List<Feather<dynamic>> centerFeathers;
  final List<Feather<dynamic>> endFeathers;

  BarConfig({
    required this.side,
    required this.size,
    double? marginLeft,
    double? marginRight,
    double? marginTop,
    double? marginBottom,
    double? exclusiveSizeLeft,
    double? exclusiveSizeRight,
    double? exclusiveSizeTop,
    double? exclusiveSizeBottom,
    double? radiusInCross,
    double? radiusInMain,
    double? radiusOutCross,
    double? radiusOutMain,
    double? indicatorMinSize,
    double? indicatorPadding,
    List<Feather<dynamic>>? startFeathers,
    List<Feather<dynamic>>? centerFeathers,
    List<Feather<dynamic>>? endFeathers,
  }) : marginLeft = marginLeft ?? 0,
       marginRight = marginRight ?? 0,
       marginTop = marginTop ?? 0,
       marginBottom = marginBottom ?? 0,
       _exclusiveSizeLeft = exclusiveSizeLeft,
       _exclusiveSizeRight = exclusiveSizeRight,
       _exclusiveSizeTop = exclusiveSizeTop,
       _exclusiveSizeBottom = exclusiveSizeBottom,
       radiusInCross = radiusInCross ?? 0,
       radiusInMain = radiusInMain ?? 0,
       radiusOutCross = radiusOutCross ?? 0,
       radiusOutMain = radiusOutMain ?? 0,
       _indicatorMinSize = indicatorMinSize,
       _indicatorPadding = indicatorPadding,
       startFeathers = startFeathers ?? <Feather>[],
       centerFeathers = centerFeathers ?? <Feather>[],
       endFeathers = endFeathers ?? <Feather>[];

  factory BarConfig.fromMap(Map<String, dynamic> map) {
    return BarConfig(
      side: map['side'],
      size: map['size'],
      marginLeft: map['marginLeft'],
      marginRight: map['marginRight'],
      marginTop: map['marginTop'],
      marginBottom: map['marginBottom'],
      exclusiveSizeLeft: map['exclusiveSizeLeft'],
      exclusiveSizeRight: map['exclusiveSizeRight'],
      exclusiveSizeTop: map['exclusiveSizeTop'],
      exclusiveSizeBottom: map['exclusiveSizeBottom'],
      radiusInCross: map['radiusInCross'],
      radiusInMain: map['radiusInMain'],
      radiusOutCross: map['radiusOutCross'],
      radiusOutMain: map['radiusOutMain'],
      indicatorMinSize: map['indicatorMinSize'],
      indicatorPadding: map['indicatorPadding'],
      startFeathers: map['startFeathers'],
      centerFeathers: map['centerFeathers'],
      endFeathers: map['endFeathers'],
    );
  }

  static TableSchema get schema => TableSchema(
    fields: {
      'side': BarConfigBase._side,
      'size': BarConfigBase._size,
      'marginLeft': BarConfigBase._marginLeft,
      'marginRight': BarConfigBase._marginRight,
      'marginTop': BarConfigBase._marginTop,
      'marginBottom': BarConfigBase._marginBottom,
      'exclusiveSizeLeft': BarConfigBase.__exclusiveSizeLeft,
      'exclusiveSizeRight': BarConfigBase.__exclusiveSizeRight,
      'exclusiveSizeTop': BarConfigBase.__exclusiveSizeTop,
      'exclusiveSizeBottom': BarConfigBase.__exclusiveSizeBottom,
      'radiusInCross': BarConfigBase._radiusInCross,
      'radiusInMain': BarConfigBase._radiusInMain,
      'radiusOutCross': BarConfigBase._radiusOutCross,
      'radiusOutMain': BarConfigBase._radiusOutMain,
      'indicatorMinSize': BarConfigBase.__indicatorMinSize,
      'indicatorPadding': BarConfigBase.__indicatorPadding,
      'startFeathers': BarConfigBase._startFeathers,
      'centerFeathers': BarConfigBase._centerFeathers,
      'endFeathers': BarConfigBase._endFeathers,
    },
  );
}
