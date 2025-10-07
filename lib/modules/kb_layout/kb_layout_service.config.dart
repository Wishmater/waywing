// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=info, type=warning

part of 'kb_layout_service.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin KbLayoutServiceConfigI {
  @ConfigDocDefault<int>(500)
  /// pull interval in milliseconds
  int get pullInterval;
}

class KbLayoutServiceConfig extends ConfigBaseI
    with KbLayoutServiceConfigI, KbLayoutServiceConfigBase {
  static const BlockSchema staticSchema = BlockSchema(
    fields: {'pullInterval': KbLayoutServiceConfigBase._pullInterval},
  );

  static BlockSchema get schema => staticSchema;

  @override
  final int pullInterval;

  KbLayoutServiceConfig({int? pullInterval})
    : pullInterval = pullInterval ?? 500;

  factory KbLayoutServiceConfig.fromBlock(BlockData data) {
    Map<String, dynamic> fields = data.fields;
    return KbLayoutServiceConfig(pullInterval: fields['pullInterval']);
  }

  @override
  String toString() {
    return '''KbLayoutServiceConfig(
	pullInterval = $pullInterval
)''';
  }

  @override
  bool operator ==(covariant KbLayoutServiceConfig other) {
    return pullInterval == other.pullInterval;
  }

  @override
  int get hashCode => Object.hashAll([pullInterval]);
}
