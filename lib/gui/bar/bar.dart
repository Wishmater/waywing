import 'package:fl_linux_window_manager/models/screen_edge.dart';
import 'package:fl_linux_window_manager/widgets/input_region.dart';
import 'package:flutter/material.dart';
import 'package:waywing/gui/widgets/docked_rounded_corners_clipper.dart';
import 'package:waywing/util/config.dart';

class Bar extends StatelessWidget {
  const Bar({super.key});

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final barCrossSize = config.barWidth / devicePixelRatio;
    final outerRoundedEdgeMainSize = barCrossSize * config.barRadiusOutPercMain;
    double? width, height, top, bottom, left, right;
    Alignment alignment;
    if (config.barSide == ScreenEdge.left || config.barSide == ScreenEdge.right) {
      // vertical bar
      width = barCrossSize;
      top = config.barMarginTop - outerRoundedEdgeMainSize;
      bottom = config.barMarginBottom - outerRoundedEdgeMainSize;
      // don't allow setting an anchor to the opossite of dockSide, doing this would break the Stack widget
      if (config.barSide == ScreenEdge.left) {
        alignment = Alignment.centerLeft;
        left = 0; // config.barMarginLeft;
      } else {
        alignment = Alignment.centerRight;
        right = 0; // config.barMarginRight;
      }
    } else {
      // horizontal bar
      height = barCrossSize;
      left = config.barMarginLeft - outerRoundedEdgeMainSize;
      right = config.barMarginRight - outerRoundedEdgeMainSize;
      // don't allow setting an anchor to the opossite of dockSide, doing this would break the Stack widget
      if (config.barSide == ScreenEdge.top) {
        alignment = Alignment.topCenter;
        top = 0; // config.barMarginTop;
      } else {
        alignment = Alignment.bottomCenter;
        bottom = 0; // config.barMarginBottom;
      }
    }

    return Positioned.fill(
      child: AnimatedAlign(
        duration: config.animationDuration,
        curve: config.animationCurve,
        alignment: alignment,
        child: AnimatedContainer(
          duration: config.animationDuration,
          curve: config.animationCurve,
          width: width ?? double.infinity,
          height: height ?? double.infinity,
          padding: EdgeInsets.only(
            top: top ?? 0,
            bottom: bottom ?? 0,
            left: left ?? 0,
            right: right ?? 0,
          ),
          child: ClipPath(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            clipper: DockedRoundedCornersClipper(
              dockedSide: config.barSide,
              radiusInPercCross: config.barRadiusInPercCross,
              radiusInPercMain: config.barRadiusInPercMain,
              radiusOutPercCross: config.barRadiusOutPercCross,
              radiusOutPercMain: config.barRadiusOutPercMain,
            ),
            child: InputRegion(
              child: Material(
                color: Theme.of(context).canvasColor,
                child: InkWell(
                  onTap: () {},
                  child: Center(child: Text('WayWing')),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
