import 'package:fl_linux_window_manager/models/screen_edge.dart';
import 'package:flutter/widgets.dart';

class DockedRoundedCornersClipper extends CustomClipper<Path> {
  final ScreenEdge dockedSide;
  final double radiusInPercCross; // in percentage of cross-size
  final double radiusInPercMain; // in percentage of cross-size
  final double radiusOutPercCross; // in percentage of cross-size
  final double radiusOutPercMain; // in percentage of cross-size

  DockedRoundedCornersClipper({
    required this.dockedSide,
    required this.radiusInPercCross,
    required this.radiusInPercMain,
    this.radiusOutPercCross = 0,
    this.radiusOutPercMain = 0,
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
  bool shouldReclip(covariant DockedRoundedCornersClipper oldClipper) {
    return dockedSide != oldClipper.dockedSide ||
        radiusInPercCross != oldClipper.radiusInPercCross ||
        radiusInPercMain != oldClipper.radiusInPercMain ||
        radiusOutPercCross != oldClipper.radiusOutPercCross ||
        radiusOutPercMain != oldClipper.radiusOutPercMain;
  }
}
