import "package:config/config.dart";
import "package:config_gen/config_gen.dart";
import "package:waywing/util/config_fields.dart";

part "battery_config.config.dart";

@Config()
mixin BatteryConfigBase {
  /// Enable powerprofile functionality
  ///
  /// this option only matters if powerprofiles is installed in the system
  /// otherwise profile service will be disable nonetheless
  static const _enableProfile = BooleanField(defaultTo: true);

  /// Enable automatic handling of powerprofile changing depending on the battery level
  static const _automaticProfileChanging = BooleanField(defaultTo: true);

  /// Profile to be set when the battery level is below the threshold
  static const _saverProfile = StringField(defaultTo: "power-saver");

  /// Profile to be set when the battery level is above the threshold
  static const _normalProfile = StringField(defaultTo: "balanced");

  /// Battery level threshold.
  static const _batteryThreshold = DoubleNumberField(defaultTo: 30, validator: _batteryThresholdValidator);
  static ValidatorResult<double> _batteryThresholdValidator(double v) {
    if (v > 0 && v <= 100) {
      return ValidatorSuccess();
    }
    return ValidatorError(MyValError("Battery threshold must be between 0 and 100, but was $v"));
  }

  /// Battery color when charging
  static const _chargingColor = ColorField(defaultTo: MyColor(0xFF43A047));

  /// Battery color when discharging
  static const _dischargingColor = ColorField(defaultTo: MyColor(0xFF424242));

  /// Battery color when the battery level is low and is discharging
  static const _warningColor = ColorField(defaultTo: MyColor(0xFFFF6E40));

  /// Battery color when the battery level is very low and is discharging
  static const _criticalColor = ColorField(defaultTo: MyColor(0xFFF44336));

  static const _outlineColor = ColorField(defaultTo: MyColor(0xFFEEEEEE));

  /// Text color of the battery percentage inside the battery
  static const _textColor = ColorField(defaultTo: MyColor(0xFFEEEEEE));

  /// Color of the lightning that indicates that the battery is charging
  static const _lightningColor = ColorField(defaultTo: MyColor(0xFFFFC107));
}
