// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=info, type=warning

part of 'notification_service.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin NotificationsServiceConfigI {
  String? get soundDefaultFilename;

  @ConfigDocDefault<Duration>(Duration(minutes: 1))
  Duration get soundCooldown;

  @ConfigDocDefault<int>(100)
  int get soundVolume;
}

class NotificationsServiceConfig extends ConfigBaseI
    with NotificationsServiceConfigI, NotificationsServiceConfigBase {
  static const BlockSchema staticSchema = BlockSchema(
    fields: {
      'soundDefaultFilename':
          NotificationsServiceConfigBase._soundDefaultFilename,
      'soundCooldown': NotificationsServiceConfigBase._soundCooldown,
      'soundVolume': NotificationsServiceConfigBase._soundVolume,
    },
  );

  static BlockSchema get schema => staticSchema;

  @override
  final String? soundDefaultFilename;
  @override
  final Duration soundCooldown;
  @override
  final int soundVolume;

  NotificationsServiceConfig({
    this.soundDefaultFilename,
    Duration? soundCooldown,
    int? soundVolume,
  }) : soundCooldown = soundCooldown ?? Duration(minutes: 1),
       soundVolume = soundVolume ?? 100;

  factory NotificationsServiceConfig.fromBlock(BlockData data) {
    Map<String, dynamic> fields = data.fields;
    return NotificationsServiceConfig(
      soundDefaultFilename: fields['soundDefaultFilename'],
      soundCooldown: fields['soundCooldown'],
      soundVolume: fields['soundVolume'],
    );
  }

  @override
  String toString() {
    return '''NotificationsServiceConfig(
	soundDefaultFilename = $soundDefaultFilename,
	soundCooldown = $soundCooldown,
	soundVolume = $soundVolume
)''';
  }

  @override
  bool operator ==(covariant NotificationsServiceConfig other) {
    return soundDefaultFilename == other.soundDefaultFilename &&
        soundCooldown == other.soundCooldown &&
        soundVolume == other.soundVolume;
  }

  @override
  int get hashCode =>
      Object.hashAll([soundDefaultFilename, soundCooldown, soundVolume]);
}
