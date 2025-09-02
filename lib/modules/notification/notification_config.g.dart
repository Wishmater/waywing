// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_config.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin NotificationsConfigI {
  Alignment get alignment;
}

class NotificationsConfig with NotificationsConfigI, NotificationsConfigBase {
  final Alignment alignment;

  NotificationsConfig({Alignment? alignment})
    : alignment = alignment ?? Alignment.topLeft;

  factory NotificationsConfig.fromMap(Map<String, dynamic> map) {
    return NotificationsConfig(alignment: map['alignment']);
  }

  static TableSchema get schema =>
      TableSchema(fields: {'alignment': NotificationsConfigBase._alignment});
}
