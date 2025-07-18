import 'package:dartx/dartx_io.dart';
import 'package:fl_linux_window_manager/models/screen_edge.dart';
import 'package:fl_linux_window_manager/widgets/input_region.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:waywing/widgets/docked_rounded_corners_clipper.dart';
import 'package:waywing/core/feather.dart';
import 'package:waywing/core/config.dart';
import 'package:waywing/widgets/winged_popover.dart';

class Bar extends StatelessWidget {
  const Bar({super.key});

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
    final barCrossSize = config.barWidth.toDouble();
    final outerRoundedEdgeMainSize = barCrossSize * config.barRadiusOutPercMain;
    double? width, height, top, bottom, left, right;
    Alignment barAlignment, startAlignment, endAlignment;
    if (config.isBarVertical) {
      startAlignment = Alignment.topCenter;
      endAlignment = Alignment.bottomCenter;
      width = barCrossSize;
      top = config.barMarginTop / devicePixelRatio - outerRoundedEdgeMainSize;
      bottom = config.barMarginBottom / devicePixelRatio - outerRoundedEdgeMainSize;
      // don't allow setting an anchor to the opossite of dockSide, doing this would break the Stack widget
      if (config.barSide == ScreenEdge.left) {
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
      left = config.barMarginLeft / devicePixelRatio - outerRoundedEdgeMainSize;
      right = config.barMarginRight / devicePixelRatio - outerRoundedEdgeMainSize;
      // don't allow setting an anchor to the opossite of dockSide, doing this would break the Stack widget
      if (config.barSide == ScreenEdge.top) {
        barAlignment = Alignment.topCenter;
        top = 0; // config.barMarginTop;
      } else {
        barAlignment = Alignment.bottomCenter;
        bottom = 0; // config.barMarginBottom;
      }
    }

    return Positioned.fill(
      child: AnimatedAlign(
        duration: config.animationDuration,
        curve: config.animationCurve,
        alignment: barAlignment,
        child: AnimatedContainer(
          duration: config.animationDuration,
          curve: config.animationCurve,
          width: width ?? monitorSize.width,
          height: height ?? monitorSize.height,
          padding: EdgeInsets.only(
            top: top?.coerceAtLeast(0) ?? 0,
            bottom: bottom?.coerceAtLeast(0) ?? 0,
            left: left?.coerceAtLeast(0) ?? 0,
            right: right?.coerceAtLeast(0) ?? 0,
          ),
          child: ClipPath(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            clipper: DockedRoundedCornersClipperPerc(
              dockedSide: config.barSide,
              radiusInPercCross: config.barRadiusInPercCross,
              radiusInPercMain: config.barRadiusInPercMain,
              radiusOutPercCross: config.barRadiusOutPercCross,
              radiusOutPercMain: config.barRadiusOutPercMain,
            ),
            child: InputRegion(
              child: Material(
                color: Theme.of(context).canvasColor,
                child: Stack(
                  clipBehavior: Clip.none,
                  fit: StackFit.expand,
                  children: [
                    Align(
                      alignment: endAlignment,
                      child: buildLayoutWidget(
                        context,
                        buildFeatherWidgets(context, config.barEndFeathers),
                      ),
                    ),

                    Align(
                      alignment: Alignment.center,
                      child: buildLayoutWidget(
                        context,
                        buildFeatherWidgets(context, config.barCenterFeathers),
                      ),
                    ),

                    Align(
                      alignment: startAlignment,
                      child: buildLayoutWidget(
                        context,
                        buildFeatherWidgets(context, config.barStartFeathers),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLayoutWidget(BuildContext context, List<Widget> children) {
    final outerRoundedEdgeMainSize = config.barWidth * config.barRadiusOutPercMain;
    final mainAxisPadding = outerRoundedEdgeMainSize + config.barItemSize * 0.2;
    // TODO: 2 implement a proper layout that handles gracefully when widgets overflow
    if (config.isBarVertical) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: mainAxisPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: mainAxisPadding),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      );
    }
  }

  List<Widget> buildFeatherWidgets(BuildContext context, List<Feather> feathers) {
    final result = <Widget>[];
    for (final feather in feathers) {
      // TODO: 3 maybe add some visual indication that widgets belong to the same feather
      for (final component in feather.components) {
        if (component.buildIndicators == null) continue;
        // TODO: 1 add tooltip
        var widget = _buildPopover(context, component, (context, popover) {
          final indicators = component.buildIndicators!(context, popover, null);
          if (config.isBarVertical) {
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
        });
        // TODO: 2 listen to component.enabled to have some kind of different decoration?
        widget = _buildVisibility(context, component, widget);
        result.add(widget);
      }
    }
    return result;
  }

  Widget _buildPopover(
    BuildContext context,
    FeatherComponent component,
    PopoverBuilder builder,
  ) {
    if (component.buildPopover == null) {
      return builder(context, null);
    }
    final barRadiusIn = config.barRadiusInPercMain * config.barWidth;
    return ValueListenableBuilder(
      valueListenable: component.isPopoverEnabled,
      builder: (context, isEnabled, child) {
        return WingedPopover(
          enabled: isEnabled,
          containerId: 'BarPopover',
          // TODO: 1 set this to BoxConstraints.loose once width changes are properly handled (maybe let the Feather decide, default loose)
          popoverConstraints: BoxConstraints.tight(Size(512, 512)),
          screenPadding: EdgeInsets.only(
            left: config.isBarVertical ? 0 : config.barMarginLeft + barRadiusIn,
            right: config.isBarVertical ? 0 : config.barMarginRight + barRadiusIn,
            top: !config.isBarVertical ? 0 : config.barMarginTop + barRadiusIn,
            bottom: !config.isBarVertical ? 0 : config.barMarginBottom + barRadiusIn,
          ),
          builder: (context, popover, _) => builder(context, popover),
          popoverBuilder: (context) {
            return ClipPath(
              clipper: DockedRoundedCornersClipper(
                dockedSide: config.barSide,
                isVertical: config.isBarVertical,
                radiusInCross: config.barRadiusInPercCross * config.barWidth,
                radiusInMain: config.barRadiusInPercMain * config.barWidth,
                radiusOutCross: config.barRadiusOutPercCross * config.barWidth,
                radiusOutMain: config.barRadiusOutPercMain * config.barWidth,
              ),
              child: Material(
                color: Colors.red,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: !config.isBarVertical ? config.barRadiusOutPercMain * config.barWidth : 0,
                    vertical: config.isBarVertical ? config.barRadiusOutPercMain * config.barWidth : 0,
                  ),
                  child: InputRegion(child: component.buildPopover!(context)),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// hides widget if component.isIndicatorsVisible is false
  Widget _buildVisibility(
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
