// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=info, type=warning

part of 'aria2_service.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin Aria2ServiceConfigI {
  String get rpcUri;

  String? get rpcSecret;
}

class Aria2ServiceConfig extends ConfigBaseI
    with Aria2ServiceConfigI, Aria2ServiceConfigBase {
  static const BlockSchema staticSchema = BlockSchema(
    fields: {
      'rpcUri': Aria2ServiceConfigBase._rpcUri,
      'rpcSecret': Aria2ServiceConfigBase._rpcSecret,
    },
  );

  static BlockSchema get schema => staticSchema;

  @override
  final String rpcUri;
  @override
  final String? rpcSecret;

  Aria2ServiceConfig({required this.rpcUri, this.rpcSecret});

  factory Aria2ServiceConfig.fromBlock(BlockData data) {
    Map<String, dynamic> fields = data.fields.map(
      (k, v) => MapEntry(k.value, v),
    );
    return Aria2ServiceConfig(
      rpcUri: fields['rpcUri'],
      rpcSecret: fields['rpcSecret'],
    );
  }

  @override
  String toString() {
    return '''Aria2ServiceConfig(
	rpcUri = $rpcUri,
	rpcSecret = $rpcSecret
)''';
  }

  @override
  bool operator ==(covariant Aria2ServiceConfig other) {
    return rpcUri == other.rpcUri && rpcSecret == other.rpcSecret;
  }

  @override
  int get hashCode => Object.hashAll([rpcUri, rpcSecret]);
}
