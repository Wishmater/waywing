import "package:config/config.dart";
import "package:config_gen/config_gen.dart";

part "volume_config.config.dart";

@Config()
mixin VolumeConfigBase on VolumeConfigI {
  static const _showPercentageIndicator = BooleanField(defaultTo: true);
  static const _showSeparateMicIndicator = BooleanField(defaultTo: false);
  static const _maxVolume = IntegerNumberField(defaultTo: 100);
  static const _volumeStep = IntegerNumberField(defaultTo: 5);
}
