// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=info, type=warning

part of 'volume_config.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin VolumeConfigI {
  @ConfigDocDefault<bool>(true)
  bool get showPercentageIndicator;

  @ConfigDocDefault<bool>(false)
  bool get showSeparateMicIndicator;

  @ConfigDocDefault<int>(100)
  int get maxVolume;

  @ConfigDocDefault<int>(5)
  int get volumeStep;

  @ConfigDocDefault<bool>(true)
  bool get showTooltipOnVolumeChange;
}

class VolumeConfig extends ConfigBaseI with VolumeConfigI, VolumeConfigBase {
  static const BlockSchema staticSchema = BlockSchema(
    fields: {
      'showPercentageIndicator': VolumeConfigBase._showPercentageIndicator,
      'showSeparateMicIndicator': VolumeConfigBase._showSeparateMicIndicator,
      'maxVolume': VolumeConfigBase._maxVolume,
      'volumeStep': VolumeConfigBase._volumeStep,
      'showTooltipOnVolumeChange': VolumeConfigBase._showTooltipOnVolumeChange,
    },
  );

  static BlockSchema get schema => staticSchema;

  @override
  final bool showPercentageIndicator;
  @override
  final bool showSeparateMicIndicator;
  @override
  final int maxVolume;
  @override
  final int volumeStep;
  @override
  final bool showTooltipOnVolumeChange;

  VolumeConfig({
    bool? showPercentageIndicator,
    bool? showSeparateMicIndicator,
    int? maxVolume,
    int? volumeStep,
    bool? showTooltipOnVolumeChange,
  }) : showPercentageIndicator = showPercentageIndicator ?? true,
       showSeparateMicIndicator = showSeparateMicIndicator ?? false,
       maxVolume = maxVolume ?? 100,
       volumeStep = volumeStep ?? 5,
       showTooltipOnVolumeChange = showTooltipOnVolumeChange ?? true;

  factory VolumeConfig.fromBlock(BlockData data) {
    Map<String, dynamic> fields = data.fields;
    return VolumeConfig(
      showPercentageIndicator: fields['showPercentageIndicator'],
      showSeparateMicIndicator: fields['showSeparateMicIndicator'],
      maxVolume: fields['maxVolume'],
      volumeStep: fields['volumeStep'],
      showTooltipOnVolumeChange: fields['showTooltipOnVolumeChange'],
    );
  }

  @override
  String toString() {
    return '''VolumeConfig(
	showPercentageIndicator = $showPercentageIndicator,
	showSeparateMicIndicator = $showSeparateMicIndicator,
	maxVolume = $maxVolume,
	volumeStep = $volumeStep,
	showTooltipOnVolumeChange = $showTooltipOnVolumeChange
)''';
  }

  @override
  bool operator ==(covariant VolumeConfig other) {
    return showPercentageIndicator == other.showPercentageIndicator &&
        showSeparateMicIndicator == other.showSeparateMicIndicator &&
        maxVolume == other.maxVolume &&
        volumeStep == other.volumeStep &&
        showTooltipOnVolumeChange == other.showTooltipOnVolumeChange;
  }

  @override
  int get hashCode => Object.hashAll([
    showPercentageIndicator,
    showSeparateMicIndicator,
    maxVolume,
    volumeStep,
    showTooltipOnVolumeChange,
  ]);
}
