import "package:config/config.dart";
import "package:config_gen/config_gen.dart";
import "package:flutter/widgets.dart";
import "package:waywing/util/config_fields.dart";

part "notification_config.g.dart";

@Config()
mixin NotificationsConfigBase on NotificationsConfigI {
  static const _alignment = AlignmentField(defaultTo: Alignment.topLeft);
}
