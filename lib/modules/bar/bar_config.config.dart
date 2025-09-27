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
  double? get _rounding;
  double? get _indicatorMinSize;
  double? get _indicatorPadding;
  List<Feather<dynamic>> get startFeathers;
  List<Feather<dynamic>> get centerFeathers;
  List<Feather<dynamic>> get endFeathers;
}

class BarConfig with BarConfigI, BarConfigBase {
  static const TableSchema staticSchema = TableSchema(
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
      'rounding': BarConfigBase.__rounding,
      'indicatorMinSize': BarConfigBase.__indicatorMinSize,
      'indicatorPadding': BarConfigBase.__indicatorPadding,
      'startFeathers': BarConfigBase._startFeathers,
      'centerFeathers': BarConfigBase._centerFeathers,
      'endFeathers': BarConfigBase._endFeathers,
    },
  );

  static TableSchema get schema => staticSchema;

  @override
  final ScreenEdge side;
  @override
  final int size;
  @override
  final double marginLeft;
  @override
  final double marginRight;
  @override
  final double marginTop;
  @override
  final double marginBottom;
  @override
  final double? _exclusiveSizeLeft;
  @override
  final double? _exclusiveSizeRight;
  @override
  final double? _exclusiveSizeTop;
  @override
  final double? _exclusiveSizeBottom;
  @override
  final double? _rounding;
  @override
  final double? _indicatorMinSize;
  @override
  final double? _indicatorPadding;
  @override
  final List<Feather<dynamic>> startFeathers;
  @override
  final List<Feather<dynamic>> centerFeathers;
  @override
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
    double? rounding,
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
       _rounding = rounding,
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
      rounding: map['rounding'],
      indicatorMinSize: map['indicatorMinSize'],
      indicatorPadding: map['indicatorPadding'],
      startFeathers: map['startFeathers'],
      centerFeathers: map['centerFeathers'],
      endFeathers: map['endFeathers'],
    );
  }

  @override
  String toString() {
    return 'BarConfig(side = $side, size = $size, marginLeft = $marginLeft, marginRight = $marginRight, marginTop = $marginTop, marginBottom = $marginBottom, _exclusiveSizeLeft = $_exclusiveSizeLeft, _exclusiveSizeRight = $_exclusiveSizeRight, _exclusiveSizeTop = $_exclusiveSizeTop, _exclusiveSizeBottom = $_exclusiveSizeBottom, _rounding = $_rounding, _indicatorMinSize = $_indicatorMinSize, _indicatorPadding = $_indicatorPadding, startFeathers = $startFeathers, centerFeathers = $centerFeathers, endFeathers = $endFeathers)';
  }

  @override
  bool operator ==(covariant BarConfig other) {
    return side == other.side &&
        size == other.size &&
        marginLeft == other.marginLeft &&
        marginRight == other.marginRight &&
        marginTop == other.marginTop &&
        marginBottom == other.marginBottom &&
        _exclusiveSizeLeft == other._exclusiveSizeLeft &&
        _exclusiveSizeRight == other._exclusiveSizeRight &&
        _exclusiveSizeTop == other._exclusiveSizeTop &&
        _exclusiveSizeBottom == other._exclusiveSizeBottom &&
        _rounding == other._rounding &&
        _indicatorMinSize == other._indicatorMinSize &&
        _indicatorPadding == other._indicatorPadding &&
        startFeathers == other.startFeathers &&
        centerFeathers == other.centerFeathers &&
        endFeathers == other.endFeathers;
  }

  @override
  int get hashCode => Object.hashAll([
    side,
    size,
    marginLeft,
    marginRight,
    marginTop,
    marginBottom,
    _exclusiveSizeLeft,
    _exclusiveSizeRight,
    _exclusiveSizeTop,
    _exclusiveSizeBottom,
    _rounding,
    _indicatorMinSize,
    _indicatorPadding,
    startFeathers,
    centerFeathers,
    endFeathers,
  ]);
}
