import "package:dartx/dartx.dart";
import "package:fl_linux_window_manager/models/screen_edge.dart";
import "package:flutter/material.dart";
import "package:motor/motor.dart";
import "package:waywing/modules/bar/bar_config.dart";
import "package:waywing/modules/bar/bar_wing.dart";
import "package:waywing/util/derived_value_notifier.dart";
import "package:waywing/util/state_positioning.dart";
import "package:waywing/widgets/motion_layout/motion_flex.dart";
import "package:waywing/widgets/motion_layout/motion_layout.dart";
import "package:waywing/widgets/motion_widgets/motion_opacity.dart";
import "package:waywing/widgets/motion_widgets/motion_positioned.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/core/config.dart";
import "package:waywing/widgets/shapes/external_rounded_corners_shape.dart";
import "package:waywing/widgets/winged_widgets/winged_container.dart";
import "package:waywing/widgets/winged_widgets/winged_popover.dart";

class Bar extends StatefulWidget {
  final BarWing wing;
  final EdgeInsets reservedSpace;

  BarConfig get config => wing.config;
  List<Feather> get startFeathers => wing.startFeathers;
  List<Feather> get centerFeathers => wing.centerFeathers;
  List<Feather> get endFeathers => wing.endFeathers;

  const Bar({
    required this.wing,
    required this.reservedSpace,
    super.key,
  });

  @override
  State<Bar> createState() => _BarState();
}

class _BarState extends State<Bar> {
  final PositioningNotifierController barPositioningController = PositioningNotifierController();

  Motion get motion => mainConfig.motions.expressive.spatial.normal;

  // TODO: 2 ANIMATION animate entrance of the bar when it is initialized
  @override
  Widget build(BuildContext context) {
    final monitorSize = MediaQuery.sizeOf(context);
    double left, top, width, height;
    if (widget.config.isVertical) {
      top = widget.config.marginTop;
      height = monitorSize.height - widget.config.marginTop - widget.config.marginBottom;
      width = widget.config.size.toDouble();
      if (widget.config.side == ScreenEdge.left) {
        left = widget.config.marginLeft;
      } else {
        left = monitorSize.width - width - widget.config.marginRight;
      }
    } else {
      left = widget.config.marginLeft;
      width = monitorSize.width - widget.config.marginLeft - widget.config.marginRight;
      height = widget.config.size.toDouble();
      if (widget.config.side == ScreenEdge.top) {
        top = widget.config.marginTop;
      } else {
        top = monitorSize.height - height - widget.config.marginBottom;
      }
    }
    left += widget.reservedSpace.left;
    top += widget.reservedSpace.top;
    if (widget.config.isVertical) {
      height -= widget.reservedSpace.vertical;
    } else {
      width -= widget.reservedSpace.horizontal;
    }

    final barShape = ExternalRoundedCornersBorder.docked(
      borderRadius: BorderRadius.all(Radius.circular(widget.config.rounding)),
      isDockedTop: widget.config.side != ScreenEdge.bottom && widget.config.marginTop == 0,
      isDockedBottom: widget.config.side != ScreenEdge.top && widget.config.marginBottom == 0,
      isDockedLeft: widget.config.side != ScreenEdge.right && widget.config.marginLeft == 0,
      isDockedRight: widget.config.side != ScreenEdge.left && widget.config.marginRight == 0,
    );
    return MotionPositioned(
      motion: motion,
      left: left,
      top: top,
      width: width,
      height: height,
      child: FocusScope(
        child: PositioningNotifierMonitor(
          controller: barPositioningController,
          child: WingedContainer(
            motion: motion,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            // TODO: 3 this is a weird hack, ideally, shadow multiplier would come for a theme that we can override
            elevation: 5 * widget.config.shadows,
            shadowOffset: getShadowOffset(),
            shape: barShape,
            child: Theme(
              data: Theme.of(context).copyWith(
                buttonTheme: Theme.of(context).buttonTheme.copyWith(
                  padding: EdgeInsets.symmetric(
                    horizontal: !widget.config.isVertical ? widget.config.indicatorPadding : 0,
                    vertical: widget.config.isVertical ? widget.config.indicatorPadding : 0,
                  ),
                ),
              ),
              child: ValueListenableBuilder(
                valueListenable: widget.wing.allFeathersInitialized,
                builder: (context, allFeathersInitialized, _) {
                  return ValueListenableBuilder(
                    valueListenable: DerivedValueNotifier(
                      dependencies: allFeathersInitialized.map((e) => e.item.components).toList(),
                      derive: () => allFeathersInitialized
                          .map((e) {
                            return e.item.components.value.where((c) => c.buildIndicators != null).mapIndexed((i, c) {
                              return BarPositionedItem(
                                c,
                                e.position,
                                c.uniqueIdentifier == null ? "${e.item.uniqueId} - $i" : null,
                              );
                            });
                          })
                          .flatten()
                          .toList(),
                    ),
                    builder: (context, allComponentsInitialized, _) {
                      return ValueListenableBuilder(
                        valueListenable: DerivedValueNotifier(
                          dependencies: allComponentsInitialized.map((e) => e.item.isIndicatorsEnabled).toList(),
                          derive: () => allComponentsInitialized
                              .where((e) => e.item.isIndicatorsEnabled.value && e.item.buildIndicators != null)
                              .toList(),
                        ),
                        builder: (context, allComponentsInitializedAndEnabled, _) {
                          return MotionLayout(
                            motion: motion,
                            data: allComponentsInitializedAndEnabled,
                            animateIndexChanges: true,
                            itemBuilder: (context, component) {
                              return buildPopover(
                                context: context,
                                component: component.item,
                                barShape: barShape,
                                builder: (context, popover) {
                                  final indicators = component.item.buildIndicators!(context, popover);
                                  return Flex(
                                    direction: widget.config.isVertical ? Axis.vertical : Axis.horizontal,
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: indicators,
                                  );
                                },
                              );
                            },
                            layoutBuilder: (context, children, data) {
                              final direction = widget.config.isVertical ? Axis.vertical : Axis.horizontal;
                              final startScrollController = ScrollController();
                              final endScrollController = ScrollController();
                              final List<Widget> startWidgets = [], centerWidgets = [], endWidgets = [];
                              for (int i = 0; i < children.length; i++) {
                                switch (data[i].position) {
                                  case BarPosition.start:
                                    startWidgets.add(children[i]);
                                  case BarPosition.center:
                                    centerWidgets.add(children[i]);
                                  case BarPosition.end:
                                    endWidgets.add(children[i]);
                                }
                              }
                              final padding = EdgeInsets.symmetric(
                                horizontal: !widget.config.isVertical ? widget.config.size * 0.2 : 0,
                                vertical: widget.config.isVertical ? widget.config.size * 0.2 : 0,
                              );
                              return Flex(
                                direction: direction,
                                children: [
                                  Expanded(
                                    child: Scrollbar(
                                      controller: startScrollController,
                                      child: SingleChildScrollView(
                                        controller: startScrollController,
                                        scrollDirection: direction,
                                        child: Padding(
                                          padding: padding,
                                          child: Flex(
                                            direction: direction,
                                            mainAxisSize: MainAxisSize.min,
                                            children: startWidgets,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: padding,
                                    child: Flex(
                                      direction: direction,
                                      mainAxisSize: MainAxisSize.min,
                                      children: centerWidgets,
                                    ),
                                  ),
                                  Expanded(
                                    child: Scrollbar(
                                      controller: endScrollController,
                                      child: SingleChildScrollView(
                                        controller: endScrollController,
                                        scrollDirection: direction,
                                        reverse: true,
                                        child: Padding(
                                          padding: padding,
                                          child: Flex(
                                            direction: direction,
                                            mainAxisSize: MainAxisSize.min,
                                            children: endWidgets,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                            transitionBuilder: MotionFlex(
                              data: const [],
                              itemBuilder: (_, _) => SizedBox.shrink(),
                              motion: motion,
                              direction: widget.config.isVertical ? Axis.vertical : Axis.horizontal,
                            ).defaultTransitionBuilder,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPopover({
    required BuildContext context,
    required FeatherComponent component,
    required PopoverBuilder builder,
    required ExternalRoundedCornersBorder barShape,
  }) {
    if (component.buildPopover == null && component.buildTooltip == null) {
      return builder(context, null);
    }
    final popoverAlignment = switch (widget.config.side) {
      ScreenEdge.top => Alignment.bottomCenter,
      ScreenEdge.right => Alignment.centerLeft,
      ScreenEdge.bottom => Alignment.topCenter,
      ScreenEdge.left => Alignment.centerRight,
    };
    final overflowAlignment = switch (widget.config.side) {
      ScreenEdge.top => Alignment.topCenter,
      ScreenEdge.right => Alignment.centerRight,
      ScreenEdge.bottom => Alignment.bottomCenter,
      ScreenEdge.left => Alignment.centerLeft,
    };
    final tooltipShape = ExternalRoundedCornersBorder(
      borderRadius: BorderRadius.all(Radius.circular(mainConfig.theme.containerRounding)),
    );
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(mainConfig.theme.buttonRounding)),
    );
    // TODO: 2 we should probably listen to this, or have PopoverProvider receive the listenable and listen to it
    final screenPadding = mainConfig.exclusiveSize.value;
    // // this limits the popovers to have the same margin as the Bar. This was necessary with
    // // the old Shapes model because it didn't support going over. Now it is not necessary, but
    // // maybe it can still be optional??
    // screenPadding: EdgeInsets.only(
    //   left: widget.config.isVertical ? 0 : widget.config.marginLeft + widget.config.radiusInMain,
    //   right: widget.config.isVertical ? 0 : widget.config.marginRight + widget.config.radiusInMain,
    //   top: !widget.config.isVertical ? 0 : widget.config.marginTop + widget.config.radiusInMain,
    //   bottom: !widget.config.isVertical ? 0 : widget.config.marginBottom + widget.config.radiusInMain,
    // ),
    return ValueListenableBuilder(
      valueListenable: component.isPopoverEnabled,
      builder: (context, isPopoverEnabled, _) {
        return ValueListenableBuilder(
          valueListenable: component.isTooltipEnabled,
          builder: (context, isTooltipEnabled, _) {
            return WingedPopover(
              builder: (context, controller, _) => builder(context, controller),
              extraClientClippers: [(barShape, barPositioningController.positioningNotifier)],
              popoverParams: component.buildPopover == null
                  ? null
                  : PopoverParams(
                      enabled: isPopoverEnabled,
                      containerId: "${widget.wing.uniqueId}.Popover",
                      motion: motion,
                      // TODO: 3 briefly document how zIndex is used and what the default values are for Bar and other core widgets
                      zIndex: -10,
                      popupAlignment: popoverAlignment,
                      anchorAlignment: popoverAlignment,
                      overflowAlignment: overflowAlignment,
                      screenPadding: screenPadding,
                      stickToHost: true,
                      builder: (context, controller, _, targetChildContainerPositioning) {
                        return ValueListenableBuilder(
                          valueListenable: controller.hostState.sizeNotifier,
                          child: component.buildPopover!(context),
                          builder: (context, hostSize, child) {
                            return ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: !widget.config.isVertical ? hostSize?.height ?? 0 : 0,
                                minHeight: widget.config.isVertical ? hostSize?.width ?? 0 : 0,
                              ),
                              child: child,
                            );
                          },
                        );
                      },
                      containerBuilder: (context, child, _, _, targetChildContainerPositioning) {
                        return buildPopoverContainer(
                          context,
                          child,
                          buttonShape,
                          targetChildContainerPositioning,
                          isClosed: false,
                          barShape: barShape,
                        );
                      },
                      closedContainerBuilder: (context, child, _, _, targetChildContainerPositioning) {
                        return buildPopoverContainer(
                          context,
                          child,
                          buttonShape,
                          targetChildContainerPositioning,
                          isClosed: true,
                          barShape: barShape,
                        );
                      },
                    ),
              tooltipParams: component.buildTooltip == null
                  ? null
                  : TooltipParams(
                      enabled: isTooltipEnabled,
                      containerId: "${widget.wing.uniqueId}.Tooltip",
                      motion: motion,
                      // TODO: 3 briefly document how zIndex is used and what the default values are for Bar and other core widgets
                      zIndex: -5,
                      popupAlignment: popoverAlignment,
                      anchorAlignment: popoverAlignment,
                      overflowAlignment: overflowAlignment,
                      screenPadding: screenPadding,
                      extraPadding: EdgeInsets.only(
                        top: widget.config.side == ScreenEdge.top ? widget.config.size / 2 : 0,
                        bottom: widget.config.side == ScreenEdge.bottom ? widget.config.size / 2 : 0,
                        left: widget.config.side == ScreenEdge.left ? widget.config.size / 2 : 0,
                        right: widget.config.side == ScreenEdge.right ? widget.config.size / 2 : 0,
                      ),
                      builder: (context, controller, _, _) {
                        return ValueListenableBuilder(
                          valueListenable: controller.hostState.sizeNotifier,
                          child: component.buildTooltip!(context),
                          builder: (context, hostSize, child) {
                            return ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: !widget.config.isVertical ? hostSize?.height ?? 0 : 0,
                                minHeight: widget.config.isVertical ? hostSize?.width ?? 0 : 0,
                              ),
                              child: child,
                            );
                          },
                        );
                      },
                      containerBuilder: (context, child, _, _, _) {
                        return MotionOpacity(
                          motion: motion,
                          opacity: 1,
                          child: buildContainer(context, child, tooltipShape, isTooltip: true, isClosed: false),
                        );
                      },
                      closedContainerBuilder: (context, child, _, _, _) {
                        return MotionOpacity(
                          motion: motion,
                          opacity: 0,
                          child: buildContainer(context, child, buttonShape, isTooltip: true, isClosed: true),
                        );
                      },
                    ),
            );
          },
        );
      },
    );
  }

  Widget buildPopoverContainer(
    BuildContext context,
    Widget child,
    ShapeBorder buttonShape,
    ValueNotifier<Positioning?> targetChildContainerPositioning, {
    required ExternalRoundedCornersBorder barShape,
    required isClosed,
  }) {
    final popoverBorderRadius = BorderRadius.all(Radius.circular(mainConfig.theme.containerRounding));
    return ValueListenableBuilder(
      valueListenable: barPositioningController.positioningNotifier,
      child: child,
      builder: (context, barPositioning, child) {
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
                    buttonShape,
                    isTooltip: false,
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
                  final barInnerPadding = barShape.innerDimensions;
                  popoverShape = ExternalRoundedCornersBorder.positioned(
                    borderRadius: popoverBorderRadius,
                    position: targetChildContainerPositioning.toRect(),
                    bounds: Rect.fromLTWH(
                      exclusiveSize.left,
                      exclusiveSize.right,
                      screenSize.width - exclusiveSize.horizontal,
                      screenSize.height - exclusiveSize.vertical,
                    ),
                    parentContainers: [
                      if (barPositioning != null)
                        Rect.fromLTWH(
                          barPositioning.offset.dx + barInnerPadding.left,
                          barPositioning.offset.dy,
                          barPositioning.size.width - barInnerPadding.horizontal,
                          barPositioning.size.height,
                        ),
                      if (barPositioning != null)
                        Rect.fromLTWH(
                          barPositioning.offset.dx,
                          barPositioning.offset.dy + barInnerPadding.top,
                          barPositioning.size.width,
                          barPositioning.size.height - barInnerPadding.vertical,
                        ),
                    ],
                  );
                }
                return buildContainer(
                  context,
                  child!,
                  popoverShape,
                  isTooltip: false,
                  isClosed: isClosed,
                );
              },
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
    required isTooltip,
    required isClosed,
  }) {
    return WingedContainer(
      // default to mainConfig.motions.expressive.spatial.slow.multiplySpeed(0.2), doesn't matter if it's different
      // motion: motion,
      elevation: isClosed ? 0 : 3.5,
      shadowOffset: getShadowOffset(),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: shape,
      color: isTooltip
          ? Theme.of(context).colorScheme.surfaceContainerLow
          : Theme.of(context).colorScheme.surfaceContainerLowest,
      child: child,
    );
  }

  Offset getShadowOffset() {
    return switch (widget.config.side) {
      ScreenEdge.top => Offset(0.66, 1),
      ScreenEdge.bottom => Offset(0.66, -1),
      ScreenEdge.left => Offset(1, 0.66),
      ScreenEdge.right => Offset(-1, 0.66),
    };
  }
}

typedef PopoverBuilder = Widget Function(BuildContext context, WingedPopoverController? controller);
