import 'package:fl_linux_window_manager/widgets/input_region.dart';
import 'package:flutter/material.dart';
import 'package:waywing/util/config.dart';

class Bar extends StatelessWidget {
  const Bar({super.key});

  @override
  Widget build(BuildContext context) {
    double devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    double barLogicalPixels = config.barWidth / devicePixelRatio;
    return AnimatedPositioned(
      duration: config.animationDuration,
      top: config.barMarginTop,
      bottom: config.barMarginBottom,
      left: config.barMarginLeft,
      right: config.barMarginRight,
      width: barLogicalPixels,
      child: ClipPath(
        clipper: BarClipper(
          radiusInPercCross: config.barRadiusInPercCross,
          radiusInPercMain: config.barRadiusInPercMain,
          radiusOutPercCross: config.barRadiusInPercCross,
          radiusOutPercMain: config.barRadiusInPercCross,
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        // borderRadius: BorderRadius.horizontal(
        //   // in DIP # TODO 2 get from user config
        //   left: Radius.elliptical(32, 24),
        // ),
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

class BarClipper extends CustomClipper<Path> {
  // in percentage # TODO 2 let user configure these
  final double radiusInPercCross;
  final double radiusInPercMain;
  final double radiusOutPercCross;
  final double radiusOutPercMain;

  BarClipper({
    required this.radiusInPercCross,
    required this.radiusInPercMain,
    required this.radiusOutPercCross,
    required this.radiusOutPercMain,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;
    final double radiusInX, radiusInY, radiusOutX, radiusOutY;
    if (width < height) {
      radiusOutX = width * radiusOutPercCross;
      radiusOutY = width * radiusOutPercMain;
      radiusInX = width * radiusInPercCross;
      radiusInY = width * radiusInPercMain + radiusOutY;
    } else {
      radiusOutX = height * radiusOutPercMain;
      radiusOutY = height * radiusOutPercCross;
      radiusInX = height * radiusInPercMain + radiusOutX;
      radiusInY = height * radiusInPercCross;
    }

    // Top-left corner
    path.moveTo(0, radiusInY);
    path.quadraticBezierTo(0, radiusOutY, radiusInX, radiusOutY);

    // Top-right corner
    path.lineTo(width - radiusOutX, radiusOutY);
    path.quadraticBezierTo(width, radiusOutY, width, 0);

    // Bottom-right corner
    path.lineTo(width, height);
    path.quadraticBezierTo(width, height - radiusOutY, width - radiusOutX, height - radiusOutY);

    // Bottom-left corner
    path.lineTo(radiusInX, height - radiusOutY);
    path.quadraticBezierTo(0, height - radiusOutY, 0, height - radiusInY);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant BarClipper oldClipper) {
    return radiusInPercCross != oldClipper.radiusInPercCross ||
        radiusInPercMain != oldClipper.radiusInPercMain ||
        radiusOutPercCross != oldClipper.radiusOutPercCross ||
        radiusInPercMain != oldClipper.radiusInPercMain;
  }
}
