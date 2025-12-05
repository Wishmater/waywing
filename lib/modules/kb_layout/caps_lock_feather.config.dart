// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=info, type=warning

part of 'caps_lock_feather.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin CapsLockConfigI {
  @ConfigDocDefault<bool>(false)
  bool get reserveSpace;
}

class CapsLockConfig extends ConfigBaseI
    with CapsLockConfigI, CapsLockConfigBase {
  static const BlockSchema staticSchema = BlockSchema(
    fields: {'reserveSpace': CapsLockConfigBase._reserveSpace},
  );

  static BlockSchema get schema => staticSchema;

  @override
  final bool reserveSpace;

  CapsLockConfig({bool? reserveSpace}) : reserveSpace = reserveSpace ?? false;

  factory CapsLockConfig.fromBlock(BlockData data) {
    Map<String, dynamic> fields = data.fields.map(
      (k, v) => MapEntry(k.value, v),
    );
    return CapsLockConfig(reserveSpace: fields['reserveSpace']);
  }

  @override
  String toString() {
    return '''CapsLockConfig(
	reserveSpace = $reserveSpace
)''';
  }

  @override
  bool operator ==(covariant CapsLockConfig other) {
    return reserveSpace == other.reserveSpace;
  }

  @override
  int get hashCode => Object.hashAll([reserveSpace]);
}
