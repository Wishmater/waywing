// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=info, type=warning

part of 'launcher_config.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin LauncherConfigI {
  String get terminal;
}

class LauncherConfig extends ConfigBaseI
    with LauncherConfigI, LauncherConfigBase {
  static const BlockSchema staticSchema = BlockSchema(
    fields: {'terminal': LauncherConfigBase._terminal},
  );

  static BlockSchema get schema => staticSchema;

  @override
  final String terminal;

  LauncherConfig({required this.terminal});

  factory LauncherConfig.fromBlock(BlockData data) {
    Map<String, dynamic> fields = data.fields.map(
      (k, v) => MapEntry(k.value, v),
    );
    return LauncherConfig(terminal: fields['terminal']);
  }

  @override
  String toString() {
    return '''LauncherConfig(
	terminal = $terminal
)''';
  }

  @override
  bool operator ==(covariant LauncherConfig other) {
    return terminal == other.terminal;
  }

  @override
  int get hashCode => Object.hashAll([terminal]);
}
