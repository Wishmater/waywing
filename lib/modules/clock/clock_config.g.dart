// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clock_config.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin ClockConfigI {
  bool get use24HourFormat;
}

class ClockConfig with ClockConfigI, ClockConfigBase {
  final bool use24HourFormat;

  ClockConfig({bool? use24HourFormat})
    : use24HourFormat = use24HourFormat ?? false;

  factory ClockConfig.fromMap(Map<String, dynamic> map) {
    return ClockConfig(use24HourFormat: map['use24HourFormat']);
  }

  static TableSchema get schema => TableSchema(
    fields: {'use24HourFormat': ClockConfigBase._use24HourFormat},
  );
}
