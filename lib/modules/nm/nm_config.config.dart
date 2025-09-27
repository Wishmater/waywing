// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nm_config.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin NetworkManagerConfigI {
  bool get showConnectionNameIndicator;
  bool get showUploadIndicator;
  bool get showDownloadIndicator;
  bool get showThroughputIndicator;
  List<String> get deviceTypeFilter;
}

class NetworkManagerConfig extends ConfigBaseI
    with NetworkManagerConfigI, NetworkManagerConfigBase {
  static const BlockSchema staticSchema = BlockSchema(
    fields: {
      'showConnectionNameIndicator':
          NetworkManagerConfigBase._showConnectionNameIndicator,
      'showUploadIndicator': NetworkManagerConfigBase._showUploadIndicator,
      'showDownloadIndicator': NetworkManagerConfigBase._showDownloadIndicator,
      'showThroughputIndicator':
          NetworkManagerConfigBase._showThroughputIndicator,
      'deviceTypeFilter': NetworkManagerConfigBase._deviceTypeFilter,
    },
  );

  static BlockSchema get schema => staticSchema;

  @override
  final bool showConnectionNameIndicator;
  @override
  final bool showUploadIndicator;
  @override
  final bool showDownloadIndicator;
  @override
  final bool showThroughputIndicator;
  @override
  final List<String> deviceTypeFilter;

  NetworkManagerConfig({
    bool? showConnectionNameIndicator,
    bool? showUploadIndicator,
    bool? showDownloadIndicator,
    bool? showThroughputIndicator,
    List<String>? deviceTypeFilter,
  }) : showConnectionNameIndicator = showConnectionNameIndicator ?? false,
       showUploadIndicator = showUploadIndicator ?? false,
       showDownloadIndicator = showDownloadIndicator ?? false,
       showThroughputIndicator = showThroughputIndicator ?? true,
       deviceTypeFilter = deviceTypeFilter ?? <String>[];

  factory NetworkManagerConfig.fromBlock(BlockData data) {
    Map<String, dynamic> fields = data.fields;
    return NetworkManagerConfig(
      showConnectionNameIndicator: fields['showConnectionNameIndicator'],
      showUploadIndicator: fields['showUploadIndicator'],
      showDownloadIndicator: fields['showDownloadIndicator'],
      showThroughputIndicator: fields['showThroughputIndicator'],
      deviceTypeFilter: fields['deviceTypeFilter'],
    );
  }

  @override
  String toString() {
    return '''NetworkManagerConfig(
	showConnectionNameIndicator = $showConnectionNameIndicator,
	showUploadIndicator = $showUploadIndicator,
	showDownloadIndicator = $showDownloadIndicator,
	showThroughputIndicator = $showThroughputIndicator,
	deviceTypeFilter = $deviceTypeFilter
)''';
  }

  @override
  bool operator ==(covariant NetworkManagerConfig other) {
    return showConnectionNameIndicator == other.showConnectionNameIndicator &&
        showUploadIndicator == other.showUploadIndicator &&
        showDownloadIndicator == other.showDownloadIndicator &&
        showThroughputIndicator == other.showThroughputIndicator &&
        deviceTypeFilter == other.deviceTypeFilter;
  }

  @override
  int get hashCode => Object.hashAll([
    showConnectionNameIndicator,
    showUploadIndicator,
    showDownloadIndicator,
    showThroughputIndicator,
    deviceTypeFilter,
  ]);
}
