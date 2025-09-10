// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'launcher_config.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin LauncherConfigI {
  int get width;
  int get height;
  bool get showScrollBar;
}

class LauncherConfig with LauncherConfigI, LauncherConfigBase {
  static const TableSchema staticSchema = TableSchema(
    fields: {
      'width': LauncherConfigBase._width,
      'height': LauncherConfigBase._height,
      'showScrollBar': LauncherConfigBase._showScrollBar,
    },
  );

  static TableSchema get schema => staticSchema;

  final int width;
  final int height;
  final bool showScrollBar;

  LauncherConfig({int? width, int? height, bool? showScrollBar})
    : width = width ?? 400,
      height = height ?? 400,
      showScrollBar = showScrollBar ?? true;

  factory LauncherConfig.fromMap(Map<String, dynamic> map) {
    return LauncherConfig(
      width: map['width'],
      height: map['height'],
      showScrollBar: map['showScrollBar'],
    );
  }

  @override
  String toString() {
    return 'LauncherConfigwidth = $width, height = $height, showScrollBar = $showScrollBar';
  }

  @override
  bool operator ==(covariant LauncherConfig other) {
    return width == other.width &&
        height == other.height &&
        showScrollBar == other.showScrollBar;
  }

  @override
  int get hashCode => Object.hashAll([width, height, showScrollBar]);
}
