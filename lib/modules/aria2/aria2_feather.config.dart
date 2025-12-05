// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=info, type=warning

part of 'aria2_feather.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin Aria2ConfigI {
  @ConfigDocDefault<bool>(true)
  bool get showDownloadSpeed;

  @ConfigDocDefault<bool>(true)
  bool get showUploadSpeed;

  @ConfigDocDefault<bool>(false)
  bool get showActiveCount;

  @ConfigDocDefault<bool>(false)
  bool get showWaitingCount;

  @ConfigDocDefault<bool>(false)
  bool get showStoppedCount;

  @ConfigDocDefault<bool>(false)
  bool get showIndicatorsOnlyWhenNotZero;
}

class Aria2Config extends ConfigBaseI with Aria2ConfigI, Aria2ConfigBase {
  static const BlockSchema staticSchema = BlockSchema(
    fields: {
      'showDownloadSpeed': Aria2ConfigBase._showDownloadSpeed,
      'showUploadSpeed': Aria2ConfigBase._showUploadSpeed,
      'showActiveCount': Aria2ConfigBase._showActiveCount,
      'showWaitingCount': Aria2ConfigBase._showWaitingCount,
      'showStoppedCount': Aria2ConfigBase._showStoppedCount,
      'showIndicatorsOnlyWhenNotZero':
          Aria2ConfigBase._showIndicatorsOnlyWhenNotZero,
    },
  );

  static BlockSchema get schema => staticSchema;

  @override
  final bool showDownloadSpeed;
  @override
  final bool showUploadSpeed;
  @override
  final bool showActiveCount;
  @override
  final bool showWaitingCount;
  @override
  final bool showStoppedCount;
  @override
  final bool showIndicatorsOnlyWhenNotZero;

  Aria2Config({
    bool? showDownloadSpeed,
    bool? showUploadSpeed,
    bool? showActiveCount,
    bool? showWaitingCount,
    bool? showStoppedCount,
    bool? showIndicatorsOnlyWhenNotZero,
  }) : showDownloadSpeed = showDownloadSpeed ?? true,
       showUploadSpeed = showUploadSpeed ?? true,
       showActiveCount = showActiveCount ?? false,
       showWaitingCount = showWaitingCount ?? false,
       showStoppedCount = showStoppedCount ?? false,
       showIndicatorsOnlyWhenNotZero = showIndicatorsOnlyWhenNotZero ?? false;

  factory Aria2Config.fromBlock(BlockData data) {
    Map<String, dynamic> fields = data.fields.map(
      (k, v) => MapEntry(k.value, v),
    );
    return Aria2Config(
      showDownloadSpeed: fields['showDownloadSpeed'],
      showUploadSpeed: fields['showUploadSpeed'],
      showActiveCount: fields['showActiveCount'],
      showWaitingCount: fields['showWaitingCount'],
      showStoppedCount: fields['showStoppedCount'],
      showIndicatorsOnlyWhenNotZero: fields['showIndicatorsOnlyWhenNotZero'],
    );
  }

  @override
  String toString() {
    return '''Aria2Config(
	showDownloadSpeed = $showDownloadSpeed,
	showUploadSpeed = $showUploadSpeed,
	showActiveCount = $showActiveCount,
	showWaitingCount = $showWaitingCount,
	showStoppedCount = $showStoppedCount,
	showIndicatorsOnlyWhenNotZero = $showIndicatorsOnlyWhenNotZero
)''';
  }

  @override
  bool operator ==(covariant Aria2Config other) {
    return showDownloadSpeed == other.showDownloadSpeed &&
        showUploadSpeed == other.showUploadSpeed &&
        showActiveCount == other.showActiveCount &&
        showWaitingCount == other.showWaitingCount &&
        showStoppedCount == other.showStoppedCount &&
        showIndicatorsOnlyWhenNotZero == other.showIndicatorsOnlyWhenNotZero;
  }

  @override
  int get hashCode => Object.hashAll([
    showDownloadSpeed,
    showUploadSpeed,
    showActiveCount,
    showWaitingCount,
    showStoppedCount,
    showIndicatorsOnlyWhenNotZero,
  ]);
}
