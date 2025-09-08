// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clock_config.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin ClockConfigI {
  bool get militar;
}

class ClockConfig with ClockConfigI, ClockConfigBase {
  final bool militar;

  ClockConfig({bool? militar}) : militar = militar ?? false;

  factory ClockConfig.fromMap(Map<String, dynamic> map) {
    return ClockConfig(militar: map['militar']);
  }

  static TableSchema get schema =>
      TableSchema(fields: {'militar': ClockConfigBase._militar});

  @override
  String toString() {
    return 'ClockConfigmilitar = $militar';
  }

  @override
  bool operator ==(covariant ClockConfig other) {
    return militar == other.militar;
  }

  @override
  int get hashCode => Object.hashAll([militar]);
}
