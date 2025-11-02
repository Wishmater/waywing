// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=info, type=warning

part of 'session_service.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin SessionServiceConfigI {
  /// The command used to lock the screen, if this is not set then the
  /// systemd integration will be used
  List<String>? get lockCommand;

  /// The command used to put the device to sleep, if this is not set then the
  /// systemd integration will be used
  List<String>? get sleepCommand;

  /// The command used to reboot the device, if this is not set then the
  /// systemd integration will be used
  List<String>? get rebootCommand;

  /// The command used to shutdown the device, if this is not set then the
  /// systemd integration will be used
  List<String>? get poweroffCommand;
}

class SessionServiceConfig extends ConfigBaseI
    with SessionServiceConfigI, SessionServiceConfigBase {
  static const BlockSchema staticSchema = BlockSchema(
    fields: {
      'lockCommand': SessionServiceConfigBase._lockCommand,
      'sleepCommand': SessionServiceConfigBase._sleepCommand,
      'rebootCommand': SessionServiceConfigBase._rebootCommand,
      'poweroffCommand': SessionServiceConfigBase._poweroffCommand,
    },
  );

  static BlockSchema get schema => staticSchema;

  @override
  final List<String>? lockCommand;
  @override
  final List<String>? sleepCommand;
  @override
  final List<String>? rebootCommand;
  @override
  final List<String>? poweroffCommand;

  SessionServiceConfig({
    this.lockCommand,
    this.sleepCommand,
    this.rebootCommand,
    this.poweroffCommand,
  });

  factory SessionServiceConfig.fromBlock(BlockData data) {
    Map<String, dynamic> fields = data.fields;
    return SessionServiceConfig(
      lockCommand: fields['lockCommand'],
      sleepCommand: fields['sleepCommand'],
      rebootCommand: fields['rebootCommand'],
      poweroffCommand: fields['poweroffCommand'],
    );
  }

  @override
  String toString() {
    return '''SessionServiceConfig(
	lockCommand = $lockCommand,
	sleepCommand = $sleepCommand,
	rebootCommand = $rebootCommand,
	poweroffCommand = $poweroffCommand
)''';
  }

  @override
  bool operator ==(covariant SessionServiceConfig other) {
    return lockCommand == other.lockCommand &&
        sleepCommand == other.sleepCommand &&
        rebootCommand == other.rebootCommand &&
        poweroffCommand == other.poweroffCommand;
  }

  @override
  int get hashCode => Object.hashAll([
    lockCommand,
    sleepCommand,
    rebootCommand,
    poweroffCommand,
  ]);
}
