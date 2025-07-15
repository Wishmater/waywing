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

    switch (dockedSide) {
      case ScreenEdge.right:
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

      case ScreenEdge.left:
        // Top-left corner
        path.moveTo(0, 0);
        path.quadraticBezierTo(0, radiusOutY, radiusOutX, radiusOutY);
        // Top-right corner
        path.lineTo(width - radiusInX, radiusOutY);
        path.quadraticBezierTo(width, radiusOutY, width, radiusInY);
        // Bottom-right corner
        path.lineTo(width, height - radiusInY);
        path.quadraticBezierTo(width, height - radiusOutY, width - radiusInX, height - radiusOutY);
        // Bottom-left corner
        path.lineTo(radiusOutX, height - radiusOutY);
        path.quadraticBezierTo(0, height - radiusOutY, 0, height);

      case ScreenEdge.top:
        // Top-left corner
        path.moveTo(radiusOutX, radiusOutY);
        path.quadraticBezierTo(radiusOutX, 0, 0, 0);
        // Top-right corner
        path.lineTo(width, 0);
        path.quadraticBezierTo(width - radiusOutX, 0, width - radiusOutX, radiusOutY);
        // Bottom-right corner
        path.lineTo(width - radiusOutX, height - radiusInY);
        path.quadraticBezierTo(width - radiusOutX, height, width - radiusInX, height);
        // Bottom-left corner
        path.lineTo(radiusInX, height);
        path.quadraticBezierTo(radiusOutX, height, radiusOutX, height - radiusInY);

      case ScreenEdge.bottom:
        // Top-left corner
        path.moveTo(0, height);
        path.quadraticBezierTo(radiusOutX, height, radiusOutX, height - radiusOutY);
        // Top-right corner
        path.lineTo(radiusOutX, radiusInY);
        path.quadraticBezierTo(radiusOutX, 0, radiusInX, 0);
        // Bottom-right corner
        path.lineTo(width - radiusInX, 0);
        path.quadraticBezierTo(width - radiusOutX, 0, width - radiusOutX, radiusInY);
        // Bottom-left corner
        path.lineTo(width - radiusOutX, height - radiusOutY);
        path.quadraticBezierTo(width - radiusOutX, height, width, height);
    }

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
