// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=info, type=warning

part of 'volume_config.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin VolumeServiceConfigI {
  @ConfigDocDefault<int>(100)
  int get maxVolume;

  @ConfigDocDefault<int>(5)
  int get volumeStep;
}

class VolumeServiceConfig extends ConfigBaseI
    with VolumeServiceConfigI, VolumeServiceConfigBase {
  static const BlockSchema staticSchema = BlockSchema(
    fields: {
      'maxVolume': VolumeServiceConfigBase._maxVolume,
      'volumeStep': VolumeServiceConfigBase._volumeStep,
    },
  );

  static BlockSchema get schema => staticSchema;

  @override
  final int maxVolume;
  @override
  final int volumeStep;

  VolumeServiceConfig({int? maxVolume, int? volumeStep})
    : maxVolume = maxVolume ?? 100,
      volumeStep = volumeStep ?? 5;

  factory VolumeServiceConfig.fromBlock(BlockData data) {
    Map<String, dynamic> fields = data.fields;
    return VolumeServiceConfig(
      maxVolume: fields['maxVolume'],
      volumeStep: fields['volumeStep'],
    );
  }

  @override
  String toString() {
    return '''VolumeServiceConfig(
	maxVolume = $maxVolume,
	volumeStep = $volumeStep
)''';
  }

  @override
  bool operator ==(covariant VolumeServiceConfig other) {
    return maxVolume == other.maxVolume && volumeStep == other.volumeStep;
  }

  @override
  int get hashCode => Object.hashAll([maxVolume, volumeStep]);
}

mixin VolumeConfigI {
  /// defaults to VolumeService.maxVolume (which defaults to 100)
  int? get maxVolume;

  /// defaults to VolumeService.volumeStep (which defaults to 100)
  int? get volumeStep;

  @ConfigDocDefault<bool>(true)
  bool get showPercentageIndicator;

  @ConfigDocDefault<bool>(false)
  bool get showSeparateMicIndicator;

  @ConfigDocDefault<Duration>(Duration(milliseconds: 1500))
  /// set duration to zero to disable tooltip on volume change
  Duration get tooltipOnVolumeChangeDuration;
}

class VolumeConfig extends ConfigBaseI with VolumeConfigI, VolumeConfigBase {
  static const BlockSchema staticSchema = BlockSchema(
    fields: {
      'maxVolume': VolumeConfigBase._maxVolume,
      'volumeStep': VolumeConfigBase._volumeStep,
      'showPercentageIndicator': VolumeConfigBase._showPercentageIndicator,
      'showSeparateMicIndicator': VolumeConfigBase._showSeparateMicIndicator,
      'tooltipOnVolumeChangeDuration':
          VolumeConfigBase._tooltipOnVolumeChangeDuration,
    },
  );

  static BlockSchema get schema => staticSchema;

  @override
  final int? maxVolume;
  @override
  final int? volumeStep;
  @override
  final bool showPercentageIndicator;
  @override
  final bool showSeparateMicIndicator;
  @override
  final Duration tooltipOnVolumeChangeDuration;

  VolumeConfig({
    this.maxVolume,
    this.volumeStep,
    bool? showPercentageIndicator,
    bool? showSeparateMicIndicator,
    Duration? tooltipOnVolumeChangeDuration,
  }) : showPercentageIndicator = showPercentageIndicator ?? true,
       showSeparateMicIndicator = showSeparateMicIndicator ?? false,
       tooltipOnVolumeChangeDuration =
           tooltipOnVolumeChangeDuration ?? Duration(milliseconds: 1500);

  factory VolumeConfig.fromBlock(BlockData data) {
    Map<String, dynamic> fields = data.fields.map(
      (k, v) => MapEntry(k.value, v),
    );
    return VolumeConfig(
      maxVolume: fields['maxVolume'],
      volumeStep: fields['volumeStep'],
      showPercentageIndicator: fields['showPercentageIndicator'],
      showSeparateMicIndicator: fields['showSeparateMicIndicator'],
      tooltipOnVolumeChangeDuration: fields['tooltipOnVolumeChangeDuration'],
    );
  }

  @override
  String toString() {
    return '''VolumeConfig(
	maxVolume = $maxVolume,
	volumeStep = $volumeStep,
	showPercentageIndicator = $showPercentageIndicator,
	showSeparateMicIndicator = $showSeparateMicIndicator,
	tooltipOnVolumeChangeDuration = $tooltipOnVolumeChangeDuration
)''';
  }

  @override
  bool operator ==(covariant VolumeConfig other) {
    return maxVolume == other.maxVolume &&
        volumeStep == other.volumeStep &&
        showPercentageIndicator == other.showPercentageIndicator &&
        showSeparateMicIndicator == other.showSeparateMicIndicator &&
        tooltipOnVolumeChangeDuration == other.tooltipOnVolumeChangeDuration;
  }

  @override
  int get hashCode => Object.hashAll([
    maxVolume,
    volumeStep,
    showPercentageIndicator,
    showSeparateMicIndicator,
    tooltipOnVolumeChangeDuration,
  ]);
}
