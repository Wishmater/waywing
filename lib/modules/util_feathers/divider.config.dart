// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=info, type=warning

part of 'divider.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin DividerConfigI {
  @ConfigDocDefault<double>(12)
  double get size;

  @ConfigDocDefault<double>(2)
  double get thickness;

  @ConfigDocDefault<double>(6)
  double get indent;
}

class DividerConfig extends ConfigBaseI with DividerConfigI, DividerConfigBase {
  static const BlockSchema staticSchema = BlockSchema(
    fields: {
      'size': DividerConfigBase._size,
      'thickness': DividerConfigBase._thickness,
      'indent': DividerConfigBase._indent,
    },
  );

  static BlockSchema get schema => staticSchema;

  @override
  final double size;
  @override
  final double thickness;
  @override
  final double indent;

  DividerConfig({double? size, double? thickness, double? indent})
    : size = size ?? 12,
      thickness = thickness ?? 2,
      indent = indent ?? 6;

  factory DividerConfig.fromBlock(BlockData data) {
    Map<String, dynamic> fields = data.fields.map(
      (k, v) => MapEntry(k.value, v),
    );
    return DividerConfig(
      size: fields['size'],
      thickness: fields['thickness'],
      indent: fields['indent'],
    );
  }

  @override
  String toString() {
    return '''DividerConfig(
	size = $size,
	thickness = $thickness,
	indent = $indent
)''';
  }

  @override
  bool operator ==(covariant DividerConfig other) {
    return size == other.size &&
        thickness == other.thickness &&
        indent == other.indent;
  }

  @override
  int get hashCode => Object.hashAll([size, thickness, indent]);
}
