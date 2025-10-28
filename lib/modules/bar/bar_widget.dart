import "package:dartx/dartx.dart";
import "package:fl_linux_window_manager/models/screen_edge.dart";
import "package:fl_linux_window_manager/widgets/input_region.dart";
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
import "package:waywing/widgets/winged_widgets/winged_popover_provider.dart";

class BarSwitcher extends StatefulWidget {
  final BarWing wing;
  final EdgeInsets reservedSpace;
  const BarSwitcher({
    required this.wing,
    required this.reservedSpace,
    super.key,
  });

  @override
  State<BarSwitcher> createState() => _BarSwitcherState();
}

class _BarSwitcherState extends State<BarSwitcher> {
  late BarConfig config;
  BarConfig? animatingFrom;
  @override
  void initState() {
    super.initState();
    config = widget.wing.config;
    animatingFrom = widget.wing.config;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        animatingFrom = null;
      });
    });
  }

  @override
  void didUpdateWidget(covariant BarSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.wing.config.containerType != config.containerType) {
      animatingFrom = config;
    }
    config = widget.wing.config;
  }

  @override
  Widget build(BuildContext context) {
    return Bar(
      wing: widget.wing,
      reservedSpace: widget.reservedSpace,
      isHidden: animatingFrom != null,
      config: animatingFrom ?? widget.wing.config,
      onPositionAnimationStatusChanged: (status) {
        if (!status.isAnimating && animatingFrom != null) {
          setState(() {
            animatingFrom = null;
          });
        }
      },
    );
  }
}

class Bar extends StatefulWidget {
  final BarWing wing;
  final EdgeInsets reservedSpace;
  final bool isHidden;

  final BarConfig config;
  final AnimationStatusListener? onPositionAnimationStatusChanged;

  List<Feather> get startFeathers => wing.startFeathers;
  List<Feather> get centerFeathers => wing.centerFeathers;
  List<Feather> get endFeathers => wing.endFeathers;

  const Bar({
    required this.wing,
    required this.reservedSpace,
    required this.isHidden,
    required this.config,
    this.onPositionAnimationStatusChanged,
    super.key,
  });

  @override
  State<Bar> createState() => _BarState();
}

class _BarState extends State<Bar> {
  Motion get motion => mainConfig.motions.expressive.spatial.normal;

  late final Map<String, (ExternalRoundedCornersBorder, PositioningNotifierController)> builtContainers = {};

  late final fullBarContainerId = "${widget.wing.uniqueId}.--FullBar--";
  late final barStartContainerId = "${widget.wing.uniqueId}.--BarStart--";
  late final barCenterContainerId = "${widget.wing.uniqueId}.--BarCenter--";
  late final barEndContainerId = "${widget.wing.uniqueId}.--BarEnd--";

  (ExternalRoundedCornersBorder, PositioningNotifierController)? get fullBarContainer =>
      builtContainers[fullBarContainerId];
  (ExternalRoundedCornersBorder, PositioningNotifierController)? get barStartContainer =>
      builtContainers[barStartContainerId];
  (ExternalRoundedCornersBorder, PositioningNotifierController)? get barCenterContainer =>
      builtContainers[barCenterContainerId];
  (ExternalRoundedCornersBorder, PositioningNotifierController)? get barEndContainer =>
      builtContainers[barEndContainerId];

  List<(ExternalRoundedCornersBorder, PositioningNotifierController)> get containers {
    return switch (widget.config.containerType) {
      BarContainerType.full => [fullBarContainer].whereNotNull().toList(),
      BarContainerType.section => [barStartContainer, barCenterContainer, barEndContainer].whereNotNull().toList(),
      BarContainerType.none => [],
      BarContainerType.button =>
        builtContainers.entries
            .where(
              (e) =>
                  e.key != fullBarContainerId &&
                  e.key != barStartContainerId &&
                  e.key != barCenterContainerId &&
                  e.key != barEndContainerId,
            )
            .map((e) => e.value)
            .toList(),
    };
  }

  @override
  void didUpdateWidget(covariant Bar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.config.containerType != oldWidget.config.containerType) {
      builtContainers.clear();
    }
  }

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
        if (widget.isHidden) {
          left = -(width + mainConfig.theme.inactiveBorderSize + mainConfig.theme.shadows * 5);
        } else {
          left = widget.config.marginLeft;
        }
      } else {
        if (widget.isHidden) {
          left = monitorSize.width + mainConfig.theme.inactiveBorderSize + mainConfig.theme.shadows * 5;
        } else {
          left = monitorSize.width - width - widget.config.marginRight;
        }
      }
    } else {
      left = widget.config.marginLeft;
      width = monitorSize.width - widget.config.marginLeft - widget.config.marginRight;
      height = widget.config.size.toDouble();
      if (widget.config.side == ScreenEdge.top) {
        if (widget.isHidden) {
          top = -(height + mainConfig.theme.inactiveBorderSize + mainConfig.theme.shadows * 5);
        } else {
          top = widget.config.marginTop;
        }
      } else {
        if (widget.isHidden) {
          top = monitorSize.height + mainConfig.theme.inactiveBorderSize + mainConfig.theme.shadows * 5;
        } else {
          top = monitorSize.height - height - widget.config.marginBottom;
        }
      }
    }
    left += widget.reservedSpace.left;
    top += widget.reservedSpace.top;
    if (widget.config.isVertical) {
      height -= widget.reservedSpace.vertical;
    } else {
      width -= widget.reservedSpace.horizontal;
    }

    Widget result = Theme(
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
                        uniqueId: component.extraId ?? component.item.uniqueIdentifier!,
                        // isDockedStart:
                        //     component.position == BarPosition.start &&
                        //     component == allComponentsInitializedAndEnabled.first,
                        // isDockedEnd:
                        //     component.position == BarPosition.end &&
                        //     component == allComponentsInitializedAndEnabled.last,
                        containerGetter:
                            widget.config.containerType == BarContainerType.full ||
                                widget.config.containerType == BarContainerType.section
                            ? () => switch (widget.config.containerType) {
                                BarContainerType.full => fullBarContainer,
                                BarContainerType.section => switch (component.position) {
                                  BarPosition.start => barStartContainer,
                                  BarPosition.center => barCenterContainer,
                                  BarPosition.end => barEndContainer,
                                },
                                _ => null,
                              }
                            : null,
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
                      Widget startWidget, centerWidget, endWidget;
                      if (startWidgets.isNotEmpty) {
                        startWidget = Padding(
                          padding: padding,
                          child: Flex(
                            direction: direction,
                            mainAxisSize: MainAxisSize.min,
                            children: startWidgets,
                          ),
                        );
                        if (widget.config.containerType == BarContainerType.section) {
                          startWidget = buildBarContainer(
                            context: context,
                            id: barStartContainerId,
                            child: startWidget,
                            isDockedEnd: false,
                          );
                        }
                        startWidget = Expanded(
                          child: Scrollbar(
                            controller: startScrollController,
                            child: SingleChildScrollView(
                              controller: startScrollController,
                              scrollDirection: direction,
                              child: startWidget,
                            ),
                          ),
                        );
                      } else {
                        startWidget = Expanded(child: SizedBox.shrink());
                      }
                      if (centerWidgets.isNotEmpty) {
                        centerWidget = Padding(
                          padding: padding,
                          child: Flex(
                            direction: direction,
                            mainAxisSize: MainAxisSize.min,
                            children: centerWidgets,
                          ),
                        );
                        if (widget.config.containerType == BarContainerType.section) {
                          centerWidget = buildBarContainer(
                            context: context,
                            id: barCenterContainerId,
                            child: centerWidget,
                            isDockedStart: false,
                            isDockedEnd: false,
                          );
                        }
                      } else {
                        centerWidget = SizedBox.shrink();
                      }
                      if (endWidgets.isNotEmpty) {
                        endWidget = Padding(
                          padding: padding,
                          child: Flex(
                            direction: direction,
                            mainAxisSize: MainAxisSize.min,
                            children: endWidgets,
                          ),
                        );
                        if (widget.config.containerType == BarContainerType.section) {
                          endWidget = buildBarContainer(
                            context: context,
                            id: barEndContainerId,
                            child: endWidget,
                            isDockedStart: false,
                          );
                        }
                        endWidget = Expanded(
                          child: Scrollbar(
                            controller: endScrollController,
                            child: SingleChildScrollView(
                              controller: endScrollController,
                              scrollDirection: direction,
                              reverse: true,
                              child: endWidget,
                            ),
                          ),
                        );
                      } else {
                        endWidget = Expanded(child: SizedBox.shrink());
                      }
                      return Flex(
                        direction: direction,
                        children: [
                          startWidget,
                          centerWidget,
                          endWidget,
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
    );
    if (widget.config.containerType == BarContainerType.full) {
      result = buildBarContainer(context: context, id: fullBarContainerId, child: result);
    }

    return MotionPositioned(
      motion: motion,
      left: left,
      top: top,
      width: width,
      height: height,
      onAnimationStatusChanged: widget.onPositionAnimationStatusChanged,
      child: FocusScope(
        child: result,
      ),
    );
  }

  Widget buildBarContainer({
    required BuildContext context,
    required String id,
    required Widget child,
    bool isDockedStart = true,
    bool isDockedEnd = true,
    bool isDockedSide = true,
  }) {
    final shape = ExternalRoundedCornersBorder.docked(
      borderRadius: BorderRadius.all(Radius.circular(widget.config.rounding)),
      isDockedTop:
          (widget.config.isVertical ? isDockedStart : isDockedSide) &&
          widget.config.side != ScreenEdge.bottom &&
          widget.config.marginTop == 0,
      isDockedBottom:
          (widget.config.isVertical ? isDockedEnd : isDockedSide) &&
          widget.config.side != ScreenEdge.top &&
          widget.config.marginBottom == 0,
      isDockedLeft:
          (widget.config.isVertical ? isDockedSide : isDockedStart) &&
          widget.config.side != ScreenEdge.right &&
          widget.config.marginLeft == 0,
      isDockedRight:
          (widget.config.isVertical ? isDockedSide : isDockedEnd) &&
          widget.config.side != ScreenEdge.left &&
          widget.config.marginRight == 0,
    );
    final controller = PositioningNotifierController();
    builtContainers[id] = (shape, controller);
    return PositioningNotifierMonitor(
      controller: controller,
      child: WingedContainer(
        motion: motion,
        // TODO: 3 this is a weird hack, ideally, shadow multiplier would come from a theme that we can override
        elevation: 5 * widget.config.shadows,
        shadowOffset: getShadowOffset(),
        shape: shape,
        clipBehavior: Clip.hardEdge,
        child: child,
      ),
    );
  }

  Widget buildPopover({
    required BuildContext context,
    required String uniqueId,
    required FeatherComponent component,
    required PopoverBuilder builder,
    required ContainerDataGetter? containerGetter,
    // required bool isDockedStart,
    // required bool isDockedEnd,
  }) {
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(mainConfig.theme.buttonRounding)),
    );
    Widget result;
    if (component.buildPopover == null && component.buildTooltip == null) {
      result = builder(context, null);
    } else {
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
      // TODO: 2 we should probably listen to this, or have PopoverProvider receive the listenable and listen to it
      final screenPadding = mainConfig.exclusiveSize.value;
      // // this limits the popovers to have the same margin as the Bar. This was necessary with
      // // the old Shapes model because it didn't support going over. Now it is not necessary, but
      // // maybe it can still be optional??
      // screenPadding = EdgeInsets.only(
      //   left: widget.config.isVertical ? 0 : widget.config.marginLeft + widget.config.radiusInMain,
      //   right: widget.config.isVertical ? 0 : widget.config.marginRight + widget.config.radiusInMain,
      //   top: !widget.config.isVertical ? 0 : widget.config.marginTop + widget.config.radiusInMain,
      //   bottom: !widget.config.isVertical ? 0 : widget.config.marginBottom + widget.config.radiusInMain,
      // ),
      result = ValueListenableBuilder(
        valueListenable: component.isPopoverEnabled,
        builder: (context, isPopoverEnabled, _) {
          return ValueListenableBuilder(
            valueListenable: component.isTooltipEnabled,
            builder: (context, isTooltipEnabled, _) {
              return WingedPopover(
                builder: (context, controller, _) => builder(context, controller),
                extraClientClipperBuilder:
                    mainConfig.theme.backgroundOpacity >= 1 || widget.config.containerType == BarContainerType.none
                    ? null
                    : (context, {required child}) {
                        return buildDefaultContainerClipper(
                          context,
                          child: child,
                          containers: containers.map((e) => (e.$1, e.$2.positioningNotifier)).toList(),
                        );
                      },
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
                        extraPadding: EdgeInsets.only(
                          left: widget.config.side == ScreenEdge.left ? mainConfig.theme.inactiveBorderSize : 0,
                          right: widget.config.side == ScreenEdge.right ? mainConfig.theme.inactiveBorderSize : 0,
                          top: widget.config.side == ScreenEdge.top ? mainConfig.theme.inactiveBorderSize : 0,
                          bottom: widget.config.side == ScreenEdge.bottom ? mainConfig.theme.inactiveBorderSize : 0,
                        ),
                        builder: (context, controller, _, targetChildContainerPositioning) {
                          return ValueListenableBuilder(
                            valueListenable: controller.hostState.sizeNotifier,
                            child: component.buildPopover!(context),
                            builder: (context, hostSize, child) {
                              return ConstrainedBox(
                                constraints: BoxConstraints(
                                  // minWidth: !widget.config.isVertical ? hostSize?.width ?? 0 : 0,
                                  // minHeight: widget.config.isVertical ? hostSize?.height ?? 0 : 0,
                                  minWidth: !widget.config.isVertical ? widget.config.indicatorMinSize : 0,
                                  minHeight: widget.config.isVertical ? widget.config.indicatorMinSize : 0,
                                ),
                                child: child,
                              );
                            },
                          );
                        },
                        containerBuilder: (context, child, _, _, targetChildContainerPositioning) {
                          Widget result = buildPopoverContainer(
                            context,
                            child,
                            buttonShape,
                            targetChildContainerPositioning,
                            isClosed: false,
                            containerGetter: containerGetter ?? () => builtContainers["$uniqueId.--BarContainer--"],
                          );
                          if (widget.config.containerType == BarContainerType.none) {
                            result = MotionOpacity(
                              motion: motion,
                              opacity: 1,
                              child: result,
                            );
                          }
                          return result;
                        },
                        closedContainerBuilder: (context, child, _, _, targetChildContainerPositioning) {
                          Widget result = buildPopoverContainer(
                            context,
                            child,
                            buttonShape,
                            targetChildContainerPositioning,
                            isClosed: true,
                            containerGetter: containerGetter ?? () => builtContainers["$uniqueId.--BarContainer--"],
                          );
                          if (widget.config.containerType == BarContainerType.none) {
                            result = MotionOpacity(
                              motion: motion,
                              opacity: 0,
                              child: result,
                            );
                          }
                          return result;
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
                                  // minWidth: !widget.config.isVertical ? hostSize?.width ?? 0 : 0,
                                  // minHeight: widget.config.isVertical ? hostSize?.height ?? 0 : 0,
                                  minWidth: !widget.config.isVertical ? widget.config.indicatorMinSize : 0,
                                  minHeight: widget.config.isVertical ? widget.config.indicatorMinSize : 0,
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

    if (widget.config.containerType == BarContainerType.button && component.wantsContainer) {
      result = Padding(
        padding: widget.config.isVertical
            ? EdgeInsets.symmetric(vertical: widget.config.indicatorPadding / 2)
            : EdgeInsets.symmetric(horizontal: widget.config.indicatorPadding / 2),
        child: buildBarContainer(
          context: context,
          id: "$uniqueId.--BarContainer--",
          child: result,
          isDockedStart: false,
          isDockedEnd: false,
          isDockedSide: false,
        ),
      );
    } else if (widget.config.containerType == BarContainerType.none) {
      result = InputRegion(
        child: Material(
          type: MaterialType.transparency,
          shape: buttonShape,
          clipBehavior: Clip.hardEdge,
          child: result,
        ),
      );
    }

    return result;
  }

  Widget buildPopoverContainer(
    BuildContext context,
    Widget child,
    ShapeBorder buttonShape,
    ValueNotifier<Positioning?> targetChildContainerPositioning, {
    required ContainerDataGetter containerGetter,
    required isClosed,
  }) {
    final container = containerGetter();
    final popoverBorderRadius = BorderRadius.all(Radius.circular(mainConfig.theme.containerRounding));
    return ValueListenableBuilder<Positioning?>(
      valueListenable: container?.$2.positioningNotifier ?? DummyValueNotifier(null),
      child: child,
      builder: (context, containerPositioning, child) {
        return ValueListenableBuilder(
          valueListenable: targetChildContainerPositioning,
          child: child,
          builder: (context, targetChildContainerPositioning, child) {
            return ValueListenableBuilder(
              valueListenable: mainConfig.exclusiveSize,
              child: child,
              builder: (context, mainExclusiveSize, child) {
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
                  final barInnerPadding = container?.$1.innerDimensions ?? EdgeInsets.zero;
                  popoverShape = ExternalRoundedCornersBorder.positioned(
                    borderRadius: popoverBorderRadius,
                    position: targetChildContainerPositioning.toRect(),
                    bounds: Rect.fromLTWH(
                      widget.config.side == ScreenEdge.left ? widget.reservedSpace.left : mainExclusiveSize.left,
                      widget.config.side == ScreenEdge.top ? widget.reservedSpace.top : mainExclusiveSize.top,
                      screenSize.width -
                          (widget.config.side == ScreenEdge.right
                              ? (widget.reservedSpace.right + mainExclusiveSize.left)
                              : mainExclusiveSize.horizontal),
                      screenSize.height -
                          (widget.config.side == ScreenEdge.bottom
                              ? (widget.reservedSpace.bottom + mainExclusiveSize.top)
                              : mainExclusiveSize.vertical),
                    ),
                    parentContainers: [
                      if (containerPositioning != null)
                        Rect.fromLTWH(
                          containerPositioning.offset.dx + barInnerPadding.left,
                          containerPositioning.offset.dy -
                              (widget.config.side == ScreenEdge.bottom ? mainConfig.theme.inactiveBorderSize : 0),
                          containerPositioning.size.width - barInnerPadding.horizontal,
                          containerPositioning.size.height +
                              (widget.config.side == ScreenEdge.top ? mainConfig.theme.inactiveBorderSize : 0),
                        ),
                      if (containerPositioning != null)
                        Rect.fromLTWH(
                          containerPositioning.offset.dx -
                              (widget.config.side == ScreenEdge.right ? mainConfig.theme.inactiveBorderSize : 0),
                          containerPositioning.offset.dy + barInnerPadding.top,
                          containerPositioning.size.width +
                              (widget.config.side == ScreenEdge.left ? mainConfig.theme.inactiveBorderSize : 0),
                          containerPositioning.size.height - barInnerPadding.vertical,
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
      clipBehavior: Clip.hardEdge,
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

typedef ContainerData = (ExternalRoundedCornersBorder, PositioningNotifierController);
typedef ContainerDataGetter = ContainerData? Function();
