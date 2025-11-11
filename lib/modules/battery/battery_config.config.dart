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

  @ConfigDocDefault<MyColor>(MyColor(0xFF43A047))
  /// Battery color when charging
  MyColor get chargingColor;

  @ConfigDocDefault<MyColor>(MyColor(0xFF424242))
  /// Battery color when discharging
  MyColor get dischargingColor;

  @ConfigDocDefault<MyColor>(MyColor(0xFFFF6E40))
  /// Battery color when the battery level is low and is discharging
  MyColor get warningColor;

  @ConfigDocDefault<MyColor>(MyColor(0xFFF44336))
  /// Battery color when the battery level is very low and is discharging
  MyColor get criticalColor;

  @ConfigDocDefault<MyColor>(MyColor(0xFFEEEEEE))
  /// Text color of the battery percentage inside the battery
  MyColor get textColor;

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
      'chargingColor': BatteryConfigBase._chargingColor,
      'dischargingColor': BatteryConfigBase._dischargingColor,
      'warningColor': BatteryConfigBase._warningColor,
      'criticalColor': BatteryConfigBase._criticalColor,
      'textColor': BatteryConfigBase._textColor,
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
  final MyColor chargingColor;
  @override
  final MyColor dischargingColor;
  @override
  final MyColor warningColor;
  @override
  final MyColor criticalColor;
  @override
  final MyColor textColor;
  @override
  final MyColor lightningColor;

  BatteryConfig({
    bool? enableProfile,
    bool? automaticProfileChanging,
    String? saverProfile,
    String? normalProfile,
    double? batteryThreshold,
    MyColor? chargingColor,
    MyColor? dischargingColor,
    MyColor? warningColor,
    MyColor? criticalColor,
    MyColor? textColor,
    MyColor? lightningColor,
  }) : enableProfile = enableProfile ?? true,
       automaticProfileChanging = automaticProfileChanging ?? true,
       saverProfile = saverProfile ?? "power-saver",
       normalProfile = normalProfile ?? "balanced",
       batteryThreshold = batteryThreshold ?? 30,
       chargingColor = chargingColor ?? MyColor(0xFF43A047),
       dischargingColor = dischargingColor ?? MyColor(0xFF424242),
       warningColor = warningColor ?? MyColor(0xFFFF6E40),
       criticalColor = criticalColor ?? MyColor(0xFFF44336),
       textColor = textColor ?? MyColor(0xFFEEEEEE),
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
      chargingColor: fields['chargingColor'],
      dischargingColor: fields['dischargingColor'],
      warningColor: fields['warningColor'],
      criticalColor: fields['criticalColor'],
      textColor: fields['textColor'],
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
	chargingColor = $chargingColor,
	dischargingColor = $dischargingColor,
	warningColor = $warningColor,
	criticalColor = $criticalColor,
	textColor = $textColor,
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
        chargingColor == other.chargingColor &&
        dischargingColor == other.dischargingColor &&
        warningColor == other.warningColor &&
        criticalColor == other.criticalColor &&
        textColor == other.textColor &&
        lightningColor == other.lightningColor;
  }

  @override
  int get hashCode => Object.hashAll([
    enableProfile,
    automaticProfileChanging,
    saverProfile,
    normalProfile,
    batteryThreshold,
    chargingColor,
    dischargingColor,
    warningColor,
    criticalColor,
    textColor,
    lightningColor,
  ]);
}
