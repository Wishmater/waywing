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
    if (config.barSide == ScreenEdge.left || config.barSide == ScreenEdge.right) {
      // vertical bar
      width = barCrossSize;
      top = config.barMarginTop - outerRoundedEdgeMainSize;
      bottom = config.barMarginBottom - outerRoundedEdgeMainSize;
      // don't allow setting an anchor to the opossite of dockSide, doing this would break the Stack widget
      if (config.barSide == ScreenEdge.left) {
        left = 0; // config.barMarginLeft;
      } else {
        right = 0; // config.barMarginRight;
      }
    } else {
      // horizontal bar
      height = barCrossSize;
      left = config.barMarginLeft - outerRoundedEdgeMainSize;
      right = config.barMarginRight - outerRoundedEdgeMainSize;
      // don't allow setting an anchor to the opossite of dockSide, doing this would break the Stack widget
      if (config.barSide == ScreenEdge.top) {
        top = 0; // config.barMarginTop;
      } else {
        bottom = 0; // config.barMarginBottom;
      }
    }

    return AnimatedPositioned(
      duration: config.animationDuration,
      width: width,
      height: height,
      top: top,
      bottom: bottom,
      left: left,
      right: right,
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
    );
  }
}
