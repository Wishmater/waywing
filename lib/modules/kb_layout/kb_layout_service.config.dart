// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kb_layout_service.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin KbLayoutServiceConfigI {
  /// pull interval in milliseconds
  int get pullInterval;
}

class KbLayoutServiceConfig extends ConfigBaseI
    with KbLayoutServiceConfigI, KbLayoutServiceConfigBase {
  static const TableSchema staticSchema = TableSchema(
    fields: {'pullInterval': KbLayoutServiceConfigBase._pullInterval},
  );

  static TableSchema get schema => staticSchema;

  @override
  final int pullInterval;

  KbLayoutServiceConfig({int? pullInterval})
    : pullInterval = pullInterval ?? 500;

  factory KbLayoutServiceConfig.fromMap(Map<String, dynamic> map) {
    return KbLayoutServiceConfig(pullInterval: map['pullInterval']);
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
