// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=info, type=warning

part of 'num_lock_feather.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin NumLockConfigI {
  @ConfigDocDefault<bool>(false)
  bool get reserveSpace;
}

class NumLockConfig extends ConfigBaseI with NumLockConfigI, NumLockConfigBase {
  static const BlockSchema staticSchema = BlockSchema(
    fields: {'reserveSpace': NumLockConfigBase._reserveSpace},
  );

  static BlockSchema get schema => staticSchema;

  @override
  final bool reserveSpace;

  NumLockConfig({bool? reserveSpace}) : reserveSpace = reserveSpace ?? false;

  factory NumLockConfig.fromBlock(BlockData data) {
    Map<String, dynamic> fields = data.fields.map(
      (k, v) => MapEntry(k.value, v),
    );
    return NumLockConfig(reserveSpace: fields['reserveSpace']);
  }

  @override
  String toString() {
    return '''NumLockConfig(
	reserveSpace = $reserveSpace
)''';
  }

  @override
  bool operator ==(covariant NumLockConfig other) {
    return reserveSpace == other.reserveSpace;
  }

  @override
  int get hashCode => Object.hashAll([reserveSpace]);
}
