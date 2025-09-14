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
  bool get autoExpand;
  bool get showProgressBar;
}

class NotificationsConfig with NotificationsConfigI, NotificationsConfigBase {
  static const TableSchema staticSchema = TableSchema(
    fields: {
      'alignment': NotificationsConfigBase._alignment,
      'marginLeft': NotificationsConfigBase._marginLeft,
      'marginRight': NotificationsConfigBase._marginRight,
      'marginTop': NotificationsConfigBase._marginTop,
      'marginBottom': NotificationsConfigBase._marginBottom,
      'autoExpand': NotificationsConfigBase._autoExpand,
      'showProgressBar': NotificationsConfigBase._showProgressBar,
    },
  );

  static TableSchema get schema => staticSchema;

  final Alignment alignment;
  final double marginLeft;
  final double marginRight;
  final double marginTop;
  final double marginBottom;
  final bool autoExpand;
  final bool showProgressBar;

  NotificationsConfig({
    Alignment? alignment,
    double? marginLeft,
    double? marginRight,
    double? marginTop,
    double? marginBottom,
    bool? autoExpand,
    bool? showProgressBar,
  }) : alignment = alignment ?? Alignment.topLeft,
       marginLeft = marginLeft ?? 32,
       marginRight = marginRight ?? 32,
       marginTop = marginTop ?? 32,
       marginBottom = marginBottom ?? 32,
       autoExpand = autoExpand ?? false,
       showProgressBar = showProgressBar ?? false;

  factory NotificationsConfig.fromMap(Map<String, dynamic> map) {
    return NotificationsConfig(
      alignment: map['alignment'],
      marginLeft: map['marginLeft'],
      marginRight: map['marginRight'],
      marginTop: map['marginTop'],
      marginBottom: map['marginBottom'],
      autoExpand: map['autoExpand'],
      showProgressBar: map['showProgressBar'],
    );
  }

  @override
  String toString() {
    return 'NotificationsConfigalignment = $alignment, marginLeft = $marginLeft, marginRight = $marginRight, marginTop = $marginTop, marginBottom = $marginBottom, autoExpand = $autoExpand, showProgressBar = $showProgressBar';
  }

  @override
  bool operator ==(covariant NotificationsConfig other) {
    return alignment == other.alignment &&
        marginLeft == other.marginLeft &&
        marginRight == other.marginRight &&
        marginTop == other.marginTop &&
        marginBottom == other.marginBottom &&
        autoExpand == other.autoExpand &&
        showProgressBar == other.showProgressBar;
  }

  @override
  int get hashCode => Object.hashAll([
    alignment,
    marginLeft,
    marginRight,
    marginTop,
    marginBottom,
    autoExpand,
    showProgressBar,
  ]);
}
