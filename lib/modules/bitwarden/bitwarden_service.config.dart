// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=info, type=warning

part of 'bitwarden_service.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin BitwardenServiceConfigI {
  @ConfigDocDefault<String>("bw")
  /// Path to the bw cli
  String get bwPath;
}

class BitwardenServiceConfig extends ConfigBaseI
    with BitwardenServiceConfigI, BitwardenServiceConfigBase {
  static const BlockSchema staticSchema = BlockSchema(
    fields: {'bwPath': BitwardenServiceConfigBase._bwPath},
  );

  static BlockSchema get schema => staticSchema;

  @override
  final String bwPath;

  BitwardenServiceConfig({String? bwPath}) : bwPath = bwPath ?? "bw";

  factory BitwardenServiceConfig.fromBlock(BlockData data) {
    Map<String, dynamic> fields = data.fields.map(
      (k, v) => MapEntry(k.value, v),
    );
    return BitwardenServiceConfig(bwPath: fields['bwPath']);
  }

  @override
  String toString() {
    return '''BitwardenServiceConfig(
	bwPath = $bwPath
)''';
  }

  @override
  bool operator ==(covariant BitwardenServiceConfig other) {
    return bwPath == other.bwPath;
  }

  @override
  int get hashCode => Object.hashAll([bwPath]);
}
