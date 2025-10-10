import "package:config/config.dart";
import "package:config_gen/config_gen.dart";
import "package:dartx/dartx_io.dart";
import "package:fl_linux_window_manager/models/screen_edge.dart";
import "package:flutter/painting.dart";
import "package:waywing/core/config.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/core/feather_registry.dart";

part "bar_config.config.dart";

@Config()
mixin BarConfigBase on BarConfigI {
  //===========================================================================
  // Positioning / sizing
  //===========================================================================

  // TODO: 2 these two should probably not have a default (force the user to set them)
  static const _side = EnumField(ScreenEdge.values, defaultTo: ScreenEdge.bottom);
  static const _size = IntegerNumberField(defaultTo: 30); // in pixels

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
  double get exclusiveSizeLeft =>
      _exclusiveSizeLeft ?? //
      (side == ScreenEdge.left ? size.toDouble() + marginLeft : 0);
  static const __exclusiveSizeRight = DoubleNumberField(nullable: true);
  double get exclusiveSizeRight =>
      _exclusiveSizeRight ?? //
      (side == ScreenEdge.right ? size.toDouble() + marginRight : 0);
  static const __exclusiveSizeTop = DoubleNumberField(nullable: true);
  double get exclusiveSizeTop =>
      _exclusiveSizeTop ?? //
      (side == ScreenEdge.top ? size.toDouble() + marginTop : 0);
  static const __exclusiveSizeBottom = DoubleNumberField(nullable: true);
  double get exclusiveSizeBottom =>
      _exclusiveSizeBottom ?? //
      (side == ScreenEdge.bottom ? size.toDouble() + marginBottom : 0);

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
  static const __rounding = DoubleNumberField(nullable: true);
  double get rounding => _rounding ?? mainConfig.theme.containerRounding;
  // TODO: 3 do we want to expose different rounding values for each corner? or at least horizontal/vertical?

  static const __shadows = DoubleNumberField(nullable: true);
  double get shadows => _shadows ?? 1; // mainConfig.theme.shadows;

  // Derived

  //===========================================================================
  // Feathers (components)
  //===========================================================================

  static const __indicatorMinSize = DoubleNumberField(nullable: true); // defaults to barSize
  double get indicatorMinSize => _indicatorMinSize ?? size.toDouble();
  static const __indicatorPadding = DoubleNumberField(nullable: true); // defaults to a fraction of barSize
  double get indicatorPadding => _indicatorPadding ?? size / 8;

  // TODO: 3 validate that at least one feather is added to one of the lists

  // TODO: 3 validate none of these are added several times
  static Map<String, ({BlockSchema schema, dynamic Function(BlockData) from})> _getDynamicSchemaTables() => {
    "Start": (schema: BarFeathersContainer.schema, from: BarFeathersContainer.fromBlock),
    "Center": (schema: BarFeathersContainer.schema, from: BarFeathersContainer.fromBlock),
    "End": (schema: BarFeathersContainer.schema, from: BarFeathersContainer.fromBlock),
  };

  BarFeathersContainer? get start =>
      dynamicSchemas.firstOrNullWhere((e) => e.$1 == "Start")?.$2 as BarFeathersContainer?;
  BarFeathersContainer? get center =>
      dynamicSchemas.firstOrNullWhere((e) => e.$1 == "Center")?.$2 as BarFeathersContainer?;
  BarFeathersContainer? get end => dynamicSchemas.firstOrNullWhere((e) => e.$1 == "End")?.$2 as BarFeathersContainer?;
}

@Config()
mixin BarFeathersContainerBase on BarFeathersContainerI {
  static Map<String, ({BlockSchema schema, dynamic Function(BlockData) from})> _getDynamicSchemaTables() =>
      featherRegistry.getDynamicFeathersSchemas();

  List<(String, Object)> get rawFeathers => dynamicSchemas;

  List<T> getFeatherInstances<T extends Feather>(String uniqueIdPrefix) {
    return getFeatherInstancesStatic<T>(rawFeathers, uniqueIdPrefix);
  }
}
