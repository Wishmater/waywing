import "package:config/config.dart";
import "package:config_gen/config_gen.dart";
import "package:fl_linux_window_manager/models/screen_edge.dart";
import "package:fl_linux_window_manager/widgets/input_region.dart";
import "package:flutter/material.dart";
import "package:waywing/core/config.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/wing.dart";
import "package:waywing/util/derived_value_notifier.dart";
import "package:waywing/util/state_positioning.dart";
import "package:waywing/widgets/motion_widgets/motion_positioned.dart";
import "package:waywing/widgets/shapes/external_rounded_corners_shape.dart";
import "package:waywing/widgets/winged_widgets/winged_container.dart";
import "package:waywing/widgets/winged_widgets/winged_popover.dart";

part "drawer.config.dart";

class DrawerWing extends Wing<DrawerConfig> {
  DrawerWing._();

  static void registerFeather(RegisterFeatherCallback<DrawerWing, DrawerConfig> registerFeather) {
    registerFeather(
      "Drawer",
      FeatherRegistration<DrawerWing, DrawerConfig>(
        constructor: DrawerWing._,
        schemaBuilder: () => DrawerConfig.schema,
        configBuilder: DrawerConfig.fromBlock,
      ),
    );
  }

  @override
  String get name => "Drawer";

  late Feather feather = config.getFeatherInstance(uniqueId);

  @override
  List<Feather> getFeathers() => [feather];

  @override
  void onConfigUpdated(DrawerConfig oldConfig) {
    feather = config.getFeatherInstance(uniqueId);
  }

  @override
  Widget buildWing(BuildContext context, EdgeInsets _) {
    // const minSize = 32.0;
    const minSize = 1.0;
    final screenSize = MediaQuery.sizeOf(context);
    final popoverAlignment = switch (config.side) {
      ScreenEdge.top => Alignment.bottomCenter,
      ScreenEdge.right => Alignment.centerLeft,
      ScreenEdge.bottom => Alignment.topCenter,
      ScreenEdge.left => Alignment.centerRight,
    };
    final overflowAlignment = switch (config.side) {
      ScreenEdge.top => Alignment.topCenter,
      ScreenEdge.right => Alignment.centerRight,
      ScreenEdge.bottom => Alignment.bottomCenter,
      ScreenEdge.left => Alignment.centerLeft,
    };
    return ValueListenableBuilder(
      valueListenable: mainConfig.exclusiveSize,
      builder: (context, reservedSpace, child) {
        double left, top, width, height, absLeft, absTop, absWidth, absHeight;
        var extraOffset = Offset.zero;
        if (!config.isVertical) {
          left = reservedSpace.left;
          absLeft = 0;
          width = screenSize.width - reservedSpace.horizontal;
          absWidth = screenSize.width;
          if (config.side == ScreenEdge.top) {
            height = reservedSpace.top;
            if (height < minSize) {
              extraOffset = Offset(0, -(minSize - height));
              height = minSize;
            }
            top = 0;
          } else {
            height = reservedSpace.bottom;
            if (height < minSize) {
              extraOffset = Offset(0, minSize - height);
              height = minSize;
            }
            top = screenSize.height - height;
          }
          absHeight = height;
          absTop = top;
        } else {
          top = reservedSpace.top;
          absTop = 0;
          height = screenSize.height - reservedSpace.vertical;
          absHeight = screenSize.height;
          if (config.side == ScreenEdge.left) {
            width = reservedSpace.left;
            if (width < minSize) {
              extraOffset = Offset(0, -(minSize - width));
              width = minSize;
            }
            left = 0;
          } else {
            width = reservedSpace.right;
            if (width < minSize) {
              extraOffset = Offset(0, minSize - width);
              width = minSize;
            }
            left = screenSize.width - width;
          }
          absWidth = width;
          absLeft = left;
        }
        return MotionPositioned(
          motion: mainConfig.motions.expressive.spatial.slow,
          left: left,
          top: top,
          width: width,
          height: height,
          child: InputRegion(
            child: WingedPopover(
              builder: (context, controller, child) {
                return SizedBox.expand();
              },
              // TODO: 3 PERFORMANCE is this needed ??
              extraClientClippers: [
                (
                  RoundedRectangleBorder(),
                  DummyValueNotifier(Positioning(Offset(absLeft, absTop), Size(absWidth, absHeight))),
                ),
              ],
              tooltipParams: TooltipParams(
                motion: mainConfig.motions.expressive.spatial.slow,
                zIndex: -5,
                popupAlignment: popoverAlignment,
                anchorAlignment: popoverAlignment,
                overflowAlignment: overflowAlignment,
                screenPadding: reservedSpace,
                stickToHost: true,
                extraOffset: extraOffset,
                builder: (context, controller, _, targetChildContainerPositioning) {
                  // TODO: 1 we should await feather initialization
                  // TODO: 1 what to do when there are several/no components, also we should listen to feather.components
                  return feather.components.value.first.buildPopover!(context);
                },
                containerBuilder: (context, child, _, _, targetChildContainerPositioning) {
                  return buildPopoverContainer(
                    context,
                    child,
                    targetChildContainerPositioning,
                    isClosed: false,
                  );
                },
                closedContainerBuilder: (context, child, _, _, targetChildContainerPositioning) {
                  return buildPopoverContainer(
                    context,
                    child,
                    targetChildContainerPositioning,
                    isClosed: true,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildPopoverContainer(
    BuildContext context,
    Widget child,
    ValueNotifier<Positioning?> targetChildContainerPositioning, {
    required bool isClosed,
  }) {
    final popoverBorderRadius = BorderRadius.all(Radius.circular(mainConfig.theme.containerRounding));
    return ValueListenableBuilder(
      valueListenable: targetChildContainerPositioning,
      child: child,
      builder: (context, targetChildContainerPositioning, child) {
        return ValueListenableBuilder(
          valueListenable: mainConfig.exclusiveSize,
          child: child,
          builder: (context, exclusiveSize, child) {
            if (isClosed) {
              return buildContainer(
                context,
                child!,
                ExternalRoundedCornersBorder(borderRadius: BorderRadius.all(Radius.zero)),
                isClosed: isClosed,
              );
            }
            final ExternalRoundedCornersBorder popoverShape;
            if (targetChildContainerPositioning == null) {
              popoverShape = ExternalRoundedCornersBorder(
                borderRadius: popoverBorderRadius,
              );
            } else {
              final screenSize = MediaQuery.sizeOf(context);
              popoverShape = ExternalRoundedCornersBorder.positioned(
                borderRadius: popoverBorderRadius,
                position: targetChildContainerPositioning.toRect(),
                bounds: Rect.fromLTWH(
                  exclusiveSize.left,
                  exclusiveSize.right,
                  screenSize.width - exclusiveSize.horizontal,
                  screenSize.height - exclusiveSize.vertical,
                ),
              );
            }
            return buildContainer(
              context,
              child!,
              popoverShape,
              isClosed: isClosed,
            );
          },
        );
      },
    );
  }

  Widget buildContainer(
    BuildContext context,
    Widget child,
    ShapeBorder shape, {
    required bool isClosed,
  }) {
    return WingedContainer(
      elevation: isClosed ? 0 : 3.5,
      shadowOffset: getShadowOffset(),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: shape,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: child,
    );
  }

  Offset getShadowOffset() {
    return switch (config.side) {
      ScreenEdge.top => Offset(0.66, 1),
      ScreenEdge.bottom => Offset(0.66, -1),
      ScreenEdge.left => Offset(1, 0.66),
      ScreenEdge.right => Offset(-1, 0.66),
    };
  }
}

@Config()
mixin DrawerConfigBase on DrawerConfigI {
  static const _side = EnumField(ScreenEdge.values, defaultTo: ScreenEdge.bottom);
  late final bool isVertical = side == ScreenEdge.left || side == ScreenEdge.right;

  static Map<String, ({BlockSchema schema, dynamic Function(BlockData) from})> _getDynamicSchemaTables() =>
      featherRegistry.getDynamicFeathersSchemas();

  // TODO: 1 validate that has 1 and only 1 feather
  (String, Object) get feather => dynamicSchemas.first;

  T getFeatherInstance<T extends Feather>(String uniqueIdPrefix) {
    return getFeatherInstancesStatic<T>([feather], uniqueIdPrefix).first;
  }
}
