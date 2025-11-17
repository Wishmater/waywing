// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=info, type=warning

part of 'battery_config.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin BatteryConfigI {
  @ConfigDocDefault<bool>(true)
  /// Enable powerprofile functionality
  ///
  /// this option only matters if powerprofiles is installed in the system
  /// otherwise profile service will be disable nonetheless
  bool get enableProfile;

  @ConfigDocDefault<bool>(true)
  /// Enable automatic handling of powerprofile changing depending on the battery level
  bool get automaticProfileChanging;

  @ConfigDocDefault<String>("power-saver")
  /// Profile to be set when the battery level is below the threshold
  String get saverProfile;

  @ConfigDocDefault<String>("balanced")
  /// Profile to be set when the battery level is above the threshold
  String get normalProfile;

  @ConfigDocDefault<double>(30)
  /// Battery level threshold.
  double get batteryThreshold;

  @ConfigDocDefault<MyColor>(MyColor(0xFFFFC107))
  /// Color of the lightning that indicates that the battery is charging
  MyColor get lightningColor;
}

class BatteryConfig extends ConfigBaseI with BatteryConfigI, BatteryConfigBase {
  static const BlockSchema staticSchema = BlockSchema(
    fields: {
      'enableProfile': BatteryConfigBase._enableProfile,
      'automaticProfileChanging': BatteryConfigBase._automaticProfileChanging,
      'saverProfile': BatteryConfigBase._saverProfile,
      'normalProfile': BatteryConfigBase._normalProfile,
      'batteryThreshold': BatteryConfigBase._batteryThreshold,
      'lightningColor': BatteryConfigBase._lightningColor,
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
  @override
  final MyColor lightningColor;

  BatteryConfig({
    bool? enableProfile,
    bool? automaticProfileChanging,
    String? saverProfile,
    String? normalProfile,
    double? batteryThreshold,
    MyColor? lightningColor,
  }) : enableProfile = enableProfile ?? true,
       automaticProfileChanging = automaticProfileChanging ?? true,
       saverProfile = saverProfile ?? "power-saver",
       normalProfile = normalProfile ?? "balanced",
       batteryThreshold = batteryThreshold ?? 30,
       lightningColor = lightningColor ?? MyColor(0xFFFFC107);

  factory BatteryConfig.fromBlock(BlockData data) {
    Map<String, dynamic> fields = data.fields.map(
      (k, v) => MapEntry(k.value, v),
    );
    return BatteryConfig(
      enableProfile: fields['enableProfile'],
      automaticProfileChanging: fields['automaticProfileChanging'],
      saverProfile: fields['saverProfile'],
      normalProfile: fields['normalProfile'],
      batteryThreshold: fields['batteryThreshold'],
      lightningColor: fields['lightningColor'],
    );
  }

  @override
  String toString() {
    return '''BatteryConfig(
	enableProfile = $enableProfile,
	automaticProfileChanging = $automaticProfileChanging,
	saverProfile = $saverProfile,
	normalProfile = $normalProfile,
	batteryThreshold = $batteryThreshold,
	lightningColor = $lightningColor
)''';
  }

  @override
  bool operator ==(covariant BatteryConfig other) {
    return enableProfile == other.enableProfile &&
        automaticProfileChanging == other.automaticProfileChanging &&
        saverProfile == other.saverProfile &&
        normalProfile == other.normalProfile &&
        batteryThreshold == other.batteryThreshold &&
        lightningColor == other.lightningColor;
  }

  @override
  int get hashCode => Object.hashAll([
    enableProfile,
    automaticProfileChanging,
    saverProfile,
    normalProfile,
    batteryThreshold,
    lightningColor,
  ]);
}

mixin BatteryServiceConfigI {
  @ConfigDocDefault<bool>(false)
  /// Use a mock implementation for development only
  bool get useMock;
}

class BatteryServiceConfig extends ConfigBaseI
    with BatteryServiceConfigI, BatteryServiceConfigBase {
  static const BlockSchema staticSchema = BlockSchema(
    fields: {'useMock': BatteryServiceConfigBase._useMock},
  );

  static BlockSchema get schema => staticSchema;

  @override
  final bool useMock;

  BatteryServiceConfig({bool? useMock}) : useMock = useMock ?? false;

  factory BatteryServiceConfig.fromBlock(BlockData data) {
    Map<String, dynamic> fields = data.fields.map(
      (k, v) => MapEntry(k.value, v),
    );
    return BatteryServiceConfig(useMock: fields['useMock']);
  }

  @override
  String toString() {
    return '''BatteryServiceConfig(
	useMock = $useMock
)''';
  }

  @override
  bool operator ==(covariant BatteryServiceConfig other) {
    return useMock == other.useMock;
  }

  @override
  int get hashCode => Object.hashAll([useMock]);
}
