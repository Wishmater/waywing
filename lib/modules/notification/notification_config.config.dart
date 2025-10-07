// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=info, type=warning

part of 'notification_config.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin NotificationsConfigI {
  @ConfigDocDefault<Alignment>(Alignment.topLeft)
  Alignment get alignment;

  @ConfigDocDefault<double>(32)
  double get marginLeft;

  @ConfigDocDefault<double>(32)
  double get marginRight;

  @ConfigDocDefault<double>(32)
  double get marginTop;

  @ConfigDocDefault<double>(32)
  double get marginBottom;

  @ConfigDocDefault<bool>(false)
  bool get autoExpand;

  @ConfigDocDefault<bool>(false)
  bool get showProgressBar;
}

class NotificationsConfig extends ConfigBaseI
    with NotificationsConfigI, NotificationsConfigBase {
  static const BlockSchema staticSchema = BlockSchema(
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

  static BlockSchema get schema => staticSchema;

  @override
  final Alignment alignment;
  @override
  final double marginLeft;
  @override
  final double marginRight;
  @override
  final double marginTop;
  @override
  final double marginBottom;
  @override
  final bool autoExpand;
  @override
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

  factory NotificationsConfig.fromBlock(BlockData data) {
    Map<String, dynamic> fields = data.fields;
    return NotificationsConfig(
      alignment: fields['alignment'],
      marginLeft: fields['marginLeft'],
      marginRight: fields['marginRight'],
      marginTop: fields['marginTop'],
      marginBottom: fields['marginBottom'],
      autoExpand: fields['autoExpand'],
      showProgressBar: fields['showProgressBar'],
    );
  }

  @override
  String toString() {
    return '''NotificationsConfig(
	alignment = $alignment,
	marginLeft = $marginLeft,
	marginRight = $marginRight,
	marginTop = $marginTop,
	marginBottom = $marginBottom,
	autoExpand = $autoExpand,
	showProgressBar = $showProgressBar
)''';
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
