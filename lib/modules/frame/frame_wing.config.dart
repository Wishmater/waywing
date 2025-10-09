// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=info, type=warning

part of 'frame_wing.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin FrameConfigI {
  @ConfigDocDefault<double>(12)
  double get size;

  double? get _sizeLeft;

  double? get _sizeRight;

  double? get _sizeTop;

  double? get _sizeBottom;

  double? get _rounding;
}

class FrameConfig extends ConfigBaseI with FrameConfigI, FrameConfigBase {
  static const BlockSchema staticSchema = BlockSchema(
    fields: {
      'size': FrameConfigBase._size,
      'sizeLeft': FrameConfigBase.__sizeLeft,
      'sizeRight': FrameConfigBase.__sizeRight,
      'sizeTop': FrameConfigBase.__sizeTop,
      'sizeBottom': FrameConfigBase.__sizeBottom,
      'rounding': FrameConfigBase.__rounding,
    },
  );

  static BlockSchema get schema => staticSchema;

  @override
  final double size;
  @override
  final double? _sizeLeft;
  @override
  final double? _sizeRight;
  @override
  final double? _sizeTop;
  @override
  final double? _sizeBottom;
  @override
  final double? _rounding;

  FrameConfig({
    double? size,
    double? sizeLeft,
    double? sizeRight,
    double? sizeTop,
    double? sizeBottom,
    double? rounding,
  }) : size = size ?? 12,
       _sizeLeft = sizeLeft,
       _sizeRight = sizeRight,
       _sizeTop = sizeTop,
       _sizeBottom = sizeBottom,
       _rounding = rounding;

  factory FrameConfig.fromBlock(BlockData data) {
    Map<String, dynamic> fields = data.fields;
    return FrameConfig(
      size: fields['size'],
      sizeLeft: fields['sizeLeft'],
      sizeRight: fields['sizeRight'],
      sizeTop: fields['sizeTop'],
      sizeBottom: fields['sizeBottom'],
      rounding: fields['rounding'],
    );
  }

  @override
  String toString() {
    return '''FrameConfig(
	size = $size,
	_sizeLeft = $_sizeLeft,
	_sizeRight = $_sizeRight,
	_sizeTop = $_sizeTop,
	_sizeBottom = $_sizeBottom,
	_rounding = $_rounding
)''';
  }

  @override
  bool operator ==(covariant FrameConfig other) {
    return size == other.size &&
        _sizeLeft == other._sizeLeft &&
        _sizeRight == other._sizeRight &&
        _sizeTop == other._sizeTop &&
        _sizeBottom == other._sizeBottom &&
        _rounding == other._rounding;
  }

  @override
  int get hashCode => Object.hashAll([
    size,
    _sizeLeft,
    _sizeRight,
    _sizeTop,
    _sizeBottom,
    _rounding,
  ]);
}
