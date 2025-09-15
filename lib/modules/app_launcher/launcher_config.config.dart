// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'launcher_config.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin LauncherConfigI {
  int get width;
  int get height;
  int? get iconSize;
  bool get showScrollBar;
}

class LauncherConfig with LauncherConfigI, LauncherConfigBase {
  static const TableSchema staticSchema = TableSchema(
    fields: {
      'width': LauncherConfigBase._width,
      'height': LauncherConfigBase._height,
      'iconSize': LauncherConfigBase._iconSize,
      'showScrollBar': LauncherConfigBase._showScrollBar,
    },
  );

  static TableSchema get schema => staticSchema;

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

  factory LauncherConfig.fromMap(Map<String, dynamic> map) {
    return LauncherConfig(
      width: map['width'],
      height: map['height'],
      iconSize: map['iconSize'],
      showScrollBar: map['showScrollBar'],
    );
  }

  @override
  String toString() {
    return 'LauncherConfig(width = $width, height = $height, iconSize = $iconSize, showScrollBar = $showScrollBar)';
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
