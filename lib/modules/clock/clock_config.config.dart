// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=info, type=warning

part of 'clock_config.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin ClockConfigI {
  @ConfigDocDefault<bool>(false)
  bool get militar;
}

class ClockConfig extends ConfigBaseI with ClockConfigI, ClockConfigBase {
  static const BlockSchema staticSchema = BlockSchema(
    fields: {'militar': ClockConfigBase._militar},
  );

  static BlockSchema get schema => staticSchema;

  @override
  final bool militar;

  ClockConfig({bool? militar}) : militar = militar ?? false;

  factory ClockConfig.fromBlock(BlockData data) {
    Map<String, dynamic> fields = data.fields;
    return ClockConfig(militar: fields['militar']);
  }

  @override
  String toString() {
    return '''ClockConfig(
	militar = $militar
)''';
  }

  @override
  bool operator ==(covariant ClockConfig other) {
    return militar == other.militar;
  }

  @override
  int get hashCode => Object.hashAll([militar]);
}
