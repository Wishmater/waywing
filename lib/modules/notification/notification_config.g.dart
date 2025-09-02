// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_config.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin NotificationsConfigI {
  Alignment get alignment;
  double get marginLeft;
  double get marginRight;
  double get marginTop;
  double get marginBottom;
}

class NotificationsConfig with NotificationsConfigI, NotificationsConfigBase {
  final Alignment alignment;
  final double marginLeft;
  final double marginRight;
  final double marginTop;
  final double marginBottom;

  NotificationsConfig({
    Alignment? alignment,
    double? marginLeft,
    double? marginRight,
    double? marginTop,
    double? marginBottom,
  }) : alignment = alignment ?? Alignment.topLeft,
       marginLeft = marginLeft ?? 32,
       marginRight = marginRight ?? 32,
       marginTop = marginTop ?? 32,
       marginBottom = marginBottom ?? 32;

  factory NotificationsConfig.fromMap(Map<String, dynamic> map) {
    return NotificationsConfig(
      alignment: map['alignment'],
      marginLeft: map['marginLeft'],
      marginRight: map['marginRight'],
      marginTop: map['marginTop'],
      marginBottom: map['marginBottom'],
    );
  }

  static TableSchema get schema => TableSchema(
    fields: {
      'alignment': NotificationsConfigBase._alignment,
      'marginLeft': NotificationsConfigBase._marginLeft,
      'marginRight': NotificationsConfigBase._marginRight,
      'marginTop': NotificationsConfigBase._marginTop,
      'marginBottom': NotificationsConfigBase._marginBottom,
    },
  );
}
