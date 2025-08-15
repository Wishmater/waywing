// ignore_for_file: deprecated_member_use

import "package:flutter/material.dart";

class SimpleShadowPainter extends CustomPainter {
  static const int up = 1;
  static const int down = 2;
  static const int left = 3;
  static const int right = 4;

  final int direction;
  final double shadowOpacity;
  final double spreadPercentage;
  final Color color;

  const SimpleShadowPainter({
    this.color = Colors.black,
    this.shadowOpacity = 1,
    this.direction = down,
    this.spreadPercentage = 1,
  });

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

  @override
  void paint(Canvas canvas, Size size) {
    //    canvas.drawPath(
    //      Path()
    //        ..addRect(Rect.fromPoints(Offset(-15, -15), Offset(size.width+15, size.height+15)))
    //        ..addOval(Rect.fromPoints(Offset(0, 0), Offset(size.width, size.height)))
    //        ..fillType = PathFillType.evenOdd,
    //      Paint()
    //        ..color = color.withOpacity(shadowOpacity)
    //        ..maskFilter = MaskFilter.blur(BlurStyle.normal, convertRadiusToSigma(3)),
    //    );

    canvas.clipRect(
      Rect.fromPoints(
        Offset(
          direction == left ? -size.width * spreadPercentage : 0,
          direction == up ? -size.height * spreadPercentage : 0,
        ),
        Offset(
          direction == right ? size.width * (1 + spreadPercentage) : size.width,
          direction == down ? size.height * (1 + spreadPercentage) : size.height,
        ),
      ),
    );
    double spread = direction == down || direction == up
        ? size.height * spreadPercentage
        : size.width * spreadPercentage;
    canvas.drawPath(
      Path()
        ..addRect(
          Rect.fromPoints(
            Offset(
              direction == left ? 0 : -spread,
              direction == up ? 0 : -spread,
            ),
            Offset(
              direction == right ? size.width : size.width + spread,
              direction == down ? size.height : size.height + spread,
            ),
          ),
        )
        ..fillType = PathFillType.evenOdd,
      Paint()
        ..color = color.withOpacity(shadowOpacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, convertRadiusToSigma(spread)),
    );

    //    canvas.drawShadow(
    //      Path()
    //        ..addRect(Rect.fromPoints(Offset(0, 0), Offset(size.width, size.height)))
    ////        ..addOval(Rect.fromPoints(Offset(0, 0), Offset(size.width, size.height)))
    //        ..fillType = PathFillType.evenOdd,
    //      color.withOpacity(shadowOpacity),
    //      elevation,
    //      true,
    //    );
  }

  static double convertRadiusToSigma(double radius) {
    return radius * 0.57735 + 0.5;
  }
}
