// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'volume_config.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin VolumeConfigI {
  bool get showPercentageIndicator;
  bool get showSeparateMicIndicator;
  int get maxVolume;
  int get volumeStep;
}

class VolumeConfig with VolumeConfigI, VolumeConfigBase {
  final bool showPercentageIndicator;
  final bool showSeparateMicIndicator;
  final int maxVolume;
  final int volumeStep;

  VolumeConfig({
    bool? showPercentageIndicator,
    bool? showSeparateMicIndicator,
    int? maxVolume,
    int? volumeStep,
  }) : showPercentageIndicator = showPercentageIndicator ?? true,
       showSeparateMicIndicator = showSeparateMicIndicator ?? false,
       maxVolume = maxVolume ?? 100,
       volumeStep = volumeStep ?? 5;

  factory VolumeConfig.fromMap(Map<String, dynamic> map) {
    return VolumeConfig(
      showPercentageIndicator: map['showPercentageIndicator'],
      showSeparateMicIndicator: map['showSeparateMicIndicator'],
      maxVolume: map['maxVolume'],
      volumeStep: map['volumeStep'],
    );
  }

  static TableSchema get schema => TableSchema(
    fields: {
      'showPercentageIndicator': VolumeConfigBase._showPercentageIndicator,
      'showSeparateMicIndicator': VolumeConfigBase._showSeparateMicIndicator,
      'maxVolume': VolumeConfigBase._maxVolume,
      'volumeStep': VolumeConfigBase._volumeStep,
    },
  );
}
