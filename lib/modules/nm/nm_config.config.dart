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

class NetworkManagerConfig
    with NetworkManagerConfigI, NetworkManagerConfigBase {
  static const TableSchema staticSchema = TableSchema(
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

  static TableSchema get schema => staticSchema;

  final bool showConnectionNameIndicator;
  final bool showUploadIndicator;
  final bool showDownloadIndicator;
  final bool showThroughputIndicator;
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

  factory NetworkManagerConfig.fromMap(Map<String, dynamic> map) {
    return NetworkManagerConfig(
      showConnectionNameIndicator: map['showConnectionNameIndicator'],
      showUploadIndicator: map['showUploadIndicator'],
      showDownloadIndicator: map['showDownloadIndicator'],
      showThroughputIndicator: map['showThroughputIndicator'],
      deviceTypeFilter: map['deviceTypeFilter'],
    );
  }

  @override
  String toString() {
    return 'NetworkManagerConfigshowConnectionNameIndicator = $showConnectionNameIndicator, showUploadIndicator = $showUploadIndicator, showDownloadIndicator = $showDownloadIndicator, showThroughputIndicator = $showThroughputIndicator, deviceTypeFilter = $deviceTypeFilter';
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
