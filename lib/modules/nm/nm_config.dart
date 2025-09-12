import "package:config/config.dart";
import "package:config_gen/config_gen.dart";

part "nm_config.config.dart";

@Config()
mixin NetworkManagerConfigBase on NetworkManagerConfigI {
  static const _showConnectionNameIndicator = BooleanField(defaultTo: false);
  static const _showUploadIndicator = BooleanField(defaultTo: false);
  static const _showDownloadIndicator = BooleanField(defaultTo: false);
  static const _showThroughputIndicator = BooleanField(defaultTo: true);
  static const _deviceTypeFilter = ListField(StringField(), defaultTo: <String>[]);
}
