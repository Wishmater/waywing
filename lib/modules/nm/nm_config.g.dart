// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nm_config.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin NetworkManagerConfigI {
  bool get showWiFiNameIndicator;
  bool get showUploadIndicator;
  bool get showDownloadIndicator;
  bool get showThroughputIndicator;
}

class NetworkManagerConfig
    with NetworkManagerConfigI, NetworkManagerConfigBase {
  final bool showWiFiNameIndicator;
  final bool showUploadIndicator;
  final bool showDownloadIndicator;
  final bool showThroughputIndicator;

  NetworkManagerConfig({
    bool? showWiFiNameIndicator,
    bool? showUploadIndicator,
    bool? showDownloadIndicator,
    bool? showThroughputIndicator,
  }) : showWiFiNameIndicator = showWiFiNameIndicator ?? false,
       showUploadIndicator = showUploadIndicator ?? false,
       showDownloadIndicator = showDownloadIndicator ?? false,
       showThroughputIndicator = showThroughputIndicator ?? true;

  factory NetworkManagerConfig.fromMap(Map<String, dynamic> map) {
    return NetworkManagerConfig(
      showWiFiNameIndicator: map['showWiFiNameIndicator'],
      showUploadIndicator: map['showUploadIndicator'],
      showDownloadIndicator: map['showDownloadIndicator'],
      showThroughputIndicator: map['showThroughputIndicator'],
    );
  }

  static TableSchema get schema => TableSchema(
    fields: {
      'showWiFiNameIndicator': NetworkManagerConfigBase._showWiFiNameIndicator,
      'showUploadIndicator': NetworkManagerConfigBase._showUploadIndicator,
      'showDownloadIndicator': NetworkManagerConfigBase._showDownloadIndicator,
      'showThroughputIndicator':
          NetworkManagerConfigBase._showThroughputIndicator,
    },
  );
}
