import "dart:math";

import "package:dartx/dartx_io.dart";
import "package:fl_linux_window_manager/models/screen_edge.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:motor/motor.dart";
import "package:tronco/tronco.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/modules/bar/bar_config.dart";
import "package:waywing/util/state_positioning.dart";
import "package:waywing/widgets/motion_widgets/motion_align.dart";
import "package:waywing/widgets/motion_widgets/motion_container.dart";
import "package:waywing/widgets/motion_widgets/motion_opacity.dart";
import "package:waywing/widgets/shapes/docked_rounded_corners_shape.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/core/config.dart";
import "package:waywing/widgets/winged_widgets/winged_container.dart";
import "package:waywing/widgets/winged_widgets/winged_popover.dart";

class Bar extends StatefulWidget {
  final BarConfig config;
  // TODO: 2 there should never be a need to log in the widgets, it's probably
  // a skill issue that can be validated before getting here
  final Logger logger;

  const Bar({
    required this.config,
    required this.logger,
    super.key,
  });

  @override
  State<Bar> createState() => _BarState();
}

class _BarState extends State<Bar> {
  // adding global keys to feathers ensures their state
  // won't be lost when reloading config, including popover and tooltip state
  Map<String, List<GlobalKey>> featherGlobalKeys = {};
  final PositioningNotifierController barPositioningController = PositioningNotifierController();

  // TODO: 2 ANIMATION animate entrance of the bar when it is initialized
  @override
  Widget build(BuildContext context) {
    // For our calculations on high scale screens, devicePixelRatio needs to be
    // applied only to the sides that span the full screen.
    // For bar crossAxis, since it is unbound, the compositor will give it more
    // physical space so we can use the same amount of DIP (at least in hyprland).
    // For sides that span the full monitor (like bar mainAxis), we actually have
    // less physical space now, so we need to asjust our DIP amounts or it will
    // overflow the screen (because the same amount of DIP now translates to more
    // physical pixels). For scale < 1 it should also work with the same logic.
    final originalMonitorSize = PlatformDispatcher.instance.views.first.display.size;
    final monitorSize = MediaQuery.sizeOf(context);
    // Get actual devicePixelRatio (scale) by comparing the original monitor size to the current one.
    // The devicePixelRatio reported by flutter is different for some reason.
    final devicePixelRatio = originalMonitorSize.width / monitorSize.width;
    final barCrossSize = widget.config.size.toDouble();
    final outerRoundedEdgeMainSize = widget.config.radiusOutMain;
    double? width, height, top, bottom, left, right;
    Alignment barAlignment, startAlignment, endAlignment;
    if (widget.config.isVertical) {
      startAlignment = Alignment.topCenter;
      endAlignment = Alignment.bottomCenter;
      width = barCrossSize;
      top = widget.config.marginTop / devicePixelRatio - outerRoundedEdgeMainSize;
      bottom = widget.config.marginBottom / devicePixelRatio - outerRoundedEdgeMainSize;
      // don't allow setting an anchor to the opossite of dockSide, doing this would break the Stack widget
      if (widget.config.side == ScreenEdge.left) {
        barAlignment = Alignment.centerLeft;
        left = 0; // config.barMarginLeft;
      } else {
        barAlignment = Alignment.centerRight;
        right = 0; // config.barMarginRight;
      }
    } else {
      startAlignment = Alignment.centerLeft;
      endAlignment = Alignment.centerRight;
      height = barCrossSize;
      left = widget.config.marginLeft / devicePixelRatio - outerRoundedEdgeMainSize;
      right = widget.config.marginRight / devicePixelRatio - outerRoundedEdgeMainSize;
      // don't allow setting an anchor to the opossite of dockSide, doing this would break the Stack widget
      if (widget.config.side == ScreenEdge.top) {
        barAlignment = Alignment.topCenter;
        top = 0; // config.barMarginTop;
      } else {
        barAlignment = Alignment.bottomCenter;
        bottom = 0; // config.barMarginBottom;
      }
    }

    final shape = DockedRoundedCornersBorder(
      dockedSide: widget.config.side,
      radiusInCross: widget.config.radiusInCross,
      radiusInMain: widget.config.radiusInMain,
      radiusOutCross: widget.config.radiusOutCross,
      radiusOutMain: widget.config.radiusOutMain,
      isVertical: widget.config.isVertical,
    );
    Map<String, int> feathersCount = {};
    return Positioned.fill(
      child: MotionAlign(
        motion: motion,
        alignment: barAlignment,
        child: MotionContainer(
          motion: motion,
          width: width ?? monitorSize.width,
          height: height ?? monitorSize.height,
          padding: EdgeInsets.only(
            top: top?.coerceAtLeast(0) ?? 0,
            bottom: bottom?.coerceAtLeast(0) ?? 0,
            left: left?.coerceAtLeast(0) ?? 0,
            right: right?.coerceAtLeast(0) ?? 0,
          ),
          child: FocusScope(
            child: PositioningNotifierMonitor(
              controller: barPositioningController,
              child: WingedContainer(
                // animationDuration: config.animationDuration * 1.5,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                elevation: 5,
                shadowOffset: getShadowOffset(),
                shape: shape,
                // TODO: 1 implement a proper layout that handles gracefully when widgets overflow
                // this should also solve the issue of widgets being disposed when switching vertical
                // to horizontal bar (or viceversa) because we switched Row / Column
                child: Padding(
                  padding: shape.dimensions,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      buttonTheme: Theme.of(context).buttonTheme.copyWith(
                        padding: EdgeInsets.symmetric(
                          horizontal: !widget.config.isVertical ? widget.config.indicatorPadding : 0,
                          vertical: widget.config.isVertical ? widget.config.indicatorPadding : 0,
                        ),
                      ),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      fit: StackFit.expand,
                      children: [
                        Container(
                          alignment: endAlignment,
                          padding: EdgeInsets.only(
                            right: !widget.config.isVertical ? widget.config.size * 0.2 : 0,
                            bottom: widget.config.isVertical ? widget.config.size * 0.2 : 0,
                          ),
                          child: buildLayoutWidget(
                            context,
                            buildFeatherWidgets(
                              context: context,
                              feathers: widget.config.endFeathers,
                              feathersCount: feathersCount,
                              barShape: shape,
                            ),
                          ),
                        ),

                        Align(
                          alignment: Alignment.center,
                          child: buildLayoutWidget(
                            context,
                            buildFeatherWidgets(
                              context: context,
                              feathers: widget.config.centerFeathers,
                              feathersCount: feathersCount,
                              barShape: shape,
                            ),
                          ),
                        ),

                        Container(
                          alignment: startAlignment,
                          padding: EdgeInsets.only(
                            left: !widget.config.isVertical ? widget.config.size * 0.2 : 0,
                            top: widget.config.isVertical ? widget.config.size * 0.2 : 0,
                          ),
                          child: buildLayoutWidget(
                            context,
                            buildFeatherWidgets(
                              context: context,
                              feathers: widget.config.startFeathers,
                              feathersCount: feathersCount,
                              barShape: shape,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLayoutWidget(BuildContext context, List<Widget> children) {
    // TODO: 1 add animations to bar components layout
    if (widget.config.isVertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: widget.config.spacing,
        children: children,
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: widget.config.spacing,
        children: children,
      );
    }
  }

  List<Widget> buildFeatherWidgets({
    required BuildContext context,
    required List<Feather> feathers,
    required Map<String, int> feathersCount,
    required ShapeBorder barShape,
  }) {
    final result = <Widget>[];
    for (final feather in feathers) {
      result.add(
        FutureBuilder(
          future: featherRegistry.awaitInitialization(feather),
          builder: (context, snapshot) {
            // TODO: 2 ANIMATIONS animate when switching out of loading state,
            if (snapshot.hasError) {
              // TODO: 1 Implement proper error handling in featherRegistry and remove this
              widget.logger.log(
                Level.error,
                "Error caught in bar when awaiting feather initialization for feather ${feather.name}",
                error: snapshot.error,
                stackTrace: snapshot.stackTrace,
              );
              return SizedBox(
                height: widget.config.isVertical ? widget.config.indicatorMinSize : null,
                width: !widget.config.isVertical ? widget.config.indicatorMinSize : null,
                child: Icon(
                  Icons.error,
                  color: Theme.of(context).colorScheme.error,
                ),
              );
            }

            if (snapshot.connectionState != ConnectionState.done) {
              return Container(
                height: widget.config.isVertical ? widget.config.indicatorMinSize : widget.config.size.toDouble(),
                width: !widget.config.isVertical ? widget.config.indicatorMinSize : widget.config.size.toDouble(),
                padding: EdgeInsets.all(0.25 * min(widget.config.indicatorMinSize, widget.config.size)),
                alignment: Alignment.center,
                child: AspectRatio(aspectRatio: 1, child: CircularProgressIndicator()),
              );
            }

            return ValueListenableBuilder(
              valueListenable: feather.components,
              builder: (context, components, child) {
                if (components.isEmpty) SizedBox.shrink();
                final result = <Widget>[];
                // TODO: 3 maybe add some visual indication that widgets belong to the same feather
                feathersCount[feather.name] ??= 0;
                final featherIndex = feathersCount[feather.name]!;
                final featherName = "${feather.name}$featherIndex";
                feathersCount[featherName] = featherIndex + 1;
                featherGlobalKeys[featherName] ??= [GlobalKey()];
                final featherKeys = featherGlobalKeys[featherName]!;
                while (featherKeys.length <= components.length) {
                  featherKeys.add(GlobalKey());
                }
                // TODO: 3 PERFORMANCE remove unused keys from featherKeys ???
                // TODO: 3 ERROR HANDLING bar should throw an error if it is assigned a feather
                // that doesn't support indicators (probably do this on handling config)
                for (int i = 0; i < components.length; i++) {
                  final component = components[i];
                  if (component.buildIndicators == null) continue;
                  final key = featherKeys[i];

                  var componentWidget = buildPopover(
                    context: context,
                    component: component,
                    barShape: barShape,
                    builder: (context, popover) {
                      final indicators = component.buildIndicators!(context, popover);
                      for (int i = 0; i < indicators.length; i++) {
                        indicators[i] = ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: !widget.config.isVertical ? widget.config.indicatorMinSize : 0,
                            minHeight: widget.config.isVertical ? widget.config.indicatorMinSize : 0,
                          ),
                          child: indicators[i],
                        );
                      }
                      if (widget.config.isVertical) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: indicators,
                        );
                      } else {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: indicators,
                        );
                      }
                    },
                  );

                  // TODO: 2 listen to component.enabled to have some kind of different decoration?

                  // TODO: 2 PERFORMANCE maybe pass a builder instead if a Widget to _buildVisibility
                  // so children aren't build unnecessarily for hidden feathers
                  componentWidget = buildVisibility(context, component, componentWidget);

                  result.add(KeyedSubtree(key: key, child: componentWidget));
                }
                return buildLayoutWidget(context, result);
              },
            );
          },
        ),
      );
    }
    return result;
  }

  Motion get motion => mainConfig.motions.expressive.spatial.normal;

  Widget buildPopover({
    required BuildContext context,
    required FeatherComponent component,
    required PopoverBuilder builder,
    required ShapeBorder barShape,
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
    return ValueListenableBuilder(
      valueListenable: component.isPopoverEnabled,
      builder: (context, isPopoverEnabled, _) {
        return ValueListenableBuilder(
          valueListenable: component.isTooltipEnabled,
          builder: (context, isTooltipEnabled, _) {
            final popoverShape = DockedRoundedCornersBorder(
              dockedSide: widget.config.side,
              isVertical: widget.config.isVertical,
              // TODO: 3 radius should probably vary with popover size, so there is more flare and animations
              radiusInCross: widget.config.radiusInCross,
              radiusInMain: widget.config.radiusInMain,
              radiusOutCross: widget.config.radiusOutCross,
              radiusOutMain: widget.config.radiusOutMain,
            );
            final tooltipShape = RoundedRectangleBorder(
              borderRadius: widget.config.isVertical
                  ? BorderRadius.all(Radius.elliptical(widget.config.radiusInCross, widget.config.radiusInMain))
                  : BorderRadius.all(Radius.elliptical(widget.config.radiusInMain, widget.config.radiusInCross)),
            );
            final buttonShape = RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.elliptical(mainConfig.buttonRadiusX, mainConfig.buttonRadiusY),
              ),
            );
            return WingedPopover(
              builder: (context, controller, _) => builder(context, controller),
              extraClientClippers: [(barShape, barPositioningController.positioningNotifier)],
              popoverParams: component.buildPopover == null
                  ? null
                  : PopoverParams(
                      enabled: isPopoverEnabled,
                      containerId: "BarPopover",
                      motion: motion,
                      // TODO: 3 briefly document how zIndex is used and what the default values are for Bar and other core widgets
                      zIndex: -10,
                      popupAlignment: popoverAlignment,
                      anchorAlignment: popoverAlignment,
                      overflowAlignment: overflowAlignment,
                      stickToHost: true,
                      screenPadding: EdgeInsets.only(
                        left: widget.config.isVertical ? 0 : widget.config.marginLeft + widget.config.radiusInMain,
                        right: widget.config.isVertical ? 0 : widget.config.marginRight + widget.config.radiusInMain,
                        top: !widget.config.isVertical ? 0 : widget.config.marginTop + widget.config.radiusInMain,
                        bottom: !widget.config.isVertical ? 0 : widget.config.marginBottom + widget.config.radiusInMain,
                      ),
                      builder: (context, controller, _) {
                        return Padding(
                          padding: popoverShape.dimensions,
                          child: ValueListenableBuilder(
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
                          ),
                        );
                      },
                      containerBuilder: (context, controller, child) {
                        return buildPopoverContainer(context, child, popoverShape, isTooltip: false);
                      },
                      closedContainerBuilder: (context, controller, child) {
                        return buildPopoverContainer(context, child, buttonShape, isTooltip: false);
                      },
                    ),
              tooltipParams: component.buildTooltip == null
                  ? null
                  : PopoverParams(
                      enabled: isTooltipEnabled,
                      containerId: "BarTooltip",
                      motion: motion,
                      // TODO: 3 briefly document how zIndex is used and what the default values are for Bar and other core widgets
                      zIndex: -5,
                      popupAlignment: popoverAlignment,
                      anchorAlignment: popoverAlignment,
                      overflowAlignment: overflowAlignment,
                      extraPadding: EdgeInsets.only(
                        top: widget.config.side == ScreenEdge.top ? widget.config.size / 2 : 0,
                        bottom: widget.config.side == ScreenEdge.bottom ? widget.config.size / 2 : 0,
                        left: widget.config.side == ScreenEdge.left ? widget.config.size / 2 : 0,
                        right: widget.config.side == ScreenEdge.right ? widget.config.size / 2 : 0,
                      ),
                      builder: (context, controller, _) {
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
                      containerBuilder: (context, controller, child) {
                        return MotionOpacity(
                          motion: motion,
                          opacity: 1,
                          child: buildPopoverContainer(context, child, tooltipShape, isTooltip: true),
                        );
                      },
                      closedContainerBuilder: (context, controller, child) {
                        return MotionOpacity(
                          motion: motion,
                          opacity: 0,
                          child: buildPopoverContainer(context, child, buttonShape, isTooltip: true),
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
    ShapeBorder shape, {
    required isTooltip,
  }) {
    return WingedContainer(
      motion: motion,
      elevation: 3.5,
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

  /// hides widget if component.isIndicatorsVisible is false
  Widget buildVisibility(
    BuildContext context,
    FeatherComponent component,
    Widget child,
  ) {
    return ValueListenableBuilder(
      valueListenable: component.isIndicatorsVisible,
      child: child,
      builder: (context, isVisible, child) {
        if (!isVisible) return SizedBox.shrink();
        // TODO: 2 maybe add animation to featherComponent visibility change (size and opacity)
        return child!;
      },
    );
  }
}

typedef PopoverBuilder = Widget Function(BuildContext context, WingedPopoverController? controller);
