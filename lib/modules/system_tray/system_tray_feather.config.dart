// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=info, type=warning

part of 'system_tray_feather.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin SystemTrayConfigI {
  /// Set the tray icon size
  double? get _iconSize;
}

class SystemTrayConfig extends ConfigBaseI
    with SystemTrayConfigI, SystemTrayConfigBase {
  static const BlockSchema staticSchema = BlockSchema(
    fields: {'iconSize': SystemTrayConfigBase.__iconSize},
  );

  static BlockSchema get schema => staticSchema;

  @override
  final double? _iconSize;

  SystemTrayConfig({double? iconSize}) : _iconSize = iconSize;

  factory SystemTrayConfig.fromBlock(BlockData data) {
    Map<String, dynamic> fields = data.fields.map(
      (k, v) => MapEntry(k.value, v),
    );
    return SystemTrayConfig(iconSize: fields['iconSize']);
  }

  @override
  String toString() {
    return '''SystemTrayConfig(
	_iconSize = $_iconSize
)''';
  }

  @override
  bool operator ==(covariant SystemTrayConfig other) {
    return _iconSize == other._iconSize;
  }

  @override
  int get hashCode => Object.hashAll([_iconSize]);
}
