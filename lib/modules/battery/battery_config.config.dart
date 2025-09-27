// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'battery_config.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin BatteryConfigI {
  /// Enable powerprofile functionality
  ///
  /// this option only matters if powerprofiles is installed in the system
  /// otherwise profile service will be disable nonetheless
  bool get enableProfile;

  /// Enable automatic handling of powerprofile changing depending on the battery level
  bool get automaticProfileChanging;

  /// Profile to be set when the battery level is below the threshold
  String get saverProfile;

  /// Profile to be set when the battery level is above the threshold
  String get normalProfile;

  /// Battery level threshold
  double get batteryThreshold;
}

class BatteryConfig extends ConfigBaseI with BatteryConfigI, BatteryConfigBase {
  static const BlockSchema staticSchema = BlockSchema(
    fields: {
      'enableProfile': BatteryConfigBase._enableProfile,
      'automaticProfileChanging': BatteryConfigBase._automaticProfileChanging,
      'saverProfile': BatteryConfigBase._saverProfile,
      'normalProfile': BatteryConfigBase._normalProfile,
      'batteryThreshold': BatteryConfigBase._batteryThreshold,
    },
  );

  static BlockSchema get schema => staticSchema;

  @override
  final bool enableProfile;
  @override
  final bool automaticProfileChanging;
  @override
  final String saverProfile;
  @override
  final String normalProfile;
  @override
  final double batteryThreshold;

  BatteryConfig({
    bool? enableProfile,
    bool? automaticProfileChanging,
    String? saverProfile,
    String? normalProfile,
    double? batteryThreshold,
  }) : enableProfile = enableProfile ?? true,
       automaticProfileChanging = automaticProfileChanging ?? true,
       saverProfile = saverProfile ?? "power-saver",
       normalProfile = normalProfile ?? "balanced",
       batteryThreshold = batteryThreshold ?? 30;

  factory BatteryConfig.fromBlock(BlockData data) {
    Map<String, dynamic> fields = data.fields;
    return BatteryConfig(
      enableProfile: fields['enableProfile'],
      automaticProfileChanging: fields['automaticProfileChanging'],
      saverProfile: fields['saverProfile'],
      normalProfile: fields['normalProfile'],
      batteryThreshold: fields['batteryThreshold'],
    );
  }

  @override
  String toString() {
    return '''BatteryConfig(
	enableProfile = $enableProfile,
	automaticProfileChanging = $automaticProfileChanging,
	saverProfile = $saverProfile,
	normalProfile = $normalProfile,
	batteryThreshold = $batteryThreshold
)''';
  }

  @override
  bool operator ==(covariant BatteryConfig other) {
    return enableProfile == other.enableProfile &&
        automaticProfileChanging == other.automaticProfileChanging &&
        saverProfile == other.saverProfile &&
        normalProfile == other.normalProfile &&
        batteryThreshold == other.batteryThreshold;
  }

  @override
  int get hashCode => Object.hashAll([
    enableProfile,
    automaticProfileChanging,
    saverProfile,
    normalProfile,
    batteryThreshold,
  ]);
}
