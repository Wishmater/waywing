// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=info, type=warning

part of 'nm_config.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin NetworkManagerConfigI {
  @ConfigDocDefault<bool>(false)
  bool get showConnectionNameIndicator;

  @ConfigDocDefault<bool>(false)
  bool get showUploadIndicator;

  @ConfigDocDefault<bool>(false)
  bool get showDownloadIndicator;

  @ConfigDocDefault<bool>(true)
  bool get showThroughputIndicator;

  @ConfigDocDefault<List<String>>(<String>[])
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
    Map<String, dynamic> fields = data.fields.map(
      (k, v) => MapEntry(k.value, v),
    );
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

mixin NetworkManagerServiceConfigI {
  @ConfigDocDefault<List<String>>(<String>[])
  List<String> get deviceTypeFilter;
}

class NetworkManagerServiceConfig extends ConfigBaseI
    with NetworkManagerServiceConfigI, NetworkManagerServiceConfigBase {
  static const BlockSchema staticSchema = BlockSchema(
    fields: {
      'deviceTypeFilter': NetworkManagerServiceConfigBase._deviceTypeFilter,
    },
  );

  static BlockSchema get schema => staticSchema;

  @override
  final List<String> deviceTypeFilter;

  NetworkManagerServiceConfig({List<String>? deviceTypeFilter})
    : deviceTypeFilter = deviceTypeFilter ?? <String>[];

  factory NetworkManagerServiceConfig.fromBlock(BlockData data) {
    Map<String, dynamic> fields = data.fields.map(
      (k, v) => MapEntry(k.value, v),
    );
    return NetworkManagerServiceConfig(
      deviceTypeFilter: fields['deviceTypeFilter'],
    );
  }

  @override
  String toString() {
    return '''NetworkManagerServiceConfig(
	deviceTypeFilter = $deviceTypeFilter
)''';
  }

  @override
  bool operator ==(covariant NetworkManagerServiceConfig other) {
    return deviceTypeFilter == other.deviceTypeFilter;
  }

  @override
  int get hashCode => Object.hashAll([deviceTypeFilter]);
}
