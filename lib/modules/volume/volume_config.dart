import "package:config/config.dart";
import "package:config_gen/config_gen.dart";

part "volume_config.config.dart";

@Config()
mixin VolumeServiceConfigBase on VolumeServiceConfigI {
  static const _maxVolume = IntegerNumberField(defaultTo: 100);

  static const _volumeStep = IntegerNumberField(defaultTo: 5);
}

@Config()
mixin VolumeConfigBase on VolumeConfigI {
  /// defaults to VolumeService.maxVolume (which defaults to 100)
  static const _maxVolume = IntegerNumberField(nullable: true);

  /// defaults to VolumeService.volumeStep (which defaults to 100)
  static const _volumeStep = IntegerNumberField(nullable: true);

  static const _showPercentageIndicator = BooleanField(defaultTo: true);

  static const _showSeparateMicIndicator = BooleanField(defaultTo: false);

  /// set duration to zero to disable tooltip on volume change
  static const _tooltipOnVolumeChangeDuration = DurationField(defaultTo: Duration(milliseconds: 1500));
}
