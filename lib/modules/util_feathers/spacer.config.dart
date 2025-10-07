// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=info, type=warning

part of 'spacer.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin SpacerConfigI {
  @ConfigDocDefault<double>(12)
  double get size;
}

class SpacerConfig extends ConfigBaseI with SpacerConfigI, SpacerConfigBase {
  static const BlockSchema staticSchema = BlockSchema(
    fields: {'size': SpacerConfigBase._size},
  );

  static BlockSchema get schema => staticSchema;

  @override
  final double size;

  SpacerConfig({double? size}) : size = size ?? 12;

  factory SpacerConfig.fromBlock(BlockData data) {
    Map<String, dynamic> fields = data.fields;
    return SpacerConfig(size: fields['size']);
  }

  @override
  String toString() {
    return '''SpacerConfig(
	size = $size
)''';
  }

  @override
  bool operator ==(covariant SpacerConfig other) {
    return size == other.size;
  }

  @override
  int get hashCode => Object.hashAll([size]);
}
