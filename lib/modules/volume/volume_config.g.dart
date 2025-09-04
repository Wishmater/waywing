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

  @override
  String toString() {
    return 'VolumeConfigshowPercentageIndicator = $showPercentageIndicator, showSeparateMicIndicator = $showSeparateMicIndicator, maxVolume = $maxVolume, volumeStep = $volumeStep';
  }

  @override
  bool operator ==(covariant VolumeConfig other) {
    return showPercentageIndicator == other.showPercentageIndicator &&
        showSeparateMicIndicator == other.showSeparateMicIndicator &&
        maxVolume == other.maxVolume &&
        volumeStep == other.volumeStep;
  }

  @override
  int get hashCode => Object.hashAll([
    showPercentageIndicator,
    showSeparateMicIndicator,
    maxVolume,
    volumeStep,
  ]);
}
