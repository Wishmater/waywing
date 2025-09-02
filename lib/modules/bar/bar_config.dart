import "package:config/config.dart";
import "package:config_gen/config_gen.dart";
import "package:fl_linux_window_manager/models/screen_edge.dart";
import "package:flutter/painting.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/util/config_fields.dart";

part "bar_config.g.dart";

@Config()
mixin BarConfigBase on BarConfigI {
  //===========================================================================
  // Positioning / sizing
  //===========================================================================

  static const _side = EnumField(ScreenEdge.values);
  static const _size = IntegerNumberField(); // in pixels

  // in flutter DIP, maybe also make in pixels so it's consistent ??? is it the same ???
  static const _marginLeft = DoubleNumberField(defaultTo: 0);
  static const _marginRight = DoubleNumberField(defaultTo: 0);
  static const _marginTop = DoubleNumberField(defaultTo: 0);
  static const _marginBottom = DoubleNumberField(defaultTo: 0);
  late final EdgeInsets margin = EdgeInsets.fromLTRB(marginLeft, marginTop, marginRight, marginBottom);

  // Derived
  late final bool isVertical = side == ScreenEdge.left || side == ScreenEdge.right;
  // TODO: 3 validate that mainSize is not <=0 after deducting margins
  // TODO: 3 validate that you can't add margin on sides that conflict with barSide selected

  //===========================================================================
  // Exclusive size
  //===========================================================================

  static const __exclusiveSizeLeft = DoubleNumberField(nullable: true);
  double get exclusiveSizeLeft => _exclusiveSizeLeft ?? (side == ScreenEdge.left ? size.toDouble() : 0);
  static const __exclusiveSizeRight = DoubleNumberField(nullable: true);
  double get exclusiveSizeRight => _exclusiveSizeRight ?? (side == ScreenEdge.right ? size.toDouble() : 0);
  static const __exclusiveSizeTop = DoubleNumberField(nullable: true);
  double get exclusiveSizeTop => _exclusiveSizeTop ?? (side == ScreenEdge.top ? size.toDouble() : 0);
  static const __exclusiveSizeBottom = DoubleNumberField(nullable: true);
  double get exclusiveSizeBottom => _exclusiveSizeBottom ?? (side == ScreenEdge.bottom ? size.toDouble() : 0);

  // Note (add to readme when it exists): explicitly set exclusiveSice will have priority over Bar size.
  // Set exclusiveSize to zero on same side bar is on to remove autoExclusiveSize on Bar.
  double? getExclusiveSizeForSide(ScreenEdge side) {
    return switch (side) {
      ScreenEdge.left => exclusiveSizeLeft,
      ScreenEdge.right => exclusiveSizeRight,
      ScreenEdge.top => exclusiveSizeTop,
      ScreenEdge.bottom => exclusiveSizeBottom,
    };
  }

  //===========================================================================
  // Style
  //===========================================================================

  // in flutter DIP, maybe also make in pixels so it's consistent ??? is it the same ???
  static const _radiusInCross = DoubleNumberField(defaultTo: 0);
  static const _radiusInMain = DoubleNumberField(defaultTo: 0);
  static const _radiusOutCross = DoubleNumberField(defaultTo: 0);
  static const _radiusOutMain = DoubleNumberField(defaultTo: 0);
  // TODO: 3 validate that barRadiusOutMain <= relevantBarMargin

  // Derived

  //===========================================================================
  // Feathers (components)
  //===========================================================================

  static const __indicatorMinSize = DoubleNumberField(nullable: true); // defaults to barSize
  double get indicatorMinSize => _indicatorMinSize ?? size.toDouble();
  static const __indicatorPadding = DoubleNumberField(nullable: true); // defaults to a fraction of barSize
  double get indicatorPadding => _indicatorPadding ?? size.toDouble();

  static const _startFeathers = ListField(FeatherField(), defaultTo: <Feather>[]);
  static const _centerFeathers = ListField(FeatherField(), defaultTo: <Feather>[]);
  static const _endFeathers = ListField(FeatherField(), defaultTo: <Feather>[]);
}
