// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=info, type=warning

part of 'launcher_config.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin LauncherConfigI {
  int? get iconSize;

  @ConfigDocDefault<bool>(true)
  bool get showScrollBar;
}

class LauncherConfig extends ConfigBaseI
    with LauncherConfigI, LauncherConfigBase {
  static const BlockSchema staticSchema = BlockSchema(
    fields: {
      'iconSize': LauncherConfigBase._iconSize,
      'showScrollBar': LauncherConfigBase._showScrollBar,
    },
  );

  static BlockSchema get schema => staticSchema;

  @override
  final int? iconSize;
  @override
  final bool showScrollBar;

  LauncherConfig({this.iconSize, bool? showScrollBar})
    : showScrollBar = showScrollBar ?? true;

  factory LauncherConfig.fromBlock(BlockData data) {
    Map<String, dynamic> fields = data.fields.map(
      (k, v) => MapEntry(k.value, v),
    );
    return LauncherConfig(
      iconSize: fields['iconSize'],
      showScrollBar: fields['showScrollBar'],
    );
  }

  @override
  String toString() {
    return '''LauncherConfig(
	iconSize = $iconSize,
	showScrollBar = $showScrollBar
)''';
  }

  @override
  bool operator ==(covariant LauncherConfig other) {
    return iconSize == other.iconSize && showScrollBar == other.showScrollBar;
  }

  @override
  int get hashCode => Object.hashAll([iconSize, showScrollBar]);
}
