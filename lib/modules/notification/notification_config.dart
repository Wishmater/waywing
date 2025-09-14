import "package:config/config.dart";
import "package:config_gen/config_gen.dart";
import "package:flutter/widgets.dart";
import "package:waywing/util/config_fields.dart";

part "notification_config.config.dart";

@Config()
mixin NotificationsConfigBase on NotificationsConfigI {
  //===========================================================================
  // Positioning / sizing
  //===========================================================================

  static const _alignment = AlignmentField(defaultTo: Alignment.topLeft);

  // in flutter DIP, maybe also make in pixels so it's consistent ??? is it the same ???
  static const _marginLeft = DoubleNumberField(defaultTo: 32);
  static const _marginRight = DoubleNumberField(defaultTo: 32);
  static const _marginTop = DoubleNumberField(defaultTo: 32);
  static const _marginBottom = DoubleNumberField(defaultTo: 32);
  late final EdgeInsets margin = EdgeInsets.fromLTRB(marginLeft, marginTop, marginRight, marginBottom);

  static const _autoExpand = BooleanField(defaultTo: false);
  static const _showProgressBar = BooleanField(defaultTo: false);
}
