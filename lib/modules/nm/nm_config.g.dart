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
}

class NetworkManagerConfig
    with NetworkManagerConfigI, NetworkManagerConfigBase {
  final bool showConnectionNameIndicator;
  final bool showUploadIndicator;
  final bool showDownloadIndicator;
  final bool showThroughputIndicator;

  NetworkManagerConfig({
    bool? showConnectionNameIndicator,
    bool? showUploadIndicator,
    bool? showDownloadIndicator,
    bool? showThroughputIndicator,
  }) : showConnectionNameIndicator = showConnectionNameIndicator ?? false,
       showUploadIndicator = showUploadIndicator ?? false,
       showDownloadIndicator = showDownloadIndicator ?? false,
       showThroughputIndicator = showThroughputIndicator ?? true;

  factory NetworkManagerConfig.fromMap(Map<String, dynamic> map) {
    return NetworkManagerConfig(
      showConnectionNameIndicator: map['showConnectionNameIndicator'],
      showUploadIndicator: map['showUploadIndicator'],
      showDownloadIndicator: map['showDownloadIndicator'],
      showThroughputIndicator: map['showThroughputIndicator'],
    );
  }

  static TableSchema get schema => TableSchema(
    fields: {
      'showConnectionNameIndicator':
          NetworkManagerConfigBase._showConnectionNameIndicator,
      'showUploadIndicator': NetworkManagerConfigBase._showUploadIndicator,
      'showDownloadIndicator': NetworkManagerConfigBase._showDownloadIndicator,
      'showThroughputIndicator':
          NetworkManagerConfigBase._showThroughputIndicator,
    },
  );

  @override
  String toString() {
    return 'NetworkManagerConfigshowConnectionNameIndicator = $showConnectionNameIndicator, showUploadIndicator = $showUploadIndicator, showDownloadIndicator = $showDownloadIndicator, showThroughputIndicator = $showThroughputIndicator';
  }

  @override
  bool operator ==(covariant NetworkManagerConfig other) {
    return showConnectionNameIndicator == other.showConnectionNameIndicator &&
        showUploadIndicator == other.showUploadIndicator &&
        showDownloadIndicator == other.showDownloadIndicator &&
        showThroughputIndicator == other.showThroughputIndicator;
  }

  @override
  int get hashCode => Object.hashAll([
    showConnectionNameIndicator,
    showUploadIndicator,
    showDownloadIndicator,
    showThroughputIndicator,
  ]);
}
