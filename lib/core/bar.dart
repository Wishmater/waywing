import "package:dartx/dartx_io.dart";
import "package:fl_linux_window_manager/models/screen_edge.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:tronco/tronco.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/util/logger.dart";
import "package:waywing/util/state_positioning.dart";
import "package:waywing/widgets/docked_rounded_corners_shape.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/core/config.dart";
import "package:waywing/widgets/winged_container.dart";
import "package:waywing/widgets/winged_popover.dart";

// TODO: 2 this logger should come from the wingRegistry once Wings are implemented
final _logger = mainLogger.clone();

class Bar extends StatefulWidget {
  const Bar({super.key});

  @override
  State<Bar> createState() => _BarState();
}

class _BarState extends State<Bar> {
  // adding global keys to feathers ensures their state
  // won't be lost when reloading config, including popover and tooltip state
  Map<String, List<GlobalKey>> featherGlobalKeys = {};
  final PositioningNotifierController barPositioningController = PositioningNotifierController();

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
    final barCrossSize = mainConfig.barSize.toDouble();
    final outerRoundedEdgeMainSize = mainConfig.barRadiusOutMain;
    double? width, height, top, bottom, left, right;
    Alignment barAlignment, startAlignment, endAlignment;
    if (mainConfig.isBarVertical) {
      startAlignment = Alignment.topCenter;
      endAlignment = Alignment.bottomCenter;
      width = barCrossSize;
      top = mainConfig.barMarginTop / devicePixelRatio - outerRoundedEdgeMainSize;
      bottom = mainConfig.barMarginBottom / devicePixelRatio - outerRoundedEdgeMainSize;
      // don't allow setting an anchor to the opossite of dockSide, doing this would break the Stack widget
      if (mainConfig.barSide == ScreenEdge.left) {
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
      left = mainConfig.barMarginLeft / devicePixelRatio - outerRoundedEdgeMainSize;
      right = mainConfig.barMarginRight / devicePixelRatio - outerRoundedEdgeMainSize;
      // don't allow setting an anchor to the opossite of dockSide, doing this would break the Stack widget
      if (mainConfig.barSide == ScreenEdge.top) {
        barAlignment = Alignment.topCenter;
        top = 0; // config.barMarginTop;
      } else {
        barAlignment = Alignment.bottomCenter;
        bottom = 0; // config.barMarginBottom;
      }
    }

    final shape = DockedRoundedCornersBorder(
      dockedSide: mainConfig.barSide,
      radiusInCross: mainConfig.barRadiusInCross,
      radiusInMain: mainConfig.barRadiusInMain,
      radiusOutCross: mainConfig.barRadiusOutCross,
      radiusOutMain: mainConfig.barRadiusOutMain,
      isVertical: mainConfig.isBarVertical,
    );
    Map<String, int> feathersCount = {};
    return Positioned.fill(
      child: AnimatedAlign(
        duration: mainConfig.animationDuration,
        curve: mainConfig.animationCurve,
        alignment: barAlignment,
        child: AnimatedContainer(
          duration: mainConfig.animationDuration,
          curve: mainConfig.animationCurve,
          width: width ?? monitorSize.width,
          height: height ?? monitorSize.height,
          padding: EdgeInsets.only(
            top: top?.coerceAtLeast(0) ?? 0,
            bottom: bottom?.coerceAtLeast(0) ?? 0,
            left: left?.coerceAtLeast(0) ?? 0,
            right: right?.coerceAtLeast(0) ?? 0,
          ),
          child: PositioningNotifierMonitor(
            controller: barPositioningController,
            child: WingedContainer(
              // animationDuration: config.animationDuration * 1.5,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              elevation: 6, // TODO: 2 expose bar elevation theme option to user
              shape: shape,
              // TODO: 2 implement a proper layout that handles gracefully when widgets overflow
              // this should also solve the issue of widgets being disposed when switching vertical
              // to horizontal bar (or viceversa) because we switched Row / Column
              child: Padding(
                padding: shape.dimensions,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    buttonTheme: Theme.of(context).buttonTheme.copyWith(
                      padding: EdgeInsets.symmetric(
                        horizontal: !mainConfig.isBarVertical ? mainConfig.barIndicatorPadding : 0,
                        vertical: mainConfig.isBarVertical ? mainConfig.barIndicatorPadding : 0,
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
                          right: !mainConfig.isBarVertical ? mainConfig.barSize * 0.2 : 0,
                          bottom: mainConfig.isBarVertical ? mainConfig.barSize * 0.2 : 0,
                        ),
                        child: buildLayoutWidget(
                          context,
                          buildFeatherWidgets(
                            context: context,
                            feathers: mainConfig.barEndFeathers,
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
                            feathers: mainConfig.barCenterFeathers,
                            feathersCount: feathersCount,
                            barShape: shape,
                          ),
                        ),
                      ),

                      Container(
                        alignment: startAlignment,
                        padding: EdgeInsets.only(
                          left: !mainConfig.isBarVertical ? mainConfig.barSize * 0.2 : 0,
                          top: mainConfig.isBarVertical ? mainConfig.barSize * 0.2 : 0,
                        ),
                        child: buildLayoutWidget(
                          context,
                          buildFeatherWidgets(
                            context: context,
                            feathers: mainConfig.barStartFeathers,
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
    );
  }

  Widget buildLayoutWidget(BuildContext context, List<Widget> children) {
    if (mainConfig.isBarVertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
            // TODO: 2 animation when switching out of loading state,
            if (snapshot.hasError) {
              // TODO: 2 should we do this log here??? this means it will be repeated every time bar is rebuilt
              _logger.log(
                Level.error,
                "Error caught in bar when awaiting feather initialization for feather ${feather.name}",
                error: snapshot.error,
                stackTrace: snapshot.stackTrace,
              );
              return SizedBox(
                height: mainConfig.isBarVertical ? mainConfig.barIndicatorMinSize : null,
                width: !mainConfig.isBarVertical ? mainConfig.barIndicatorMinSize : null,
                child: Icon(
                  Icons.error,
                  color: Theme.of(context).colorScheme.error,
                ),
              );
            }

            if (snapshot.connectionState != ConnectionState.done) {
              return Container(
                height: mainConfig.isBarVertical ? mainConfig.barIndicatorMinSize : null,
                width: !mainConfig.isBarVertical ? mainConfig.barIndicatorMinSize : null,
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
                for (int i = 0; i < components.length; i++) {
                  final component = components[i];
                  if (component.buildIndicators == null) continue;
                  final key = featherKeys[i];

                  var widget = buildPopover(
                    context: context,
                    component: component,
                    barShape: barShape,
                    builder: (context, popover) {
                      final indicators = component.buildIndicators!(context, popover, null);
                      for (int i = 0; i < indicators.length; i++) {
                        indicators[i] = ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: !mainConfig.isBarVertical ? mainConfig.barIndicatorMinSize : 0,
                            minHeight: mainConfig.isBarVertical ? mainConfig.barIndicatorMinSize : 0,
                          ),
                          child: indicators[i],
                        );
                      }
                      if (mainConfig.isBarVertical) {
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
                  widget = buildVisibility(context, component, widget);

                  result.add(KeyedSubtree(key: key, child: widget));
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

  Widget buildPopover({
    required BuildContext context,
    required FeatherComponent component,
    required PopoverBuilder builder,
    required ShapeBorder barShape,
  }) {
    if (component.buildPopover == null && component.buildTooltip == null) {
      return builder(context, null);
    }
    final popoverAlignment = switch (mainConfig.barSide) {
      ScreenEdge.top => Alignment.bottomCenter,
      ScreenEdge.right => Alignment.centerLeft,
      ScreenEdge.bottom => Alignment.topCenter,
      ScreenEdge.left => Alignment.centerRight,
    };
    final overflowAlignment = switch (mainConfig.barSide) {
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
              dockedSide: mainConfig.barSide,
              isVertical: mainConfig.isBarVertical,
              // TODO: 3 radius should probably vary with popover size, so there is more flare and animations
              radiusInCross: mainConfig.barRadiusInCross,
              radiusInMain: mainConfig.barRadiusInMain,
              radiusOutCross: mainConfig.barRadiusOutCross,
              radiusOutMain: mainConfig.barRadiusOutMain,
            );
            final tooltipShape = RoundedRectangleBorder(
              borderRadius: mainConfig.isBarVertical
                  ? BorderRadius.all(Radius.elliptical(mainConfig.barRadiusInCross, mainConfig.barRadiusInMain))
                  : BorderRadius.all(Radius.elliptical(mainConfig.barRadiusInMain, mainConfig.barRadiusInCross)),
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
                      // TODO: 3 briefly document how zIndex is used and what the default values are for Bar and other core widgets
                      zIndex: -10,
                      popupAlignment: popoverAlignment,
                      anchorAlignment: popoverAlignment,
                      overflowAlignment: overflowAlignment,
                      screenPadding: EdgeInsets.only(
                        left: mainConfig.isBarVertical ? 0 : mainConfig.barMarginLeft + mainConfig.barRadiusInMain,
                        right: mainConfig.isBarVertical ? 0 : mainConfig.barMarginRight + mainConfig.barRadiusInMain,
                        top: !mainConfig.isBarVertical ? 0 : mainConfig.barMarginTop + mainConfig.barRadiusInMain,
                        bottom: !mainConfig.isBarVertical ? 0 : mainConfig.barMarginBottom + mainConfig.barRadiusInMain,
                      ),
                      builder: (context, controller) {
                        return Padding(
                          padding: popoverShape.dimensions,
                          child: ValueListenableBuilder(
                            valueListenable: controller.hostState.sizeNotifier,
                            child: component.buildPopover!(context),
                            builder: (context, hostSize, child) {
                              return ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: !mainConfig.isBarVertical ? hostSize?.height ?? 0 : 0,
                                  minHeight: mainConfig.isBarVertical ? hostSize?.width ?? 0 : 0,
                                ),
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      containerBuilder: (context, controller, child) {
                        return buildPopoverContainer(context, child, popoverShape);
                      },
                      closedContainerBuilder: (context, controller, child) {
                        return buildPopoverContainer(context, child, buttonShape);
                      },
                    ),
              tooltipParams: component.buildTooltip == null
                  ? null
                  : PopoverParams(
                      enabled: isTooltipEnabled,
                      containerId: "BarTooltip",
                      // TODO: 3 briefly document how zIndex is used and what the default values are for Bar and other core widgets
                      zIndex: -5,
                      popupAlignment: popoverAlignment,
                      anchorAlignment: popoverAlignment,
                      overflowAlignment: overflowAlignment,
                      extraPadding: EdgeInsets.only(
                        top: mainConfig.barSide == ScreenEdge.top ? mainConfig.barSize / 2 : 0,
                        bottom: mainConfig.barSide == ScreenEdge.bottom ? mainConfig.barSize / 2 : 0,
                        left: mainConfig.barSide == ScreenEdge.left ? mainConfig.barSize / 2 : 0,
                        right: mainConfig.barSide == ScreenEdge.right ? mainConfig.barSize / 2 : 0,
                      ),
                      builder: (context, controller) {
                        return ValueListenableBuilder(
                          valueListenable: controller.hostState.sizeNotifier,
                          child: component.buildTooltip!(context),
                          builder: (context, hostSize, child) {
                            return ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: !mainConfig.isBarVertical ? hostSize?.height ?? 0 : 0,
                                minHeight: mainConfig.isBarVertical ? hostSize?.width ?? 0 : 0,
                              ),
                              child: child,
                            );
                          },
                        );
                      },
                      containerBuilder: (context, controller, child) {
                        return AnimatedOpacity(
                          opacity: 1,
                          duration: mainConfig.animationDuration,
                          curve: mainConfig.animationCurve,
                          child: buildPopoverContainer(context, child, tooltipShape),
                        );
                      },
                      closedContainerBuilder: (context, controller, child) {
                        return AnimatedOpacity(
                          opacity: 0,
                          duration: mainConfig.animationDuration,
                          curve: mainConfig.animationCurve,
                          child: buildPopoverContainer(context, child, buttonShape),
                        );
                      },
                    ),
            );
          },
        );
      },
    );
  }

  Widget buildPopoverContainer(BuildContext context, Widget child, ShapeBorder shape) {
    return WingedContainer(
      // animationDuration: config.animationDuration * 1.5,
      elevation: 4, // TODO: 2 expose popover elevation theme option to user
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: shape,
      child: child,
    );
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
