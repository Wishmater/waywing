// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=info, type=warning

part of 'launcher_config.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin LauncherConfigI {
  @ConfigDocDefault<int>(400)
  int get width;

  @ConfigDocDefault<int>(400)
  int get height;

  int? get iconSize;

  @ConfigDocDefault<bool>(true)
  bool get showScrollBar;
}

class LauncherConfig extends ConfigBaseI
    with LauncherConfigI, LauncherConfigBase {
  static const BlockSchema staticSchema = BlockSchema(
    fields: {
      'width': LauncherConfigBase._width,
      'height': LauncherConfigBase._height,
      'iconSize': LauncherConfigBase._iconSize,
      'showScrollBar': LauncherConfigBase._showScrollBar,
    },
  );

  static BlockSchema get schema => staticSchema;

  @override
  final int width;
  @override
  final int height;
  @override
  final int? iconSize;
  @override
  final bool showScrollBar;

  LauncherConfig({int? width, int? height, this.iconSize, bool? showScrollBar})
    : width = width ?? 400,
      height = height ?? 400,
      showScrollBar = showScrollBar ?? true;

  factory LauncherConfig.fromBlock(BlockData data) {
    Map<String, dynamic> fields = data.fields;
    return LauncherConfig(
      width: fields['width'],
      height: fields['height'],
      iconSize: fields['iconSize'],
      showScrollBar: fields['showScrollBar'],
    );
  }

  @override
  String toString() {
    return '''LauncherConfig(
	width = $width,
	height = $height,
	iconSize = $iconSize,
	showScrollBar = $showScrollBar
)''';
  }

  @override
  bool operator ==(covariant LauncherConfig other) {
    return width == other.width &&
        height == other.height &&
        iconSize == other.iconSize &&
        showScrollBar == other.showScrollBar;
  }

  @override
  int get hashCode => Object.hashAll([width, height, iconSize, showScrollBar]);
}
